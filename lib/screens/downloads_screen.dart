import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/download_service.dart';
import '../services/audio_player_service.dart';
import '../providers/audio_provider.dart';
import '../models/song_model_clean.dart';
import '../theme/app_theme.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  final _downloadService = DownloadService();
  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final files = await _downloadService.getDownloadedFiles();
    if (mounted) setState(() => _files = files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadFiles,
          ),
        ],
      ),
      body: _files.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download_rounded, size: 80, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('No downloads yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Songs you download will appear here', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/search'),
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Find Music'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 140),
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                final name = file.path.split('/').last.replaceAll('.mp3', '');
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.music_note_rounded, color: AppColors.primary),
                  ),
                  title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(_formatSize(file.lengthSync()), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary),
                    onPressed: () async {
                      await file.delete();
                      _loadFiles();
                    },
                  ),
                  onTap: () {
                    final song = SongModel(
                      id: file.path.hashCode.toString(),
                      title: name,
                      artist: 'Local',
                      album: 'Downloads',
                      thumbnailUrl: '',
                      localPath: file.path,
                      durationMs: 0,
                      source: 'local',
                    );
                    ref.read(audioServiceProvider).playSong(song);
                    context.push('/player');
                  },
                );
              },
            ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  void dispose() {
    _downloadService.dispose();
    super.dispose();
  }
}
