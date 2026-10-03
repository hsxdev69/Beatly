class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String coverUrl;
  final String audioUrl;
  final Duration duration;
  final String? plays;
  final List<LyricLine> lyrics;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.audioUrl,
    required this.duration,
    this.plays,
    this.lyrics = const [],
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? coverUrl,
    String? audioUrl,
    Duration? duration,
    String? plays,
    List<LyricLine>? lyrics,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      plays: plays ?? this.plays,
      lyrics: lyrics ?? this.lyrics,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'coverUrl': coverUrl,
        'audioUrl': audioUrl,
        'durationSeconds': duration.inSeconds,
        'plays': plays,
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? 'Unknown',
        artist: json['artist'] ?? 'Unknown',
        album: json['album'] ?? '',
        coverUrl: json['coverUrl'] ?? '',
        audioUrl: json['audioUrl'] ?? '',
        duration: Duration(seconds: json['durationSeconds'] ?? 180),
        plays: json['plays'],
      );
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

class Playlist {
  final String id;
  final String name;
  final String coverUrl;
  final List<Song> songs;

  const Playlist({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.songs,
  });
}
