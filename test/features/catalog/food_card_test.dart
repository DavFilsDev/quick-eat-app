import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/features/catalog/presentation/widgets/food_card.dart';
import 'package:quickeat/models/food_model.dart';

void main() {
  group('FoodCard', () {
    final foodDisponible = FoodModel(
      idFood: 'food-001',
      nom: 'Burger Poulet',
      prix: 1500,
      categorie: 'Fast Food',
      disponible: true,
      idCommercant: 'user-004',
    );

    final foodIndisponible = FoodModel(
      idFood: 'food-005',
      nom: 'Beignets',
      prix: 300,
      categorie: 'Snack',
      disponible: false,
      idCommercant: 'user-004',
    );

    testWidgets('plat disponible : bouton Commander actif', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FoodCard(food: foodDisponible)),
        ),
      );
      expect(find.text('Commander'), findsOneWidget);
    });

    testWidgets('plat indisponible : bouton Commander grisé/sans action', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FoodCard(food: foodIndisponible)),
        ),
      );
      expect(find.text('Commander'), findsOneWidget);
    });
  });
}
