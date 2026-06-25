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

  List<SongModel> _songQueue = [];
  int _currentIndex = 0;
  bool _shuffle = false;
  LoopMode _loopMode = LoopMode.off;

  Stream<PositionData> get positionDataStream => Rx.combineLatest3(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (pos, buf, dur) => PositionData(pos, buf, dur),
      );

  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  AudioPlayer get player => _player;
  List<SongModel> get songQueue => _songQueue;
  int get currentIndex => _currentIndex;
  bool get isShuffle => _shuffle;
  LoopMode get loopMode => _loopMode;

  AudioPlayerService() {
    _init();
  }

  void _init() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.currentIndexStream.listen((i) {
      if (i != null && i < _songQueue.length) {
        _currentIndex = i;
        mediaItem.add(_mediaItemFromSong(_songQueue[i]));
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

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) await _player.seekToNext();
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
    if (index >= 0 && index < _songQueue.length) {
      await _player.seek(Duration.zero, index: index);
      await _player.play();
    }
  }

  Future<void> playSong(SongModel song,
      {List<SongModel>? songQueue, int startIndex = 0}) async {
    if (songQueue != null) {
      _songQueue = songQueue;
      _currentIndex = startIndex;
    } else {
      _songQueue = [song];
      _currentIndex = 0;
    }
    await _rebuildPlaylist();
    await _player.seek(Duration.zero, index: _currentIndex);
    await _player.play();
  }

  Future<void> addToQueue(SongModel song) async {
    _songQueue.add(song);
    final url = await _getStreamUrl(song);
    if (url.isNotEmpty) {
      await _playlist.add(
        AudioSource.uri(Uri.parse(url), tag: _mediaItemFromSong(song)),
      );
    }
  }

  Future<void> removeFromQueue(int index) async {
    if (index >= 0 && index < _songQueue.length) {
      _songQueue.removeAt(index);
      await _playlist.removeAt(index);
    }
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex--;
    final song = _songQueue.removeAt(oldIndex);
    _songQueue.insert(newIndex, song);
    await _playlist.move(oldIndex, newIndex);
  }

  Future<void> _rebuildPlaylist() async {
    await _playlist.clear();
    final sources = <AudioSource>[];
    for (final song in _songQueue) {
      final url = await _getStreamUrl(song);
      if (url.isNotEmpty) {
        sources.add(AudioSource.uri(
          Uri.parse(url),
          tag: _mediaItemFromSong(song),
        ));
      }
    }
    await _playlist.addAll(sources);
    // Update the parent class queue with MediaItems
    queue.add(_songQueue.map(_mediaItemFromSong).toList());
  }

  Future<String> _getStreamUrl(SongModel song) async {
    if (song.localPath != null) return song.localPath!;
    if (song.streamUrl != null) return song.streamUrl!;
    final url = await _ytService.getStreamUrl(song.id);
    return url ?? '';
  }

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

  Future<void> setSpeed(double speed) => _player.setSpeed(speed);
  Future<void> setPitch(double pitch) => _player.setPitch(pitch);
  Future<void> setVolume(double volume) => _player.setVolume(volume);

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
