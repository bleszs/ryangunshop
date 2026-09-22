import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

abstract final class FirebaseAppSecurity {
  /// Harus dipanggil sebelum Firestore/Storage digunakan, termasuk dari
  /// background isolate ketika proses aplikasi utama tidak sedang hidup.
  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
    );
  }
}
