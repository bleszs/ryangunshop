import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../security/firebase_app_security.dart';
import '../security/sensitive_data_redactor.dart';
import 'safe_logger.dart';

enum MonitoringStatus { notStarted, active, localOnly }

final class FirebaseMonitoring {
  FirebaseMonitoring({SafeLogger logger = const SafeLogger()})
    : _logger = logger;

  final SafeLogger _logger;
  MonitoringStatus _status = MonitoringStatus.notStarted;

  MonitoringStatus get status => _status;

  /// Dipasang sinkron sebelum [runApp] agar error framework dan async tidak
  /// hilang. Pengiriman baru dilakukan setelah Firebase siap.
  void installGlobalErrorHandlers() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(
        recordError(
          details.exception,
          details.stack ?? StackTrace.current,
          fatal: true,
          reason: 'flutter-framework',
        ),
      );
    };
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      unawaited(
        recordError(
          error,
          stackTrace,
          fatal: true,
          reason: 'platform-dispatcher',
        ),
      );
      return true;
    };
  }

  /// Tidak memblokir startup. Tanpa konfigurasi FlutterFire, aplikasi tetap
  /// berfungsi lokal dan status berubah menjadi [MonitoringStatus.localOnly].
  Future<MonitoringStatus> initialize() async {
    try {
      await FirebaseAppSecurity.initialize();
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode ||
            const bool.fromEnvironment('ENABLE_CRASHLYTICS_IN_DEBUG'),
      );
      _status = MonitoringStatus.active;
      _logger.log('monitoring.ready');
    } on Object catch (error, stackTrace) {
      _status = MonitoringStatus.localOnly;
      _logger.log(
        'monitoring.local_only',
        severity: LogSeverity.warning,
        error: error,
        stackTrace: stackTrace,
      );
    }
    return _status;
  }

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String reason = 'handled-error',
  }) async {
    final safeReason = SensitiveDataRedactor.text(reason, maxLength: 120);
    final safeError = SensitiveDataRedactor.error(error);
    if (_status == MonitoringStatus.active) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          safeError,
          stackTrace,
          fatal: fatal,
          reason: safeReason,
        );
        return;
      } on Object catch (monitoringError, monitoringStack) {
        _logger.log(
          'monitoring.record_failed',
          severity: LogSeverity.warning,
          error: monitoringError,
          stackTrace: monitoringStack,
        );
      }
    }
    _logger.log(
      safeReason,
      severity: LogSeverity.error,
      error: safeError,
      stackTrace: stackTrace,
    );
  }
}
