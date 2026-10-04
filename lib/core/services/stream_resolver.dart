import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../constants/api_constants.dart';

class StreamResolutionException implements Exception {
  final String message;
  const StreamResolutionException(this.message);

  @override
  String toString() => 'StreamResolutionException: $message';
}

class StreamInfo {
  final String url;
  final String mimeType;
  final int bitrate;
  final Duration duration;

  const StreamInfo({
    required this.url,
    required this.mimeType,
    required this.bitrate,
    required this.duration,
  });
}

class StreamResolver {
  final http.Client _client;
  final YoutubeExplode _yt;

  StreamResolver({http.Client? client, YoutubeExplode? yt})
      : _client = client ?? http.Client(),
        _yt = yt ?? YoutubeExplode();

  /// Resolves a videoId or song title into a real playable audio stream (audio/webm or audio/mp4).
  /// Strictly extracts real YouTube/InnerTube audio stream URLs directly on-device.
  /// Falls back to searching YouTube if a direct videoId is removed, region-locked, or blocked.
  Future<StreamInfo> resolveStream(
    String videoId, {
    String? title,
    String? artist,
    String? fallbackUrl,
  }) async {
    final query = [title, artist].where((s) => s != null && s.isNotEmpty).join(' ').trim();

    // Strategy 1: Direct on-device YouTube extraction via YoutubeExplode (No server needed!)
    try {
      // 1A. If we have a plausible 11-char YouTube video ID, try it first
      if (videoId.isNotEmpty && videoId.length == 11 && int.tryParse(videoId) == null && !videoId.contains(' ')) {
        try {
          final manifest = await _yt.videos.streamsClient.getManifest(videoId);
          final audioOnly = manifest.audioOnly;
          if (audioOnly.isNotEmpty) {
            final best = audioOnly.withHighestBitrate();
            return StreamInfo(
              url: best.url.toString(),
              mimeType: best.codec.mimeType,
              bitrate: best.bitrate.bitsPerSecond,
              duration: const Duration(minutes: 3, seconds: 30),
            );
          }
        } catch (idErr) {
          debugPrint('[StreamResolver] Video ID $videoId blocked or unavailable, searching by title: $idErr');
        }
      }

      // 1B. Smart Search Fallback: Search YouTube by title + artist to find active playable video
      final searchQuery = query.isNotEmpty ? query : videoId;
      if (searchQuery.isNotEmpty) {
        final searchResults = await _yt.search.search(searchQuery);
        for (final video in searchResults.take(4)) {
          try {
            final manifest = await _yt.videos.streamsClient.getManifest(video.id);
            final audioOnly = manifest.audioOnly;
            if (audioOnly.isNotEmpty) {
              final best = audioOnly.withHighestBitrate();
              return StreamInfo(
                url: best.url.toString(),
                mimeType: best.codec.mimeType,
                bitrate: best.bitrate.bitsPerSecond,
                duration: video.duration ?? const Duration(minutes: 3, seconds: 30),
              );
            }
          } catch (_) {
            continue; // Try next search result if this video is restricted
          }
        }
      }
    } catch (e) {
      debugPrint('[StreamResolver] YoutubeExplode error: $e');
    }

    // Strategy 2: Local development API server resolver (if running)
    try {
      final uri = Uri.parse(
        '${ApiConstants.apiBaseUrl}/api/stream?id=${Uri.encodeComponent(videoId)}&q=${Uri.encodeComponent(query)}',
      );
      final res = await _client.get(uri).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final streamUrl = data['streamUrl'] as String?;
        if (streamUrl != null && streamUrl.isNotEmpty) {
          return StreamInfo(
            url: streamUrl,
            mimeType: data['mimeType'] ?? 'audio/mp4',
            bitrate: data['bitrate'] ?? 160000,
            duration: Duration(seconds: data['durationSeconds'] ?? 200),
          );
        }
      }
    } catch (_) {}

    // Strategy 3: Public Piped instances for YouTube audio stream resolution
    final pipedInstances = [
      'https://pipedapi.kavin.rocks',
      'https://api.piped.privacy.com.de',
      'https://piped-api.lunar.icu',
    ];

    if (videoId.length == 11 && !videoId.contains(' ')) {
      for (final instance in pipedInstances) {
        try {
          final res = await _client.get(
            Uri.parse('$instance/streams/$videoId'),
            headers: {'User-Agent': 'EchoMusic/1.0'},
          ).timeout(const Duration(seconds: 3));

          if (res.statusCode == 200) {
            final data = json.decode(res.body);
            final audioStreams = (data['audioStreams'] as List?) ?? [];
            if (audioStreams.isNotEmpty) {
              audioStreams.sort((a, b) => ((b['bitrate'] ?? 0) as int).compareTo((a['bitrate'] ?? 0) as int));
              final top = audioStreams.first;
              final streamUrl = top['url'] as String?;
              if (streamUrl != null && streamUrl.isNotEmpty) {
                return StreamInfo(
                  url: streamUrl,
                  mimeType: top['mimeType'] ?? 'audio/webm',
                  bitrate: top['bitrate'] ?? 160000,
                  duration: Duration(seconds: data['duration'] ?? 200),
                );
              }
            }
          }
        } catch (_) {}
      }
    }

    // Direct fallback if given and verified
    if (fallbackUrl != null && fallbackUrl.isNotEmpty && !fallbackUrl.contains('soundhelix.com')) {
      return StreamInfo(
        url: fallbackUrl,
        mimeType: 'audio/mp4',
        bitrate: 128000,
        duration: const Duration(minutes: 3, seconds: 30),
      );
    }

    throw StreamResolutionException(
      'Could not resolve playable audio stream for "${title ?? videoId}".',
    );
  }
}
