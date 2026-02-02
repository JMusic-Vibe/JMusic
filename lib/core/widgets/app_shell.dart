import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/music_lib/presentation/library_screen.dart';
import 'package:jmusic/features/playlists/presentation/playlists_screen.dart';
import 'package:jmusic/features/home/presentation/home_screen.dart';
import 'package:jmusic/features/more/presentation/more_screen.dart';
import 'package:jmusic/features/sync/presentation/sync_center_screen.dart';
import 'package:jmusic/features/scraper/presentation/scraper_center_screen.dart';
import 'package:jmusic/features/settings/presentation/settings_screen.dart';
import 'package:jmusic/features/player/presentation/widgets/mini_player.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late int _selectedIndex;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize selected index from preferences
    _selectedIndex = ref.read(preferencesServiceProvider).defaultPageIndex;
  }

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const LibraryScreen(),
      const PlaylistsScreen(),
      const SyncCenterScreen(),
      const ScraperCenterScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  void dispose() {
    // 在应用关闭时保存播放队列
    // 注意：这里无法直接访问ref，因为dispose时context可能不可用
    // 我们在其他地方处理保存逻辑
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final railDestinations = <_NavDestination>[
      _NavDestination(label: l10n.home, icon: Icons.home_outlined, selectedIcon: Icons.home),
      _NavDestination(label: l10n.library, icon: Icons.library_music_outlined, selectedIcon: Icons.library_music),
      _NavDestination(label: l10n.playlists, icon: Icons.queue_music_outlined, selectedIcon: Icons.queue_music),
      _NavDestination(label: l10n.sync, icon: Icons.sync_outlined, selectedIcon: Icons.sync),
      _NavDestination(label: l10n.scraper, icon: Icons.auto_awesome_outlined, selectedIcon: Icons.auto_awesome),
      _NavDestination(label: l10n.settings, icon: Icons.settings_outlined, selectedIcon: Icons.settings),
    ];

    final bottomDestinations = <_NavDestination>[
      _NavDestination(label: l10n.home, icon: Icons.home_outlined, selectedIcon: Icons.home),
      _NavDestination(label: l10n.library, icon: Icons.library_music_outlined, selectedIcon: Icons.library_music),
      _NavDestination(label: l10n.playlists, icon: Icons.queue_music_outlined, selectedIcon: Icons.queue_music),
      _NavDestination(label: l10n.more, icon: Icons.more_horiz, selectedIcon: Icons.more_horiz), 
    ];

    final screens = _buildScreens();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = _navigatorKeys[_selectedIndex.clamp(0, _navigatorKeys.length - 1)].currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else if (_selectedIndex != 0) {
          // If we can't pop the nested navigator, switch to the first tab (Home)
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        final isMedium = constraints.maxWidth >= 700;
        final isTall = constraints.maxHeight >= 400; // 防止小高度时NavigationRail溢出
        if ((isWide || isMedium) && isTall) {
          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        extended: isWide,
                        minExtendedWidth: 240,
                        labelType: NavigationRailLabelType.none,
                        destinations: railDestinations
                            .map((d) => NavigationRailDestination(
                                  icon: Icon(d.icon),
                                  selectedIcon: Icon(d.selectedIcon),
                                  label: Text(d.label),
                                ))
                            .toList(),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: screens.asMap().entries.map((entry) {
                            final index = entry.key;
                            final screen = entry.value;
                            return Navigator(
                              key: _navigatorKeys[index],
                              onGenerateRoute: (settings) => MaterialPageRoute(
                                settings: settings,
                                builder: (context) => screen,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const MiniPlayer(),
              ],
            ),
          );
        }

        final bottomScreens = [
          const HomeScreen(),
          const LibraryScreen(),
          const PlaylistsScreen(),
          const MoreScreen(),
        ];

        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex.clamp(0, bottomScreens.length - 1),
                  children: bottomScreens.asMap().entries.map((entry) {
                    final index = entry.key;
                    final screen = entry.value;
                    return Navigator(
                      key: _navigatorKeys[index],
                      onGenerateRoute: (settings) => MaterialPageRoute(
                        settings: settings,
                        builder: (context) => screen,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const MiniPlayer(),
            ],
          ),
          bottomNavigationBar: SizedBox(
            height: 65,
            child: NavigationBar(
              selectedIndex: _selectedIndex.clamp(0, bottomDestinations.length - 1),
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: bottomDestinations
                  .map((d) => NavigationDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: d.label,
                      ))
                  .toList(),
            ),
          ),
        );
      },
    ),
  );
}
}

class _NavDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

