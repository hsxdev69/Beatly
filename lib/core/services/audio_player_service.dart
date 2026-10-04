import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../shared/models/song.dart';
import '../network/music_repository.dart';
import '../database/local_storage.dart';
import 'audio_handler.dart';

class AudioPlayerService extends ChangeNotifier {
  final EchoAudioHandler _handler;
  final MusicRepository _repository;
  final LocalStorage _storage;

  Song? _currentSong;
  List<Song> _queue = [];
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Set<String> _favoriteIds = {};
  String? _errorMessage;

  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _playSub;
  StreamSubscription? _songSub;
  StreamSubscription? _errorSub;
  StreamSubscription? _loadingSub;

  AudioPlayerService({
    required EchoAudioHandler handler,
    required MusicRepository repository,
    required LocalStorage storage,
  })  : _handler = handler,
        _repository = repository,
        _storage = storage {
    _favoriteIds = _storage.getFavoriteIds();
    _listenToHandlerEvents();
  }

  // Getters
  Song? get currentSong => _currentSong ?? _handler.currentSong;
  List<Song> get queue => _queue.isNotEmpty ? _queue : _handler.currentQueue;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isShuffle => _handler.isShuffle;
  bool get isRepeat => _handler.isRepeat;
  Set<String> get favoriteIds => _favoriteIds;
  bool isFavorite(String id) => _favoriteIds.contains(id);
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _listenToHandlerEvents() {
    _songSub = _handler.currentSongStream.listen((song) {
      _currentSong = song;
      _queue = _handler.currentQueue;
      _errorMessage = null;
      if (song != null) {
        _storage.addRecentlyPlayed(song);
        if (song.lyrics.isEmpty) {
          _fetchLyrics(song);
        }
      }
      notifyListeners();
    });

    _posSub = _handler.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durSub = _handler.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });

    _playSub = _handler.isPlayingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _loadingSub = _handler.loadingStream.listen((loading) {
      _isLoading = loading;
      notifyListeners();
    });

    _errorSub = _handler.errorStream.listen((err) {
      _errorMessage = err;
      notifyListeners();
    });
  }

  Future<void> playSong(Song song, [List<Song>? contextQueue]) async {
    _errorMessage = null;
    _currentSong = song;
    _position = Duration.zero;
    if (contextQueue != null) {
      _queue = List.from(contextQueue);
    }
    notifyListeners();

    await _handler.playSong(song, contextQueue);
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
      await _handler.pause();
    } else {
      if (_currentSong != null) {
        await _handler.play();
      }
    }
  }

  Future<void> seek(Duration pos) async {
    await _handler.seek(pos);
  }

  void next() {
    _handler.skipToNext();
  }

  void prev() {
    _handler.skipToPrevious();
  }

  void toggleShuffle() {
    _handler.toggleShuffle();
    _queue = _handler.currentQueue;
    notifyListeners();
  }

  void toggleRepeat() {
    _handler.toggleRepeat();
    notifyListeners();
  }

  Future<void> toggleFavorite(String songId) async {
    await _storage.toggleFavorite(songId);
    _favoriteIds = _storage.getFavoriteIds();
    notifyListeners();
  }

  void addToQueue(Song song) {
    _handler.addToQueue(song);
    _queue = _handler.currentQueue;
    notifyListeners();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _playSub?.cancel();
    _songSub?.cancel();
    _errorSub?.cancel();
    _loadingSub?.cancel();
    super.dispose();
  }
}
