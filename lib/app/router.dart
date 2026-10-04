import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/audio_player_service.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/player/presentation/full_player_sheet.dart';
import '../shared/widgets/floating_tab_bar.dart';
import '../shared/widgets/mini_player.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentTab = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    SearchScreen(),
    ExploreScreen(),
    LibraryScreen(),
  ];

  void _openFullPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const FullPlayerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerService>();
    final hasSong = player.currentSong != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Current Tab Page
          IndexedStack(
            index: _currentTab,
            children: _pages,
          ),

          // 2. Floating Bottom Controls: Mini Player + Floating Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasSong)
                  MiniPlayer(
                    onTap: _openFullPlayer,
                  ),
                FloatingTabBar(
                  selectedIndex: _currentTab,
                  onTabSelected: (index) {
                    setState(() => _currentTab = index);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
