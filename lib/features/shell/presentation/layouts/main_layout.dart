import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/quick_eat_bottom_nav.dart';

class MainLayoutController extends ChangeNotifier {
  MainLayoutController(int initialIndex) : _index = initialIndex;

  int _index;
  int get index => _index;

  void select(int index) {
    if (_index == index) return;
    _index = index;
    notifyListeners();
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    required this.pages,
    required this.navItems,
    this.initialIndex = 0,
  });

  final List<Widget> pages;
  final List<QuickEatNavItem> navItems;
  final int initialIndex;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late final MainLayoutController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MainLayoutController(widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MainLayoutController>.value(
      value: _controller,
      child: Scaffold(
        body: Consumer<MainLayoutController>(
          builder: (context, controller, _) =>
              IndexedStack(index: controller.index, children: widget.pages),
        ),
        bottomNavigationBar: Consumer<MainLayoutController>(
          builder: (context, controller, _) => QuickEatBottomNav(
            items: widget.navItems,
            currentIndex: controller.index,
            onTap: controller.select,
          ),
        ),
      ),
    );
  }
}
