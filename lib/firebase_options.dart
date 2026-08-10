import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const FirebaseOptions _options = FirebaseOptions(
    apiKey: "AIzaSyCz_QquMVR99ILrTt4okXw0z8aCCcIdMs4",
    authDomain: "smart-gift-finder-d8eee.firebaseapp.com",
    projectId: "smart-gift-finder-d8eee",
    storageBucket: "smart-gift-finder-d8eee.firebasestorage.app",
    messagingSenderId: "810091208013",
    appId: "1:810091208013:web:c1fca412fe7312d609eb04",
    measurementId: "G-M3BR4Q5F0D",
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _options;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return _options;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions has not been configured for fuchsia.',
        );
    }
  }
}
