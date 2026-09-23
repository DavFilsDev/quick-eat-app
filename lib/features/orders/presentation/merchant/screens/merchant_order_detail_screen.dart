import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../models/enums/delivery_type.dart';
import '../../../../../models/enums/order_status.dart';
import '../../../../../models/order_model.dart';
import '../../../../../models/order_item_model.dart';
import '../../../../../models/user_model.dart';
import '../controllers/merchant_orders_controller.dart';
import '../../../../../core/widgets/dish_thumbnail.dart';
import '../widgets/merchant_orders_scope.dart';
import '../widgets/order_progress_bar.dart';

class MerchantOrderDetailScreen extends StatefulWidget {
  final String idCommande;

  const MerchantOrderDetailScreen({super.key, required this.idCommande});

  @override
  State<MerchantOrderDetailScreen> createState() =>
      _MerchantOrderDetailScreenState();
}

class _MerchantOrderDetailScreenState extends State<MerchantOrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return MerchantOrdersScope(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COMMANDE ACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Détails de la commande',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            Consumer<MerchantOrdersController>(
              builder: (context, controller, child) {
                final o = controller.orders.where(
                  (o) => o.idCommande == widget.idCommande,
                );
                if (o.isEmpty) return const SizedBox.shrink();
                final delivery =
                    o.first.typeReception == DeliveryType.livraison;
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: delivery
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            delivery ? Icons.directions_walk : Icons.storefront,
                            size: 14,
                            color: delivery
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            delivery ? 'À LIVRER' : 'SUR PLACE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: delivery
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<MerchantOrdersController>(
          builder: (context, controller, child) {
            final orders = controller.orders;
            final orderIndex = orders.indexWhere(
              (o) => o.idCommande == widget.idCommande,
            );

            if (orderIndex == -1) {
              return const Center(child: CircularProgressIndicator());
            }

            final order = orders[orderIndex];

            final steps = [OrderStatus.enAttente, ...order.statutsMarchand];
            final nextStatus = _getNextStatus(order);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statut de la commande',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          OrderProgressBar(
                            currentStatus: order.statut,
                            steps: steps,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: steps
                                .map(
                                  (s) => Text(
                                    s.label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: order.statut == s
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      fontWeight: order.statut == s
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'CLIENT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: StreamBuilder<UserModel?>(
                      stream: context
                          .read<MerchantOrdersController>()
                          .streamStudentInfo(order.idEtudiant),
                      builder: (context, snapshot) {
                        final enChargement =
                            snapshot.connectionState == ConnectionState.waiting;
                        final etudiant = snapshot.hasData
                            ? snapshot.data
                            : null;
                        final introuvable =
                            order.idEtudiant.trim().isEmpty ||
                            !snapshot.hasData;

                        return ListTile(
                          leading: _AvatarEtudiant(
                            photoUrl: etudiant?.photoUrl,
                            nom: etudiant?.nomComplet ?? '',
                          ),
                          title: Text(
                            enChargement
                                ? 'Chargement...'
                                : (etudiant?.nomComplet ??
                                      'Étudiant non renseigné'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: _InformationsClient(
                            etudiant: etudiant,
                            isLoading: enChargement,
                            introuvable: introuvable,
                            typeReception: order.typeReception,
                            adresseLivraison: order.adresseLivraison,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.statusAccepted.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  size: 14,
                                  color: AppColors.statusAccepted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Client vérifié',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.statusAccepted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'PLATS COMMANDÉS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          DishThumbnail(
                            imageUrl: order.items.isNotEmpty
                                ? order.items.first.imageUrl
                                : null,
                            size: 56,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _platsSummary(order.items),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${order.items.length} plat(s)',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total à encaisser',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${order.montantTotal.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (nextStatus != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _updateStatus(
                          context,
                          order.idCommande,
                          nextStatus,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(_actionLabel(order, nextStatus)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _actionHint(order, nextStatus),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  OrderStatus? _getNextStatus(OrderModel order) {
    if (order.statut == OrderStatus.annulee ||
        order.statut == OrderStatus.recu ||
        order.statut == OrderStatus.livree) {
      return null;
    }

    final merchantSteps = order.statutsMarchand;

    if (order.statut == OrderStatus.enAttente) {
      return merchantSteps.first;
    }

    final currentIndex = merchantSteps.indexOf(order.statut);
    if (currentIndex == -1 || currentIndex == merchantSteps.length - 1) {
      return null;
    }

    final next = merchantSteps[currentIndex + 1];

    if (next == OrderStatus.livree) {
      return null;
    }

    return next;
  }

  Future<void> _updateStatus(
    BuildContext context,
    String orderId,
    OrderStatus nextStatus,
  ) async {
    try {
      await context.read<MerchantOrdersController>().updateOrderStatus(
        orderId,
        nextStatus,
      );
    } catch (e) {
      if (context.mounted) {
        final message = e is Failure
            ? e.message
            : 'Erreur lors de la mise à jour du statut. Réessayez.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _platsSummary(List<OrderItemModel> items) {
    if (items.isEmpty) return 'Commande';
    final first = items.first;
    final rest = items.length - 1;
    return rest > 0
        ? '${first.quantite}× ${first.nom} +$rest autre(s)'
        : '${first.quantite}× ${first.nom}';
  }

  String _actionLabel(OrderModel order, OrderStatus nextStatus) {
    if (nextStatus == OrderStatus.recu) {
      return 'Reçu par le client';
    }
    return 'Passer à : ${nextStatus.label}';
  }

  String _actionHint(OrderModel order, OrderStatus nextStatus) {
    final count = order.items.fold<int>(0, (sum, i) => sum + i.quantite);
    switch (nextStatus) {
      case OrderStatus.acceptee:
        return 'Valide la préparation des $count plats en cuisine.';
      case OrderStatus.enCoursDeLivraison:
        return 'La commande part en livraison.';
      case OrderStatus.terminee:
        return 'Marque la commande comme prête pour le retrait.';
      case OrderStatus.recu:
        return 'Confirme la réception de la commande.';
      default:
        return '';
    }
  }
}

class _AvatarEtudiant extends StatelessWidget {
  const _AvatarEtudiant({required this.photoUrl, required this.nom});

  final String? photoUrl;
  final String nom;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;

    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.brown.shade100,
      child: ClipOval(
        child: url == null || url.isEmpty
            ? _Initiales(nom: nom)
            : AppImage(
                value: url,
                width: 48,
                height: 48,
                placeholder: _Initiales(nom: nom),
                errorWidget: _Initiales(nom: nom),
              ),
      ),
    );
  }
}

class _Initiales extends StatelessWidget {
  const _Initiales({required this.nom});

  final String nom;

  @override
  Widget build(BuildContext context) {
    final parties = nom.trim().split(RegExp(r'\s+'));
    final initiales = parties
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: initiales.isEmpty
            ? Icon(Icons.person, size: 24, color: Colors.brown.shade600)
            : Text(
                initiales,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade700,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

class _InformationsClient extends StatelessWidget {
  const _InformationsClient({
    required this.etudiant,
    required this.isLoading,
    required this.introuvable,
    required this.typeReception,
    required this.adresseLivraison,
  });

  final UserModel? etudiant;
  final bool isLoading;
  final bool introuvable;
  final DeliveryType typeReception;
  final String? adresseLivraison;

  @override
  Widget build(BuildContext context) {
    final champ = isLoading ? 'Chargement...' : '';
    final telephone = isLoading
        ? champ
        : (introuvable ? '' : (etudiant?.telephone ?? ''));
    final campus = isLoading ? champ : (etudiant?.campus ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (telephone.trim().isNotEmpty)
          Text(telephone, style: AppTextStyles.caption),
        Text(
          typeReception == DeliveryType.livraison
              ? 'Livraison : ${adresseLivraison ?? 'Lieu non spécifié'}'
              : 'Campus ${campus.isEmpty ? 'non renseigné' : campus}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
