import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/core/theme/app_theme.dart';

// NOTE : l'ancien smoke test pompait QuickEatApp() directement, mais
// QuickEatApp démarre maintenant sur AuthGate, qui appelle
// FirebaseAuth.instance / FirebaseFirestore.instance — impossible sans
// initialiser Firebase (absent en environnement de test).
//
// TODO(Dev 1 - feat/auth-onboarding) : réintroduire un smoke test complet
// en injectant des AuthRepository/UserRepository mockés (mocktail, déjà
// ajouté aux dev_dependencies) au lieu des implémentations Firebase.
void main() {
  test('Le thème de l\'application se construit sans erreur', () {
    expect(AppTheme.lightTheme, isNotNull);
  });
}
