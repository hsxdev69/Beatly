import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/database/local_storage.dart';
import '../core/network/music_repository.dart';
import '../core/services/audio_handler.dart';
import '../core/services/audio_player_service.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class EchoMusicApp extends StatefulWidget {
  final LocalStorage storage;
  final EchoAudioHandler audioHandler;

  const EchoMusicApp({
    super.key,
    required this.storage,
    required this.audioHandler,
  });

  @override
  State<EchoMusicApp> createState() => _EchoMusicAppState();
}

class _EchoMusicAppState extends State<EchoMusicApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStorage>.value(value: widget.storage),
        Provider<EchoAudioHandler>.value(value: widget.audioHandler),
        Provider<MusicRepository>(create: (_) => MusicRepositoryImpl()),
        ChangeNotifierProvider<AudioPlayerService>(
          create: (ctx) {
            final repo = ctx.read<MusicRepository>();
            final storage = ctx.read<LocalStorage>();
            final handler = ctx.read<EchoAudioHandler>();
            return AudioPlayerService(handler: handler, repository: repo, storage: storage);
          },
        ),
      ],
      child: MaterialApp(
        title: 'Echo Music',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const MainNavigationShell(),
      ),
    );
  }
}
