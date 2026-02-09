import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:id3/id3.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/core/services/song_metadata_cache_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/album.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/core/utils/artist_parser.dart';

final fileScannerServiceProvider = Provider<FileScannerService>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final metaCache = ref.watch(songMetadataCacheServiceProvider);
  return FileScannerService(dbService, metaCache);
});

typedef ScanProgressCallback = void Function(int current, int total, String currentFile);

class _AsyncPool {
  final int _max;
  int _running = 0;
  int _pending = 0;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  _AsyncPool(this._max);

  Future<T> run<T>(Future<T> Function() task) async {
    _pending++;
    if (_running >= _max) {
      final gate = Completer<void>();
      _waiters.addLast(gate);
      await gate.future;
    }
    _running++;
    try {
      return await task();
    } finally {
      _running--;
      _pending--;
      if (_waiters.isNotEmpty) {
        _waiters.removeFirst().complete();
      }
    }
  }

  Future<void> drain() async {
    while (_pending > 0) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }
}

class FileScannerService {
  final DatabaseService _dbService;
  final SongMetadataCacheService _metaCache;

  FileScannerService(this._dbService, this._metaCache);

  // 支持的格式
  static const _videoExtensions = {'.mp4', '.mkv', '.avi', '.mov', '.rmvb', '.webm', '.flv', '.m3u8'};
  static const _supportedExtensions = {'.mp3', '.flac', '.m4a', '.wav', '.ogg', ..._videoExtensions};

