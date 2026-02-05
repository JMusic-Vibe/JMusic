import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
// no external 'path' package required here

final logServiceProvider = Provider<LogService>((ref) => LogService.instance);

class LogService {
  static final LogService instance = LogService._();
  LogService._();

  static const String _logDirName = 'logs';
  static const String _logFileName = 'app.log';
  static const int _maxBytes = 5 * 1024 * 1024; // 5MB

  late Logger _logger;
  File? _logFile;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final docDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${docDir.path}/j_music/$_logDirName');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    final file = File('${logDir.path}/$_logFileName');
    if (await file.exists()) {
      final len = await file.length();
      if (len > _maxBytes) {
        final backup = File('${logDir.path}/app_${DateTime.now().millisecondsSinceEpoch}.log');
        try {
          await file.rename(backup.path);
        } catch (_) {
          // ignore rename failures
        }
      }
    }

    _logFile = File('${logDir.path}/$_logFileName');
    if (!await _logFile!.exists()) {
      await _logFile!.create(recursive: true);
    }

    _logger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        printTime: true,
      ),
      output: _FileLogOutput(_logFile!),
    );

    _initialized = true;
    i('LogService initialized.');
  }

  void d(String message) => _logger.d(message);
  void i(String message) => _logger.i(message);
  void w(String message) => _logger.w(message);
  void e(String message, [Object? error, StackTrace? stackTrace]) => _logger.e(message, error: error, stackTrace: stackTrace);

  Future<File?> getLogFile() async {
    if (!_initialized) return null;
    return _logFile;
  }

  /// Export log file for sharing or saving.
  ///
  /// On mobile platforms this opens the system share sheet. On desktop
  /// platforms this will copy the current log to the user's Downloads
  /// directory with a timestamped name and optionally open the file
  /// location (Windows selects the file in Explorer).
  Future<File?> exportLog({bool openAfter = true}) async {
    if (!_initialized || _logFile == null) return null;
    if (!await _logFile!.exists()) return null;

    // Try showing a native Save dialog (desktop & web via file_selector).
    final safeName = 'j_music-log-${DateTime.now().toIso8601String().replaceAll(':', '-')}.log';
    try {
      String? savePath;
      try {
        savePath = await FilePicker.platform.saveFile(dialogTitle: 'Save log', fileName: safeName);
      } catch (_) {
        savePath = null;
      }

      if (savePath != null) {
        final dest = File(savePath);
        await dest.create(recursive: true);
        await dest.writeAsBytes(await _logFile!.readAsBytes());

        if (openAfter && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
          try {
            if (Platform.isWindows) {
              await Process.run('explorer.exe', ['/select,${dest.path}']);
            } else if (Platform.isMacOS) {
              await Process.run('open', ['-R', dest.path]);
            } else if (Platform.isLinux) {
              await Process.run('xdg-open', [dest.parent.path]);
            }
          } catch (_) {}
        }
        return dest;
      }
    } catch (_) {
      // fall through to mobile/share fallback
    }

    // If user cancelled save dialog or it's unsupported, fall back to mobile share
    if (kIsWeb == false && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await Share.shareXFiles([XFile(_logFile!.path)], subject: 'JMusic Logs');
        return _logFile;
      } catch (_) {
        return _logFile;
      }
    }

    return null;
  }

  Future<int> getLogSize() async {
    if (!_initialized || _logFile == null) return 0;
    try {
      return await _logFile!.length();
    } catch (_) {
      return 0;
    }
  }

  Future<void> clearLogs() async {
    if (!_initialized || _logFile == null) return;
    try {
      await _logFile!.writeAsString('', flush: true);
    } catch (_) {}
  }
}

class _FileLogOutput extends LogOutput {
  final File _file;
  _FileLogOutput(this._file);

  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      try {
        _file.writeAsStringSync('$line\n', mode: FileMode.append);
      } catch (_) {
        // ignore write errors
      }
    }
  }
}
