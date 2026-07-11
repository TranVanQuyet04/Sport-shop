class ImageUrlUtils {
  const ImageUrlUtils._();

  static String sanitize(Object? value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) {
      return '';
    }

    final host = uri.host.toLowerCase();
    if (host == 'example.com' || host.endsWith('.example.com')) {
      return '';
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return '';
    }

    return raw;
  }

  static List<String> sanitizeList(Iterable<Object?> values) {
    return values
        .map(sanitize)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
  }
}
