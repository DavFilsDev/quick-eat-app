import 'package:flutter/material.dart';

/// Carte d'un restaurant dans l'accueil étudiant.
/// Affiche le logo, le nom du restaurant et le nombre de plats disponibles.
/// Au clic, navigation vers l'écran Détail Restaurant.
class RestaurantCard extends StatelessWidget {
  final String? idCommercant;
  final String? restaurantNom;
  final int nbPlats;
  final VoidCallback? onTap;

  const RestaurantCard({
    super.key,
    required this.idCommercant,
    required this.restaurantNom,
    required this.nbPlats,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayNom = restaurantNom ?? 'Restaurant';
    final String nbPlatsTxt = nbPlats == 1
        ? '1 plat disponible'
        : '$nbPlats plats disponibles';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Logo (80×80)
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade200,
                child: idCommercant != null
                    ? Text(
                        idCommercant!
                            .substring(idCommercant!.length - 3)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 12),
              // Nom + nb plats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayNom,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nbPlatsTxt,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
