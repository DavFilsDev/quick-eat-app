import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  // Initialize Firebase before launching the app.
  // Platform options (firebase_options.dart) will be added
  // once `flutterfire configure` is run against the project.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const QuickEatApp());
}
