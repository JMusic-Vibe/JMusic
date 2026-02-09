enum ScrapeSource {
  musicBrainz,
  itunes,
  qqMusic,
}

class ScrapeResult {
  final ScrapeSource source;
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? date;
  final String? releaseId; // For MusicBrainz cover art
  final String? coverUrl;  // For sources providing direct cover
  final int? durationMs; // Track duration from source (milliseconds)

  const ScrapeResult({
    required this.source,
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.date,
    this.releaseId,
    this.coverUrl,
    this.durationMs,
  });
}
