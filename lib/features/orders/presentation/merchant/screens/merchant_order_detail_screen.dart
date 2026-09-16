import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../models/enums/delivery_type.dart';
import '../../../../../models/enums/order_status.dart';
import '../../../../../models/order_model.dart';
import '../../../../../models/user_model.dart';
import '../controllers/merchant_orders_controller.dart';
import '../widgets/order_progress_bar.dart';

class MerchantOrderDetailScreen extends StatefulWidget {
  final String idCommande;

  const MerchantOrderDetailScreen({super.key, required this.idCommande});

  @override
  State<MerchantOrderDetailScreen> createState() => _MerchantOrderDetailScreenState();
}

class _MerchantOrderDetailScreenState extends State<MerchantOrderDetailScreen> {
  UserModel? _student;
  bool _isLoadingStudent = true;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchStudentInfo();
  }

  Future<void> _fetchStudentInfo() async {
    if (_isFetching || !mounted) return;
    
    final controller = context.read<MerchantOrdersController>();
    final orders = controller.orders;
    
    final orderIndex = orders.indexWhere((o) => o.idCommande == widget.idCommande);
    if (orderIndex == -1) return;
    
    _isFetching = true;
    final order = orders[orderIndex];

    try {
      final student = await controller.getStudentInfo(order.idEtudiant);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Détail Commande')),
      body: Consumer<MerchantOrdersController>(
        builder: (context, controller, child) {
          final orders = controller.orders;
          final orderIndex = orders.indexWhere((o) => o.idCommande == widget.idCommande);
          
          if (orderIndex == -1) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_isLoadingStudent && _student == null && !_isFetching) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _fetchStudentInfo());
          }
          
          final order = orders[orderIndex];

          final steps = [OrderStatus.enAttente, ...order.statutsMarchand];
          final nextStatus = _getNextStatus(order);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progression
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
                        OrderProgressBar(currentStatus: order.statut, steps: steps),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: steps.map((s) => Text(
                            s.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: order.statut == s ? AppColors.primary : Colors.grey,
                              fontWeight: order.statut == s ? FontWeight.bold : FontWeight.normal,
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Infos Client
                const Text('Client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(_isLoadingStudent ? 'Chargement...' : (_student?.nomComplet ?? 'Inconnu')),
                    subtitle: Text(
                      order.typeReception == DeliveryType.livraison
                          ? 'Livraison : ${order.adresseLivraison ?? 'Non précisée'}'
                          : 'Retrait sur place (Campus : ${_student?.campus ?? '...'})',
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Plats
                const Text('Articles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return ListTile(
                        title: Text(item.nom),
                        trailing: Text('x${item.quantite}'),
                        subtitle: Text('${item.prixUnitaire.toStringAsFixed(0)} FCFA'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(
                      '${order.montantTotal.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Action Button
                if (nextStatus != null)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(context, order.idCommande, nextStatus),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Passer à : ${nextStatus.label}'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  OrderStatus? _getNextStatus(OrderModel order) {
    if (order.statut == OrderStatus.annulee || order.statut == OrderStatus.recu || order.statut == OrderStatus.livree) {
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

    // Si la prochaine étape est LIVREE, elle dépend de l'étudiant
    if (next == OrderStatus.livree) {
      return null;
    }

    return next;
  }

  Future<void> _updateStatus(BuildContext context, String orderId, OrderStatus nextStatus) async {
    try {
      await context.read<MerchantOrdersController>().updateOrderStatus(orderId, nextStatus);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
