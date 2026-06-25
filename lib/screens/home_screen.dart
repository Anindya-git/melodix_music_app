import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/search_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../models/song_model_clean.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';
import '../widgets/song_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeFeed = ref.watch(homeFeedProvider);
    final likedSongs = ref.watch(likedSongsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            snap: true,
            backgroundColor: AppColors.darkBg,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Melodix',
                style: TextStyle(
                  fontFamily: 'Circular',
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.go('/settings'),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Quick Access Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _QuickAccessGrid(likedSongs: likedSongs),
                  const SizedBox(height: 24),
                  // Greeting
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.displayMedium,
                  ).animate().fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),

          // Home Feed
          homeFeed.when(
            data: (shelves) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final shelf = shelves[index];
                  return _MusicShelf(
                    title: shelf['title'] as String,
                    songs: shelf['songs'] as List<SongModel>,
                  );
                },
                childCount: shelves.length,
              ),
            ),
            loading: () => SliverToBoxAdapter(child: _ShimmerShelf()),
            error: (err, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text('Could not load feed. Check your connection.',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 🌅';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }
}

class _QuickAccessGrid extends ConsumerWidget {
  final List<SongModel> likedSongs;
  const _QuickAccessGrid({required this.likedSongs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 4.5,
      children: [
        _QuickTile(
          icon: Icons.favorite_rounded,
          color: const Color(0xFF9B59B6),
          label: 'Liked Songs',
          onTap: () => context.push('/playlist/liked'),
        ),
        _QuickTile(
          icon: Icons.download_rounded,
          color: const Color(0xFF3498DB),
          label: 'Downloads',
          onTap: () => context.go('/downloads'),
        ),
        _QuickTile(
          icon: Icons.history_rounded,
          color: const Color(0xFFE74C3C),
          label: 'Recent',
          onTap: () {},
        ),
        _QuickTile(
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF1ABC9C),
          label: 'Charts',
          onTap: () => context.go('/search'),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicShelf extends ConsumerWidget {
  final String title;
  final List<SongModel> songs;

  const _MusicShelf({required this.title, required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () {},
                child: const Text('See all', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongCard(
                song: song,
                onTap: () {
                  ref.read(audioServiceProvider).playSong(song, songQueue: songs, startIndex: index);
                  context.push('/player');
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ShimmerShelf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.darkCard,
      highlightColor: AppColors.darkElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < 2; i++) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Container(height: 20, width: 140, color: Colors.white, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4))),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 5,
                itemBuilder: (_, __) => Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
