import 'package:flutter/foundation.dart';

class ApiConstants {
  // Configurable development API base URL
  // Android emulator uses 10.0.2.2, Web uses localhost, physical devices use LAN IP or custom port
  static String defaultBaseUrl = kIsWeb
      ? 'http://localhost:8080'
      : (defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8080'
          : 'http://localhost:8080');

  static String apiBaseUrl = defaultBaseUrl;

  static String get searchEndpoint => '$apiBaseUrl/api/search';
  static String get lyricsEndpoint => '$apiBaseUrl/api/lyrics';

  // Direct public fallback APIs when local proxy server is not running
  static const String directLrclibSearch = 'https://lrclib.net/api/search';
  static const String directItunesSearch = 'https://itunes.apple.com/search';
}
