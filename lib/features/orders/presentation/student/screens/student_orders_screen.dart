import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/widgets/quick_eat_app_bar.dart';
import '../../../../../data/repositories/order_repository.dart';
import '../../../../../models/enums/order_status.dart';
import '../../../../../models/order_model.dart';
import '../controllers/student_orders_controller.dart';
import '../widgets/order_card_student.dart';

class StudentOrdersScreen extends StatelessWidget {
  const StudentOrdersScreen({super.key});

  static OrderRepository _resolveOrderRepository(BuildContext context) {
    try {
      return context.read<OrderRepository>();
    } catch (_) {
      return FirestoreOrderRepository();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StudentOrdersController>(
      create: (context) => StudentOrdersController(
        orderRepository: _resolveOrderRepository(context),
        idEtudiant: FirebaseAuth.instance.currentUser?.uid ?? '',
      )..startListening(),
      child: const _StudentOrdersView(),
    );
  }
}

class _StudentOrdersView extends StatelessWidget {
  const _StudentOrdersView();

  static const _statutsTermines = {
    OrderStatus.livree,
    OrderStatus.recu,
    OrderStatus.annulee,
  };

  Future<void> _annuler(BuildContext context, String idCommande) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler la commande'),
        content: const Text(
          'Veux-tu vraiment annuler cette commande ? Cette action est définitive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (confirme != true || !context.mounted) return;

    final controller = context.read<StudentOrdersController>();
    final succes = await controller.annulerCommande(idCommande);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          succes
              ? 'Commande annulée.'
              : controller.errorMessage ?? 'Une erreur est survenue.',
        ),
      ),
    );
  }

  Future<void> _confirmerReception(
    BuildContext context,
    String idCommande,
  ) async {
    final controller = context.read<StudentOrdersController>();
    final succes = await controller.confirmerReception(idCommande);
    if (!context.mounted) return;
    if (!succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Une erreur est survenue.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StudentOrdersController>();
    final nbActives = controller.orders
        .where((o) => !_statutsTermines.contains(o.statut))
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const QuickEatAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _EnTeteMesCommandes(nbActives: nbActives),
            Expanded(child: _corps(controller, context)),
          ],
        ),
      ),
    );
  }

  Widget _corps(StudentOrdersController controller, BuildContext context) {
    switch (controller.status) {
      case StudentOrdersStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case StudentOrdersStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              controller.errorMessage ?? 'Une erreur est survenue.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ),
        );
      case StudentOrdersStatus.success:
        if (controller.orders.isEmpty) {
          return const Center(child: Text('Aucune commande pour le moment.'));
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return GridView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 320,
                ),
                itemCount: controller.orders.length,
                itemBuilder: (context, index) =>
                    _carte(context, controller.orders[index]),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: controller.orders.length,
              itemBuilder: (context, index) =>
                  _carte(context, controller.orders[index]),
            );
          },
        );
    }
  }

  Widget _carte(BuildContext context, OrderModel commande) {
    return OrderCardStudent(
      commande: commande,
      onConfirmReception: () =>
          _confirmerReception(context, commande.idCommande),
      onCancel: () => _annuler(context, commande.idCommande),
    );
  }
}

class _EnTeteMesCommandes extends StatelessWidget {
  const _EnTeteMesCommandes({required this.nbActives});

  final int nbActives;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mes Commandes', style: AppTextStyles.heading1),
                const SizedBox(height: 2),
                Text(
                  'Suivi en direct de vos repas sur le campus',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Container(
            key: const Key('badge_commandes_actives'),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  '$nbActives active${nbActives > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
