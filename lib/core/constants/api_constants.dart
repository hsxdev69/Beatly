import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  // Android Emulator loopback is 10.0.2.2; configurable for physical device / local server
  static const String defaultEmulatorBaseUrl = 'http://10.0.2.2:8080';
  static const String defaultLanBaseUrl = 'http://192.168.1.100:8080';
  static String defaultBaseUrl = kIsWeb
      ? 'http://localhost:8080'
      : (defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8080'
          : 'http://localhost:8080');

  static String apiBaseUrl = defaultBaseUrl;
  static String get searchEndpoint => '$apiBaseUrl/api/search';
  static String get lyricsEndpoint => '$apiBaseUrl/api/lyrics';

  // Public fallback instances for piped / invidious / innertube
  static const String pipedApiBase = 'https://pipedapi.kavin.rocks';
  static const String lrclibApiBase = 'https://lrclib.net/api';
  static const String directItunesSearch = 'https://itunes.apple.com/search';
  static const String directLrclibSearch = 'https://lrclib.net/api/search';

  // Preference Keys
  static const String prefCustomApiUrl = 'pref_custom_api_url';
  static const String prefAudioQuality = 'pref_audio_quality';
  static const String prefPureBlack = 'pref_pure_black';
  static const String prefDynamicColor = 'pref_dynamic_color';
  static const String prefAutoPlayNext = 'pref_autoplay_next';
  static const String prefAudioCacheEnabled = 'pref_audio_cache_enabled';
  static const String prefCacheLimitMb = 'pref_cache_limit_mb';
}
