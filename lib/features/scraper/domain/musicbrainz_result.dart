class MusicBrainzResult {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? date;
  final String? releaseId; // For cover art

  MusicBrainzResult({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.date,
    this.releaseId,
  });

  factory MusicBrainzResult.fromJson(Map<String, dynamic> json) {
    String artist = 'Unknown';
    if (json['artist-credit'] != null && (json['artist-credit'] as List).isNotEmpty) {
      artist = json['artist-credit'][0]['name'];
    }

    String album = 'Unknown';
    String? releaseId;
    String? date;

    if (json['releases'] != null && (json['releases'] as List).isNotEmpty) {
      final releases = List<Map<String, dynamic>>.from(json['releases']);
      
      // 优 "Official"  "Album"  Release
      // 许多时候搜到的录音对应很多 Release，有些是 bootleg  compilation，可能没封面
      // 简单打分排序：Official=2, Promotion=1; Album=2, Single=1
      releases.sort((a, b) {
        int scoreA = 0;
        int scoreB = 0;
        
        if (a['status'] == 'Official') scoreA += 10;
        if (b['status'] == 'Official') scoreB += 10;
        
        // release-group primary-type (search result 里的结构可能比较简略，需防御性取 
        // 搜索结果里的 release 可能不直接包 release-group type，或者是 properties  
        // 假设 structure: release['release-group']['primary-type'] (需验证)
        //  Search API 中，release 往往包含 'release-group'
        
        // 优先选有日期 
        if (a['date'] != null) scoreA += 2;
        if (b['date'] != null) scoreB += 2;

        return scoreB.compareTo(scoreA); // 降序
      });

      final bestRelease = releases.first;
      album = bestRelease['title'];
      releaseId = bestRelease['id'];
      date = bestRelease['date'];
    }

    return MusicBrainzResult(
      id: json['id'],
      title: json['title'],
      artist: artist,
      album: album,
      date: date,
      releaseId: releaseId,
    );
  }
}

