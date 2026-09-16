import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/features/orders/presentation/student/widgets/order_card_student.dart';
import 'package:quickeat/models/enums/delivery_type.dart';
import 'package:quickeat/models/enums/order_status.dart';
import 'package:quickeat/models/order_item_model.dart';
import 'package:quickeat/models/order_model.dart';

OrderModel _commande({
  required OrderStatus statut,
  required DeliveryType typeReception,
}) {
  return OrderModel(
    idCommande: 'cmd123',
    idEtudiant: 'etu1',
    idCommercant: 'com1',
    dateCommande: DateTime.now(),
    montantTotal: 2500,
    typeReception: typeReception,
    statut: statut,
    items: const [
      OrderItemModel(
        idFood: 'food1',
        nom: 'Riz sauce arachide',
        quantite: 1,
        prixUnitaire: 2500,
      ),
    ],
  );
}

Future<void> _pump(WidgetTester tester, OrderModel commande) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: OrderCardStudent(
          commande: commande,
          onCancel: () {},
          onConfirmReception: () {},
        ),
      ),
    ),
  );
}

void main() {
  group('Test : bouton "Annuler la commande"', () {
    testWidgets('apparaît quand statut == EN_ATTENTE', (tester) async {
      await _pump(
        tester,
        _commande(
          statut: OrderStatus.enAttente,
          typeReception: DeliveryType.retrait,
        ),
      );

      expect(find.byKey(const Key('bouton_annuler_commande')), findsOneWidget);
    });

    testWidgets("n'apparaît pas si statut != EN_ATTENTE", (tester) async {
      for (final statut in OrderStatus.values.where(
        (s) => s != OrderStatus.enAttente,
      )) {
        await _pump(
          tester,
          _commande(statut: statut, typeReception: DeliveryType.retrait),
        );

        expect(
          find.byKey(const Key('bouton_annuler_commande')),
          findsNothing,
          reason: 'Le bouton Annuler ne doit pas apparaître pour $statut',
        );
      }
    });
  });

  group('Test : bouton "Confirmer la réception"', () {
    testWidgets("n'apparaît que pour LIVRAISON + EN_COURS_DE_LIVRAISON", (
      tester,
    ) async {
      // Cas positif.
      await _pump(
        tester,
        _commande(
          statut: OrderStatus.enCoursDeLivraison,
          typeReception: DeliveryType.livraison,
        ),
      );
      expect(
        find.byKey(const Key('bouton_confirmer_reception')),
        findsOneWidget,
      );

      // Même statut mais RETRAIT : le commerçant confirme, pas l'étudiant.
      await _pump(
        tester,
        _commande(
          statut: OrderStatus.enCoursDeLivraison,
          typeReception: DeliveryType.retrait,
        ),
      );
      expect(find.byKey(const Key('bouton_confirmer_reception')), findsNothing);

      // LIVRAISON mais mauvais statut.
      for (final statut in OrderStatus.values.where(
        (s) => s != OrderStatus.enCoursDeLivraison,
      )) {
        await _pump(
          tester,
          _commande(statut: statut, typeReception: DeliveryType.livraison),
        );
        expect(
          find.byKey(const Key('bouton_confirmer_reception')),
          findsNothing,
          reason:
              'Le bouton Confirmer la réception ne doit pas apparaître pour $statut',
        );
      }
    });
  });

  testWidgets(
    'badge "Prêt à récupérer" visible pour RETRAIT + TERMINEE, sans action étudiant',
    (tester) async {
      await _pump(
        tester,
        _commande(
          statut: OrderStatus.terminee,
          typeReception: DeliveryType.retrait,
        ),
      );

      expect(find.text('Terminé (Prêt à récupérer)'), findsOneWidget);
      // Rappel de la règle métier : aucune action pour l'étudiant ici,
      // c'est le commerçant qui confirme RECU à la remise physique.
      expect(find.byKey(const Key('bouton_confirmer_reception')), findsNothing);
      expect(find.byKey(const Key('bouton_annuler_commande')), findsNothing);
    },
  );
}
