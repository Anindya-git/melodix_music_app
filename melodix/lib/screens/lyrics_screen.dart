import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../providers/search_provider.dart';
import '../theme/app_theme.dart';
import '../services/youtube_music_service.dart';

class LyricsScreen extends ConsumerStatefulWidget {
  const LyricsScreen({super.key});

  @override
  ConsumerState<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends ConsumerState<LyricsScreen> {
  String? _lyrics;
  bool _loading = true;
  final _ytService = YouTubeMusicService();

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  Future<void> _loadLyrics() async {
    final song = ref.read(currentSongProvider).value;
    if (song == null) {
      setState(() { _lyrics = 'No song playing.'; _loading = false; });
      return;
    }
    final lyrics = await _ytService.getLyrics(song.id);
    if (mounted) {
      setState(() {
        _lyrics = lyrics ?? 'Lyrics not available for this song.';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _ytService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(currentSongProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lyrics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() { _loading = true; _lyrics = null; });
              _loadLyrics();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (song != null) ...[
                    Text(song.title,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(song.artist,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.darkSurface),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    _lyrics ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
