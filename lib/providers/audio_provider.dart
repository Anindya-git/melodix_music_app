import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_player_service.dart';
import '../models/song_model_clean.dart';

final audioServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

final currentSongProvider = StreamProvider<SongModel?>((ref) {
  final service = ref.watch(audioServiceProvider);
  return service.currentIndexStream.map((index) {
    if (index == null || index >= service.songQueue.length) return null;
    return service.songQueue[index];
  });
});

final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  final service = ref.watch(audioServiceProvider);
  return service.playbackState;
});

final positionDataProvider = StreamProvider<PositionData>((ref) {
  final service = ref.watch(audioServiceProvider);
  return service.positionDataStream;
});

final queueProvider = Provider<List<SongModel>>((ref) {
  final service = ref.watch(audioServiceProvider);
  return service.songQueue;
});
