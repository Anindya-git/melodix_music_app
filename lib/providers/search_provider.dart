import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song_model_clean.dart';
import '../services/youtube_music_service.dart';

final ytMusicServiceProvider = Provider<YouTubeMusicService>((ref) {
  final service = YouTubeMusicService();
  ref.onDispose(() => service.dispose());
  return service;
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchFilterProvider = StateProvider<String>((ref) => 'songs');

final searchResultsProvider = FutureProvider<List<SongModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(searchFilterProvider);
  if (query.isEmpty) return [];
  final service = ref.read(ytMusicServiceProvider);
  return service.search(query, filter: filter);
});

final homeFeedProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(ytMusicServiceProvider);
  return service.getHomeFeed();
});

final chartsProvider = FutureProvider<List<SongModel>>((ref) async {
  final service = ref.read(ytMusicServiceProvider);
  return service.getCharts();
});
