import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../shared/models/song.dart';
import '../network/music_repository.dart';
import '../database/local_storage.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final MusicRepository _repository;
  final LocalStorage _storage;

  Song? _currentSong;
  List<Song> _queue = [];
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isShuffle = false;
  bool _isRepeat = false;
  Set<String> _favoriteIds = {};

  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _completeSub;

  AudioPlayerService({
    required MusicRepository repository,
    required LocalStorage storage,
  })  : _repository = repository,
        _storage = storage {
    _favoriteIds = _storage.getFavoriteIds();
    _initAudioListeners();
  }

  // Getters
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;
  Set<String> get favoriteIds => _favoriteIds;
  bool isFavorite(String id) => _favoriteIds.contains(id);

  void _initAudioListeners() {
    _posSub = _player.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durSub = _player.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    _stateSub = _player.onPlayerStateChanged.listen((state) {
      _isPlaying = (state == PlayerState.playing);
      notifyListeners();
    });

    _completeSub = _player.onPlayerComplete.listen((_) {
      if (_isRepeat && _currentSong != null) {
        playSong(_currentSong!);
      } else {
        next();
      }
    });
  }

  Future<void> setQueue(List<Song> newQueue) async {
    _queue = List.from(newQueue);
    notifyListeners();
  }

  Future<void> playSong(Song song, [List<Song>? contextQueue]) async {
    if (contextQueue != null && contextQueue.isNotEmpty) {
      _queue = List.from(contextQueue);
    } else if (!_queue.any((s) => s.id == song.id)) {
      _queue.add(song);
    }

    _currentSong = song;
    _position = Duration.zero;
    notifyListeners();

    _storage.addRecentlyPlayed(song);

    // Fetch lyrics asynchronously if not already loaded
    if (song.lyrics.isEmpty) {
      _fetchLyrics(song);
    }

    try {
      await _player.stop();
      await _player.play(UrlSource(song.audioUrl));
    } catch (e) {
      debugPrint("AudioPlayer play error: $e");
    }
  }

  Future<void> _fetchLyrics(Song song) async {
    final lyrics = await _repository.getLyrics(song.title, song.artist);
    if (lyrics.isNotEmpty && _currentSong?.id == song.id) {
      _currentSong = _currentSong!.copyWith(lyrics: lyrics);
      notifyListeners();
    }
  }

  Future<void> playPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_currentSong != null) {
        if (_player.state == PlayerState.paused) {
          await _player.resume();
        } else {
          await playSong(_currentSong!);
        }
      }
    }
  }

  Future<void> seek(Duration pos) async {
    await _player.seek(pos);
  }

  void next() {
    if (_queue.isEmpty || _currentSong == null) return;
    int idx = _queue.indexWhere((s) => s.id == _currentSong!.id);
    if (idx == -1) idx = 0;
    int nextIdx = (idx + 1) % _queue.length;
    playSong(_queue[nextIdx]);
  }

  void prev() {
    if (_queue.isEmpty || _currentSong == null) return;
    int idx = _queue.indexWhere((s) => s.id == _currentSong!.id);
    if (idx == -1) idx = 0;
    int prevIdx = (idx - 1 + _queue.length) % _queue.length;
    playSong(_queue[prevIdx]);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    if (_isShuffle && _queue.length > 1) {
      _queue.shuffle();
    }
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    notifyListeners();
  }

  Future<void> toggleFavorite(String songId) async {
    await _storage.toggleFavorite(songId);
    _favoriteIds = _storage.getFavoriteIds();
    notifyListeners();
  }

  void addToQueue(Song song) {
    _queue.add(song);
    notifyListeners();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
