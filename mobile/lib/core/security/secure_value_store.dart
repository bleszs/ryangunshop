import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<void> clear();
}

/// Penyimpanan untuk credential/session kecil yang dienkripsi oleh platform.
/// Data transaksi tetap disimpan di Drift agar alur kasir selalu offline-first.
final class PlatformSecureValueStore implements SecureValueStore {
  PlatformSecureValueStore({
    FlutterSecureStorage? storage,
    this.namespace = 'ryangunshop',
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  final String namespace;

  String _key(String key) {
    final normalized = key.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9._-]{1,80}$').hasMatch(normalized)) {
      throw ArgumentError.value(key, 'key', 'Format key tidak aman');
    }
    return '$namespace.$normalized';
  }

  @override
  Future<String?> read(String key) => _storage.read(key: _key(key));

  @override
  Future<void> write(String key, String value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'Nilai tidak boleh kosong');
    }
    return _storage.write(key: _key(key), value: value);
  }

  @override
  Future<void> delete(String key) => _storage.delete(key: _key(key));

  @override
  Future<void> clear() async {
    final prefix = '$namespace.';
    final entries = await _storage.readAll();
    await Future.wait(
      entries.keys
          .where((key) => key.startsWith(prefix))
          .map((key) => _storage.delete(key: key)),
    );
  }
}
