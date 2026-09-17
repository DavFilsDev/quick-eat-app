import 'package:flutter/material.dart';

import 'core/auth/auth_gate.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

class QuickEatApp extends StatelessWidget {
  const QuickEatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickEat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
