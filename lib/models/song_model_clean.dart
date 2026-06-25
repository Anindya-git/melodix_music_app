import 'package:hive/hive.dart';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String thumbnailUrl;
  final String? streamUrl;
  final int durationMs;
  final String? localPath;
  final bool isDownloaded;
  final bool isLiked;
  final String? lyrics;
  final String source;
  final Map<String, dynamic>? extra;
  final DateTime? addedAt;
  final int playCount;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.thumbnailUrl,
    this.streamUrl,
    required this.durationMs,
    this.localPath,
    this.isDownloaded = false,
    this.isLiked = false,
    this.lyrics,
    this.source = 'youtube',
    this.extra,
    this.addedAt,
    this.playCount = 0,
  });

  String get durationFormatted {
    final minutes = (durationMs / 60000).floor();
    final seconds = ((durationMs % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? thumbnailUrl,
    String? streamUrl,
    int? durationMs,
    String? localPath,
    bool? isDownloaded,
    bool? isLiked,
    String? lyrics,
    String? source,
    Map<String, dynamic>? extra,
    DateTime? addedAt,
    int? playCount,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      durationMs: durationMs ?? this.durationMs,
      localPath: localPath ?? this.localPath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isLiked: isLiked ?? this.isLiked,
      lyrics: lyrics ?? this.lyrics,
      source: source ?? this.source,
      extra: extra ?? this.extra,
      addedAt: addedAt ?? this.addedAt,
      playCount: playCount ?? this.playCount,
    );
  }

  factory SongModel.fromMap(Map<String, dynamic> data) {
    return SongModel(
      id: data['videoId'] ?? data['id'] ?? '',
      title: data['title'] ?? 'Unknown',
      artist: data['artist'] ?? data['author'] ?? 'Unknown Artist',
      album: data['album'] ?? '',
      thumbnailUrl: data['thumbnail'] ?? data['thumbnailUrl'] ?? '',
      durationMs: data['duration'] ?? 0,
      streamUrl: data['streamUrl'],
      localPath: data['localPath'],
      isDownloaded: data['isDownloaded'] ?? false,
      isLiked: data['isLiked'] ?? false,
      lyrics: data['lyrics'],
      source: data['source'] ?? 'youtube',
      extra: data['extra'],
      addedAt: data['addedAt'] != null ? DateTime.tryParse(data['addedAt']) : null,
      playCount: data['playCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'thumbnailUrl': thumbnailUrl,
        'streamUrl': streamUrl,
        'durationMs': durationMs,
        'localPath': localPath,
        'isDownloaded': isDownloaded,
        'isLiked': isLiked,
        'lyrics': lyrics,
        'source': source,
        'extra': extra,
        'addedAt': addedAt?.toIso8601String(),
        'playCount': playCount,
      };
}

class SongModelAdapter extends TypeAdapter<SongModel> {
  @override
  final int typeId = 0;

  @override
  SongModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongModel(
      id: fields[0] as String? ?? '',
      title: fields[1] as String? ?? '',
      artist: fields[2] as String? ?? '',
      album: fields[3] as String? ?? '',
      thumbnailUrl: fields[4] as String? ?? '',
      streamUrl: fields[5] as String?,
      durationMs: fields[6] as int? ?? 0,
      localPath: fields[7] as String?,
      isDownloaded: fields[8] as bool? ?? false,
      isLiked: fields[9] as bool? ?? false,
      lyrics: fields[10] as String?,
      source: fields[11] as String? ?? 'youtube',
      extra: (fields[12] as Map?)?.cast<String, dynamic>(),
      addedAt: fields[13] != null ? DateTime.tryParse(fields[13].toString()) : null,
      playCount: fields[14] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, SongModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.artist)
      ..writeByte(3)..write(obj.album)
      ..writeByte(4)..write(obj.thumbnailUrl)
      ..writeByte(5)..write(obj.streamUrl)
      ..writeByte(6)..write(obj.durationMs)
      ..writeByte(7)..write(obj.localPath)
      ..writeByte(8)..write(obj.isDownloaded)
      ..writeByte(9)..write(obj.isLiked)
      ..writeByte(10)..write(obj.lyrics)
      ..writeByte(11)..write(obj.source)
      ..writeByte(12)..write(obj.extra)
      ..writeByte(13)..write(obj.addedAt?.toIso8601String())
      ..writeByte(14)..write(obj.playCount);
  }
}
