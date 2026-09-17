import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/quick_eat_app_bar.dart';
import '../../../../data/repositories/menu_repository.dart';
import '../../../../models/food_model.dart';
import '../../../../models/user_model.dart';
import '../controllers/menu_management_controller.dart';
import '../widgets/menu_form_dialog.dart';
import '../widgets/menu_item_tile.dart';

class MerchantMenuScreen extends StatefulWidget {
  const MerchantMenuScreen({
    super.key,
    this.menuRepository,
    this.idCommercant,
    this.userStream,
  });

  final MenuRepository? menuRepository;
  final String? idCommercant;
  final Stream<UserModel?>? userStream;

  @override
  State<MerchantMenuScreen> createState() => _MerchantMenuScreenState();
}

class _MerchantMenuScreenState extends State<MerchantMenuScreen> {
  late final MenuManagementController _controller;
  final _rechercheController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = MenuManagementController(
      menuRepository: widget.menuRepository ?? FirestoreMenuRepository(),
      idCommercant:
          widget.idCommercant ?? FirebaseAuth.instance.currentUser?.uid ?? '',
    )..startListening();
  }

  @override
  void dispose() {
    _rechercheController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ajouter() async {
    final succes = await MenuFormDialog.show(context, controller: _controller);
    if (succes && mounted) _afficherMessage('Plat ajouté avec succès.');
  }

  Future<void> _editer(FoodModel plat) async {
    final succes = await MenuFormDialog.show(
      context,
      controller: _controller,
      plat: plat,
    );
    if (succes && mounted) _afficherMessage('Plat modifié avec succès.');
  }

  Future<void> _basculer(FoodModel plat, bool disponible) async {
    final succes = await _controller.basculerDisponibilite(plat, disponible);
    if (!mounted) return;
    _afficherMessage(
      succes
          ? 'Disponibilité mise à jour.'
          : (_controller.errorMessage ?? 'Une erreur est survenue.'),
    );
  }

  Future<void> _supprimer(FoodModel plat) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le plat'),
        content: const Text('Veux-tu vraiment supprimer ce plat ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            key: const Key('confirmer_suppression_plat'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.statusCancelled,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;
    final succes = await _controller.supprimer(plat.idFood);
    if (!mounted) return;
    _afficherMessage(
      succes
          ? 'Plat supprimé.'
          : (_controller.errorMessage ?? 'Une erreur est survenue.'),
    );
  }

  void _afficherMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: QuickEatAppBar(
          title: 'Mes Plats',
          userStream: widget.userStream,
        ),
        floatingActionButton: FloatingActionButton(
          key: const Key('ajouter_plat'),
          onPressed: _ajouter,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        body: Consumer<MenuManagementController>(
          builder: (context, controller, _) {
            if (controller.status == MenuManagementStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.status == MenuManagementStatus.error) {
              return Center(
                child: Text(
                  controller.errorMessage ?? 'Erreur de chargement.',
                  style: AppTextStyles.body,
                ),
              );
            }
            return Column(
              children: [
                _BarreOutils(
                  controller: controller,
                  rechercheController: _rechercheController,
                ),
                Expanded(child: _liste(controller)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _liste(MenuManagementController controller) {
    if (!controller.aDesPlats) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Vous n'avez pas encore de plat dans votre menu. Cliquez sur + pour en ajouter un.",
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ),
      );
    }
    if (controller.plats.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aucun plat ne correspond à votre recherche.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: controller.plats.length,
      itemBuilder: (context, index) {
        final plat = controller.plats[index];
        return MenuItemTile(
          food: plat,
          onToggleDisponible: (valeur) => _basculer(plat, valeur),
          onEditer: () => _editer(plat),
          onSupprimer: () => _supprimer(plat),
        );
      },
    );
  }
}

class _BarreOutils extends StatelessWidget {
  const _BarreOutils({
    required this.controller,
    required this.rechercheController,
  });

  final MenuManagementController controller;
  final TextEditingController rechercheController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('recherche_plat'),
            controller: rechercheController,
            onChanged: controller.setRecherche,
            decoration: InputDecoration(
              hintText: 'Rechercher un plat...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final categorie in controller.categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      key: Key('categorie_$categorie'),
                      label: Text(categorie),
                      selected:
                          (controller.categorieSelectionnee ?? 'Tous') ==
                          categorie,
                      onSelected: (_) => controller.setCategorie(categorie),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MenuTri>(
            key: const Key('tri_plats'),
            initialValue: controller.tri,
            hint: const Text('Trier par'),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(
                value: MenuTri.prixCroissant,
                child: Text('Prix croissant'),
              ),
              DropdownMenuItem(
                value: MenuTri.prixDecroissant,
                child: Text('Prix décroissant'),
              ),
            ],
            onChanged: controller.setTri,
          ),
        ],
      ),
    );
  }
}
