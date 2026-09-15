import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../models/food_model.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Carte d'un plat dans le catalogue étudiant.
/// Affiche le nom, le prix et un bouton "Commander".
/// Le callback [onCommander] est fourni par l'écran parent ; le Dev 3
/// (feat/student-orders) le branchera sur `CreateOrderModal.show(context, food: food)`.
class FoodCard extends StatelessWidget {
  final FoodModel food;
  final VoidCallback? onCommander;

  const FoodCard({super.key, required this.food, this.onCommander});

  @override
  Widget build(BuildContext context) {
    final isDisponible = food.disponible;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du plat
          CachedNetworkImage(
            imageUrl: food.imageUrl ?? '',
            height: 110,
            width: double.infinity,
            placeholder: (context, url) => Container(
              height: 110,
              color: Colors.grey.shade200,
              child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
            ),
            errorWidget: (context, url, error) => Container(
              height: 110,
              color: Colors.grey.shade200,
              child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
            ),
          ),
          // Nom + prix + bouton
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.nom,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(food.prix),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                // Bouton Commander
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isDisponible && onCommander != null
                        ? onCommander
                        : null,
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    label: const Text('Commander'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 32),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
