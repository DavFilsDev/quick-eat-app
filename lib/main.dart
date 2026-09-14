import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/auth/dev_auto_login.dart';
import 'data/repositories/user_repository.dart';
import 'firebase_options.dart';
import 'services/firestore_seed.dart';

const bool _useRealFirebase = bool.fromEnvironment(
  'USE_REAL_FIREBASE',
  defaultValue: false,
);
final bool _useEmulator = kDebugMode && !_useRealFirebase;

const String _devRole = String.fromEnvironment('DEV_ROLE', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (_useEmulator) {
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);

    if (_devRole.isNotEmpty) {
      await devAutoLogin(
        role: _devRole,
        userRepository: FirestoreUserRepository(),
      );
    }
  }

  if (kDebugMode) {
    try {
      if (_useEmulator) {
        final bool dejaConnecte = FirebaseAuth.instance.currentUser != null;
        if (!dejaConnecte) {
          await FirebaseAuth.instance.signInAnonymously();
        }
        await assurerSeedFirestore();
        if (!dejaConnecte) {
          await FirebaseAuth.instance.signOut();
        }
      } else {
        await assurerSeedFirestore();
      }
    } catch (error) {
      debugPrint('Seed Firestore ignoré : $error');
    }
  }

  runApp(const QuickEatApp());
}
