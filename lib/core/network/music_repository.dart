import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../shared/models/song.dart';
import '../constants/api_constants.dart';

abstract class MusicRepository {
  Future<List<Song>> searchSongs(String query);
  Future<List<LyricLine>> getLyrics(String title, String artist);
  List<Song> getFeaturedCarouselSongs();
  List<Song> getForgottenFavorites();
  List<Song> getTop100Chart();
}

class MusicRepositoryImpl implements MusicRepository {
  final http.Client _client;
  final YoutubeExplode _yt;

  MusicRepositoryImpl({http.Client? client, YoutubeExplode? yt})
      : _client = client ?? http.Client(),
        _yt = yt ?? YoutubeExplode();

  @override
  List<Song> getFeaturedCarouselSongs() => [
        const Song(
          id: 't7wSjy9Lv-o',
          title: 'Khalasi | Coke Studio Bharat',
          artist: 'Aditya Gadhvi, Achint',
          album: 'Coke Studio Bharat',
          coverUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 4, seconds: 24),
          lyrics: [
            LyricLine(time: Duration(seconds: 0), text: "♪ Khalasi Intro - Coke Studio ♪"),
            LyricLine(time: Duration(seconds: 12), text: "Arere rang chhe, rang chhe"),
            LyricLine(time: Duration(seconds: 24), text: "Gotilo gotilo gotilo re"),
            LyricLine(time: Duration(seconds: 40), text: "Mari hodi hankaari chali re"),
            LyricLine(time: Duration(seconds: 65), text: "Dariyani lahero ma moj chhe re"),
            LyricLine(time: Duration(seconds: 90), text: "Khalasi re khalasi mari jaat re"),
            LyricLine(time: Duration(seconds: 120), text: "♪ Traditional Dhol & Beats ♪"),
          ],
        ),
        const Song(
          id: 'f6vQ6t0GgG0',
          title: 'Fakira',
          artist: 'Sanam Puri, Vishal-Shekhar, Neeti Mohan',
          album: 'Student of the Year 2',
          coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 4, seconds: 43),
        ),
        const Song(
          id: 'dQw4w9WgXcQ',
          title: 'Last Thing You Need (from GTAVI: The Album)',
          artist: 'Morgan Wallen, Grand Theft Auto VI',
          album: 'Grand Theft Auto VI: The Album',
          coverUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 3, seconds: 16),
          lyrics: [
            LyricLine(time: Duration(seconds: 0), text: "Bad for your heart and good for your sheets"),
            LyricLine(time: Duration(seconds: 14), text: "Keep saying that it's over now"),
            LyricLine(time: Duration(seconds: 28), text: "Girl, I ain't gonna slow you down"),
            LyricLine(time: Duration(seconds: 45), text: "But you know where I am, you know where I'll be"),
            LyricLine(time: Duration(seconds: 64), text: "Whenever you want the last thing you need"),
            LyricLine(time: Duration(seconds: 88), text: "The last thing I'm meant to do"),
            LyricLine(time: Duration(seconds: 110), text: "Was be the best you ever had"),
          ],
        ),
      ];

  @override
  List<Song> getForgottenFavorites() => [
        const Song(
          id: 'H7_1-8jRk7Y',
          title: 'Vaaroon Forever (From "Mirzapur Th...")',
          artist: 'Anand Bhaskar, Romy, Shreya Ghoshal',
          album: 'Mirzapur',
          coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 3, seconds: 45),
        ),
        const Song(
          id: 'e-ORhEE9VVg',
          title: 'Bairan',
          artist: 'Banjaare',
          album: 'Banjaare Sessions',
          coverUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 4, seconds: 10),
        ),
        const Song(
          id: 'ubx2KqSgMHg',
          title: 'Ghar More Pardesiya',
          artist: 'Pritam, Shreya Ghoshal',
          album: 'Kalank',
          coverUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 5, seconds: 19),
        ),
        const Song(
          id: '_mmsu9yZkQ4',
          title: 'Sahiba',
          artist: 'Jasleen Royal, Stebin Ben',
          album: 'Sahiba Single',
          coverUrl: 'https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 3, seconds: 55),
        ),
      ];

  @override
  List<Song> getTop100Chart() => [
        const Song(
          id: 'k3g_WjLCsgo',
          title: 'Pehle Bhi Main',
          artist: 'Vishal Mishra, Raj Shekhar',
          album: 'ANIMAL',
          plays: '833k plays',
          coverUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 4, seconds: 10),
        ),
        const Song(
          id: 'HR1Z2w7x-fA',
          title: 'Satranga',
          artist: 'Arijit Singh, Shreyas Puranik',
          album: 'ANIMAL',
          plays: '625k plays',
          coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 4, seconds: 31),
        ),
        const Song(
          id: 'VAdGW7QDJUI',
          title: 'Chaleya',
          artist: 'Arijit Singh, Shilpa Rao',
          album: 'Jawan',
          plays: '500k plays',
          coverUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 3, seconds: 20),
        ),
        const Song(
          id: 'hV74vYvXjbg',
          title: 'Tum Kya Mile',
          artist: 'Arijit Singh, Shreya Ghoshal',
          album: 'Rocky Aur Rani Kii Prem Kahaani',
          plays: '416k plays',
          coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 4, seconds: 37),
        ),
        const Song(
          id: 'RLzC55ai0eo',
          title: 'Heeriye',
          artist: 'Jasleen Royal, Arijit Singh',
          album: 'Heeriye Single',
          plays: '357k plays',
          coverUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&auto=format&fit=crop&q=80',
          duration: Duration(minutes: 3, seconds: 14),
        ),
      ];

  @override
  Future<List<Song>> searchSongs(String query) async {
    if (query.trim().isEmpty) return [];

    // Strategy 1: Direct on-device YouTube search via YoutubeExplode
    try {
      final searchList = await _yt.search.search(query);
      if (searchList.isNotEmpty) {
        return searchList.map((video) {
          final thumb = video.thumbnails.highResUrl.isNotEmpty
              ? video.thumbnails.highResUrl
              : (video.thumbnails.mediumResUrl.isNotEmpty
                  ? video.thumbnails.mediumResUrl
                  : 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600');
          return Song(
            id: video.id.value,
            title: video.title,
            artist: video.author,
            album: 'YouTube Music',
            coverUrl: thumb,
            duration: video.duration ?? const Duration(minutes: 3, seconds: 30),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[MusicRepository] YoutubeExplode search error: $e');
    }

    // Strategy 2: Local development proxy server
    try {
      final res = await _client.get(
        Uri.parse('${ApiConstants.searchEndpoint}?q=${Uri.encodeComponent(query)}'),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        if (list.isNotEmpty) {
          return list.map((item) => Song.fromJson(item)).toList();
        }
      }
    } catch (_) {}

    // Strategy 3: Direct public iTunes API fallback (metadata only, full audio resolved via YouTube)
    try {
      final res = await _client.get(
        Uri.parse('${ApiConstants.directItunesSearch}?term=${Uri.encodeComponent(query)}&entity=song&limit=25'),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List results = data['results'] ?? [];
        return results.map((item) {
          final art = (item['artworkUrl100'] as String?)?.replaceAll('100x100bb', '600x600bb') ?? '';
          return Song(
            id: item['trackId'].toString(),
            title: item['trackName'] ?? 'Unknown',
            artist: item['artistName'] ?? 'Unknown',
            album: item['collectionName'] ?? '',
            coverUrl: art.isNotEmpty ? art : 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600',
            duration: Duration(milliseconds: item['trackTimeMillis'] ?? 180000),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Direct search error: $e");
    }

    return [];
  }

  @override
  Future<List<LyricLine>> getLyrics(String title, String artist) async {
    // Strategy 1: Local LRCLIB proxy
    try {
      final res = await _client.get(
        Uri.parse('${ApiConstants.lyricsEndpoint}?track=${Uri.encodeComponent(title)}&artist=${Uri.encodeComponent(artist)}'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final synced = data['syncedLyrics'] as String? ?? '';
        if (synced.isNotEmpty) {
          return _parseLrc(synced);
        }
      }
    } catch (_) {}

    // Strategy 2: Direct LRCLIB public API fallback
    try {
      final query = Uri.encodeComponent('$artist $title'.trim());
      final res = await _client.get(
        Uri.parse('${ApiConstants.directLrclibSearch}?q=$query'),
        headers: {'User-Agent': 'EchoMusic/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        for (final entry in data) {
          final synced = entry['syncedLyrics'] as String?;
          if (synced != null && synced.isNotEmpty) {
            return _parseLrc(synced);
          }
        }
      }
    } catch (_) {}

    return [];
  }

  List<LyricLine> _parseLrc(String lrc) {
    final List<LyricLine> result = [];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');
    for (final line in lrc.split('\n')) {
      final match = regex.firstMatch(line.trim());
      if (match != null) {
        final min = int.tryParse(match.group(1)!) ?? 0;
        final sec = int.tryParse(match.group(2)!) ?? 0;
        final ms = int.tryParse(match.group(3)!) ?? 0;
        final text = match.group(4)!.trim();
        if (text.isNotEmpty) {
          result.add(LyricLine(
            time: Duration(
              minutes: min,
              seconds: sec,
              milliseconds: ms * (match.group(3)!.length == 2 ? 10 : 1),
            ),
            text: text,
          ));
        }
      }
    }
    return result;
  }
}
