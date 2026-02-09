import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';

final itunesLyricsServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  return ItunesLyricsService(proxySettings);
});

class ItunesLyricsService {
  late final Dio _dio;
  final ProxySettings proxySettings;

  ItunesLyricsService(this.proxySettings) {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'application/json',
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

  Future<List<String>> fetchFromItunesPage({required String trackUrl}) async {
    final pageResp = await _dio.get<String>(
      trackUrl,
      options: Options(responseType: ResponseType.plain, validateStatus: (s) => s == 200),
    );
    final html = pageResp.data ?? '';
    if (html.isEmpty) return [];

    final patterns = [
      RegExp(r'<section[^>]*class="lyrics"[^>]*>([\s\S]*?)<\/section>', caseSensitive: false),
      RegExp(r'<div[^>]*class="songs-lyrics"[^>]*>([\s\S]*?)<\/div>', caseSensitive: false),
      RegExp(r'data-lyrics="([^"]+)"', caseSensitive: false),
      RegExp(r'"lyrics"\s*:\s*"([^"]+)"', caseSensitive: false),
    ];

    final results = <String>[];
    for (final pat in patterns) {
      final m = pat.firstMatch(html);
      if (m == null) continue;
      var found = m.groupCount >= 1 ? m.group(1) ?? '' : m.group(0) ?? '';
      if (found.trim().isEmpty) continue;
      found = found.replaceAll(RegExp(r'<[^>]*>'), '');
      found = found
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'");
      results.add(found);
    }

    return results;
  }

  Future<List<Map<String, dynamic>>> searchItunesApi({required String title, required String artist}) async {
    final query = '$artist $title'.trim();
    if (query.isEmpty) return [];
    final resp = await _dio.get(
      'https://itunes.apple.com/search',
      queryParameters: {'term': query, 'entity': 'song', 'limit': 5},
      options: Options(validateStatus: (s) => s == 200),
    );

    if (resp.statusCode != 200 || resp.data == null) return [];
    dynamic parsed = resp.data;
    if (parsed is String) {
      try {
        parsed = jsonDecode(parsed);
      } catch (_) {}
    }
    if (parsed is Map && parsed['results'] is List) return List<Map<String, dynamic>>.from(parsed['results']);
    return [];
  }
}
