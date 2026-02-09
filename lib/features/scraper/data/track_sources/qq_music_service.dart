import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/scraper/domain/scrape_result.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';
import 'package:jmusic/core/utils/scraper_utils.dart';

final qqMusicServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  return QQMusicService(proxySettings);
});

class QQMusicService {
  late final Dio _dio;
  final ProxySettings proxySettings;

  QQMusicService(this.proxySettings) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://u.y.qq.com',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.9',
        'referer': 'https://y.qq.com/',
        'origin': 'https://y.qq.com',
      },
    ));

    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      client.idleTimeout = const Duration(seconds: 15);
      client.connectionTimeout = const Duration(seconds: 15);
      return client;
    };
  }

  Future<List<ScrapeResult>> searchTrack(String title, {String? artist, String? album, int resultNum = 30, int pageNum = 1}) async {
    final cleanTitle = sanitizeTitleForSearch(title);
    final cleanArtist = artist == null ? '' : sanitizeArtistForSearch(artist);
    final cleanAlbum = album == null ? '' : sanitizeAlbumForSearch(album);

    final keyword = [cleanTitle, cleanArtist, cleanAlbum].where((s) => s.isNotEmpty).join(' ');
    if (keyword.isEmpty) return [];

    try {
      final body = {
        'comm': {
          'ct': '19',
          'cv': '1859',
          'uin': '0'
        },
        'req': {
          'method': 'DoSearchForQQMusicDesktop',
          'module': 'music.search.SearchCgiService',
          'param': {
            'grp': 1,
            'num_per_page': resultNum,
            'page_num': pageNum,
            'query': keyword,
            'search_type': 0
          }
        }
      };

      final response = await _dio.post(
        '/cgi-bin/musicu.fcg',
        data: jsonEncode(body),
        options: Options(contentType: Headers.jsonContentType, headers: {
          'referer': 'https://y.qq.com/',
          'origin': 'https://y.qq.com',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }
        print('[QQMusic] search response OK for "$keyword"');
        try {
          if (data is Map) print('[QQMusic] top keys: ${data.keys.toList()}');
        } catch (_) {}
        dynamic songs;
        try {
          songs = data['req']?['data']?['body']?['song'];
        } catch (_) {
          songs = null;
        }

        if (songs is Map && songs['list'] != null) songs = songs['list'];

        List list = [];
        if (songs is List) list = songs;
        else if (songs is Map) list = [songs];

        if (list.isEmpty) {
          try {
            print('[QQMusic] Empty list for keyword "$keyword"; response snippet: ${jsonEncode((data is Map && data.length < 5) ? data : {'note': 'large response'})}');
          } catch (_) {}
        }

        return list.map((item) {
          final Map<String, dynamic> it = item is Map ? Map<String, dynamic>.from(item) : {};
          final title = it['songname']?.toString() ?? it['name']?.toString() ?? '';
          String artistStr = '';
          final singer = it['singer'];
          if (singer is List) {
            artistStr = singer.map((s) => s['name']?.toString() ?? '').where((s) => s.isNotEmpty).join(', ');
          } else if (singer is Map) {
            artistStr = singer['name']?.toString() ?? '';
          }
          final album = it['albumname']?.toString() ?? (it['album'] is Map ? it['album']['name']?.toString() ?? '' : '');
          final id = it['songmid']?.toString() ?? it['id']?.toString() ?? '';
          String? cover;
          final albummid = it['albummid'] ?? it['album']?['mid'];
          if (albummid != null && albummid.toString().isNotEmpty) {
            cover = 'https://y.gtimg.cn/music/photo_new/T002R300x300M000${albummid}.jpg';
          }
          int? durationMs;
          final interval = it['interval'] ?? it['duration'];
          if (interval != null) {
            final iv = int.tryParse(interval.toString());
            if (iv != null) durationMs = iv * 1000;
          }

          return ScrapeResult(
            source: ScrapeSource.qqMusic,
            id: id,
            title: title,
            artist: artistStr,
            album: album,
            date: null,
            releaseId: null,
            coverUrl: cover,
            durationMs: durationMs,
          );
        }).toList();
      }
    } catch (e) {
      print('QQ Music search error: $e');
    }

    return [];
  }
}
