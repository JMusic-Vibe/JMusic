// Utilities to sanitize and normalize strings for scraper searches.
String _removeBracketed(String s) {
  // remove content inside (), [], {}, 【】, （） etc.
  return s.replaceAll(RegExp(r'[\(\[\{【（][^\)\]\}】）]*[\)\]\}\】）]'), ' ');
}

String _removeNoiseWords(String s) {
  final noise = [
    'live', 'remaster', 'remastered', 'official video', 'official', 'mv', 'karaoke', 'instrumental', 'acoustic', 'cover', 'hd', '4k',
    // Chinese
    '现场', '混音', '翻唱', '伴奏', '官方', '推广', '单曲', '版',
  ];
  var out = s;
  for (final n in noise) {
    out = out.replaceAll(RegExp('\\b${RegExp.escape(n)}\\b', caseSensitive: false), ' ');
  }
  return out;
}

String sanitizeTitleForSearch(String? input) {
  if (input == null) return '';
  var s = input.trim();
  if (s.isEmpty) return '';

  // Normalize punctuation
  s = s.replaceAll('\u2018', "'")
       .replaceAll('\u2019', "'")
       .replaceAll('\u201C', '"')
       .replaceAll('\u201D', '"')
       .replaceAll('（', '(')
       .replaceAll('）', ')')
       .replaceAll('【', '[')
       .replaceAll('】', ']');

  // Remove bracketed content like (feat. ...), [Live], 【...】
  s = _removeBracketed(s);

  // Remove common noise words
  s = _removeNoiseWords(s);

  // Remove multiple separators and punctuation except basic ones
  // replace a handful of special separator characters by unicode escapes
  s = s.replaceAll(RegExp("[\"\\\\`\u00B7\u2022\u266A\u25AA]+"), ' ');

  // Keep letters, numbers and basic punctuation, collapse whitespace
  s = s.replaceAll(RegExp(r"[^\p{L}\p{N}'\-:\s]", unicode: true), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

String sanitizeAlbumForSearch(String? input) => sanitizeTitleForSearch(input);

String sanitizeArtistForSearch(String? input) {
  if (input == null) return '';
  var s = input.trim();
  if (s.isEmpty) return '';

  // Normalize and remove bracketed content
  s = s.replaceAll('（', '(').replaceAll('）', ')').replaceAll('【', '[').replaceAll('】', ']');
  s = _removeBracketed(s);

  // If multiple artists present, return only the primary (before feat, /, &, etc.)
  final parts = s.split(RegExp(r'\s*(?:feat\.?|ft\.?|featuring)\s*', caseSensitive: false));
  var primary = parts.first;
  // Further split by common separators
  primary = primary.split(RegExp(r'[\/,&;\+]|\s+and\s+|\s+x\s+|×|・|、')).first.trim();

  // Collapse spaces and strip unwanted chars
  primary = primary.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  return primary;
}
