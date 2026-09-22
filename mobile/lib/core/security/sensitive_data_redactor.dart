import 'dart:convert';

/// Menjaga credential dan data personal tidak masuk ke log, Crashlytics,
/// maupun kolom error outbox. Redaksi dilakukan sebelum data meninggalkan
/// boundary aplikasi.
abstract final class SensitiveDataRedactor {
  static const redacted = '[REDACTED]';

  static final RegExp _authorization = RegExp(
    r'\b(Bearer|Basic)\s+[A-Za-z0-9._~+/=-]+',
    caseSensitive: false,
  );
  static final RegExp _jwt = RegExp(
    r'\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\b',
  );
  static final RegExp _sensitivePair = RegExp(
    r'\b(password|passwd|pin|token|secret|api[_-]?key|authorization|cookie)'
    r'("?\s*[:=]\s*"?)([^\s,;}"]+)',
    caseSensitive: false,
  );
  static final RegExp _email = RegExp(
    r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b',
    caseSensitive: false,
  );
  static final RegExp _longNumber = RegExp(
    r'(?<!\d)(?:\d[ -]?){11,18}\d(?!\d)',
  );

  static String text(String source, {int maxLength = 1000}) {
    var value = source
        .replaceAll(_authorization, 'Authorization: $redacted')
        .replaceAll(_jwt, redacted)
        .replaceAllMapped(
          _sensitivePair,
          (match) => '${match.group(1)}${match.group(2)}$redacted',
        )
        .replaceAll(_email, '[REDACTED-EMAIL]')
        .replaceAll(_longNumber, '[REDACTED-NUMBER]')
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .trim();
    if (value.length > maxLength) value = value.substring(0, maxLength);
    return value;
  }

  static String error(Object error, {int maxLength = 500}) =>
      text(error.toString(), maxLength: maxLength);

  static Object? value(Object? input) {
    if (input is Map) {
      return input.map((key, item) {
        final name = key.toString();
        return MapEntry(name, _isSensitiveKey(name) ? redacted : value(item));
      });
    }
    if (input is Iterable) return input.map(value).toList(growable: false);
    if (input is String) return text(input);
    return input;
  }

  static String json(Object? input, {int maxLength = 1000}) =>
      text(jsonEncode(value(input)), maxLength: maxLength);

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[_-]'), '');
    return normalized.contains('password') ||
        normalized == 'pin' ||
        normalized.contains('token') ||
        normalized.contains('secret') ||
        normalized.contains('apikey') ||
        normalized.contains('authorization') ||
        normalized.contains('cookie');
  }
}
