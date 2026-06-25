import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song_model_clean.dart';

/// YouTube Music search & streaming service
/// Uses youtube_explode_dart for stream extraction + YTMusic internal API for metadata
class YouTubeMusicService {
  final YoutubeExplode _yt = YoutubeExplode();
  static const _ytMusicBaseUrl = 'https://music.youtube.com/youtubei/v1';
  static const _apiKey = 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-KLET5YdCE';

  static final _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': '*/*',
    'Accept-Language': 'en-US,en;q=0.9',
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': _apiKey,
    'Origin': 'https://music.youtube.com',
    'Referer': 'https://music.youtube.com/',
  };

  static final _ytMusicContext = {
    "client": {
      "clientName": "WEB_REMIX",
      "clientVersion": "1.20240101.01.00",
      "hl": "en",
      "gl": "US",
    }
  };

  // ─── Search ────────────────────────────────────────────────────────────────

  Future<List<SongModel>> search(String query, {String filter = 'songs'}) async {
    try {
      final body = jsonEncode({
        "context": _ytMusicContext,
        "query": query,
        "params": _getSearchParams(filter),
      });

      final response = await http.post(
        Uri.parse('$_ytMusicBaseUrl/search?key=$_apiKey'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseSongs(data);
      }
    } catch (e) {
      // Fallback to youtube_explode_dart
      return _fallbackSearch(query);
    }
    return [];
  }

  String _getSearchParams(String filter) {
    switch (filter) {
      case 'songs':
        return 'EgWKAQIIAWoKEAkQBRAKEAMQBA%3D%3D';
      case 'albums':
        return 'EgWKAQIYAWoKEAkQBRAKEAMQBA%3D%3D';
      case 'artists':
        return 'EgWKAQIgAWoKEAkQBRAKEAMQBA%3D%3D';
      case 'playlists':
        return 'EgeKAQQoAEABagoQCRAFEAoQAxAE';
      case 'videos':
        return 'EgWKAQIQAWoKEAkQBRAKEAMQBA%3D%3D';
      default:
        return 'EgWKAQIIAWoKEAkQBRAKEAMQBA%3D%3D';
    }
  }

  List<SongModel> _parseSongs(Map<String, dynamic> data) {
    final results = <SongModel>[];
    try {
      final contents = data['contents']?['tabbedSearchResultsRenderer']
              ?['tabs']?[0]?['tabRenderer']?['content']
          ?['sectionListRenderer']?['contents'];

      if (contents == null) return [];

      for (final section in contents) {
        final items = section['musicShelfRenderer']?['contents'];
        if (items == null) continue;
        for (final item in items) {
          final renderer = item['musicResponsiveListItemRenderer'];
          if (renderer == null) continue;
          final song = _parseItem(renderer);
          if (song != null) results.add(song);
        }
      }
    } catch (_) {}
    return results;
  }

  SongModel? _parseItem(Map<String, dynamic> renderer) {
    try {
      final flexColumns = renderer['flexColumns'] as List?;
      if (flexColumns == null || flexColumns.isEmpty) return null;

      final titleRuns = flexColumns[0]['musicResponsiveListItemFlexColumnRenderer']
          ['text']['runs'] as List?;
      final title = titleRuns?.first['text'] ?? 'Unknown';

      String artist = 'Unknown Artist';
      String album = '';
      if (flexColumns.length > 1) {
        final runs = flexColumns[1]['musicResponsiveListItemFlexColumnRenderer']
            ?['text']?['runs'] as List?;
        if (runs != null && runs.isNotEmpty) {
          artist = runs.map((r) => r['text']).join('');
        }
      }

      final thumbnails = renderer['thumbnail']?['musicThumbnailRenderer']
          ?['thumbnail']?['thumbnails'] as List?;
      final thumbnail = thumbnails?.last?['url'] ?? '';

      final videoId = renderer['playlistItemData']?['videoId'] ??
          renderer['overlay']?['musicItemThumbnailOverlayRenderer']
              ?['content']?['musicPlayButtonRenderer']?['playNavigationEndpoint']
          ?['watchEndpoint']?['videoId'] ??
          '';

      // Duration
      final fixedColumns = renderer['fixedColumns'] as List?;
      String durationText = '0:00';
      if (fixedColumns != null && fixedColumns.isNotEmpty) {
        durationText = fixedColumns[0]['musicResponsiveListItemFixedColumnRenderer']
                ?['text']?['runs']?[0]?['text'] ??
            '0:00';
      }
      final durationMs = _parseDuration(durationText);

      return SongModel(
        id: videoId,
        title: title,
        artist: artist,
        album: album,
        thumbnailUrl: thumbnail,
        durationMs: durationMs,
        source: 'ytmusic',
        addedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  int _parseDuration(String text) {
    final parts = text.split(':');
    if (parts.length == 2) {
      final min = int.tryParse(parts[0]) ?? 0;
      final sec = int.tryParse(parts[1]) ?? 0;
      return (min * 60 + sec) * 1000;
    }
    if (parts.length == 3) {
      final hr = int.tryParse(parts[0]) ?? 0;
      final min = int.tryParse(parts[1]) ?? 0;
      final sec = int.tryParse(parts[2]) ?? 0;
      return (hr * 3600 + min * 60 + sec) * 1000;
    }
    return 0;
  }

  Future<List<SongModel>> _fallbackSearch(String query) async {
    final results = <SongModel>[];
    try {
      final searchResults = await _yt.search.search(query);
      for (final video in searchResults.take(20)) {
        results.add(SongModel(
          id: video.id.value,
          title: video.title,
          artist: video.author,
          album: '',
          thumbnailUrl: video.thumbnails.highResUrl,
          durationMs: video.duration?.inMilliseconds ?? 0,
          source: 'youtube',
          addedAt: DateTime.now(),
        ));
      }
    } catch (_) {}
    return results;
  }

  // ─── Stream URL ────────────────────────────────────────────────────────────

  Future<String?> getStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      // Prefer audio-only streams for music
      final audioStreams = manifest.audioOnly.sortByBitrate();
      if (audioStreams.isNotEmpty) {
        return audioStreams.last.url.toString(); // highest quality
      }
      // Fallback to muxed
      final muxed = manifest.muxed.sortByVideoQuality();
      if (muxed.isNotEmpty) {
        return muxed.first.url.toString();
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // ─── Home Feed ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getHomeFeed() async {
    try {
      final body = jsonEncode({
        "context": _ytMusicContext,
      });

      final response = await http.post(
        Uri.parse('$_ytMusicBaseUrl/browse?key=$_apiKey'),
        headers: {..._headers, 'browseId': 'FEmusic_home'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseHomeShelf(data);
      }
    } catch (_) {}
    return _getMockHomeFeed();
  }

  List<Map<String, dynamic>> _parseHomeShelf(Map<String, dynamic> data) {
    final shelves = <Map<String, dynamic>>[];
    try {
      final contents = data['contents']?['singleColumnBrowseResultsRenderer']
              ?['tabs']?[0]?['tabRenderer']?['content']
          ?['sectionListRenderer']?['contents'];
      if (contents == null) return _getMockHomeFeed();

      for (final shelf in contents) {
        final musicShelf = shelf['musicCarouselShelfRenderer'] ?? shelf['musicImmersiveCarouselShelfRenderer'];
        if (musicShelf == null) continue;
        final titleRuns = musicShelf['header']?['musicCarouselShelfBasicHeaderRenderer']?['title']?['runs'] as List?;
        final title = titleRuns?.map((r) => r['text']).join('') ?? 'Recommended';
        final items = musicShelf['contents'] as List? ?? [];
        final songs = <SongModel>[];
        for (final item in items) {
          final renderer = item['musicTwoRowItemRenderer'];
          if (renderer == null) continue;
          final titleText = (renderer['title']?['runs'] as List?)?.map((r) => r['text']).join('') ?? '';
          final subtitleText = (renderer['subtitle']?['runs'] as List?)?.map((r) => r['text']).join('') ?? '';
          final thumbnails = renderer['thumbnailRenderer']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails'] as List?;
          final thumbnail = thumbnails?.last?['url'] ?? '';
          final videoId = renderer['navigationEndpoint']?['watchEndpoint']?['videoId'] ?? '';
          if (videoId.isEmpty) continue;
          songs.add(SongModel(
            id: videoId,
            title: titleText,
            artist: subtitleText,
            album: '',
            thumbnailUrl: thumbnail,
            durationMs: 0,
            source: 'ytmusic',
          ));
        }
        if (songs.isNotEmpty) {
          shelves.add({'title': title, 'songs': songs});
        }
      }
    } catch (_) {}
    return shelves.isEmpty ? _getMockHomeFeed() : shelves;
  }

  List<Map<String, dynamic>> _getMockHomeFeed() => [
        {
          'title': 'Trending Now',
          'songs': [
            SongModel(id: 'dQw4w9WgXcQ', title: 'Never Gonna Give You Up', artist: 'Rick Astley', album: 'Whenever You Need Somebody', thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg', durationMs: 213000, source: 'youtube'),
            SongModel(id: 'kXYiU_JCYtU', title: 'Numb', artist: 'Linkin Park', album: 'Meteora', thumbnailUrl: 'https://img.youtube.com/vi/kXYiU_JCYtU/maxresdefault.jpg', durationMs: 187000, source: 'youtube'),
          ],
        },
        {
          'title': 'Recently Added',
          'songs': [
            SongModel(id: 'hT_nvWreIhg', title: 'Counting Stars', artist: 'OneRepublic', album: 'Native', thumbnailUrl: 'https://img.youtube.com/vi/hT_nvWreIhg/maxresdefault.jpg', durationMs: 257000, source: 'youtube'),
          ],
        },
      ];

  // ─── Charts ─────────────────────────────────────────────────────────────── 

  Future<List<SongModel>> getCharts({String countryCode = 'US'}) async {
    try {
      final response = await http.post(
        Uri.parse('$_ytMusicBaseUrl/browse?key=$_apiKey'),
        headers: _headers,
        body: jsonEncode({
          "context": _ytMusicContext,
          "browseId": "FEmusic_charts",
          "formData": {"selectedValues": ["$countryCode"]}
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseSongs(data);
      }
    } catch (_) {}
    return [];
  }

  // ─── Lyrics ────────────────────────────────────────────────────────────────

  Future<String?> getLyrics(String videoId) async {
    try {
      // Get browse ID from video
      final watchResponse = await http.post(
        Uri.parse('$_ytMusicBaseUrl/next?key=$_apiKey'),
        headers: _headers,
        body: jsonEncode({
          "context": _ytMusicContext,
          "videoId": videoId,
          "isAudioOnly": true,
        }),
      );

      if (watchResponse.statusCode == 200) {
        final watchData = jsonDecode(watchResponse.body);
        final tabs = watchData['contents']?['singleColumnMusicWatchNextResultsRenderer']
                ?['tabbedRenderer']?['watchNextTabbedResultsRenderer']?['tabs'] as List?;
        if (tabs == null) return null;
        
        for (final tab in tabs) {
          final endpoint = tab['tabRenderer']?['endpoint']?['browseEndpoint'];
          if (endpoint?['browseEndpointContextSupportedConfigs']?
              ['browseEndpointContextMusicConfig']?['pageType'] == 'MUSIC_PAGE_TYPE_TRACK_LYRICS') {
            final lyricsId = endpoint['browseId'];
            // Fetch lyrics
            final lyricsResponse = await http.post(
              Uri.parse('$_ytMusicBaseUrl/browse?key=$_apiKey'),
              headers: _headers,
              body: jsonEncode({
                "context": _ytMusicContext,
                "browseId": lyricsId,
              }),
            );
            if (lyricsResponse.statusCode == 200) {
              final lyricsData = jsonDecode(lyricsResponse.body);
              final lyricsText = lyricsData['contents']?['sectionListRenderer']
                  ?['contents']?[0]?['musicDescriptionShelfRenderer']?['description']?['runs']?[0]?['text'];
              return lyricsText;
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  // ─── Related Songs ─────────────────────────────────────────────────────────

  Future<List<SongModel>> getRelated(String videoId) async {
    try {
      final response = await http.post(
        Uri.parse('$_ytMusicBaseUrl/next?key=$_apiKey'),
        headers: _headers,
        body: jsonEncode({
          "context": _ytMusicContext,
          "videoId": videoId,
          "isAudioOnly": true,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseSongs(data);
      }
    } catch (_) {}
    return [];
  }

  void dispose() => _yt.close();
}
