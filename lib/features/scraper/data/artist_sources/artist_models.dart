class ArtistSearchResult {
  final String id;
  final String name;
  final ArtistSource source;
  final String? imageUrl;
  final String? disambiguation;
  final String? type;
  final String? country;

  const ArtistSearchResult({
    required this.id,
    required this.name,
    required this.source,
    this.imageUrl,
    this.disambiguation,
    this.type,
    this.country,
  });
}

enum ArtistSource { musicBrainz, itunes, qqMusic }

extension ArtistSourceExt on ArtistSource {
  String get name => toString().split('.').last;
}
