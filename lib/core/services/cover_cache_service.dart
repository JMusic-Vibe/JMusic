import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class CoverCacheService {
  static const _baseDirName = 'j_music';
  static const coverCacheSubDir = 'cover_cache';
  static const artistAvatarSubDir = 'artist_avatars';
  static const embeddedCoverSubDir = 'covers';
  static const _defaultSubDir = coverCacheSubDir;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
      'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Connection': 'keep-alive',
    },
  ));

  String _hash(String input) {
    final bytes = utf8.encode(input);
    return md5.convert(bytes).toString();
  }

  String _inferExt(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      if (path.endsWith('.png')) return 'png';
      if (path.endsWith('.webp')) return 'webp';
      if (path.endsWith('.gif')) return 'gif';
      if (path.endsWith('.bmp')) return 'bmp';
      if (path.endsWith('.jpeg')) return 'jpeg';
      if (path.endsWith('.jpg')) return 'jpg';
    } catch (_) {}
    return 'jpg';
  }

  Future<Directory> _getBaseDir() async {
    final appDoc = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDoc.path}/$_baseDirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> _getSubDir(String subDir) async {
    final base = await _getBaseDir();
    final dir = Directory('${base.path}/$subDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String?> getOrDownload(String url, {String subDir = _defaultSubDir}) async {
    final safeKey = _hash(url);
    final ext = _inferExt(url);
    final dir = await _getSubDir(subDir);
    final file = File('${dir.path}/$safeKey.$ext');
    if (await file.exists()) return file.path;

    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!, flush: true);
        return file.path;
      }
    } catch (_) {}
    return null;
  }

  /// 返回已缓存的本地路径（不会触发下载）
  Future<String?> getCachedPath(String url, {String subDir = _defaultSubDir}) async {
    final safeKey = _hash(url);
    final ext = _inferExt(url);
    final dir = await _getSubDir(subDir);
    final file = File('${dir.path}/$safeKey.$ext');
    if (await file.exists()) return file.path;
    return null;
  }

  Future<int> getCacheSize({String subDir = _defaultSubDir}) async {
    final dir = await _getSubDir(subDir);
    if (!await dir.exists()) return 0;
    int total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {}
      }
    }
    return total;
  }

  Future<void> clearCache({String subDir = _defaultSubDir}) async {
    final dir = await _getSubDir(subDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<int> getAppDataSize() async {
    final base = await _getBaseDir();
    if (!await base.exists()) return 0;
    int total = 0;
    await for (final entity in base.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {}
      }
    }
    return total;
  }
}
