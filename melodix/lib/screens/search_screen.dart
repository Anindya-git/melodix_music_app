import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/search_provider.dart';
import '../providers/audio_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';
import 'dart:async';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  final _filters = ['songs', 'albums', 'artists', 'playlists', 'videos'];

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final filter = ref.watch(searchFilterProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: false,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search songs, artists, albums...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                                onPressed: () {
                                  _controller.clear();
                                  ref.read(searchQueryProvider.notifier).state = '';
                                },
                              )
                            : null,
                      ),
                      onChanged: _onSearchChanged,
                      onSubmitted: (v) => ref.read(searchQueryProvider.notifier).state = v,
                    ),
                  ),
                ],
              ),
            ),

            // Filter chips
            if (query.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final f = _filters[index];
                    final selected = filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f[0].toUpperCase() + f.substring(1)),
                        selected: selected,
                        onSelected: (_) => ref.read(searchFilterProvider.notifier).state = f,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.darkCard,
                        labelStyle: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        checkmarkColor: Colors.black,
                        side: BorderSide.none,
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(duration: 300.ms),

            // Results
            Expanded(
              child: query.isEmpty
                  ? _BrowseCategories()
                  : results.when(
                      data: (songs) {
                        if (songs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondary),
                                const SizedBox(height: 16),
                                Text('No results for "$query"', style: const TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 140),
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            return SongTile(
                              song: song,
                              onTap: () {
                                ref.read(audioServiceProvider).playSong(song, songQueue: songs, startIndex: index);
                                context.push('/player');
                              },
                            ).animate().fadeIn(delay: (index * 30).ms);
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      error: (_, __) => const Center(child: Text('Search failed', style: TextStyle(color: AppColors.textSecondary))),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrowseCategories extends StatelessWidget {
  final _categories = [
    {'label': 'Pop', 'color': const Color(0xFF4158D0), 'icon': Icons.music_note_rounded},
    {'label': 'Hip-Hop', 'color': const Color(0xFFC850C0), 'icon': Icons.headphones_rounded},
    {'label': 'Rock', 'color': const Color(0xFFE74C3C), 'icon': Icons.electric_bolt_rounded},
    {'label': 'Electronic', 'color': const Color(0xFF00B09B), 'icon': Icons.graphic_eq_rounded},
    {'label': 'Jazz', 'color': const Color(0xFFf7971e), 'icon': Icons.piano_rounded},
    {'label': 'Classical', 'color': const Color(0xFF8E2DE2), 'icon': Icons.queue_music_rounded},
    {'label': 'R&B', 'color': const Color(0xFF1DB954), 'icon': Icons.favorite_rounded},
    {'label': 'Country', 'color': const Color(0xFFf093fb), 'icon': Icons.nature_rounded},
    {'label': 'Metal', 'color': const Color(0xFF2C3E50), 'icon': Icons.bolt_rounded},
    {'label': 'Latin', 'color': const Color(0xFFFF6B6B), 'icon': Icons.celebration_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text('Browse Categories', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final cat = _categories[index];
                return GestureDetector(
                  onTap: () {
                    // Could trigger search for this genre
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: cat['color'] as Color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(cat['icon'] as IconData, color: Colors.white, size: 28),
                        const Spacer(),
                        Text(cat['label'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 40).ms).scale(begin: const Offset(0.9, 0.9));
              },
              childCount: _categories.length,
            ),
          ),
        ),
      ],
    );
  }
}
