import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // firebase_options.dart sera ajouté après `flutterfire configure`.
  await Firebase.initializeApp();
  runApp(const QuickEatApp());
}
