import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';
import 'package:jmusic/features/scraper/data/artist_sources/artist_models.dart';

final qqArtistServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  return QQArtistService(proxySettings);
});

class QQArtistService {
  late final Dio _dio;
  final ProxySettings proxySettings;

  QQArtistService(this.proxySettings) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://u.y.qq.com',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
        'Content-Type': 'application/json;charset=utf-8',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-origin',
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

  Future<List<ArtistSearchResult>> searchArtists(String name, {int resultNum = 25, int pageNum = 1}) async {
    final query = name.trim();
    if (query.isEmpty) return [];
    print('[QQArtist] searchArtists called for: "$query"');
    try {
      final body = {
        'comm': {'ct': '19', 'cv': '1859', 'uin': '0'},
        'req': {
          'method': 'DoSearchForQQMusicDesktop',
          'module': 'music.search.SearchCgiService',
          'param': {
            'grp': 1,
            'num_per_page': resultNum,
            'page_num': pageNum,
            'query': query,
            // use search_type 1 to get singer results
            'search_type': 1
          }
        }
      };

      final response = await _dio.post(
        '/cgi-bin/musicu.fcg',
        data: jsonEncode(body),
        options: Options(contentType: 'application/json;charset=utf-8', headers: {
          'referer': 'https://y.qq.com/',
          'origin': 'https://y.qq.com',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-origin',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }

        // Print raw response (truncated) for debugging
        // try {
        //   final dump = jsonEncode(data);
        //   if (dump.length > 2000) {
        //     print('[QQArtist] raw response (truncated 2000 chars): ${dump.substring(0, 2000)}...');
        //   } else {
        //     print('[QQArtist] raw response: $dump');
        //   }
        // } catch (e) {
        //   print('[QQArtist] raw response toString: ${data.toString()}');
        // }

        // Prefer explicit singer results when available, otherwise fallback to other keys
        dynamic body;
        try {
          body = data['req']?['data']?['body'];
        } catch (_) {
          body = null;
        }

        // Debug: show body keys
        if (body is Map) {
          try {
            print('[QQArtist] body keys: ${body.keys.toList()}');
          } catch (_) {}
        }

        dynamic users;
        if (body is Map) {
          if (body['singer'] != null) {
            users = body['singer'];
          } else if (body['user'] != null) {
            users = body['user'];
          } else if (body['list'] != null) {
            users = body['list'];
          } else {
            users = body;
          }
        } else {
          users = data['req']?['data']?['body'];
        }

        // Debug: show extracted users structure
        // try {
        //   final uDump = jsonEncode(users);
        //   if (uDump.length > 1000) {
        //     print('[QQArtist] extracted users (truncated): ${uDump.substring(0, 1000)}...');
        //   } else {
        //     print('[QQArtist] extracted users: $uDump');
        //   }
        // } catch (e) {
        //   print('[QQArtist] users toString: ${users?.toString()}');
        // }

        List list = [];
        if (users is List) list = users;
        else if (users is Map) {
          // if it's a wrapper with 'list', unwrap it
          if (users['list'] is List) list = users['list'];
          else list = [users];
        }

        print('[QQArtist] normalized list length: ${list.length}');

        final results = <ArtistSearchResult>[];
        for (final item in list) {
          if (item is! Map) continue;
          final it = Map<String, dynamic>.from(item);
          // Support QQ singer response fields (singerName, singerMID, singerPic)
          String name = it['singerName']?.toString() ?? it['singername']?.toString() ?? it['nick']?.toString() ?? it['name']?.toString() ?? '';
          String id = it['singerMID']?.toString() ?? it['singer_mid']?.toString() ?? it['mid']?.toString() ?? it['singerID']?.toString() ?? it['id']?.toString() ?? it['uin']?.toString() ?? name;
          String? imageUrl;
          // Prefer explicit singerPic if present
          imageUrl = it['singerPic']?.toString();
          // fallback to known mids
          final singermid = it['singerMID'] ?? it['singer_mid'] ?? it['mid'] ?? it['singermid'];
          if ((imageUrl == null || imageUrl.isEmpty) && singermid != null && singermid.toString().isNotEmpty) {
            imageUrl = 'https://y.gtimg.cn/music/photo_new/T001R300x300M000${singermid}.jpg';
          }
          // Try common avatar fields returned by QQ
          imageUrl ??= it['avatar']?.toString();
          imageUrl ??= it['headurl']?.toString();
          imageUrl ??= it['pic']?.toString();
          imageUrl ??= it['pic_mid']?.toString();
          imageUrl ??= it['pic_big']?.toString();
          imageUrl ??= it['pic_small']?.toString();
          // If pic_mid provided without url, construct using same pattern
          if ((imageUrl == null || imageUrl.isEmpty) && it['pic_mid'] != null) {
            final pm = it['pic_mid']?.toString();
            if (pm != null && pm.isNotEmpty) {
              imageUrl = 'https://y.gtimg.cn/music/photo_new/T001R300x300M000${pm}.jpg';
            }
          }

          if (name.isEmpty) continue;
          results.add(ArtistSearchResult(
            id: id,
            name: name,
            source: ArtistSource.qqMusic,
            imageUrl: imageUrl,
          ));
        }

        print('[QQArtist] parsed ${results.length} artist results for "$query"');
        return results;
      }
    } catch (e) {
      print('QQ Artist search error: $e');
    }
    return [];
  }

  Future<String?> fetchArtistImageUrlFromQQ(String artistName) async {
    final results = await searchArtists(artistName, resultNum: 10);
    if (results.isEmpty) return null;
    return results.first.imageUrl;
  }
}
