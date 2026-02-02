import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jmusic/core/services/image_cache_manager.dart';
import '../network/system_proxy_helper.dart';

class CoverArt extends StatefulWidget {
  final String? path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? cacheKey;

  const CoverArt({
    super.key, 
    this.path, 
    this.width, 
    this.height, 
    this.fit = BoxFit.cover, 
    this.cacheKey
  });

  @override
  State<CoverArt> createState() => _CoverArtState();
}

class _CoverArtState extends State<CoverArt> {
  @override
  void initState() {
    super.initState();
    // SystemProxyHelper.refreshProxy(); // 移除频繁的代理检查，交由全局 HttpOverrides 处理
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path == null || widget.path!.isEmpty) {
      return _placeholder();
    }

    try {
      if (widget.path!.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: widget.path!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          cacheKey: widget.cacheKey ?? widget.path,
          // 使用统一ImageCacheManager 进行缓存管理
          cacheManager: ImageCacheManager.instance,
          // 关键：同MusicBrainzService Header 伪装
          httpHeaders: const {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
            'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'Connection': 'keep-alive',
          },
          placeholder: (context, url) => _loading(),
          errorWidget: (context, url, error) {
            // 如果加载失败，在日志中打印详情方便排查代理问题
            print('[CoverArt] Loading failed for: $url, Error: $error');
            return _error();
          },
        );
      } else {
        // Support file:// URIs as well as plain filesystem paths.
        final path = widget.path!;
        File file;
        if (path.startsWith('file://')) {
          try {
            file = File.fromUri(Uri.parse(path));
          } catch (e) {
            print('[CoverArt] Invalid file URI: $path, Error: $e');
            return _placeholder();
          }
        } else {
          file = File(path);
        }

        if (!file.existsSync()) return _placeholder();
        return Image.file(
          file,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (_, __, ___) => _error(),
        );
      }
    } catch (e) {
      print('[CoverArt] Catch Error: $e');
      return _error();
    }
  }

  Widget _loading() => Container(
    width: widget.width,
    height: widget.height,
    color: Theme.of(context).colorScheme.surfaceVariant,
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );

  Widget _error() => Container(
    width: widget.width,
    height: widget.height,
    color: Theme.of(context).colorScheme.surfaceVariant,
    child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurfaceVariant),
  );

  Widget _placeholder() => Container(
    width: widget.width,
    height: widget.height,
    color: Theme.of(context).colorScheme.surfaceVariant,
    child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
  );
}

