import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

class PlaylistScreen extends ConsumerWidget {
  final String id;
  const PlaylistScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLikedSongs = id == 'liked';
    final songs = isLikedSongs
        ? ref.watch(likedSongsProvider)
        : ref.watch(playlistProvider).firstWhere((p) => p.id == id, orElse: () => throw Exception()).songs;
    final title = isLikedSongs ? 'Liked Songs' : ref.watch(playlistProvider).firstWhere((p) => p.id == id).name;
    final audioService = ref.read(audioServiceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isLikedSongs ? const Color(0xFF9B59B6) : AppColors.primary,
                      AppColors.darkBg,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
                      ),
                      child: Icon(
                        isLikedSongs ? Icons.favorite_rounded : Icons.queue_music_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('${songs.length} songs', style: const TextStyle(color: AppColors.textSecondary)),
                  const Spacer(),
                  // Shuffle button
                  IconButton(
                    icon: const Icon(Icons.shuffle_rounded, color: AppColors.textSecondary),
                    onPressed: () {
                      if (songs.isEmpty) return;
                      audioService.toggleShuffle();
                      audioService.playSong(songs.first, songQueue: songs);
                      context.push('/player');
                    },
                  ),
                  // Play all button
                  ElevatedButton.icon(
                    onPressed: songs.isEmpty ? null : () {
                      audioService.playSong(songs.first, songQueue: songs);
                      context.push('/player');
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Play All'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SongTile(
                song: songs[index],
                showRemove: !isLikedSongs,
                onTap: () {
                  audioService.playSong(songs[index], songQueue: songs, startIndex: index);
                  context.push('/player');
                },
                onRemove: isLikedSongs
                    ? () => ref.read(likedSongsProvider.notifier).toggleLike(songs[index])
                    : () => ref.read(playlistProvider.notifier).removeSongFromPlaylist(id, songs[index].id),
              ).animate().fadeIn(delay: (index * 30).ms),
              childCount: songs.length,
            ),
          ),
          if (songs.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        isLikedSongs ? Icons.favorite_border_rounded : Icons.music_off_rounded,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isLikedSongs ? 'No liked songs yet' : 'This playlist is empty',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
        ],
      ),
    );
  }
}
