import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../shared/models/song.dart';
import 'stream_resolver.dart';

class EchoAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final StreamResolver _resolver = StreamResolver();

  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  bool _isRepeat = false;

  final _songChangeController = StreamController<Song?>.broadcast();
  Stream<Song?> get currentSongStream => _songChangeController.stream;
  Song? get currentSong => _currentSong;
  List<Song> get currentQueue => _queue;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;

  VoidCallback? onSkipNext;
  VoidCallback? onSkipPrevious;
  VoidCallback? onCompleted;
  AudioPlayer get player => _player;

  EchoAudioHandler() {
    _initAudioSession();
    _broadcastPlayerEvents();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _broadcastPlayerEvents() {
    // Pipe playback events from just_audio into audio_service playbackState
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _currentIndex,
      ));
    });

    // Auto-advance when track finishes
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_isRepeat && _currentSong != null) {
          playSong(_currentSong!);
        } else {
          skipToNext();
        }
      }
    });
  }

  Future<void> playSong(Song song, [List<Song>? contextQueue]) async {
    if (contextQueue != null && contextQueue.isNotEmpty) {
      _queue = List.from(contextQueue);
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    } else {
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) {
        _queue.add(song);
        _currentIndex = _queue.length - 1;
      }
    }

    _currentSong = song;
    _songChangeController.add(song);

    // Update MediaItem for Android MediaSession and Notification
    final mediaItemObj = MediaItem(
      id: song.id,
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: song.duration,
      artUri: Uri.tryParse(song.coverUrl),
    );
    mediaItem.add(mediaItemObj);

    // Resolve real audio stream (audio/webm, audio/mp4)
    final streamInfo = await _resolver.resolveStream(song.id, fallbackUrl: song.audioUrl);

    try {
      await _player.stop();
      await _player.setUrl(streamInfo.url);
      await _player.play();
    } catch (e) {
      debugPrint("just_audio playback error: $e");
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await playbackState.firstWhere((state) => state.processingState == AudioProcessingState.idle);
  }

  @override
  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _queue.length;
    await playSong(_queue[_currentIndex]);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    await playSong(_queue[_currentIndex]);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    if (_isShuffle && _queue.length > 1) {
      _queue.shuffle();
      if (_currentSong != null) {
        _currentIndex = _queue.indexWhere((s) => s.id == _currentSong!.id);
      }
    }
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
  }

  void setQueue(List<Song> newQueue) {
    _queue = List.from(newQueue);
  }

  void addToQueue(Song song) {
    _queue.add(song);
  }

  // Stream accessors for UI bindings
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get isPlayingStream => _player.playingStream;
}
