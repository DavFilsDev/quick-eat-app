import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/quick_eat_app_bar.dart';
import '../../../../data/repositories/menu_repository.dart';
import '../../../../models/food_model.dart';
import '../controllers/menu_management_controller.dart';
import '../widgets/menu_form_dialog.dart';
import '../widgets/menu_item_tile.dart';

class MerchantMenuScreen extends StatefulWidget {
  const MerchantMenuScreen({super.key});

  @override
  State<MerchantMenuScreen> createState() => _MerchantMenuScreenState();
}

class _MerchantMenuScreenState extends State<MerchantMenuScreen> {
  late final MenuManagementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MenuManagementController(
      menuRepository: FirestoreMenuRepository(),
      idCommercant: FirebaseAuth.instance.currentUser?.uid ?? '',
    )..startListening();
  }

  @override
  void dispose() {
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
        content: Text(
          'Voulez-vous vraiment supprimer « ${plat.nom} » de votre menu ?',
        ),
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
        appBar: const QuickEatAppBar(title: 'Mes Plats'),
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
            if (controller.plats.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Aucun plat dans votre menu pour le moment',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
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
          },
        ),
      ),
    );
  }
}
