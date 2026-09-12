// Generated from the Firebase console configs of the fscamp-app project.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Le web n\'est pas supporté par QuickEat.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBnZ1fVFo4BZq0WBWafLaGaj1nSuIQRntk',
    appId: '1:407341650736:android:41e69bb5815d2fc36c6ef5',
    messagingSenderId: '407341650736',
    projectId: 'fscamp-app',
    storageBucket: 'fscamp-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDB_juzNA7rR8oQ0MW4tpTWPGy543BQclY',
    appId: '1:407341650736:ios:45627a5b665f6abd6c6ef5',
    messagingSenderId: '407341650736',
    projectId: 'fscamp-app',
    storageBucket: 'fscamp-app.firebasestorage.app',
  );
}
