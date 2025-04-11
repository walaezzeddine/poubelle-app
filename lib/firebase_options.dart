import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAD8Z36O5ggXL3_PGpMiqJwCoDdllfwOKY",
    authDomain: "poubelle-f39a1.firebaseapp.com",
    projectId: "poubelle-f39a1",
     storageBucket: "poubelle-f39a1.firebasestorage.app",
  messagingSenderId: "1087387451838",
  appId: "1:1087387451838:web:c810c58015f599558fb9ef"
  );

  static const FirebaseOptions android = FirebaseOptions(
apiKey: "AIzaSyAD8Z36O5ggXL3_PGpMiqJwCoDdllfwOKY", // Clé API Web (valable aussi pour Android)
  appId: "1:1087387451838:android:c1f9d034fe0d67df8fb9ef",
    messagingSenderId: "1087387451838",
    projectId: "poubelle-f39a1",
    storageBucket: "poubelle-f39a1.firebasestorage.app",
  );
}