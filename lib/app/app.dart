import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/database/local_storage.dart';
import '../core/network/music_repository.dart';
import '../core/services/audio_player_service.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/player/presentation/mini_player.dart';
import 'theme/app_theme.dart';

class EchoMusicApp extends StatefulWidget {
  final LocalStorage storage;

  const EchoMusicApp({super.key, required this.storage});

  @override
  State<EchoMusicApp> createState() => _EchoMusicAppState();
}

class _EchoMusicAppState extends State<EchoMusicApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStorage>.value(value: widget.storage),
        Provider<MusicRepository>(create: (_) => MusicRepositoryImpl()),
        ChangeNotifierProvider<AudioPlayerService>(
          create: (ctx) {
            final repo = ctx.read<MusicRepository>();
            final storage = ctx.read<LocalStorage>();
            final service = AudioPlayerService(repository: repo, storage: storage);
            // Default initial track
            final initialSongs = repo.getFeaturedCarouselSongs();
            service.playSong(initialSongs[2], initialSongs);
            return service;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Echo Music',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const EchoMusicMainShell(),
      ),
    );
  }
}

class EchoMusicMainShell extends StatefulWidget {
  const EchoMusicMainShell({super.key});

  @override
  State<EchoMusicMainShell> createState() => _EchoMusicMainShellState();
}

class _EchoMusicMainShellState extends State<EchoMusicMainShell> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _activeTabIndex,
                    children: const [
                      HomeScreen(),
                      SearchScreen(),
                      LibraryScreen(),
                    ],
                  ),
                ),
                // Spacing above dock
                const SizedBox(height: 140),
              ],
            ),
          ),

          // Floating mini-player and dock overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingDockAndMiniPlayer(
              activeIndex: _activeTabIndex,
              onTabSelected: (index) => setState(() => _activeTabIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}
