import 'package:hive/hive.dart';
import 'song_model_clean.dart';

class PlaylistModel {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final List<SongModel> songs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final String? color;

  PlaylistModel({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.songs,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.color,
  });

  int get totalDurationMs => songs.fold(0, (sum, s) => sum + s.durationMs);

  String get totalDurationFormatted {
    final totalSeconds = totalDurationMs ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    List<SongModel>? songs,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    String? color,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'coverUrl': coverUrl,
        'songs': songs.map((s) => s.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isPublic': isPublic,
        'color': color,
      };

  factory PlaylistModel.fromMap(Map<String, dynamic> data) {
    return PlaylistModel(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Unnamed Playlist',
      description: data['description'],
      coverUrl: data['coverUrl'],
      songs: (data['songs'] as List<dynamic>?)
              ?.map((s) => SongModel.fromMap(Map<String, dynamic>.from(s)))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
      isPublic: data['isPublic'] ?? false,
      color: data['color'],
    );
  }
}

class PlaylistModelAdapter extends TypeAdapter<PlaylistModel> {
  @override
  final int typeId = 1;

  @override
  PlaylistModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final songAdapter = SongModelAdapter();
    return PlaylistModel(
      id: fields[0] as String? ?? '',
      name: fields[1] as String? ?? '',
      description: fields[2] as String?,
      coverUrl: fields[3] as String?,
      songs: (fields[4] as List?)?.cast<dynamic>().map((e) => songAdapter.read(e as BinaryReader)).toList() ?? [],
      createdAt: DateTime.tryParse(fields[5]?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(fields[6]?.toString() ?? '') ?? DateTime.now(),
      isPublic: fields[7] as bool? ?? false,
      color: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlaylistModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.description)
      ..writeByte(3)..write(obj.coverUrl)
      ..writeByte(4)..write(obj.songs.map((s) => s.toMap()).toList())
      ..writeByte(5)..write(obj.createdAt.toIso8601String())
      ..writeByte(6)..write(obj.updatedAt.toIso8601String())
      ..writeByte(7)..write(obj.isPublic)
      ..writeByte(8)..write(obj.color);
  }
}
