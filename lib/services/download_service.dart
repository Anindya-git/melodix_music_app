import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song_model_clean.dart';
import 'youtube_music_service.dart';

class DownloadProgress {
  final String songId;
  final double progress; // 0.0 to 1.0
  final DownloadStatus status;
  final String? error;
  final String? localPath;

  DownloadProgress({
    required this.songId,
    required this.progress,
    required this.status,
    this.error,
    this.localPath,
  });
}

enum DownloadStatus { queued, downloading, completed, failed, cancelled }

class DownloadService {
  final _ytService = YouTubeMusicService();
  final _dio = Dio();
  final _progressMap = <String, BehaviorSubject<DownloadProgress>>{};
  final _activeDownloads = <String, CancelToken>{};

  Stream<DownloadProgress> getProgressStream(String songId) {
    _progressMap.putIfAbsent(
      songId,
      () => BehaviorSubject<DownloadProgress>.seeded(
        DownloadProgress(songId: songId, progress: 0, status: DownloadStatus.queued),
      ),
    );
    return _progressMap[songId]!.stream;
  }

  Future<String?> downloadSong(SongModel song) async {
    final cancelToken = CancelToken();
    _activeDownloads[song.id] = cancelToken;

    _updateProgress(song.id, 0, DownloadStatus.downloading);

    try {
      // Get download directory
      final dir = await _getDownloadDir();
      final safeTitle = song.title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final filePath = '$dir/$safeTitle-${song.id}.mp3';

      // Check if already downloaded
      if (await File(filePath).exists()) {
        _updateProgress(song.id, 1.0, DownloadStatus.completed, localPath: filePath);
        return filePath;
      }

      // Get stream URL
      final streamUrl = await _ytService.getStreamUrl(song.id);
      if (streamUrl == null) {
        _updateProgress(song.id, 0, DownloadStatus.failed, error: 'Could not get stream URL');
        return null;
      }

      // Download file
      await _dio.download(
        streamUrl,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            _updateProgress(song.id, progress, DownloadStatus.downloading, localPath: filePath);
          }
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0',
          },
          receiveTimeout: const Duration(minutes: 10),
        ),
      );

      _updateProgress(song.id, 1.0, DownloadStatus.completed, localPath: filePath);
      return filePath;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _updateProgress(song.id, 0, DownloadStatus.cancelled);
      } else {
        _updateProgress(song.id, 0, DownloadStatus.failed, error: e.message);
      }
      return null;
    } finally {
      _activeDownloads.remove(song.id);
    }
  }

  void cancelDownload(String songId) {
    _activeDownloads[songId]?.cancel();
  }

  Future<String> _getDownloadDir() async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Music/Melodix');
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  void _updateProgress(
    String songId,
    double progress,
    DownloadStatus status, {
    String? error,
    String? localPath,
  }) {
    _progressMap[songId]?.add(DownloadProgress(
      songId: songId,
      progress: progress,
      status: status,
      error: error,
      localPath: localPath,
    ));
  }

  Future<bool> isDownloaded(String songId) async {
    final dir = await _getDownloadDir();
    final files = Directory(dir).listSync();
    return files.any((f) => f.path.contains(songId));
  }

  Future<List<File>> getDownloadedFiles() async {
    final dir = await _getDownloadDir();
    final directory = Directory(dir);
    if (!await directory.exists()) return [];
    return directory.listSync().whereType<File>().toList();
  }

  Future<void> deleteDownload(String songId) async {
    final dir = await _getDownloadDir();
    final files = Directory(dir).listSync();
    for (final file in files) {
      if (file.path.contains(songId)) {
        await file.delete();
      }
    }
  }

  void dispose() {
    for (final subject in _progressMap.values) {
      subject.close();
    }
    _ytService.dispose();
  }
}
