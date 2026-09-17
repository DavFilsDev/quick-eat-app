// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quickeat/data/repositories/order_repository.dart';
import 'package:quickeat/features/orders/presentation/student/controllers/student_orders_controller.dart';
import 'package:quickeat/features/orders/presentation/student/widgets/create_order_modal.dart';
import 'package:quickeat/models/enums/delivery_type.dart';
import 'package:quickeat/models/food_model.dart';
import 'package:quickeat/models/order_model.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class _FakeOrderModel extends Fake implements OrderModel {}

String _currency(num value) {
  return NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  ).format(value);
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeOrderModel());
  });

  late MockOrderRepository mockRepository;
  late StudentOrdersController controller;

  const food = FoodModel(
    idFood: 'food1',
    nom: 'Riz sauce arachide',
    prix: 2500,
    idCommercant: 'com1',
  );

  setUp(() {
    mockRepository = MockOrderRepository();
    controller = StudentOrdersController(
      orderRepository: mockRepository,
      idEtudiant: 'etu1',
    );
  });

  Future<void> pumpModal(WidgetTester tester) {
    // Surface de test élargie (800 × 1200) : le `SingleChildScrollView` de la
    // modale rend le contenu scrollable, mais les tests qui tapent sur les
    // boutons de quantité et le bouton de confirmation ont besoin que tout le
    // contenu soit visible (motif `scroll jusqu'à l'élément hors écran`).
    // Sans cette surface, `tester.tap` échoue : offset en dehors des bornes
    // (800 × 600) → « would not hit test on the specified widget ».
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) =>
                    CreateOrderModal(food: food, controller: controller),
              ),
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'Widget test modale : ouverture affiche le plat, le prix et la quantité initiale',
    (tester) async {
      await pumpModal(tester);

      // Fermée au départ.
      expect(find.textContaining('Riz sauce arachide'), findsNothing);

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // Ouverture : contenu affiché.
      expect(find.text('Confirmer votre commande'), findsOneWidget);
      expect(find.textContaining('Riz sauce arachide'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'Widget test modale : la croix ferme la modale sans créer de commande',
    (tester) async {
      await pumpModal(tester);
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bouton_fermer_modale')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Riz sauce arachide'), findsNothing);
      verifyNever(() => mockRepository.creerCommande(any()));
    },
  );

  testWidgets(
    'Test : calcul du montant total dans la modale (quantité × prix unitaire)',
    (tester) async {
      await pumpModal(tester);
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // 1 × 2500 FCFA au départ.
      expect(
        tester.widget<Text>(find.byKey(const Key('valeur_montant_total'))).data,
        _currency(2500),
      );

      await tester.tap(find.byKey(const Key('bouton_incrementer_quantite')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('bouton_incrementer_quantite')));
      await tester.pump();

      // 3 × 2500 FCFA après deux incréments.
      expect(find.text('3'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('valeur_montant_total'))).data,
        _currency(7500),
      );

      await tester.tap(find.byKey(const Key('bouton_decrementer_quantite')));
      await tester.pump();

      // Retour à 2 × 2500 FCFA après un décrément.
      expect(find.text('2'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('valeur_montant_total'))).data,
        _currency(5000),
      );
    },
  );

  testWidgets(
    'Widget test modale : validation → "Valider la commande" désactive '
    'le bouton pendant la création, appelle le repository avec les bons '
    'paramètres puis ferme la modale au succès',
    (tester) async {
      final completer = Completer<String>();
      when(() => mockRepository.creerCommande(any()))
          .thenAnswer((_) => completer.future);

      await pumpModal(tester);
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // L'étudiant choisit Livraison (déjà sélectionné par défaut, on
      // vérifie explicitement le choix inverse pour prouver que le
      // sélecteur fonctionne) puis augmente la quantité à 2.
      await tester.tap(find.byKey(const Key('choix_retrait')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('choix_livraison')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('bouton_incrementer_quantite')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('bouton_confirmer_commande')));
      await tester.pump();

      // Pendant la création : bouton désactivé, indicateur visible.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final bouton = tester.widget<ElevatedButton>(
        find.byKey(const Key('bouton_confirmer_commande')),
      );
      expect(bouton.onPressed, isNull);

      completer.complete('cmd123');
      await tester.pumpAndSettle();

      final captured =
          verify(() => mockRepository.creerCommande(captureAny()))
                  .captured
                  .single
              as OrderModel;

      expect(captured.idEtudiant, 'etu1');
      expect(captured.idCommercant, 'com1');
      expect(captured.typeReception, DeliveryType.livraison);
      expect(captured.items.single.quantite, 2);
      expect(captured.montantTotal, 5000);

      // Fermeture : la modale n'est plus affichée.
      expect(find.textContaining('Riz sauce arachide'), findsNothing);
    },
  );

  testWidgets(
    "Widget test modale : en cas d'échec, un message d'erreur s'affiche et "
    'la modale reste ouverte',
    (tester) async {
      when(() => mockRepository.creerCommande(any()))
          .thenThrow(Exception('network error'));

      await pumpModal(tester);
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bouton_confirmer_commande')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Riz sauce arachide'), findsOneWidget);
      expect(find.text('Une erreur est survenue. Réessayez.'), findsOneWidget);
    },
  );
}
