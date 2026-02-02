import 'dart:io';
import 'package:system_proxy/system_proxy.dart';

class SystemProxyHelper {
  static String? _cachedProxy;
  static DateTime? _lastCheckTime;
  static const _checkInterval = Duration(seconds: 10);

  /// 获取当前生效的代理配置字符串 (e.g. "PROXY 127.0.0.1:7890; DIRECT")
  static String? get proxyDirective => _cachedProxy;

  static Future<void> refreshProxy() async {
    // 简单的节流，避免短时间内频繁读取注册表影响性能
    if (_lastCheckTime != null && DateTime.now().difference(_lastCheckTime!) < _checkInterval) {
      return;
    }
    _lastCheckTime = DateTime.now();

    _cachedProxy = await _resolve();
  }

  static Future<String?> _resolve() async {
    try {
      // 1. 尝试使用 system_proxy 包
      final proxy = await SystemProxy.getProxySettings();
      if (proxy != null && proxy['host'] != null && proxy['port'] != null) {
          final host = proxy['host'];
          final port = proxy['port'];
          return 'PROXY $host:$port';
      }
    } catch (e) {
      // Silent error
    }

    // 2. Windows 平台的回退方案：直接查注册
    if (Platform.isWindows) {
      try {
        final resultEnable = await Process.run('reg', [
          'query',
          r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings',
          '/v',
          'ProxyEnable'
        ]);
        
        final enableStdout = resultEnable.stdout.toString();
        // 兼容不同reg 输出格式 (0x1 或 1)
        if (enableStdout.contains('0x1') || enableStdout.contains(' 1')) {
          final resultServer = await Process.run('reg', [
            'query',
            r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings',
            '/v',
            'ProxyServer'
          ]);
          
          final output = resultServer.stdout.toString();

          // 更加健壮的正则表达式，匹配IP/域名:端口
          // 同时也支持http=127.0.0.1:7890 这种格式
          final match = RegExp(r'REG_SZ\s+(?:.*=)?([a-zA-Z0-9\.]+:[0-9]+)').firstMatch(output);
          if (match != null) {
            final proxyServer = match.group(1)?.trim();
            if (proxyServer != null) {
              return 'PROXY $proxyServer';
            }
          }
        }
      } catch (e) {
        // Silent error
      }
    }
    
    return null;
  }
}

