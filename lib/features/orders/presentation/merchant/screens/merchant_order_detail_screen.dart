import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../models/enums/delivery_type.dart';
import '../../../../../models/enums/order_status.dart';
import '../../../../../models/order_model.dart';
import '../../../../../models/order_item_model.dart';
import '../../../../../models/user_model.dart';
import '../controllers/merchant_orders_controller.dart';
import '../widgets/order_progress_bar.dart';
import '../widgets/merchant_orders_scope.dart';

class MerchantOrderDetailScreen extends StatefulWidget {
  final String idCommande;

  const MerchantOrderDetailScreen({super.key, required this.idCommande});

  @override
  State<MerchantOrderDetailScreen> createState() =>
      _MerchantOrderDetailScreenState();
}

class _MerchantOrderDetailScreenState extends State<MerchantOrderDetailScreen> {
  UserModel? _student;
  bool _isLoadingStudent = true;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchStudentInfoById(String studentId) async {
    if (_isFetching || !mounted) return;

    _isFetching = true;

    try {
      final controller = context.read<MerchantOrdersController>();
      final student = await controller.getStudentInfo(studentId);
      if (mounted) {
        setState(() {
          _student = student;
          _isLoadingStudent = false;
        });
      }
    } finally {
      _isFetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MerchantOrdersScope(
      child: Scaffold(
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
                'Détails #QE-${widget.idCommande.substring(0, 3).toUpperCase()}',
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
                            ? Colors.orange.shade50
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            delivery ? Icons.delivery_dining : Icons.storefront,
                            size: 14,
                            color: delivery
                                ? Colors.deepOrange
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            delivery ? 'À LIVRER' : 'SUR PLACE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: delivery
                                  ? Colors.deepOrange
                                  : Colors.grey.shade700,
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

            if (_student == null && !_isFetching) {
              Future.microtask(() => _fetchStudentInfoById(order.idEtudiant));
            }

            final steps = [OrderStatus.enAttente, ...order.statutsMarchand];
            final nextStatus = _getNextStatus(order);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
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
                                          : Colors.grey,
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
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFFFDCB4),
                        child: Text(
                          _initials(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      title: Text(
                        _isLoadingStudent
                            ? 'Chargement...'
                            : (_student?.nomComplet ?? 'Inconnu'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        order.typeReception == DeliveryType.livraison
                            ? 'Livraison : ${order.adresseLivraison ?? 'Non précisée'}'
                            : 'Campus ${_student?.campus ?? '...'}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Client vérifié',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'PLATS COMMANDÉS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.deepOrange,
                              size: 26,
                            ),
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
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
                          backgroundColor: const Color(0xFFC0392B),
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
                            Text('Passer à : ${nextStatus.label}'),
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

  String _initials() {
    final s = _student;
    if (s == null) return '?';
    final parts = '${s.prenoms} ${s.nom}'
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    return ((parts.isNotEmpty ? parts.first[0] : '') +
            (parts.length > 1 ? parts.last[0] : ''))
        .toUpperCase();
  }

  String _platsSummary(List<OrderItemModel> items) {
    if (items.isEmpty) return 'Commande';
    final first = items.first;
    final rest = items.length - 1;
    return rest > 0
        ? '${first.quantite}× ${first.nom} +$rest autre(s)'
        : '${first.quantite}× ${first.nom}';
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
