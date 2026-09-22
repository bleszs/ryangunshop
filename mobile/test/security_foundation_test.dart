import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/core/security/secure_value_store.dart';
import 'package:ryangunshop/core/security/sensitive_data_redactor.dart';

void main() {
  test('redactor membuang credential dan data personal dari pesan', () {
    const jwt = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.signature';
    final result = SensitiveDataRedactor.text(
      'Authorization: Bearer super-secret token=abc123 '
      'user=owner@example.com jwt=$jwt rekening=1234 5678 9012 3456',
    );

    expect(result, isNot(contains('super-secret')));
    expect(result, isNot(contains('abc123')));
    expect(result, isNot(contains('owner@example.com')));
    expect(result, isNot(contains(jwt)));
    expect(result, isNot(contains('1234 5678 9012 3456')));
    expect(result, contains(SensitiveDataRedactor.redacted));
  });

  test('redactor membersihkan field sensitif di object bertingkat', () {
    final result = SensitiveDataRedactor.value({
      'storeId': 'store-1',
      'session': {
        'refresh_token': 'refresh-secret',
        'profile': 'owner@example.com',
      },
    });

    expect(result, {
      'storeId': 'store-1',
      'session': {
        'refresh_token': SensitiveDataRedactor.redacted,
        'profile': '[REDACTED-EMAIL]',
      },
    });
  });

  test('secure store menolak key yang dapat keluar dari namespace', () {
    final store = PlatformSecureValueStore();

    expect(() => store.read('../session'), throwsArgumentError);
    expect(() => store.write('session token', 'secret'), throwsArgumentError);
  });
}
