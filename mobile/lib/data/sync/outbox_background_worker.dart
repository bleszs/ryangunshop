import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/security/firebase_app_security.dart';
import '../local/app_database.dart';
import '../remote/firestore_catalog_data_source.dart';
import '../remote/firebase_correction_photo_data_source.dart';
import 'inventory_stock_outbox_sync.dart';
import 'product_catalog_outbox_sync.dart';
import 'prediction_correction_photo_outbox_sync.dart';
import 'store_layout_outbox_sync.dart';

abstract final class OutboxBackgroundWorker {
  static const taskName = 'ryangunshop.outbox.sync';
  static const periodicUniqueName = 'ryangunshop.outbox.periodic.v1';
  static const startupUniqueName = 'ryangunshop.outbox.startup.v1';
  static const tag = 'ryangunshop-outbox';

  /// Registrasi bersifat best-effort. Kegagalan plugin tidak boleh menghalangi
  /// aplikasi offline untuk dibuka.
  static Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      final manager = Workmanager();
      await manager.initialize(outboxCallbackDispatcher);
      final constraints = Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresStorageNotLow: true,
      );
      await manager.registerPeriodicTask(
        periodicUniqueName,
        taskName,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(minutes: 1),
        constraints: constraints,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
        tag: tag,
      );
      await manager.registerOneOffTask(
        startupUniqueName,
        taskName,
        constraints: constraints,
        existingWorkPolicy: ExistingWorkPolicy.keep,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
        tag: tag,
      );
    } on Object {
      // Offline-first: transaksi lokal tetap tersedia walau scheduler gagal.
    }
  }
}

@pragma('vm:entry-point')
void outboxCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != OutboxBackgroundWorker.taskName) return true;
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    // Sampai `flutterfire configure` selesai, tidak ada default Firebase app.
    // Anggap siklus ini selesai agar WorkManager periodik tidak retry agresif.
    try {
      await FirebaseAppSecurity.initialize();
    } on Object {
      return true;
    }

    final database = AppDatabase();
    try {
      final remote = FirestoreCatalogDataSource(FirebaseFirestore.instance);
      await StoreLayoutOutboxSyncProcessor(
        database: database,
        remote: remote,
      ).processPending();
      await ProductCatalogOutboxSyncProcessor(
        database: database,
        remote: remote,
      ).processPending();
      await InventoryStockOutboxSyncProcessor(
        database: database,
        remote: remote,
      ).processPending();
      await PredictionCorrectionPhotoOutboxSyncProcessor(
        database: database,
        remote: FirebaseCorrectionPhotoDataSource(FirebaseStorage.instance),
      ).processPending();
      return true;
    } on Object {
      return false;
    } finally {
      await database.close();
    }
  });
}

void scheduleOutboxBackgroundSync() {
  unawaited(OutboxBackgroundWorker.initialize());
}
