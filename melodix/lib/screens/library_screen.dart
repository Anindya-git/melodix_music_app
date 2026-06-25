import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../theme/app_theme.dart';
import '../models/playlist_model.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistProvider);
    final likedSongs = ref.watch(likedSongsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Your Library'),
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                onPressed: () => context.go('/search'),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                onPressed: () => _showCreatePlaylistDialog(context, ref),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Liked Songs
                  _LibraryItem(
                    title: 'Liked Songs',
                    subtitle: '${likedSongs.length} songs',
                    color: const Color(0xFF9B59B6),
                    icon: Icons.favorite_rounded,
                    onTap: () => context.push('/playlist/liked'),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 8),

                  // Downloads
                  _LibraryItem(
                    title: 'Downloaded Music',
                    subtitle: 'Available offline',
                    color: const Color(0xFF3498DB),
                    icon: Icons.download_done_rounded,
                    onTap: () => context.go('/downloads'),
                  ).animate().fadeIn(duration: 300.ms, delay: 60.ms),

                  const SizedBox(height: 24),
                  const Text('Playlists', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Playlists
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final playlist = playlists[index];
                return _PlaylistTile(
                  playlist: playlist,
                  onTap: () => context.push('/playlist/${playlist.id}'),
                  onDelete: () => ref.read(playlistProvider.notifier).deletePlaylist(playlist.id),
                ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.1);
              },
              childCount: playlists.length,
            ),
          ),

          if (playlists.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.library_music_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      const Text('No playlists yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text('Create one to organize your music', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showCreatePlaylistDialog(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Playlist'),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('New Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(playlistProvider.notifier).createPlaylist(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _LibraryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _LibraryItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PlaylistTile({required this.playlist, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: playlist.color != null ? Color(int.parse(playlist.color!)) : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.queue_music_rounded, color: Colors.white),
      ),
      title: Text(playlist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text('${playlist.songs.length} songs · ${playlist.totalDurationFormatted}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
        color: AppColors.darkCard,
        onSelected: (v) {
          if (v == 'delete') onDelete();
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
      onTap: onTap,
    );
  }
}
