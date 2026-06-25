import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song_model_clean.dart';
import 'youtube_music_service.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration? duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class AudioPlayerService extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final _ytService = YouTubeMusicService();
  final _playlist = ConcatenatingAudioSource(children: []);

  List<SongModel> _queue = [];
  int _currentIndex = 0;
  bool _shuffle = false;
  LoopMode _loopMode = LoopMode.off;

  // Streams
  Stream<PositionData> get positionDataStream => Rx.combineLatest3(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (pos, buf, dur) => PositionData(pos, buf, dur),
      );

  Stream<PlaybackState> get playbackStateStream => playbackState;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  AudioPlayer get player => _player;
  List<SongModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isShuffle => _shuffle;
  LoopMode get loopMode => _loopMode;

  AudioPlayerService() {
    _init();
  }

  void _init() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.currentIndexStream.listen((i) {
      if (i != null && i < _queue.length) {
        _currentIndex = i;
        mediaItem.add(_mediaItemFromSong(_queue[i]));
      }
    });

    _player.setAudioSource(_playlist, preload: false);
  }

  MediaItem _mediaItemFromSong(SongModel song) => MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        album: song.album,
        artUri: Uri.tryParse(song.thumbnailUrl),
        duration: Duration(milliseconds: song.durationMs),
      );

  // ─── Playback Controls ────────────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await playbackState.firstWhere(
        (state) => state.processingState == AudioProcessingState.idle);
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < _queue.length) {
      await _player.seek(Duration.zero, index: index);
      await _player.play();
    }
  }

  // ─── Queue Management ─────────────────────────────────────────────────────

  Future<void> playSong(SongModel song, {List<SongModel>? songQueue, int startIndex = 0}) async {
    if (songQueue != null) {
      _queue = songQueue;
      _currentIndex = startIndex;
    } else {
      _queue = [song];
      _currentIndex = 0;
    }

    await _rebuildPlaylist();
    await _player.seek(Duration.zero, index: _currentIndex);
    await _player.play();
  }

  Future<void> addToQueue(SongModel song) async {
    _queue.add(song);
    final url = await _getStreamUrl(song);
    await _playlist.add(AudioSource.uri(Uri.parse(url), tag: _mediaItemFromSong(song)));
  }

  Future<void> removeFromQueue(int index) async {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      await _playlist.removeAt(index);
    }
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex--;
    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);
    await _playlist.move(oldIndex, newIndex);
  }

  Future<void> _rebuildPlaylist() async {
    await _playlist.clear();
    final sources = <AudioSource>[];
    for (final song in _queue) {
      final url = await _getStreamUrl(song);
      sources.add(AudioSource.uri(
        Uri.parse(url),
        tag: _mediaItemFromSong(song),
      ));
    }
    await _playlist.addAll(sources);
    queue.add(_queue.map(_mediaItemFromSong).toList());
  }

  Future<String> _getStreamUrl(SongModel song) async {
    if (song.localPath != null) return song.localPath!;
    if (song.streamUrl != null) return song.streamUrl!;
    final url = await _ytService.getStreamUrl(song.id);
    return url ?? '';
  }

  // ─── Shuffle & Repeat ─────────────────────────────────────────────────────

  Future<void> toggleShuffle() async {
    _shuffle = !_shuffle;
    await _player.setShuffleModeEnabled(_shuffle);
  }

  Future<void> cycleLoopMode() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    await _player.setLoopMode(_loopMode);
  }

  // ─── Speed & Pitch ────────────────────────────────────────────────────────

  Future<void> setSpeed(double speed) => _player.setSpeed(speed);
  Future<void> setPitch(double pitch) => _player.setPitch(pitch);

  // ─── Volume ───────────────────────────────────────────────────────────────

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  // ─── State Broadcast ──────────────────────────────────────────────────────

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
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
      queueIndex: event.currentIndex,
    ));
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await super.onTaskRemoved();
  }

  void dispose() {
    _player.dispose();
    _ytService.dispose();
  }
}
