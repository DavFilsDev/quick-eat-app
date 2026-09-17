import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/catalog/presentation/screens/restaurant_detail_screen.dart';
import '../features/menu_management/presentation/screens/merchant_menu_screen.dart';
import '../features/orders/presentation/merchant/screens/merchant_order_detail_screen.dart';
import '../features/orders/presentation/student/screens/student_orders_screen.dart';
import '../features/profile/presentation/screens/merchant_profile_screen.dart';
import '../features/profile/presentation/screens/student_profile_screen.dart';
import '../features/shell/presentation/layouts/merchant_main_layout.dart';
import '../features/shell/presentation/layouts/student_main_layout.dart';

/// Toutes les routes de l'app sont déclarées ICI, une seule fois, par le
/// Tech Lead, AVANT le démarrage du sprint. Chaque développeur crée
/// uniquement le fichier d'écran pointé par sa route (voir le plan de
/// sprint) — personne ne doit plus modifier ce fichier pendant le sprint,
/// pour éviter tout conflit de merge. Les imports ci-dessus pointent vers
/// des écrans qui n'existent pas encore : ils seront ajoutés par chaque
/// dev sur sa propre branche via `flutter create`-style stub (voir
/// prérequis n°6).
class AppRouter {
  AppRouter._();

  // Auth (Dev 1)
  static const String login = '/login';
  static const String register = '/register';

  // Catalogue étudiant (Dev 2)
  static const String studentHome = '/student/home';
  static const String restaurantDetail = '/student/restaurant-detail';

  // Commandes étudiant (Dev 3)
  static const String studentOrders = '/student/orders';

  // Commandes commerçant (Dev 4)
  static const String merchantHome = '/merchant/home';
  static const String merchantOrderDetail = '/merchant/order-detail';

  // Menus & profils (Dev 5)
  static const String merchantMenuManagement = '/merchant/menus';
  static const String studentProfile = '/student/profile';
  static const String merchantProfile = '/merchant/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case studentHome:
        return MaterialPageRoute(builder: (_) => const StudentMainLayout());
      case restaurantDetail:
        return MaterialPageRoute(
          builder: (_) => RestaurantDetailScreen(
            idCommercant: settings.arguments as String,
          ),
        );
      case studentOrders:
        return MaterialPageRoute(builder: (_) => const StudentOrdersScreen());
      case merchantHome:
        return MaterialPageRoute(builder: (_) => const MerchantMainLayout());
      case merchantOrderDetail:
        return MaterialPageRoute(
          builder: (_) => MerchantOrderDetailScreen(
            idCommande: settings.arguments as String,
          ),
        );
      case merchantMenuManagement:
        return MaterialPageRoute(builder: (_) => const MerchantMenuScreen());
      case studentProfile:
        return MaterialPageRoute(builder: (_) => const StudentProfileScreen());
      case merchantProfile:
        return MaterialPageRoute(builder: (_) => const MerchantProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route non trouvée : ${settings.name}')),
          ),
        );
    }
  }
}
