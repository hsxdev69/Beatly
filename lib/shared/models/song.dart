class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String thumbnailUrl;
  final Duration? duration;
  final String? streamUrl;
  final bool isLiked;
  final DateTime? playedAt;
  final String? plays;
  final List<LyricLine> lyrics;

  // Compatibility getters
  String get coverUrl => thumbnailUrl;
  String get audioUrl => streamUrl ?? '';

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    String? thumbnailUrl,
    String? coverUrl,
    this.duration,
    String? streamUrl,
    String? audioUrl,
    this.isLiked = false,
    this.playedAt,
    this.plays,
    this.lyrics = const [],
  })  : thumbnailUrl = thumbnailUrl ?? coverUrl ?? '',
        streamUrl = streamUrl ?? audioUrl;

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? thumbnailUrl,
    Duration? duration,
    String? streamUrl,
    bool? isLiked,
    DateTime? playedAt,
    String? plays,
    List<LyricLine>? lyrics,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      streamUrl: streamUrl ?? this.streamUrl,
      isLiked: isLiked ?? this.isLiked,
      playedAt: playedAt ?? this.playedAt,
      plays: plays ?? this.plays,
      lyrics: lyrics ?? this.lyrics,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'thumbnail_url': thumbnailUrl,
      'duration_ms': duration?.inMilliseconds,
      'stream_url': streamUrl,
      'is_liked': isLiked ? 1 : 0,
      'played_at': playedAt?.toIso8601String(),
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unknown',
      artist: map['artist'] ?? 'Unknown',
      album: map['album'],
      thumbnailUrl: map['thumbnail_url'] ?? '',
      duration: map['duration_ms'] != null ? Duration(milliseconds: map['duration_ms']) : null,
      streamUrl: map['stream_url'],
      isLiked: (map['is_liked'] ?? 0) == 1,
      playedAt: map['played_at'] != null ? DateTime.tryParse(map['played_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Song.fromJson(Map<String, dynamic> json) => Song.fromMap(json);
}

class LyricLine {
  final Duration time;
  final String text;

  const LyricLine({required this.time, required this.text});

  Map<String, dynamic> toJson() => {
        'timeMs': time.inMilliseconds,
        'text': text,
      };

  factory LyricLine.fromJson(Map<String, dynamic> json) => LyricLine(
        time: Duration(milliseconds: json['timeMs'] ?? 0),
        text: json['text'] ?? '',
      );
}
