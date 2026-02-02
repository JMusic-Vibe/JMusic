import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/preferences_service.dart';

class ProxySettings {
  final String mode; // 'system', 'custom', 'none'
  final String host;
  final int port;

  ProxySettings({required this.mode, required this.host, required this.port});
}

class ProxySettingsNotifier extends Notifier<ProxySettings> {
  @override
  ProxySettings build() {
    final prefs = ref.watch(preferencesServiceProvider);
    return ProxySettings(
      mode: prefs.proxyMode,
      host: prefs.proxyHost,
      port: prefs.proxyPort,
    );
  }

  Future<void> setMode(String mode) async {
    await ref.read(preferencesServiceProvider).setProxyMode(mode);
    state = ProxySettings(mode: mode, host: state.host, port: state.port);
  }

  Future<void> setHost(String host) async {
    await ref.read(preferencesServiceProvider).setProxyHost(host);
    state = ProxySettings(mode: state.mode, host: host, port: state.port);
  }

  Future<void> setPort(int port) async {
    await ref.read(preferencesServiceProvider).setProxyPort(port);
    state = ProxySettings(mode: state.mode, host: state.host, port: port);
  }
}

final proxySettingsProvider = NotifierProvider<ProxySettingsNotifier, ProxySettings>(ProxySettingsNotifier.new);

