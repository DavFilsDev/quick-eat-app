import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/features/orders/presentation/merchant/widgets/merchant_order_card.dart';
import 'package:quickeat/models/enums/delivery_type.dart';
import 'package:quickeat/models/enums/order_status.dart';
import 'package:quickeat/models/order_item_model.dart';
import 'package:quickeat/models/order_model.dart';

const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

OrderModel _order({required DeliveryType type, String? imageUrl}) {
  return OrderModel(
    idCommande: 'abcdef123',
    idEtudiant: 'etudiant-uid-secret',
    idCommercant: 'com1',
    dateCommande: DateTime.now().subtract(const Duration(minutes: 5)),
    montantTotal: 2500,
    typeReception: type,
    statut: OrderStatus.enAttente,
    items: [
      OrderItemModel(
        idFood: 'food1',
        nom: 'Riz sauce arachide',
        quantite: 2,
        prixUnitaire: 1250,
        imageUrl: imageUrl,
      ),
    ],
  );
}

Future<void> _pumpCard(
  WidgetTester tester,
  OrderModel order, {
  VoidCallback? onTap,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MerchantOrderCard(order: order, onTap: onTap ?? () {}),
      ),
    ),
  );
}

void main() {
  testWidgets('affiche le résumé du plat, masque les identifiants et utilise '
      'l\'icône livreur en livraison', (tester) async {
    await _pumpCard(tester, _order(type: DeliveryType.livraison));

    expect(find.text('2x Riz sauce arachide'), findsOneWidget);
    expect(find.textContaining('#QE-'), findsNothing);
    expect(find.text('etudiant-uid-secret'), findsNothing);
    expect(find.text('À livrer'), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
    expect(find.byIcon(Icons.storefront), findsNothing);
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
    expect(find.text('Détails'), findsOneWidget);
  });

  testWidgets('affiche "Sur place" avec l\'icône boutique en retrait', (
    tester,
  ) async {
    await _pumpCard(tester, _order(type: DeliveryType.retrait));

    expect(find.text('Sur place'), findsOneWidget);
    expect(find.byIcon(Icons.storefront), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsNothing);
  });

  testWidgets('affiche l\'image du plat quand elle est disponible', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      _order(
        type: DeliveryType.retrait,
        imageUrl: 'data:image/png;base64,$_pngBase64',
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.restaurant), findsNothing);
  });

  testWidgets('déclenche le callback au tap sur "Détails"', (tester) async {
    var tapped = false;
    await _pumpCard(
      tester,
      _order(type: DeliveryType.retrait),
      onTap: () => tapped = true,
    );

    await tester.tap(find.text('Détails'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
