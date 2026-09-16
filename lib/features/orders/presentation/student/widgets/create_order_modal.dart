import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../data/repositories/order_repository.dart';
import '../../../../../models/enums/delivery_type.dart';
import '../../../../../models/food_model.dart';
import '../controllers/student_orders_controller.dart';

/// Modale "Confirmer votre commande" (maquette `Accueil Étudiant Modal
/// Commande`), ouverte depuis l'écran d'accueil (Dev1) via le contrat
/// fixé : `CreateOrderModal.show(context, food: food)`.
///
/// Le widget prend un [controller] en paramètre (plutôt que de le
/// construire lui-même) pour rester testable sans Firebase réel — c'est
/// `show()` qui câble les vraies dépendances (repository + utilisateur
/// connecté).
class CreateOrderModal extends StatefulWidget {
  const CreateOrderModal({
    super.key,
    required this.food,
    required this.controller,
  });

  final FoodModel food;
  final StudentOrdersController controller;

  /// Point d'entrée utilisé par les autres écrans (contrat fixé par le
  /// Lead). Résout `OrderRepository` via `Provider` si l'app l'expose plus
  /// haut dans l'arbre de widgets, avec un repli sur
  /// `FirestoreOrderRepository` sinon — à ajuster selon la façon dont le
  /// Lead a câblé les providers dans `app.dart`.
  static Future<bool> show(BuildContext context, {required FoodModel food}) {
    final controller = StudentOrdersController(
      orderRepository: _resolveOrderRepository(context),
      idEtudiant: FirebaseAuth.instance.currentUser?.uid ?? '',
    );

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateOrderModal(food: food, controller: controller),
    ).then((resultat) => resultat ?? false);
  }

  static OrderRepository _resolveOrderRepository(BuildContext context) {
    try {
      return context.read<OrderRepository>();
    } catch (_) {
      return FirestoreOrderRepository();
    }
  }

  @override
  State<CreateOrderModal> createState() => _CreateOrderModalState();
}

class _CreateOrderModalState extends State<CreateOrderModal> {
  DeliveryType _typeReception = DeliveryType.livraison;
  int _quantite = 1;

  static const int _quantiteMin = 1;
  static const int _quantiteMax = 20;

  double get _montantTotal => widget.food.prix * _quantite;

  void _incrementer() {
    if (_quantite >= _quantiteMax) return;
    setState(() => _quantite++);
  }

  void _decrementer() {
    if (_quantite <= _quantiteMin) return;
    setState(() => _quantite--);
  }

  Future<void> _confirmer() async {
    final succes = await widget.controller.creerCommande(
      food: widget.food,
      typeReception: _typeReception,
      quantite: _quantite,
    );
    if (!mounted) return;
    if (succes) Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final isSubmitting = widget.controller.isCreatingOrder;
        final erreur = widget.controller.creationErrorMessage;

        // Responsive : largeur plafonnée sur grand écran (tablette/web),
        // pleine largeur sur mobile.
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            // Scroll intérieur : le contenu (mode de réception, quantité,
            // total, bouton) est plus grand que la hauteur disponible quand
            // la modale est ouverte sur un petit écran avec le clavier
            // (maquette `Modal Commande` + `isScrollControlled`). Sans
            // `SingleChildScrollView`, le `Column` déborde (RenderFlex
            // overflow) et les boutons du bas deviennent hors d'atteinte.
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Confirmer votre commande',
                          style: AppTextStyles.heading1,
                        ),
                      ),
                      IconButton(
                        key: const Key('bouton_fermer_modale'),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Text(
                    "${widget.food.nom} (${currency.format(widget.food.prix)} l'unité)",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Mode de réception', style: AppTextStyles.heading2),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ModeReceptionCard(
                          key: const Key('choix_livraison'),
                          icon: Icons.two_wheeler,
                          label: 'Livraison',
                          selectionnee:
                              _typeReception == DeliveryType.livraison,
                          onTap: () => setState(
                            () => _typeReception = DeliveryType.livraison,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModeReceptionCard(
                          key: const Key('choix_retrait'),
                          icon: Icons.storefront,
                          label: 'À récupérer sur place',
                          selectionnee: _typeReception == DeliveryType.retrait,
                          onTap: () => setState(
                            () => _typeReception = DeliveryType.retrait,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Quantité', style: AppTextStyles.heading2),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _BoutonQuantite(
                        key: const Key('bouton_decrementer_quantite'),
                        icon: Icons.remove,
                        onTap: _quantite > _quantiteMin ? _decrementer : null,
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '$_quantite',
                        key: const Key('valeur_quantite'),
                        style: AppTextStyles.heading1,
                      ),
                      const SizedBox(width: 24),
                      _BoutonQuantite(
                        key: const Key('bouton_incrementer_quantite'),
                        icon: Icons.add,
                        onTap: _quantite < _quantiteMax ? _incrementer : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Montant total', style: AppTextStyles.heading2),
                      Text(
                        currency.format(_montantTotal),
                        key: const Key('valeur_montant_total'),
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                  if (erreur != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      erreur,
                      style: const TextStyle(color: AppColors.statusCancelled),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      key: const Key('bouton_confirmer_commande'),
                      onPressed: isSubmitting ? null : _confirmer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        isSubmitting
                            ? 'Envoi en cours...'
                            : 'Valider la commande',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      key: const Key('bouton_annuler_modale'),
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModeReceptionCard extends StatelessWidget {
  const _ModeReceptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.selectionnee,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selectionnee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selectionnee
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          border: Border.all(
            color: selectionnee ? AppColors.primary : Colors.grey.shade300,
            width: selectionnee ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selectionnee ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: selectionnee ? AppColors.primary : AppColors.textPrimary,
                fontWeight: selectionnee ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoutonQuantite extends StatelessWidget {
  const _BoutonQuantite({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final actif = onTap != null;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.background,
        ),
        child: Icon(
          icon,
          size: 18,
          color: actif
              ? AppColors.textPrimary
              : AppColors.textSecondary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
