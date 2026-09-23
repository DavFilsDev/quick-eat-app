import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/quick_eat_app_bar.dart';
import '../../../../../routes/app_router.dart';
import '../../../../shell/presentation/layouts/main_layout.dart';
import '../controllers/merchant_orders_controller.dart';
import '../widgets/merchant_orders_scope.dart';
import '../widgets/merchant_order_card.dart';

class MerchantHomeScreen extends StatelessWidget {
  const MerchantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MerchantOrdersScope(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: QuickEatAppBar(
          onOuvrirCommandes: () =>
              context.read<MainLayoutController?>()?.select(0),
          actions: [
            Consumer<MerchantOrdersController>(
              builder: (context, controller, child) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.enCoursCount} EN COURS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage != null) {
              return Center(child: Text(controller.errorMessage!));
            }
            final orders = controller.orders;
            if (orders.isEmpty) {
              return const Center(
                child: Text('Aucune commande pour le moment.'),
              );
            }

            return ListView.builder(
              itemCount: orders.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final order = orders[index];

                return MerchantOrderCard(
                  order: order,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.merchantOrderDetail,
                      arguments: order.idCommande,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
