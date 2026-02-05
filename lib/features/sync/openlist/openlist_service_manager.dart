import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/core/network/system_proxy_helper.dart';
import 'dart:convert';

class OpenListRuntimeConfig {
  final int port;
  final String proxyMode; // 'none', 'system', 'custom'
  final String proxyHost;
  final int proxyPort;

  const OpenListRuntimeConfig({
    required this.port,
    required this.proxyMode,
    required this.proxyHost,
    required this.proxyPort,
  });
}

class OpenListServiceState {
  final bool isRunning;
  final String address;
  final int port;
  final bool isBusy;
  final String? error;

  const OpenListServiceState({
    required this.isRunning,
    required this.address,
    required this.port,
    required this.isBusy,
    this.error,
  });

  OpenListServiceState copyWith({
    bool? isRunning,
    String? address,
    int? port,
    bool? isBusy,
    String? error,
  }) {
    return OpenListServiceState(
      isRunning: isRunning ?? this.isRunning,
      address: address ?? this.address,
      port: port ?? this.port,
      isBusy: isBusy ?? this.isBusy,
      error: error,
    );
  }
}

final openListServiceControllerProvider = StateNotifierProvider<OpenListServiceController, OpenListServiceState>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  final manager = OpenListServiceManager(prefs);
  final controller = OpenListServiceController(manager);
  controller.refresh();
  return controller;
});

class OpenListServiceController extends StateNotifier<OpenListServiceState> {
  final OpenListServiceManager _manager;

  OpenListServiceController(this._manager)
      : super(const OpenListServiceState(
          isRunning: false,
          address: '127.0.0.1',
          port: 5244,
          isBusy: false,
          error: null,
        ));

  Future<void> refresh() async {
    state = state.copyWith(isBusy: true, error: null);
    try {
      final running = await _manager.isRunning();
      final port = await _manager.getHttpPort();
      final address = await _manager.getServiceAddress();
      state = state.copyWith(
        isRunning: running,
        port: port,
        address: address,
        isBusy: false,
      );
    } catch (e) {
      state = state.copyWith(isBusy: false, error: e.toString());
    }
  }

  Future<void> start() async {
    state = state.copyWith(isBusy: true, error: null);
    try {
      final ok = await _manager.start();
      if (!ok) {
        state = state.copyWith(isBusy: false, error: _manager.lastError ?? 'Start failed');
        return;
      }
      await refresh();
    } catch (e) {
      state = state.copyWith(isBusy: false, error: e.toString());
    }
  }

  Future<void> stop() async {
    state = state.copyWith(isBusy: true, error: null);
    try {
      final ok = await _manager.stop();
      if (!ok) {
        state = state.copyWith(isBusy: false, error: _manager.lastError ?? 'Stop failed');
        return;
      }
      await refresh();
    } catch (e) {
      state = state.copyWith(isBusy: false, error: e.toString());
    }
  }
}

class OpenListServiceManager {
  static const MethodChannel _channel = MethodChannel('com.jmusic.openlist/service');
  static const String _pidFileName = 'openlist.pid';
  final PreferencesService _prefs;
  Process? _process;
  StreamSubscription<List<int>>? _stdoutSub;
  StreamSubscription<List<int>>? _stderrSub;
  String? lastError;

  OpenListServiceManager(this._prefs);

  Future<Directory> _getDataDir() async {
    final appDoc = await getApplicationDocumentsDirectory();
    final dataDir = Directory(p.join(appDoc.path, 'j_music', 'openlist'));
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    return dataDir;
  }

  Future<Directory?> _getWindowsInstallDir() async {
    if (!Platform.isWindows) return null;
    final exePath = Platform.resolvedExecutable;
    return Directory(p.dirname(exePath));
  }

  Directory _getWindowsOpenListInstallDir(Directory installDir) {
    return Directory(p.join(installDir.path, 'openlist'));
  }

  Future<void> _ensureFrontendAssets(Directory installOpenListDir, Directory dataDir) async {
    final src = Directory(p.join(installOpenListDir.path, 'public', 'dist'));
    final dest = Directory(p.join(dataDir.path, 'public', 'dist'));
    if (await dest.exists() || !await src.exists()) {
      return;
    }
    await _copyDirectory(src, dest);
  }

