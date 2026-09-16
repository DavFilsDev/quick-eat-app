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

    if (steps.length < 2) return const SizedBox.shrink();

    return Row(
      children: List.generate(steps.length - 1, (segmentIndex) {
        final isFilled =
            currentStatus != OrderStatus.annulee &&
            currentIndex != -1 &&
            segmentIndex <= currentIndex;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: segmentIndex == steps.length - 2 ? 0 : 4,
            ),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: isFilled ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }),
    );
  }
}
