import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/menu_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../routes/app_router.dart';
import '../controllers/catalog_controller.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/food_card.dart';
import '../widgets/restaurant_card.dart';

/// Écran d'accueil étudiant (maquette "Accueil Étudiant") :
/// barre de recherche, filtres par restaurant, liste des restaurants
/// et liste des plats disponibles.
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
        appBar: AppBar(title: const Text('Accueil Étudiant')),
        body: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (value) => _controller.setRecherche(value),
                decoration: const InputDecoration(
                  hintText: 'Rechercher un plat...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),

            // Filtres par campus (dynamiques depuis Firestore)
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
                        labels: controller.nomsCampuses,
                        selectedLabel: null,
                        onSelected: (nom) => controller.setCampusParNom(nom),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Filtres par restaurant (Tous / nom des restaurants)
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
                        labels: controller.nomsRestaurants,
                        selectedLabel: null,
                        onSelected: (nom) =>
                            controller.setRestaurantParNom(nom),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Liste des restaurants
            SizedBox(
              height: 120,
              child: Consumer<CatalogController>(
                builder: (context, controller, child) {
                  final ids = controller.restaurantsDisponibles;
                  if (ids.isEmpty) {
                    return const Center(
                      child: Text('Aucun restaurant disponible'),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ids.length,
                    itemBuilder: (context, index) {
                      final id = ids[index];
                      return SizedBox(
                        width: 220,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: RestaurantCard(
                            idCommercant: id,
                            restaurantNom: controller.getNomRestaurant(id),
                            nbPlats: controller.nbPlatsRestaurant(id),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRouter.restaurantDetail,
                                arguments: id,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Liste des plats disponibles
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Plats disponibles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Expanded(
              child: Consumer<CatalogController>(
                builder: (context, controller, child) {
                  final plats = controller.plats;
                  if (plats.isEmpty) {
                    return const Center(child: Text('Aucun plat trouvé'));
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
