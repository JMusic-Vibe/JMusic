import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio_background/just_audio_background.dart';
import 'core/theme/app_theme.dart';
import 'features/scraper/presentation/scrape_overlay_widget.dart';
import 'core/theme/theme_provider.dart';
import 'core/localization/language_provider.dart';
import 'core/widgets/app_shell.dart';
import 'core/widgets/custom_title_bar.dart';
import 'core/services/preferences_service.dart';
import 'core/services/database_service.dart';
import 'core/services/audio_player_service.dart';
import 'core/network/global_http_overrides.dart';
import 'core/network/system_proxy_helper.dart';

import 'package:audio_service/audio_service.dart';
import 'core/services/my_audio_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化AudioService (替代 JustAudioBackground.init)
  // 这会注册 MyAudioHandler 来处理系统媒体控制
  final audioHandler = await MyAudioHandler.init();
  
  // 禁用 Debug 下的键盘检查（仅开发用途）
  HardwareKeyboard.instance;
  
  // 预先探测系统代理设置 (解决 archive.org 访问超时)
  await SystemProxyHelper.refreshProxy();
  
  final prefs = await SharedPreferences.getInstance();

  // 初始化全局 HTTP 代理设置 (影响 Image.network 等)
  HttpOverrides.global = GlobalHttpOverrides(prefs);

  // 锁定小屏设备为竖屏，防止旋转导致布局溢出
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    final size = WidgetsBinding.instance.window.physicalSize / WidgetsBinding.instance.window.devicePixelRatio;
    if (size.shortestSide < 600) { // 小屏设备（手机）
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(400, 600),
      center: true,
      title: 'J-Music',
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  
  runApp(ProviderScope(
    overrides: [
      preferencesServiceProvider.overrideWithValue(PreferencesService(prefs)),
      myAudioHandlerProvider.overrideWithValue(audioHandler),
    ],
    child: const JMusicApp(),
  ));
}

class JMusicApp extends ConsumerStatefulWidget {
  const JMusicApp({super.key});

  @override
  ConsumerState<JMusicApp> createState() => _JMusicAppState();
}

class _JMusicAppState extends ConsumerState<JMusicApp> {
  @override
  void initState() {
    super.initState();
    // 延迟到下一帧，确保所有provider都初始化�?
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreLastQueue();
    });
  }

  Future<void> _restoreLastQueue() async {
    final audioPlayerService = ref.read(audioPlayerServiceProvider);
    await audioPlayerService.restoreLastQueue();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(languageProvider);
    
    return MaterialApp(
      title: 'J-Music',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: isDesktop ? 36 : 0),
              child: child,
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomTitleBar(),
            ),
            const ScrapeOverlayWidget(),
          ],
        );
      },
      home: const AppShell(),
    );
  }
}

