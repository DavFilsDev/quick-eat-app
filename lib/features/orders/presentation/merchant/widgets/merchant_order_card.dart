import 'package:flutter/material.dart';

import '../../../../../core/utils/time_ago_formatter.dart';
import '../../../../../models/enums/delivery_type.dart';
import '../../../../../models/order_model.dart';
import 'dish_thumbnail.dart';
import 'order_status_badge.dart';

class MerchantOrderCard extends StatelessWidget {
  const MerchantOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final itemSummary = firstItem != null
        ? '${firstItem.quantite}x ${firstItem.nom}'
        : 'Commande';
    final estLivraison = order.typeReception == DeliveryType.livraison;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          TimeAgoFormatter.format(order.dateCommande),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                OrderStatusBadge(status: order.statut),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                DishThumbnail(imageUrl: firstItem?.imageUrl),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    itemSummary,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: estLivraison
                        ? Colors.orange.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        estLivraison ? Icons.directions_walk : Icons.storefront,
                        size: 14,
                        color: estLivraison
                            ? Colors.deepOrange
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        estLivraison ? 'À livrer' : 'Sur place',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: estLivraison
                              ? Colors.deepOrange
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Détails',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
