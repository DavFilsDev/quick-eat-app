import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/menu_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../routes/app_router.dart';
import '../../../orders/presentation/student/widgets/create_order_modal.dart';
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
        appBar: const QuickEatAppBar(),
        body: Consumer<CatalogController>(
          builder: (context, controller, child) {
            final plats = controller.plats;
            final restaurantIds = controller.restaurantsDisponibles;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Barre de recherche
                  TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: (value) => controller.setRecherche(value),
                    decoration: InputDecoration(
                      hintText: 'Chercher un plat ou un restaurant...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Section RESTAURANTS DU CAMPUS (Filtres Chips)
                  const Text(
                    'RESTAURANTS DU CAMPUS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
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

                  // 3. Section Plats disponibles
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
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Liste verticale des plats
                  if (plats.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('Aucun plat disponible')),
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
                          onCommander: () =>
                              CreateOrderModal.show(context, food: food),
                        );
                      },
                    ),
                  const SizedBox(height: 24),

                  // 4. Section Restaurants du campus
                  const Text(
                    'Restaurants du campus',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Liste verticale des restaurants avec bouton "Visiter"
                  if (restaurantIds.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('Aucun restaurant trouvé')),
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
