import 'package:flutter/material.dart';

import 'quick_eat_app_bar.dart';

class ScreenPlaceholder extends StatelessWidget {
  final String titre;

  const ScreenPlaceholder({super.key, required this.titre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const QuickEatAppBar(),
      body: Center(child: Text('$titre — TODO')),
    );
  }
}
