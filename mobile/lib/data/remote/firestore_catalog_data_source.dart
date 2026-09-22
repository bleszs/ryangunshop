import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/entities.dart';
import '../../domain/entities/store_layout_entities.dart';
import '../../domain/repositories/repositories.dart';

/// Adapter remote tenant-scoped. UI tetap mengobservasi Drift/SQLite.
class FirestoreCatalogDataSource
    implements
        StoreLayoutRemoteRepository,
        ProductRemoteRepository,
        InventoryStockRemoteRepository {
  const FirestoreCatalogDataSource(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<void> upsertProduct(
    ProductEntity product, {
    required String mutationId,
    required DateTime clientUpdatedAt,
  }) async {
    final reference = _products(product.storeId).doc(product.id);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final metadata = <String, Object?>{
        'name': product.name,
        'normalizedName': _normalize(product.name),
        'category': product.category,
        'purchasePrice': product.purchasePrice,
        'sellingPrice': product.sellingPrice,
        'minimumStock': product.minimumStock,
        'leadTimeDays': product.leadTimeDays,
        'barcode': product.barcode,
        'photoUrl': product.photoUri,
        'shelfLocation': product.shelfLocation,
        'aiLabel': product.aiLabel,
        'active': true,
        'clientMutationId': mutationId,
        'clientUpdatedAt': Timestamp.fromDate(clientUpdatedAt.toUtc()),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (snapshot.exists) {
        // Stok dokumen yang sudah ada hanya boleh berubah melalui delta.
        transaction.update(reference, metadata);
      } else {
        transaction.set(reference, {
          ...metadata,
          'stock': product.stock,
          'isLowStock': product.stock <= product.minimumStock,
        });
      }
    });
  }

  @override
  Future<void> deleteProduct({
    required String storeId,
    required String productId,
    required String mutationId,
    required DateTime deletedAt,
  }) => _products(storeId).doc(productId).set({
    'active': false,
    'clientMutationId': mutationId,
    'clientUpdatedAt': Timestamp.fromDate(deletedAt.toUtc()),
    'deletedAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  Future<List<Map<String, Object?>>> fetchChangedProducts(
    String storeId,
    DateTime updatedAfter,
  ) async {
    final snapshot = await _products(storeId)
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(updatedAfter))
        .orderBy('updatedAt')
        .get();
    return snapshot.docs
        .map(
          (document) => <String, Object?>{
            'id': document.id,
            ...document.data(),
          },
        )
        .toList(growable: false);
  }

  @override
  Future<void> upsertStoreLayout(
    StoreLayoutEntity layout, {
    required String mutationId,
  }) async {
    final layoutReference = _firestore
        .collection('stores')
        .doc(layout.storeId)
        .collection('layouts')
        .doc(layout.id);
    final currentFixtures = await layoutReference.collection('fixtures').get();
    final fixtureIds = layout.fixtures.map((fixture) => fixture.id).toSet();
    final batch = _firestore.batch();
    batch.set(layoutReference, {
      'name': layout.name,
      'canvasAspectRatio': layout.canvasAspectRatio,
      'templateVersion': layout.templateVersion,
      'clientMutationId': mutationId,
      'clientUpdatedAt': Timestamp.fromDate(layout.updatedAt.toUtc()),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    for (final document in currentFixtures.docs) {
      if (!fixtureIds.contains(document.id)) {
        batch.delete(document.reference);
      }
    }
    for (final fixture in layout.fixtures) {
      batch.set(
        layoutReference.collection('fixtures').doc(fixture.id),
        {
          'type': fixture.type.name,
          'label': fixture.label,
          'x': fixture.x,
          'y': fixture.y,
          'width': fixture.width,
          'height': fixture.height,
          'rotationQuarterTurns': fixture.rotationQuarterTurns,
          'productIds': fixture.productIds,
          'panoramaZoneId': fixture.panoramaZoneId,
          'clientMutationId': mutationId,
          'clientUpdatedAt': Timestamp.fromDate(layout.updatedAt.toUtc()),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  @override
  Future<void> applyStockMutation({
    required String storeId,
    required String productId,
    required int delta,
    required String transactionId,
    required String mutationId,
    required DateTime occurredAt,
  }) async {
    if (delta == 0) return;
    final store = _firestore.collection('stores').doc(storeId);
    final productReference = store.collection('products').doc(productId);
    final mutationReference = store
        .collection('inventoryMutations')
        .doc(mutationId);

    await _firestore.runTransaction((transaction) async {
      final previousMutation = await transaction.get(mutationReference);
      if (previousMutation.exists) return;

      final productSnapshot = await transaction.get(productReference);
      final data = productSnapshot.data();
      final currentStock = data?['stock'];
      final available = currentStock is num ? currentStock.toInt() : 0;
      final nextStock = available + delta;
      if (!productSnapshot.exists || nextStock < 0) {
        throw RemoteStockConflict(
          productId: productId,
          available: available,
          requestedReduction: delta < 0 ? -delta : 0,
        );
      }
      final minimumStock = data?['minimumStock'];
      final minimum = minimumStock is num ? minimumStock.toInt() : 0;

      transaction.update(productReference, {
        'stock': nextStock,
        'isLowStock': nextStock <= minimum,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(mutationReference, {
        'productId': productId,
        'delta': delta,
        'transactionId': transactionId,
        'clientOccurredAt': Timestamp.fromDate(occurredAt.toUtc()),
        'appliedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  CollectionReference<Map<String, dynamic>> _products(String storeId) =>
      _firestore.collection('stores').doc(storeId).collection('products');
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
