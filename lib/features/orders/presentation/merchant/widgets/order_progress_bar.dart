import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../models/enums/order_status.dart';

class OrderProgressBar extends StatelessWidget {
  final OrderStatus currentStatus;
  final List<OrderStatus> steps;

  const OrderProgressBar({
    super.key,
    required this.currentStatus,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = steps.indexOf(currentStatus);
    
    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentIndex && currentStatus != OrderStatus.annulee;
        final isLast = index == steps.length - 1;

        return Expanded(
          flex: isLast ? 0 : 1,
          child: Row(
            children: [
              // Step dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primary : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              // Connector line
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentIndex && currentStatus != OrderStatus.annulee
                        ? AppColors.primary
                        : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
