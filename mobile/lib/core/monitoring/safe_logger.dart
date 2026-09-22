import 'dart:developer' as developer;

import '../security/sensitive_data_redactor.dart';

enum LogSeverity { info, warning, error }

final class SafeLogger {
  const SafeLogger({this.name = 'RyanGunshop'});

  final String name;

  void log(
    String event, {
    LogSeverity severity = LogSeverity.info,
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    final safeEvent = SensitiveDataRedactor.text(event, maxLength: 160);
    final safeAttributes = SensitiveDataRedactor.json(
      attributes,
      maxLength: 800,
    );
    final safeError = error == null
        ? null
        : SensitiveDataRedactor.error(error, maxLength: 500);
    developer.log(
      '$safeEvent $safeAttributes',
      name: name,
      level: switch (severity) {
        LogSeverity.info => 800,
        LogSeverity.warning => 900,
        LogSeverity.error => 1000,
      },
      error: safeError,
      // Stack trace tidak dikirim karena dapat memuat URI/query sensitif dari
      // exception pihak ketiga. Crashlytics menerima stack aslinya terpisah.
      stackTrace: safeError == null ? null : stackTrace,
    );
  }
}