  Future<void> _copyDirectory(Directory source, Directory dest) async {
    if (!await dest.exists()) {
      await dest.create(recursive: true);
    }
    await for (final entity in source.list(followLinks: false)) {
      final newPath = p.join(dest.path, p.basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(newPath));
      } else if (entity is File) {
        await entity.copy(newPath);
      }
    }
  }

  Future<void> _writePidFile(int pid) async {
    try {
      final dataDir = await _getDataDir();
      final pidFile = File(p.join(dataDir.path, _pidFileName));
      await pidFile.writeAsString(pid.toString());
    } catch (_) {}
  }

  Future<int?> _readPidFile() async {
    try {
      final dataDir = await _getDataDir();
      final pidFile = File(p.join(dataDir.path, _pidFileName));
      if (!await pidFile.exists()) return null;
      final text = await pidFile.readAsString();
      return int.tryParse(text.trim());
    } catch (_) {
      return null;
    }
  }

  Future<void> _deletePidFile() async {
    try {
      final dataDir = await _getDataDir();
      final pidFile = File(p.join(dataDir.path, _pidFileName));
      if (await pidFile.exists()) {
        await pidFile.delete();
      }
    } catch (_) {}
  }

  OpenListRuntimeConfig get _currentConfig => OpenListRuntimeConfig(
        port: _prefs.openListPort,
        proxyMode: _prefs.openListProxyMode,
        proxyHost: _prefs.openListProxyHost,
        proxyPort: _prefs.openListProxyPort,
      );

  Future<bool> start() async {
    lastError = null;
    if (kIsWeb) {
      lastError = 'Web not supported';
      return false;
    }
    final config = _currentConfig;
    final applied = await applyConfig(config);
    if (!applied) {
      lastError ??= 'Apply config failed';
      return false;
    }
    if (Platform.isAndroid) {
      return await _invokeBool('startService');
    }
    if (Platform.isWindows) {
      return await _startWindows();
    }
    if (Platform.isLinux || Platform.isMacOS) {
      return await _startUnix();
    }
    lastError = 'Platform not supported';
    return false;
  }

  Future<bool> stop() async {
    lastError = null;
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      return await _invokeBool('stopService');
    }
    if (Platform.isWindows) {
      return await _stopWindows();
    }
    if (Platform.isLinux || Platform.isMacOS) {
      return await _stopUnix();
    }
    return false;
  }

  Future<bool> isRunning() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      return await _invokeBool('isServiceRunning');
    }
    if (Platform.isWindows) {
      return await _isLocalProcessRunning();
    }
    if (Platform.isLinux || Platform.isMacOS) {
      return await _isLocalProcessRunning();
    }
    return false;
  }

  Future<int> getHttpPort() async {
    if (kIsWeb) return 5244;
    if (Platform.isAndroid) {
      final result = await _invokeInt('getHttpPort');
      return result ?? _prefs.openListPort;
    }
    return _prefs.openListPort;
  }

  Future<String> getServiceAddress() async {
    if (kIsWeb) return '127.0.0.1';
    if (Platform.isAndroid) {
      final result = await _invokeString('getServiceAddress');
      return (result == null || result.isEmpty) ? '127.0.0.1' : result;
    }
    return '127.0.0.1';
  }

  static String buildBaseUrl(String address, int port) => 'http://$address:$port';

  static String buildManageUrl(String address, int port) => '${buildBaseUrl(address, port)}/@manage/storages';

  static String buildDavUrl(String address, int port) => '${buildBaseUrl(address, port)}/dav';

  Future<String?> getInitialAdminPassword() async {
    if (kIsWeb) return null;
    if (Platform.isAndroid) {
      return await _invokeString('getInitialAdminPassword');
    }
    lastError = 'Platform not supported';
    return null;
  }

  Future<bool> clearInitialAdminPassword() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      return await _invokeBool('clearInitialAdminPassword');
    }
    lastError = 'Platform not supported';
    return false;
  }

  Future<String?> resetAdminPassword() async {
    if (kIsWeb) return null;
    if (Platform.isAndroid) {
      return await _invokeString('resetAdminPassword');
    }
    lastError = 'Platform not supported';
    return null;
  }
  /// 打开自启动设置页面（各厂商可能不同）
  Future<bool> openAutoStartSettings() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid) {
      return await _invokeBool('openAutoStartSettings');
    }
    return true;
  }

  Future<bool> applyConfig(OpenListRuntimeConfig config) async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      return await _invokeBool('applyConfig', {
        'port': config.port,
        'proxyMode': config.proxyMode,
        'proxyHost': config.proxyHost,
        'proxyPort': config.proxyPort,
      });
    }
    if (Platform.isWindows) {
      return await _applyWindowsConfig(config);
    }
    if (Platform.isLinux || Platform.isMacOS) {
      return await _applyUnixConfig(config);
    }
    return false;
  }

  Future<bool> _invokeBool(String method, [Map<String, dynamic>? args]) async {
    try {
      final result = await _channel.invokeMethod<bool>(method, args);
      return result ?? false;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<int?> _invokeInt(String method) async {
    try {
      return await _channel.invokeMethod<int>(method);
    } catch (e) {
      lastError = e.toString();
      return null;
    }
  }

  Future<String?> _invokeString(String method) async {
    try {
      return await _channel.invokeMethod<String>(method);
    } catch (e) {
      lastError = e.toString();
      return null;
    }
  }

  Future<bool> _startWindows() async {
    try {
      final dataDir = await _getDataDir();
      final installDir = await _getWindowsInstallDir();
      final installOpenListDir = installDir == null ? null : _getWindowsOpenListInstallDir(installDir);

      final candidates = <String>[
        if (installOpenListDir != null) p.join(installOpenListDir.path, 'openlist.exe'),
        p.join(dataDir.path, 'openlist.exe'),
      ];

      String? exePath;
      for (final candidate in candidates) {
        if (await File(candidate).exists()) {
          exePath = candidate;
          break;
        }
      }
      if (exePath == null) {
        lastError = installOpenListDir == null
            ? 'openlist.exe not found in ${dataDir.path}'
            : 'openlist.exe not found in ${installOpenListDir.path} or ${dataDir.path}';
        return false;
      }

      if (installOpenListDir != null) {
        await _ensureFrontendAssets(installOpenListDir, dataDir);
      }

      _process = await Process.start(
        exePath,
        ['server', '--data', dataDir.path],
        workingDirectory: dataDir.path,
        runInShell: false,
      );
      await _writePidFile(_process!.pid);
      _attachProcessStreams();
      _attachProcessExitHandler();
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> _startUnix() async {
    try {
      final dataDir = await _getDataDir();
      final binPath = p.join(dataDir.path, 'openlist');
      final binFile = File(binPath);
      if (!await binFile.exists()) {
        lastError = 'openlist binary not found in ${dataDir.path}';
        return false;
      }

      try {
        await Process.run('chmod', ['+x', binPath]);
      } catch (_) {}

      _process = await Process.start(
        binPath,
        ['server', '--data', dataDir.path],
        workingDirectory: dataDir.path,
        runInShell: false,
      );
      await _writePidFile(_process!.pid);
      _attachProcessStreams();
      _attachProcessExitHandler();
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> _applyWindowsConfig(OpenListRuntimeConfig config) async {
    try {
      if (_process != null) {
        lastError = 'Service is running';
        return false;
      }
      final dataDir = await _getDataDir();
      final configPath = p.join(dataDir.path, 'config.json');
      Map<String, dynamic> json = {};
      final file = File(configPath);
      if (await file.exists()) {
        try {
          final text = await file.readAsString();
          final decoded = jsonDecode(text);
          if (decoded is Map<String, dynamic>) {
            json = decoded;
          }
        } catch (_) {
          json = {};
        }
      }

      final scheme = (json['scheme'] is Map<String, dynamic>) ? (json['scheme'] as Map<String, dynamic>) : <String, dynamic>{};
      scheme['http_port'] = config.port;
      json['scheme'] = scheme;

      if (config.proxyMode == 'custom') {
        json['proxy_address'] = 'http://${config.proxyHost}:${config.proxyPort}';
      } else if (config.proxyMode == 'system') {
        final systemProxy = await _resolveSystemProxy();
        json['proxy_address'] = systemProxy ?? '';
      } else {
        json['proxy_address'] = '';
      }

      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> _applyUnixConfig(OpenListRuntimeConfig config) async {
    try {
      if (_process != null) {
        lastError = 'Service is running';
        return false;
      }
      final dataDir = await _getDataDir();
      final configPath = p.join(dataDir.path, 'config.json');
      Map<String, dynamic> json = {};
      final file = File(configPath);
      if (await file.exists()) {
        try {
          final text = await file.readAsString();
          final decoded = jsonDecode(text);
          if (decoded is Map<String, dynamic>) {
            json = decoded;
          }
        } catch (_) {
          json = {};
        }
      }

      final scheme = (json['scheme'] is Map<String, dynamic>) ? (json['scheme'] as Map<String, dynamic>) : <String, dynamic>{};
      scheme['http_port'] = config.port;
      json['scheme'] = scheme;

      if (config.proxyMode == 'custom') {
        json['proxy_address'] = 'http://${config.proxyHost}:${config.proxyPort}';
      } else if (config.proxyMode == 'system') {
        final systemProxy = await _resolveSystemProxy();
        json['proxy_address'] = systemProxy ?? '';
      } else {
        json['proxy_address'] = '';
      }

      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<String?> _resolveSystemProxy() async {
    try {
      await SystemProxyHelper.refreshProxy();
      final directive = SystemProxyHelper.proxyDirective;
      if (directive != null && directive.contains('PROXY')) {
        final proxy = directive.split(';').firstWhere((p) => p.trim().startsWith('PROXY'), orElse: () => '');
        final hostPort = proxy.replaceFirst('PROXY', '').trim();
        if (hostPort.isNotEmpty) {
          return 'http://$hostPort';
        }
      }
    } catch (_) {}
    return null;
  }

  Future<bool> _stopWindows() async {
    try {
      final process = _process;
      if (process != null) {
        await Process.run('taskkill', ['/PID', process.pid.toString(), '/T', '/F']);
        _clearProcess();
        await _deletePidFile();
        return true;
      }

      final pid = await _readPidFile();
      if (pid != null) {
        await Process.run('taskkill', ['/PID', pid.toString(), '/T', '/F']);
        await _deletePidFile();
      }
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> _stopUnix() async {
    try {
      final process = _process;
      if (process != null) {
        process.kill(ProcessSignal.sigterm);
        await process.exitCode.timeout(const Duration(seconds: 3), onTimeout: () => -1);
        if (_process != null) {
          process.kill(ProcessSignal.sigkill);
        }
        _clearProcess();
        await _deletePidFile();
        return true;
      }

      final pid = await _readPidFile();
      if (pid != null) {
        Process.killPid(pid, ProcessSignal.sigterm);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        Process.killPid(pid, ProcessSignal.sigkill);
        await _deletePidFile();
      }
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> _isLocalProcessRunning() async {
    final process = _process;
    if (process == null) {
      return await _pingService();
    }

    if (await _pingService()) {
      return true;
    }

    final exitCode = await process.exitCode.timeout(const Duration(milliseconds: 100), onTimeout: () => -1);
    if (exitCode != -1) {
      _clearProcess();
      return false;
    }

    return true;
  }

  Future<bool> _pingService() async {
    try {
      final address = await getServiceAddress();
      final url = Uri.parse(buildBaseUrl(address, _prefs.openListPort));
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      final request = await client.getUrl(url).timeout(const Duration(seconds: 2));
      final response = await request.close().timeout(const Duration(seconds: 2));
      await response.drain();
      client.close(force: true);
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  void _attachProcessStreams() {
    _stdoutSub?.cancel();
    _stderrSub?.cancel();
    _stdoutSub = _process?.stdout.listen((_) {});
    _stderrSub = _process?.stderr.listen((_) {});
  }

  void _attachProcessExitHandler() {
    final process = _process;
    if (process == null) return;
    process.exitCode.then((_) {
      _clearProcess();
      _deletePidFile();
    });
  }

  void _clearProcess() {
    _stdoutSub?.cancel();
    _stderrSub?.cancel();
    _stdoutSub = null;
    _stderrSub = null;
    _process = null;
  }
}
