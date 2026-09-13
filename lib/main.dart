import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/firestore_seed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    try {
      await assurerSeedFirestore();
    } catch (error) {
      debugPrint('Seed Firestore ignoré : $error');
    }
  }
  runApp(const QuickEatApp());
}
