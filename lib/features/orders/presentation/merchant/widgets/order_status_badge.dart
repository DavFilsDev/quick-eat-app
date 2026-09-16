import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../models/enums/order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case OrderStatus.enAttente:
        return AppColors.statusPending;
      case OrderStatus.acceptee:
        return AppColors.statusAccepted;
      case OrderStatus.enCoursDeLivraison:
        return AppColors.statusInProgress;
      case OrderStatus.livree:
      case OrderStatus.terminee:
      case OrderStatus.recu:
        return AppColors.statusDone;
      case OrderStatus.annulee:
        return AppColors.statusCancelled;
    }
  }
}
