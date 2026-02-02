import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/preferences_service.dart';
import 'system_proxy_helper.dart';

class GlobalHttpOverrides extends HttpOverrides {
  final SharedPreferences prefs;

  GlobalHttpOverrides(this.prefs);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    
    // 每次创建 Client 时读取最新的配置
    final service = PreferencesService(prefs);
    final mode = service.proxyMode;
    final host = service.proxyHost;
    final port = service.proxyPort;

    // Configure Proxy
    if (mode == 'custom') {
      client.findProxy = (uri) {
        return 'PROXY $host:$port; DIRECT';
      };
    } else if (mode == 'none') {
      client.findProxy = (uri) => 'DIRECT';
    } else {
      // mode == 'system': 优先使用探测到的系统代理
      client.findProxy = (uri) {
        // 实时探测环境变量 (HTTP_PROXY)
        final envProxy = HttpClient.findProxyFromEnvironment(uri);
        
        // 获取 Helper 探测到的注册表/系统设置代理
        final systemProxy = SystemProxyHelper.proxyDirective;

        if (systemProxy != null && systemProxy != 'DIRECT') {
          return '$systemProxy; $envProxy; DIRECT';
        }
        return '$envProxy; DIRECT';
      };
    }

    // Ignore SSL errors
    client.badCertificateCallback = (cert, host, port) => true;
    
    // 尝试解决 Windows 上的信号灯超时问题
    // 设置较短的空闲超时，避免复用已断开的连接
    client.idleTimeout = const Duration(seconds: 15);
    client.connectionTimeout = const Duration(seconds: 15);

    return client;
  }
}

