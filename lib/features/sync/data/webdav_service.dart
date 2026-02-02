import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:jmusic/features/sync/domain/entities/sync_config.dart';

final webDavServiceProvider = Provider((ref) => WebDavService());

class WebDavService {
  webdav.Client? _client;

  /// 初始 连接
  Future<bool> connect(SyncConfig config) async {
    try {
      _client = webdav.newClient(
        config.url,
        user: config.username ?? '',
        password: config.password ?? '',
        debug: true,
      );
      // 这里 ping 实际上是通过发送一个简单请求来测试连接
      // webdav包没有直接的 connect 方法，通常在第一次操作时连接
      // 我们尝试列出根目录来测试连通性
      await _client!.readDir('/');
      return true;
    } catch (e) {
      print('WebDAV connection failed: $e');
      return false;
    }
  }

  /// 列出目录内容
  Future<List<webdav.File>> listDir(String path) async {
    if (_client == null) throw Exception('WebDAV client not initialized');
    return await _client!.readDir(path);
  }

  /// 下载文件到本地
  Future<void> downloadFile(String remotePath, String localPath) async {
    if (_client == null) throw Exception('WebDAV client not initialized');
    await _client!.read2File(remotePath, localPath);
  }

  /// 上传文件到云端
  Future<void> uploadFile(String localPath, String remotePath) async {
    if (_client == null) throw Exception('WebDAV client not initialized');
    await _client!.writeFromFile(localPath, remotePath);
  }
}

