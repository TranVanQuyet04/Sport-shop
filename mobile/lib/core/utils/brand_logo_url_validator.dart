class BrandLogoUrlValidator {
  const BrandLogoUrlValidator._();

  static const int maxLength = 1000;

  static String normalize(String value) => value.trim();

  static String? validate(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    if (raw.length > maxLength) {
      return 'URL logo tối đa $maxLength ký tự. Không dán ảnh base64/data URL.';
    }
    if (raw.toLowerCase().startsWith('data:image')) {
      return 'Không hỗ trợ data:image/base64. Hãy dùng link ảnh http hoặc https.';
    }
    final uri = Uri.tryParse(raw);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.trim().isEmpty) {
      return 'URL logo phải bắt đầu bằng http:// hoặc https://.';
    }
    return null;
  }
}
