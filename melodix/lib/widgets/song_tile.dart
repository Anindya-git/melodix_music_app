import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song_model_clean.dart';
import '../theme/app_theme.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final bool showRemove;
  final VoidCallback? onRemove;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.showRemove = false,
    this.onRemove,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: song.thumbnailUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: song.thumbnailUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          if (isPlaying)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.equalizer_rounded, color: AppColors.primary, size: 22),
              ),
            ),
          if (song.isDownloaded)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.download_done_rounded, color: Colors.black, size: 8),
              ),
            ),
        ],
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isPlaying ? AppColors.primary : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist}${song.album.isNotEmpty ? ' · ${song.album}' : ''}',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(song.durationFormatted, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(width: 4),
          if (showRemove && onRemove != null)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.textSecondary, size: 20),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _placeholder() => Container(
        width: 50,
        height: 50,
        color: AppColors.darkCard,
        child: const Icon(Icons.music_note_rounded, color: AppColors.primary, size: 24),
      );
}
