import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quickeat/data/repositories/menu_repository.dart';
import 'package:quickeat/features/menu_management/presentation/screens/merchant_menu_screen.dart';
import 'package:quickeat/features/menu_management/presentation/widgets/menu_item_tile.dart';
import 'package:quickeat/models/food_model.dart';
import 'package:quickeat/models/user_model.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  const plats = <FoodModel>[
    FoodModel(
      idFood: 'f1',
      nom: 'Burger',
      prix: 1500,
      categorie: 'Fast Food',
      idCommercant: 'user-004',
    ),
    FoodModel(
      idFood: 'f2',
      nom: 'Pizza',
      prix: 3500,
      categorie: 'Pizza',
      idCommercant: 'user-004',
    ),
    FoodModel(
      idFood: 'f3',
      nom: 'Coca',
      prix: 500,
      categorie: 'Boisson',
      idCommercant: 'user-004',
    ),
  ];

  Widget sujet(MenuRepository repository) {
    return MaterialApp(
      home: MerchantMenuScreen(
        menuRepository: repository,
        idCommercant: 'user-004',
        userStream: const Stream<UserModel?>.empty(),
      ),
    );
  }

  setUpAll(() {
    registerFallbackValue(
      const FoodModel(
        idFood: 'fallback',
        nom: 'Fallback',
        prix: 1,
        idCommercant: 'fallback',
      ),
    );
  });

  testWidgets("affiche le message d'état vide", (tester) async {
    final repository = MockMenuRepository();
    when(() => repository.streamMenusParCommercant('user-004'))
        .thenAnswer((_) => Stream.value(const <FoodModel>[]));

    await tester.pumpWidget(sujet(repository));
    await tester.pump();

    expect(
      find.text(
        "Vous n'avez pas encore de plat dans votre menu. Cliquez sur + pour en ajouter un.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('filtre la liste par recherche', (tester) async {
    final repository = MockMenuRepository();
    when(() => repository.streamMenusParCommercant('user-004'))
        .thenAnswer((_) => Stream.value(plats));

    await tester.pumpWidget(sujet(repository));
    await tester.pump();

    expect(find.byType(MenuItemTile), findsNWidgets(3));

    await tester.enterText(find.byKey(const Key('recherche_plat')), 'piz');
    await tester.pump();

    expect(find.byType(MenuItemTile), findsOneWidget);
    expect(
      tester.widget<MenuItemTile>(find.byType(MenuItemTile)).food.idFood,
      'f2',
    );
  });

  testWidgets('filtre la liste par catégorie', (tester) async {
    final repository = MockMenuRepository();
    when(() => repository.streamMenusParCommercant('user-004'))
        .thenAnswer((_) => Stream.value(plats));

    await tester.pumpWidget(sujet(repository));
    await tester.pump();

    await tester.tap(find.byKey(const Key('categorie_Boisson')));
    await tester.pump();

    expect(find.byType(MenuItemTile), findsOneWidget);
    expect(
      tester.widget<MenuItemTile>(find.byType(MenuItemTile)).food.idFood,
      'f3',
    );
  });

  testWidgets('trie la liste par prix décroissant', (tester) async {
    final repository = MockMenuRepository();
    when(() => repository.streamMenusParCommercant('user-004'))
        .thenAnswer((_) => Stream.value(plats));

    await tester.pumpWidget(sujet(repository));
    await tester.pump();

    await tester.tap(find.byKey(const Key('tri_plats')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prix décroissant').last);
    await tester.pumpAndSettle();

    final ids = tester
        .widgetList<MenuItemTile>(find.byType(MenuItemTile))
        .map((tile) => tile.food.idFood)
        .toList();
    expect(ids, ['f2', 'f1', 'f3']);
  });
}
