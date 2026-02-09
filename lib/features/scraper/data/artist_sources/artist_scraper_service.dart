import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';
import 'package:jmusic/features/scraper/data/artist_sources/musicbrainz_artist_service.dart';
import 'package:jmusic/features/scraper/data/artist_sources/itunes_artist_service.dart';
import 'package:jmusic/features/scraper/data/artist_sources/qq_artist_service.dart';
import 'package:jmusic/features/scraper/data/artist_sources/artist_models.dart';

final artistScraperServiceProvider = Provider((ref) {
  return ArtistScraperService(ref);
});

class ArtistScraperService {
  final Ref ref;

  ArtistScraperService(this.ref);

  Future<List<ArtistSearchResult>> searchArtists(
    String name, {
    bool useMusicBrainz = true,
    bool useItunes = true,
    bool useQQ = true,
  }) async {
    final results = <ArtistSearchResult>[];
    if (useMusicBrainz) {
      final svc = ref.read(musicBrainzArtistServiceProvider);
      results.addAll(await svc.searchArtists(name));
    }
    if (useItunes) {
      final svc = ref.read(itunesArtistServiceProvider);
      results.addAll(await svc.searchArtists(name));
    }
    if (useQQ) {
      final svc = ref.read(qqArtistServiceProvider);
      results.addAll(await svc.searchArtists(name));
    }

    final seen = <String>{};
    return results.where((r) {
      final key = '${r.source.name}:${r.id}:${r.name}'.toLowerCase();
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  Future<String?> fetchArtistImageUrl(String artistName) async {
    final svc = ref.read(musicBrainzArtistServiceProvider);
    return await svc.fetchArtistImageUrl(artistName);
  }

  Future<String?> fetchArtistImageUrlFromItunes(String artistName) async {
    final svc = ref.read(itunesArtistServiceProvider);
    return await svc.fetchArtistImageUrlFromItunes(artistName);
  }

  Future<String?> fetchArtistImageUrlById(String artistId) async {
    final svc = ref.read(musicBrainzArtistServiceProvider);
    return await svc.fetchArtistImageUrlById(artistId);
  }

  Future<String?> fetchArtistImageUrlFromQQ(String artistName) async {
    final svc = ref.read(qqArtistServiceProvider);
    return await svc.fetchArtistImageUrlFromQQ(artistName);
  }
}
