import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';

final qqLyricsServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  return QQLyricsService(proxySettings);
});

class QQLyricsService {
  late final Dio _dio;
  final ProxySettings proxySettings;

  QQLyricsService(this.proxySettings) {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'application/json',
        'Content-Type': 'application/json;charset=utf-8',
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

  /// 在 QQ 音乐上用关键词搜索歌曲，返回候选结果列表。
  /// 每个返回项包含至少: songmid, songname, singers(字符串), albumname
  Future<List<Map<String, dynamic>>> search({
    required String title,
    String? artist,
    int resultNum = 10,
    int page = 1,
  }) async {
    final q = ([artist, title]
            .where((s) => s != null && s.trim().isNotEmpty)
            .join(' '))
        .trim();
    if (q.isEmpty) return [];

    print('[qqlyrics] search query: "${q}"');

    final body = {
      'comm': {'ct': 19, 'cv': 1859, 'uin': 0},
      'req': {
        'method': 'DoSearchForQQMusicDesktop',
        'module': 'music.search.SearchCgiService',
        'param': {
          'grp': 1,
          'num_per_page': resultNum,
          'page_num': page,
          'query': q,
          'search_type': 0,
        }
      }
    };

    try {
      final resp = await _dio.post(
        'https://u.y.qq.com/cgi-bin/musicu.fcg',
        data: body,
        options: Options(validateStatus: (s) => s == 200),
      );

      if (resp.statusCode != 200 || resp.data == null) {
        print('[qqlyrics] search failed status: ${resp.statusCode}');
        return [];
      }

      var data = resp.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          print(
              '[qqlyrics] search: response is string but jsonDecode failed, len=${data.length}');
        }
      }

      // debug print small summary
      if (data is Map) {
        print('[qqlyrics] search response keys: ${data.keys}');
      } else {
        print('[qqlyrics] search response type: ${data.runtimeType}');
      }

      final req = data is Map ? data['req'] : null;
      final list = req?['data']?['body']?['song']?['list'];
      if (list is List) {
        return list.map<Map<String, dynamic>>((item) {
          final singers = (item['singer'] is List)
              ? (item['singer'] as List)
                  .map((s) => s['name']?.toString() ?? '')
                  .where((s) => s.isNotEmpty)
                  .join(', ')
              : '';
          return {
            'songmid': item['mid'] ?? item['songmid'] ?? '',
            'songname': item['name'] ?? item['songname'] ?? '',
            'singers': singers,
            'albumname': item['album']?['name'] ?? item['albumname'] ?? '',
          };
        }).toList();
      }
    } catch (e, st) {
      print('[qqlyrics] search error: $e\n$st');
    }

    return [];
  }

  /// 根据 songmid 获取歌词（若 QQ 返回 base64，可考虑解码，但这里使用 nobase64=1）
  Future<String?> fetchLyricBySongmid(String songmid) async {
    if (songmid.trim().isEmpty) return null;
    print('[qqlyrics] fetchLyric songmid: $songmid');
    try {
      // Use V2 API from api.vkeys.cn which returns { code, message, data: { lrc, trans, yrc, roma } }
      final resp = await _dio.get(
        'https://api.vkeys.cn/v2/music/tencent/lyric',
        queryParameters: {
          'mid': songmid,
        },
        options: Options(validateStatus: (s) => s == 200),
      );

      if (resp.statusCode != 200 || resp.data == null) {
        print('[qqlyrics] fetchLyric V2 failed status: ${resp.statusCode}');
        return null;
      }

      var data = resp.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          print(
              '[qqlyrics] fetchLyric V2: response is string but jsonDecode failed, len=${data.length}');
        }
      }

      if (data is Map) {
        print('[qqlyrics] fetchLyric V2 response keys: ${data.keys}');
      } else {
        print('[qqlyrics] fetchLyric V2 response type: ${data.runtimeType}');
      }

      final inner = data is Map ? data['data'] : null;
      final lrc = inner is Map ? inner['lrc']?.toString() ?? '' : '';
      if (lrc.trim().isEmpty) return null;
      return lrc;
    } catch (e, st) {
      print('[qqlyrics] fetchLyric error: $e\n$st');
      return null;
    }
  }
}
