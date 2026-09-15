import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/menu_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../controllers/catalog_controller.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/food_card.dart';

/// Écran détail restaurant (maquette "Détail Restaurant") :
/// bannière, horaires (statiques), recherche interne, filtres par catégorie
/// et liste des plats du commerçant uniquement.
class RestaurantDetailScreen extends StatefulWidget {
  final String idCommercant;

  const RestaurantDetailScreen({required this.idCommercant, super.key});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late final CatalogController _controller;
  final _focusNode = FocusNode();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CatalogController(
      menuRepository: FirestoreMenuRepository(),
      userRepository: FirestoreUserRepository(),
    );
    _controller.setCommercant(widget.idCommercant);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Horaires fixes (texte statique dérivé du profil commerçant).
  String get _horaires => 'Ouvert lundi - vendredi, 08h00 - 20h00';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _controller,
      child: Scaffold(
        body: Column(
          children: [
            // Bannière du restaurant
            Consumer<CatalogController>(
              builder: (context, controller, child) {
                return Container(
                  width: double.infinity,
                  color: AppColors.primary,
                  padding: const EdgeInsets.only(
                    top: 40,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.getNomRestaurant(widget.idCommercant),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _horaires,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Recherche interne
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (value) => _controller.setRecherche(value),
                decoration: const InputDecoration(
                  hintText: 'Rechercher dans ce restaurant...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),

            // Filtres par catégorie (dynamiques)
            SizedBox(
              height: 48,
              child: Consumer<CatalogController>(
                builder: (context, controller, child) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CategoryFilterChip(
                        labels: controller.categories,
                        selectedLabel: null,
                        onSelected: (label) => controller.setCategorie(label),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Liste des plats du commerçant
            Expanded(
              child: Consumer<CatalogController>(
                builder: (context, controller, child) {
                  final plats = controller.plats;
                  if (plats.isEmpty) {
                    return const Center(
                      child: Text('Aucun plat dans ce restaurant'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: plats.length,
                    itemBuilder: (context, index) {
                      final food = plats[index];
                      return FoodCard(
                        food: food,
                        // TODO(Dev 3 - feat/student-orders): CreateOrderModal.show(context, food: food);
                        onCommander: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