  /// 批量处理导入的路径（文件或文件夹）
  Future<int> scanPaths(List<String> paths, {ScanProgressCallback? onProgress}) async {
    // Collect all files
    final allFiles = <File>[];
    final folderNames = <String, String>{}; // file.path -> folderName

    for (final path in paths) {
      final type = await FileSystemEntity.type(path);
      if (type == FileSystemEntityType.directory) {
        final dir = Directory(path);
        final folderName = p.basename(path);
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (_supportedExtensions.contains(ext)) {
              allFiles.add(entity);
              folderNames[entity.path] = folderName;
            }
          }
        }
      } else if (type == FileSystemEntityType.file) {
        final ext = p.extension(path).toLowerCase();
        if (_supportedExtensions.contains(ext)) {
          allFiles.add(File(path));
          folderNames[path] = p.basename(p.dirname(path));
        }
      }
    }

    if (allFiles.isEmpty) {
      return 0;
    }

    final List<Song> songsToAdd = [];
    final parsePool = _AsyncPool(4);
    final counterPool = _AsyncPool(1);
    int completed = 0;

    final tasks = <Future<void>>[];
    for (final file in allFiles) {
      tasks.add(parsePool.run(() async {
        try {
          final folderName = folderNames[file.path];
          final song = await _parseFile(file, parentFolderName: folderName);
          await counterPool.run(() async {
            songsToAdd.add(song);
          });
        } catch (e) {
          print('Error parsing file ${file.path}: $e');
        } finally {
          await counterPool.run(() async {
            completed++;
            onProgress?.call(completed, allFiles.length, p.basename(file.path));
          });
        }
      }));
    }
    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }

    if (songsToAdd.isNotEmpty) {
      final isar = await _dbService.db;
      await isar.writeTxn(() async {
        await isar.songs.putAll(songsToAdd);
        
        // 更新或创建专辑封面
        final albumMap = <String, String>{}; // albumKey -> coverPath
        for (final song in songsToAdd) {
          if (song.coverPath != null) {
            final key = '${song.artist}_${song.album}';
            albumMap[key] = song.coverPath!;
          }
        }
        
        for (final entry in albumMap.entries) {
          final parts = entry.key.split('_');
          final artist = parts[0];
          final albumName = parts.sublist(1).join('_');
          
          final existingAlbum = await isar.albums.filter()
              .nameEqualTo(albumName)
              .artistEqualTo(artist)
              .findFirst();
          
          if (existingAlbum != null) {
            if (existingAlbum.coverPath == null) {
              existingAlbum.coverPath = entry.value;
              await isar.albums.put(existingAlbum);
            }
          } else {
            final newAlbum = Album()
              ..name = albumName
              ..artist = artist
              ..coverPath = entry.value;
            await isar.albums.put(newAlbum);
          }
        }
      });
    }

    return songsToAdd.length;
  }
  
  // 辅助方法：保存歌曲(Check duplicates by path)
  Future<bool> _saveSongIfNotExists(Song song) async {
      final isar = await _dbService.db;
      return await isar.writeTxn(() async {
        final existing = await isar.songs.filter().pathEqualTo(song.path).findFirst();
        if (existing == null) {
          await isar.songs.put(song);
          return true;
        }
        return false;
      });
  }

  /// 扫描文件夹并入库
  /// 返回新增的歌曲数量
  Future<int> scanFolder(String folderPath, {ScanProgressCallback? onProgress}) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) {
      print('Folder does not exist: $folderPath');
      return 0;
    }

    final List<File> audioFiles = [];
    final folderName = p.basename(folderPath); // 获取文件夹名称
    
    print('Scanning folder: $folderPath');
    
    // 递归遍历收集音频文件
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (_supportedExtensions.contains(ext)) {
            audioFiles.add(entity);
          }
        }
      }
      print('Found ${audioFiles.length} audio files');
    } catch (e) {
      print('Scan error: $e');
      return 0;
    }

    if (audioFiles.isEmpty) {
      return 0;
    }

    final List<Song> songsToAdd = [];
    final parsePool = _AsyncPool(4);
    final counterPool = _AsyncPool(1);
    int completed = 0;
    
    // 处理每个文件并报告进度 (limited concurrency)
    final tasks = <Future<void>>[];
    for (final file in audioFiles) {
      tasks.add(parsePool.run(() async {
        try {
          final song = await _parseFile(file, parentFolderName: folderName);
          await counterPool.run(() async {
            songsToAdd.add(song);
          });
        } catch (e) {
          print('Error parsing file ${file.path}: $e');
        } finally {
          await counterPool.run(() async {
            completed++;
            onProgress?.call(completed, audioFiles.length, p.basename(file.path));
          });
        }
      }));
    }
    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }

    if (songsToAdd.isNotEmpty) {
      final isar = await _dbService.db;
      await isar.writeTxn(() async {
        await isar.songs.putAll(songsToAdd);
        
        // 更新或创建专辑封面
        final albumMap = <String, String>{}; // albumKey -> coverPath
        for (final song in songsToAdd) {
          if (song.coverPath != null) {
            final key = '${song.artist}_${song.album}';
            albumMap[key] = song.coverPath!;
          }
        }
        
        for (final entry in albumMap.entries) {
          final parts = entry.key.split('_');
          final artist = parts[0];
          final albumName = parts.sublist(1).join('_');
          
          final existingAlbum = await isar.albums.filter()
              .nameEqualTo(albumName)
              .artistEqualTo(artist)
              .findFirst();
          
          if (existingAlbum != null) {
            if (existingAlbum.coverPath == null) {
              existingAlbum.coverPath = entry.value;
              await isar.albums.put(existingAlbum);
            }
          } else {
            final newAlbum = Album()
              ..name = albumName
              ..artist = artist
              ..coverPath = entry.value;
            await isar.albums.put(newAlbum);
          }
        }
      });
    }

    return songsToAdd.length;
  }

  /// 从文件名中提取音乐名称
  /// 去除括号内容、排序号等
  /// 例如：'01 - Song Name (Original Mix)' -> 'Song Name'
  String _cleanTitle(String filename) {
    // 移除扩展名
    String title = p.basenameWithoutExtension(filename);
    
    // 移除前导的排序号 (如"01 - ", "1. " 等)
    title = title.replaceFirst(RegExp(r'^\d+[\s\-\.]*'), '');
    
    // 移除括号内的内容 (包括圆括号、方括号、花括号)
    title = title.replaceAll(RegExp(r'\s*[\(\[\{].*?[\)\]\}]'), '');
    
    // 移除尾部的特殊标记（如"Radio Edit", "Remix" 等）- 可选
    title = title.replaceAll(RegExp(r'\s*(Radio Edit|Remix|Remaster|Extended|Version|Mix)$', caseSensitive: false), '');
    
    // 移除多余的空格
    title = title.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // 移除非必要的歌手名称（如果出现在标题中） - 可选
    
    return title.isNotEmpty ? title : p.basenameWithoutExtension(filename);
  }

  Future<Song> _parseFile(File file, {String? parentFolderName}) async {
    String title = _cleanTitle(file.path);
    String artist = 'Unknown Artist';
    String album = 'Unknown Album';
    String? date;
    bool hasMetadata = false;
    String? coverPath;
    String? lyrics;

    final ext = p.extension(file.path).toLowerCase();
    final isVideo = _videoExtensions.contains(ext);

    // 根据不同的文件格式读取元数据
    if (ext == '.mp3') {
      final bytes = await file.readAsBytes();
      final mp3 = MP3Instance(bytes);
      if (mp3.parseTagsSync()) {
        final meta = mp3.getMetaTags();
        if (meta != null) {
          if (meta['Title'] != null || meta['Artist'] != null) {
            hasMetadata = true;
          }
          title = meta['Title']?.toString() ?? title;
          artist = meta['Artist']?.toString() ?? artist;
          album = meta['Album']?.toString() ?? album;
          date = meta['Year']?.toString();

          final apic = meta['APIC'];
          if (apic is List<int>) {
            coverPath = await _saveCoverImage(Uint8List.fromList(apic), file.path);
          }
        }
      }
    } else if (ext == '.flac') {
      final bytes = await file.readAsBytes();
      hasMetadata = await _readFlacMetadata(bytes, (meta) {
        title = meta['Title']?.toString() ?? title;
        artist = meta['Artist']?.toString() ?? artist;
        album = meta['Album']?.toString() ?? album;
        date = meta['Year']?.toString();
      });
      coverPath = await _extractCoverFromFLAC(bytes, file.path);
    }

    // 如果没有元数据，则使用文件夹结构推断艺术家和专辑名称
    if (!hasMetadata) {
      title = _cleanTitle(file.path);

      final fileDirectory = file.parent;
      final parentDirectory = fileDirectory.parent;

      if (parentDirectory.path != fileDirectory.path) {
        artist = parentDirectory.path == fileDirectory.path
            ? fileDirectory.path.split(p.separator).last
            : parentDirectory.path.split(p.separator).last;
        album = fileDirectory.path.split(p.separator).last;
      } else {
        artist = fileDirectory.path.split(p.separator).last;
      }
    }

    // parse artists into list and set primary artist for backward compatibility
    final parsedArtists = parseArtists(artist);
    final primary = parsedArtists.isNotEmpty ? parsedArtists.first : artist;

    lyrics = isVideo ? null : await _loadLocalLyrics(file);

    final song = Song()
      ..path = file.path
      ..mediaType = isVideo ? MediaType.video : MediaType.audio
      ..title = title
      ..artist = primary
      ..artists = parsedArtists
      ..album = album
      ..year = int.tryParse(date ?? '')
      ..coverPath = coverPath
      ..lyrics = lyrics
      ..dateAdded = DateTime.now()
      ..size = await file.length();

    await _metaCache.applyIfMissing(song);
    return song;
  }

  Future<String?> _loadLocalLyrics(File audioFile) async {
    try {
      final dir = audioFile.parent.path;
      final baseName = p.basenameWithoutExtension(audioFile.path);
      final lrcPath = p.join(dir, '$baseName.lrc');
      final lrcFile = File(lrcPath);
      if (await lrcFile.exists()) {
        final text = await lrcFile.readAsString(encoding: utf8);
        final trimmed = text.trim();
        return trimmed.isNotEmpty ? trimmed : null;
      }
    } catch (e) {
      print('Error reading local lyrics for ${audioFile.path}: $e');
    }
    return null;
  }

  /// 从 FLAC 文件中提取封面图片
  Future<String?> _extractCoverFromFLAC(Uint8List bytes, String filePath) async {
    try {
      // FLAC 文件从位置 4 开始（跳过 "fLaC" 标识）
      if (bytes.length < 4 || 
          bytes[0] != 0x66 || bytes[1] != 0x4C || // 'f', 'L'
          bytes[2] != 0x61 || bytes[3] != 0x43) { // 'a', 'C'
        return null;
      }
      
      // 解析 FLAC 元数据块
      var pos = 4;
      while (pos < bytes.length) {
        if (pos + 4 > bytes.length) break;
        
        final blockHeader = bytes[pos];
        final isLastBlock = (blockHeader & 0x80) != 0;
        final blockType = blockHeader & 0x7F;
        
        // 读取块大小（3 字节，大端字节序）
        final blockSize = (bytes[pos + 1] << 16) | 
                         (bytes[pos + 2] << 8) | 
                         bytes[pos + 3];
        
        pos += 4;
        
        // blockType: 6 = METADATA_BLOCK_PICTURE
        if (blockType == 6 && pos + blockSize <= bytes.length) {
          final pictureData = _parseFlacPicture(bytes.sublist(pos, pos + blockSize));
          if (pictureData != null) {
            return await _saveCoverImage(pictureData, filePath);
          }
        }
        
        pos += blockSize;
        if (isLastBlock) break;
      }
    } catch (e) {
      print('Error extracting cover from FLAC: $e');
    }
    return null;
  }

  /// 解析 FLAC METADATA_BLOCK_PICTURE
  Uint8List? _parseFlacPicture(List<int> data) {
    try {
      if (data.length < 8) return null;
      
      // 跳过 picture type (4 bytes)
      var pos = 4;
      
      // MIME type length (4 bytes, big endian)
      final mimeLen = (data[pos] << 24) | (data[pos + 1] << 16) | (data[pos + 2] << 8) | data[pos + 3];
      pos += 4;
      
      // 跳过 MIME type
      pos += mimeLen;
      
      // Description length (4 bytes)
      final descLen = (data[pos] << 24) | (data[pos + 1] << 16) | (data[pos + 2] << 8) | data[pos + 3];
      pos += 4;
      
      // 跳过 description
      pos += descLen;
      
      // 跳过 width, height, depth, colors (4 * 4 = 16 bytes)
      pos += 16;
      
      // Picture data length (4 bytes)
      final picLen = (data[pos] << 24) | (data[pos + 1] << 16) | (data[pos + 2] << 8) | data[pos + 3];
      pos += 4;
      
      // Picture data
      if (pos + picLen <= data.length) {
        return Uint8List.fromList(data.sublist(pos, pos + picLen));
      }
    } catch (e) {
      print('Error parsing FLAC picture: $e');
    }
    return null;
  }

  /// 保存封面图片到缓存目录
  Future<String?> _saveCoverImage(Uint8List imageData, String filePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final coverDir = Directory(p.join(dir.path, 'j_music', 'covers'));
      await coverDir.create(recursive: true);

      // 使用文件路径的哈希作为文件名，避免冲突
      final fileName = '${filePath.hashCode}.jpg';
      final coverPath = p.join(coverDir.path, fileName);

      final coverFile = File(coverPath);
      await coverFile.writeAsBytes(imageData);

      return coverPath;
    } catch (e) {
      print('Error saving cover image: $e');
      return null;
    }
  }

  /// 读取 FLAC 文件的元数据
  /// FLAC 文件格式：ID3 标签（可选）+ FLAC 帧头 + Vorbis 注释块（可选）
  /// 如果成功读取返回 true，通过回调函数返回元数据
  Future<bool> _readFlacMetadata(Uint8List bytes, void Function(Map<String, dynamic>) onMetadata) async {
    try {
      // FLAC 文件从位置 4 开始（跳过 "fLaC" 标识）
      if (bytes.length < 4 || 
          bytes[0] != 0x66 || bytes[1] != 0x4C || // 'f', 'L'
          bytes[2] != 0x61 || bytes[3] != 0x43) { // 'a', 'C'
        return false;
      }
      
      // 解析 FLAC 元数据块
      var pos = 4;
      while (pos < bytes.length) {
        if (pos + 4 > bytes.length) break;
        
        final blockHeader = bytes[pos];
        final isLastBlock = (blockHeader & 0x80) != 0;
        final blockType = blockHeader & 0x7F;
        
        // 读取块大小（3 字节，大端字节序）
        final blockSize = (bytes[pos + 1] << 16) | 
                         (bytes[pos + 2] << 8) | 
                         bytes[pos + 3];
        
        pos += 4;
        
        // blockType: 4 = Vorbis 注释块（包含元数据）
        if (blockType == 4 && pos + blockSize <= bytes.length) {
          final metadata = _parseVorbisComments(bytes.sublist(pos, pos + blockSize));
          if (metadata.isNotEmpty) {
            onMetadata(metadata);
            return true;
          }
        }
        
        pos += blockSize;
        if (isLastBlock) break;
      }
      
      return false;
    } catch (e) {
      print('Error reading FLAC metadata: $e');
      return false;
    }
  }

  /// 解析 Vorbis 注释块中的元数据
  Map<String, dynamic> _parseVorbisComments(List<int> data) {
    final result = <String, dynamic>{};
    
    try {
      if (data.length < 4) return result;
      
      // 跳过 vendor 字符串长度（4 字节，小端字节序）
      var vendorLen = data[0] | 
                      (data[1] << 8) | 
                      (data[2] << 16) | 
                      (data[3] << 24);
      
      var pos = 4 + vendorLen;
      if (pos + 4 > data.length) return result;
      
      // 读取注释数量（4 字节，小端字节序）
      final commentCount = data[pos] | 
                          (data[pos + 1] << 8) | 
                          (data[pos + 2] << 16) | 
                          (data[pos + 3] << 24);
      
      pos += 4;
      
      // 解析每个注释
      for (int i = 0; i < commentCount && pos + 4 <= data.length; i++) {
        final commentLen = data[pos] | 
                          (data[pos + 1] << 8) | 
                          (data[pos + 2] << 16) | 
                          (data[pos + 3] << 24);
        
        pos += 4;
        
        if (pos + commentLen > data.length) break;
        
        // 使用 UTF-8 解码正确处理多字节字符
        final comment = utf8.decode(data.sublist(pos, pos + commentLen));
        pos += commentLen;
        
        // 解析 "KEY=VALUE" 格式的注释
        final eqIndex = comment.indexOf('=');
        if (eqIndex != -1) {
          final key = comment.substring(0, eqIndex).toUpperCase();
          final value = comment.substring(eqIndex + 1);
          
          // 映射到标准元数据字段
          switch (key) {
            case 'TITLE':
              result['Title'] = value;
              break;
            case 'ARTIST':
              result['Artist'] = value;
              break;
            case 'ALBUM':
              result['Album'] = value;
              break;
            case 'DATE':
            case 'YEAR':
              result['Year'] = value;
              break;
            case 'TRACKNUMBER':
              result['TrackNumber'] = value;
              break;
          }
        }
      }
    } catch (e) {
      print('Error parsing Vorbis comments: $e');
    }
    
    return result;
  }
}