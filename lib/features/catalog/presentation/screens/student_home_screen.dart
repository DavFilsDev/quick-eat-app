import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/menu_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../routes/app_router.dart';
import '../../../orders/presentation/student/widgets/create_order_modal.dart';
import '../../../shell/presentation/layouts/main_layout.dart';
import '../controllers/catalog_controller.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/food_card.dart';
import '../widgets/restaurant_card.dart';
import '../../../../core/widgets/quick_eat_app_bar.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  late final CatalogController _controller;
  final _focusNode = FocusNode();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CatalogController(
      menuRepository: FirestoreMenuRepository(),
      userRepository: FirestoreUserRepository(),
      idEtudiant: FirebaseAuth.instance.currentUser?.uid,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _controller,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: QuickEatAppBar(
          onOuvrirCommandes: () =>
              context.read<MainLayoutController?>()?.select(1),
        ),
        body: Consumer<CatalogController>(
          builder: (context, controller, child) {
            final plats = controller.plats.take(4).toList();
            final restaurantIds = controller.restaurantsDisponibles;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: (value) => controller.setRecherche(value),
                    decoration: InputDecoration(
                      hintText: 'Chercher un plat ou un restaurant...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'RESTAURANTS DU CAMPUS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: CategoryFilterChip(
                      labels: controller.nomsRestaurants,
                      selectedLabel: controller.restaurantSelectionne,
                      onSelected: (nom) => controller.setRestaurantParNom(nom),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Plats disponibles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${plats.length} ${plats.length > 1 ? "plats" : "plat"}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (plats.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "Il n'y a pas encore de plats disponibles dans votre campus.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                              context.read<MainLayoutController>().select(1);
                            }
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 24),

                  const Text(
                    'Restaurants du campus',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (restaurantIds.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "Pour l'instant, il n'y a pas encore de restaurant dans votre campus.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: restaurantIds.length,
                      itemBuilder: (context, index) {
                        final id = restaurantIds[index];
                        return RestaurantCard(
                          idCommercant: id,
                          restaurantNom: controller.getNomRestaurant(id),
                          nbPlats: controller.nbPlatsRestaurant(id),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRouter.restaurantDetail,
                              arguments: id,
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
