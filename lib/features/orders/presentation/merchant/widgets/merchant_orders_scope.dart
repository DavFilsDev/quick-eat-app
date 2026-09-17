import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/repositories/notification_repository.dart';
import '../../../../../data/repositories/order_repository.dart';
import '../../../../../data/repositories/user_repository.dart';
import '../controllers/merchant_orders_controller.dart';

class MerchantOrdersScope extends StatefulWidget {
  final Widget child;

  const MerchantOrdersScope({super.key, required this.child});

  @override
  State<MerchantOrdersScope> createState() => _MerchantOrdersScopeState();
}

class _MerchantOrdersScopeState extends State<MerchantOrdersScope> {
  MerchantOrdersController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alreadyProvided =
        context
            .findAncestorWidgetOfExactType<
              ChangeNotifierProvider<MerchantOrdersController>
            >() !=
        null;
    if (alreadyProvided) return widget.child;

    _controller ??= MerchantOrdersController(
      orderRepository: FirestoreOrderRepository(),
      userRepository: FirestoreUserRepository(),
      notificationRepository: FirestoreNotificationRepository(),
      merchantId: FirebaseAuth.instance.currentUser?.uid ?? '',
    );
    return ChangeNotifierProvider<MerchantOrdersController>(
      create: (_) => _controller!,
      child: widget.child,
    );
  }
}
