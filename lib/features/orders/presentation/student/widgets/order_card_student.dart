import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../models/enums/delivery_type.dart';
import '../../../../../models/enums/order_status.dart';
import '../../../../../models/order_model.dart';

class OrderCardStudent extends StatelessWidget {
  const OrderCardStudent({
    super.key,
    required this.commande,
    this.onConfirmReception,
    this.onCancel,
  });

  final OrderModel commande;
  final VoidCallback? onConfirmReception;
  final VoidCallback? onCancel;

  bool get _peutConfirmerReception =>
      commande.typeReception == DeliveryType.livraison &&
      commande.statut == OrderStatus.enCoursDeLivraison;

  bool get _pretARecuperer =>
      commande.typeReception == DeliveryType.retrait &&
      commande.statut == OrderStatus.terminee;

  String get _statutLabel =>
      _pretARecuperer ? 'Terminé (Prêt à récupérer)' : commande.statut.label;

  _StatutVisuel get _statutVisuel {
    switch (commande.statut) {
      case OrderStatus.enAttente:
        return const _StatutVisuel(
          icon: Icons.hourglass_empty,
          color: AppColors.statusPending,
        );
      case OrderStatus.acceptee:
        return const _StatutVisuel(
          icon: Icons.check_circle_outline,
          color: AppColors.statusAccepted,
        );
      case OrderStatus.enCoursDeLivraison:
        return const _StatutVisuel(
          icon: Icons.delivery_dining,
          color: AppColors.statusInProgress,
        );
      case OrderStatus.livree:
      case OrderStatus.terminee:
      case OrderStatus.recu:
        return const _StatutVisuel(
          icon: Icons.check_circle,
          color: AppColors.statusDone,
        );
      case OrderStatus.annulee:
        return const _StatutVisuel(
          icon: Icons.cancel,
          color: AppColors.statusCancelled,
        );
    }
  }

  String? get _detailDroit {
    if (commande.statut == OrderStatus.enAttente) {
      return 'Attente confirmation resto';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    final statutVisuel = _statutVisuel;

    return LayoutBuilder(
      builder: (context, constraints) {
        final large = constraints.maxWidth > 480;

        return Card(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: large ? 24 : 16,
            vertical: 8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '#${_numeroCommande(commande.idCommande)}',
                                  style: AppTextStyles.heading2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _TagModeReception(
                                typeReception: commande.typeReception,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _sousTitre(commande),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currency.format(commande.montantTotal),
                      style: AppTextStyles.price,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...commande.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.nom, style: AppTextStyles.body),
                              Text(
                                'Quantité : x${item.quantite}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: statutVisuel.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statutVisuel.icon,
                        size: 18,
                        color: statutVisuel.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statutLabel,
                          style: TextStyle(
                            color: statutVisuel.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_detailDroit != null)
                        Flexible(
                          child: Text(
                            _detailDroit!,
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_peutConfirmerReception || commande.peutEtreAnnulee) ...[
                  const SizedBox(height: 12),
                  if (_peutConfirmerReception)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        key: const Key('bouton_confirmer_reception'),
                        onPressed: onConfirmReception,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Confirmer la réception (Livré)'),
                      ),
                    ),
                  if (commande.peutEtreAnnulee) ...[
                    if (_peutConfirmerReception) const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        key: const Key('bouton_annuler_commande'),
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.statusCancelled,
                          side: const BorderSide(
                            color: AppColors.statusCancelled,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Annuler la commande'),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _numeroCommande(String idCommande) {
    if (idCommande.isEmpty) return 'QE-000';
    final court = idCommande.length > 3
        ? idCommande.substring(idCommande.length - 3)
        : idCommande;
    return 'QE-$court'.toUpperCase();
  }

  String _sousTitre(OrderModel commande) {
    final delai = _texteDelai(commande.dateCommande);
    final adresse = commande.typeReception == DeliveryType.livraison
        ? commande.adresseLivraison
        : null;
    if (adresse != null && adresse.isNotEmpty) {
      return '$delai • $adresse';
    }
    return delai;
  }

  String _texteDelai(DateTime dateCommande) {
    final ecart = DateTime.now().difference(dateCommande);
    if (ecart.inMinutes < 1) return "À l'instant";
    if (ecart.inMinutes < 60) return 'Il y a ${ecart.inMinutes} minutes';
    if (ecart.inHours < 24) return "Aujourd'hui";
    return DateFormat('dd/MM/yyyy').format(dateCommande);
  }
}

class _StatutVisuel {
  const _StatutVisuel({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

class _TagModeReception extends StatelessWidget {
  const _TagModeReception({required this.typeReception});

  final DeliveryType typeReception;

  @override
  Widget build(BuildContext context) {
    final estLivraison = typeReception == DeliveryType.livraison;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            estLivraison ? Icons.directions_walk : Icons.storefront,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            estLivraison ? 'Livraison' : 'Sur place',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
