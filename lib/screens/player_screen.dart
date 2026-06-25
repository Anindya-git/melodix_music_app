import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../models/song_model_clean.dart';
import '../theme/app_theme.dart';
import '../services/download_service.dart';
import '../services/youtube_music_service.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  Color _bgColor = AppColors.darkBg;
  Color _accentColor = AppColors.primary;
  String? _lastThumbnail;
  bool _showLyrics = false;
  String? _lyrics;
  final _ytService = YouTubeMusicService();
  final _downloadService = DownloadService();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _ytService.dispose();
    _downloadService.dispose();
    super.dispose();
  }

  Future<void> _updatePalette(String imageUrl) async {
    if (_lastThumbnail == imageUrl) return;
    _lastThumbnail = imageUrl;
    try {
      final provider = NetworkImage(imageUrl);
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        size: const Size(100, 100),
      );
      if (mounted) {
        setState(() {
          _bgColor = palette.darkVibrantColor?.color ??
              palette.dominantColor?.color ??
              AppColors.darkBg;
          _accentColor = palette.vibrantColor?.color ??
              palette.lightVibrantColor?.color ??
              AppColors.primary;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadLyrics(String songId) async {
    final lyrics = await _ytService.getLyrics(songId);
    if (mounted) setState(() => _lyrics = lyrics ?? 'No lyrics available for this song.');
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(currentSongProvider);
    final playbackState = ref.watch(playbackStateProvider);
    final positionData = ref.watch(positionDataProvider);
    final audioService = ref.read(audioServiceProvider);

    return currentSong.when(
      data: (song) {
        if (song != null) {
          _updatePalette(song.thumbnailUrl);
          final isPlaying = playbackState.value?.playing ?? false;
          if (isPlaying) {
            _rotationController.repeat();
          } else {
            _rotationController.stop();
          }
        }

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _bgColor,
                  _bgColor.withOpacity(0.6),
                  AppColors.darkBg,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, song),
                  Expanded(
                    child: _showLyrics
                        ? _buildLyricsView()
                        : _buildAlbumArt(song, playbackState.value?.playing ?? false),
                  ),
                  _buildSongInfo(context, ref, song),
                  _buildProgressBar(positionData, audioService),
                  _buildControls(playbackState, audioService, song),
                  _buildBottomBar(context, song, audioService),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))),
      error: (_, __) => const Scaffold(body: Center(child: Text('Error loading player'))),
    );
  }

  Widget _buildHeader(BuildContext context, SongModel? song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text('NOW PLAYING', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                Text(song?.album.isNotEmpty == true ? song!.album : 'Melodix Player',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            color: AppColors.darkCard,
            onSelected: (value) => _handleMenuAction(value, song),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'add_playlist', child: Text('Add to Playlist', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'download', child: Text('Download', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'share', child: Text('Share', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'goto_artist', child: Text('Go to Artist', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'sleep_timer', child: Text('Sleep Timer', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'equalizer', child: Text('Equalizer', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(SongModel? song, bool isPlaying) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: AnimatedScale(
        scale: isPlaying ? 1.0 : 0.88,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.14159,
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: song != null
                  ? CachedNetworkImage(
                      imageUrl: song.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.darkCard,
                        child: const Icon(Icons.music_note_rounded, size: 80, color: AppColors.primary),
                      ),
                    )
                  : Container(
                      color: AppColors.darkCard,
                      child: const Icon(Icons.music_note_rounded, size: 80, color: AppColors.primary),
                    ),
            ),
          ),
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildLyricsView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Text(
          _lyrics ?? 'Loading lyrics...',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.8,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, WidgetRef ref, SongModel? song) {
    final isLiked = song != null ? ref.watch(likedSongsProvider.notifier).isLiked(song.id) : false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song?.title ?? 'No song playing',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  song?.artist ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (song != null)
            GestureDetector(
              onTap: () => ref.read(likedSongsProvider.notifier).toggleLike(song),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  key: ValueKey(isLiked),
                  color: isLiked ? AppColors.accent : Colors.white,
                  size: 28,
                ).animate(target: isLiked ? 1.0 : 0.0).scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(AsyncValue<PositionData> positionData, dynamic audioService) {
    return positionData.when(
      data: (pos) {
        final duration = pos.duration?.inMilliseconds ?? 0;
        final position = pos.position.inMilliseconds;
        final progress = duration > 0 ? (position / duration).clamp(0.0, 1.0) : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withOpacity(0.1),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                ),
                child: Slider(
                  value: progress,
                  onChanged: (value) {
                    final seekMs = (value * duration).round();
                    audioService.seek(Duration(milliseconds: seekMs));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(pos.position), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                    Text(pos.duration != null ? _formatDuration(pos.duration!) : '--:--',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildControls(AsyncValue<PlaybackState> playbackState, dynamic audioService, SongModel? song) {
    final isPlaying = playbackState.value?.playing ?? false;
    final loopMode = audioService.loopMode;
    final isShuffle = audioService.isShuffle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Shuffle
          IconButton(
            icon: Icon(
              Icons.shuffle_rounded,
              color: isShuffle ? _accentColor : Colors.white.withOpacity(0.6),
              size: 24,
            ),
            onPressed: () => audioService.toggleShuffle(),
          ),
          // Previous
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 36),
            onPressed: () => audioService.skipToPrevious(),
          ),
          // Play/Pause
          GestureDetector(
            onTap: () => isPlaying ? audioService.pause() : audioService.play(),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.black,
                size: 36,
              ),
            ),
          ).animate(target: isPlaying ? 1.0 : 0.0).scale(begin: const Offset(1, 1), end: const Offset(0.95, 0.95)),
          // Next
          IconButton(
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 36),
            onPressed: () => audioService.skipToNext(),
          ),
          // Loop
          IconButton(
            icon: Icon(
              loopMode == LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
              color: loopMode == LoopMode.off ? Colors.white.withOpacity(0.6) : _accentColor,
              size: 24,
            ),
            onPressed: () => audioService.cycleLoopMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, SongModel? song, dynamic audioService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Device/Cast
          IconButton(
            icon: Icon(Icons.devices_rounded, color: Colors.white.withOpacity(0.6), size: 22),
            onPressed: () {},
          ),
          // Lyrics toggle
          IconButton(
            icon: Icon(
              Icons.lyrics_rounded,
              color: _showLyrics ? _accentColor : Colors.white.withOpacity(0.6),
              size: 22,
            ),
            onPressed: () {
              setState(() => _showLyrics = !_showLyrics);
              if (_showLyrics && song != null && _lyrics == null) {
                _loadLyrics(song.id);
              }
            },
          ),
          // Queue
          IconButton(
            icon: Icon(Icons.queue_music_rounded, color: Colors.white.withOpacity(0.6), size: 22),
            onPressed: () => _showQueueSheet(context, audioService),
          ),
          // Speed
          IconButton(
            icon: Icon(Icons.speed_rounded, color: Colors.white.withOpacity(0.6), size: 22),
            onPressed: () => _showSpeedSheet(context, audioService),
          ),
          // Equalizer
          IconButton(
            icon: Icon(Icons.equalizer_rounded, color: Colors.white.withOpacity(0.6), size: 22),
            onPressed: () => context.push('/equalizer'),
          ),
        ],
      ),
    );
  }

  void _showQueueSheet(BuildContext context, dynamic audioService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _QueueSheet(audioService: audioService),
    );
  }

  void _showSpeedSheet(BuildContext context, dynamic audioService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SpeedSheet(audioService: audioService),
    );
  }

  void _handleMenuAction(String action, SongModel? song) {
    if (song == null) return;
    switch (action) {
      case 'download':
        _downloadService.downloadSong(song);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download started...'), backgroundColor: AppColors.primary),
        );
        break;
      case 'equalizer':
        context.push('/equalizer');
        break;
      case 'sleep_timer':
        _showSleepTimerDialog(context);
        break;
    }
  }

  void _showSleepTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Sleep Timer', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final minutes in [15, 30, 45, 60])
              ListTile(
                title: Text('$minutes minutes', style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sleep timer
                  Future.delayed(Duration(minutes: minutes), () {
                    ref.read(audioServiceProvider).pause();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sleep timer set for $minutes minutes'), backgroundColor: AppColors.primary),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _QueueSheet extends ConsumerWidget {
  final dynamic audioService;
  const _QueueSheet({required this.audioService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = audioService.queue as List;
    final currentIndex = audioService.currentIndex as int;

    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.textSecondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('Queue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${queue.length} songs', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: queue.length,
            onReorder: (oldIndex, newIndex) => audioService.reorderQueue(oldIndex, newIndex),
            itemBuilder: (context, index) {
              final song = queue[index];
              return ListTile(
                key: ValueKey(song.id + index.toString()),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(imageUrl: song.thumbnailUrl, width: 40, height: 40, fit: BoxFit.cover),
                ),
                title: Text(song.title,
                    style: TextStyle(
                      color: index == currentIndex ? AppColors.primary : Colors.white,
                      fontSize: 14,
                      fontWeight: index == currentIndex ? FontWeight.w700 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(song.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                trailing: index == currentIndex
                    ? const Icon(Icons.equalizer_rounded, color: AppColors.primary)
                    : ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle_rounded, color: AppColors.textSecondary),
                      ),
                onTap: () {
                  audioService.skipToIndex(index);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SpeedSheet extends StatefulWidget {
  final dynamic audioService;
  const _SpeedSheet({required this.audioService});

  @override
  State<_SpeedSheet> createState() => _SpeedSheetState();
}

class _SpeedSheetState extends State<_SpeedSheet> {
  double _speed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(2)),
          ),
          const Text('Playback Speed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Text('${_speed.toStringAsFixed(2)}x', style: const TextStyle(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.w900)),
          Slider(
            value: _speed,
            min: 0.25,
            max: 3.0,
            divisions: 44,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.darkElevated,
            onChanged: (v) {
              setState(() => _speed = v);
              widget.audioService.setSpeed(v);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
              return GestureDetector(
                onTap: () {
                  setState(() => _speed = speed);
                  widget.audioService.setSpeed(speed);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _speed == speed ? AppColors.primary : AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${speed}x',
                    style: TextStyle(
                      color: _speed == speed ? Colors.black : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
