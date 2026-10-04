import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'core/database/local_storage.dart';
import 'core/services/audio_handler.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final storage = await LocalStorage.create();

  // Initialize Background Audio Service & Android MediaSession
  final audioHandler = await AudioService.init(
    builder: () => EchoAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.echomusic.flutter.channel.audio',
      androidNotificationChannelName: 'Echo Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidShowNotificationBadge: true,
    ),
  );

  runApp(EchoMusicApp(storage: storage, audioHandler: audioHandler));
}
