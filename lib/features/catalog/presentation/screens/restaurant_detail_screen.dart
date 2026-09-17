import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/quick_eat_app_bar.dart';
import '../../../../data/repositories/menu_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../routes/app_router.dart';
import '../../../orders/presentation/student/widgets/create_order_modal.dart';
import '../controllers/catalog_controller.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/food_card.dart';

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

  String get _horaires => 'Ouvert lundi - vendredi, 08h00 - 20h00';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _controller,
      child: Scaffold(
        appBar: const QuickEatAppBar(automaticallyImplyLeading: false),
        body: Column(
          children: [
            Consumer<CatalogController>(
              builder: (context, controller, child) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.75),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black87,
                                size: 20,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.getNomRestaurant(
                                  widget.idCommercant,
                                ),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.storefront,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Stand Campus • $_horaires',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

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
                        selectedLabel: controller.categorieSelectionnee,
                        onSelected: (label) => controller.setCategorie(label),
                      ),
                    ),
                  );
                },
              ),
            ),

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
                        onCommander: () async {
                          final succes = await CreateOrderModal.show(
                            context,
                            food: food,
                          );
                          if (succes && context.mounted) {
                            Navigator.of(context)
                                .pushNamed(AppRouter.studentOrders);
                          }
                        },
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
