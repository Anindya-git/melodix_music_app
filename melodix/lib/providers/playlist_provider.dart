import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/playlist_model.dart';
import '../models/song_model_clean.dart';

final playlistProvider = StateNotifierProvider<PlaylistNotifier, List<PlaylistModel>>((ref) {
  return PlaylistNotifier();
});

final likedSongsProvider = StateNotifierProvider<LikedSongsNotifier, List<SongModel>>((ref) {
  return LikedSongsNotifier();
});

class PlaylistNotifier extends StateNotifier<List<PlaylistModel>> {
  final _box = Hive.box('playlists');
  final _uuid = const Uuid();

  PlaylistNotifier() : super([]) {
    _load();
  }

  void _load() {
    final raw = _box.get('all', defaultValue: '[]');
    final List<dynamic> list = jsonDecode(raw);
    state = list.map((e) => PlaylistModel.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> _save() async {
    await _box.put('all', jsonEncode(state.map((p) => p.toMap()).toList()));
  }

  Future<PlaylistModel> createPlaylist(String name, {String? description}) async {
    final playlist = PlaylistModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [...state, playlist];
    await _save();
    return playlist;
  }

  Future<void> deletePlaylist(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _save();
  }

  Future<void> addSongToPlaylist(String playlistId, SongModel song) async {
    state = state.map((p) {
      if (p.id == playlistId) {
        if (p.songs.any((s) => s.id == song.id)) return p;
        return p.copyWith(
          songs: [...p.songs, song],
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _save();
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    state = state.map((p) {
      if (p.id == playlistId) {
        return p.copyWith(
          songs: p.songs.where((s) => s.id != songId).toList(),
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _save();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    state = state.map((p) {
      if (p.id == id) {
        return p.copyWith(name: newName, updatedAt: DateTime.now());
      }
      return p;
    }).toList();
    await _save();
  }

  PlaylistModel? getPlaylist(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

class LikedSongsNotifier extends StateNotifier<List<SongModel>> {
  final _box = Hive.box('liked_songs');

  LikedSongsNotifier() : super([]) {
    _load();
  }

  void _load() {
    final raw = _box.get('songs', defaultValue: '[]');
    final List<dynamic> list = jsonDecode(raw);
    state = list.map((e) => SongModel.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> _save() async {
    await _box.put('songs', jsonEncode(state.map((s) => s.toMap()).toList()));
  }

  bool isLiked(String songId) => state.any((s) => s.id == songId);

  Future<void> toggleLike(SongModel song) async {
    if (isLiked(song.id)) {
      state = state.where((s) => s.id != song.id).toList();
    } else {
      state = [song.copyWith(isLiked: true), ...state];
    }
    await _save();
  }
}
