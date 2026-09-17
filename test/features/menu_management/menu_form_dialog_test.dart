import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quickeat/data/repositories/menu_repository.dart';
import 'package:quickeat/features/menu_management/presentation/controllers/menu_management_controller.dart';
import 'package:quickeat/features/menu_management/presentation/widgets/menu_form_dialog.dart';
import 'package:quickeat/models/food_model.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class FakeFoodModel extends Fake implements FoodModel {}

void main() {
  late MockMenuRepository mockMenuRepository;
  late MenuManagementController controller;

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

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    controller = MenuManagementController(
      menuRepository: mockMenuRepository,
      idCommercant: 'user-004',
    );
  });

  tearDown(() => controller.dispose());

  Future<void> ouvrirFormulaire(WidgetTester tester, {FoodModel? plat}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              key: const Key('ouvrir_formulaire'),
              onPressed: () => MenuFormDialog.show(
                context,
                controller: controller,
                plat: plat,
              ),
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('ouvrir_formulaire')));
    await tester.pumpAndSettle();
  }

  Future<void> valider(WidgetTester tester) async {
    final finder = find.byKey(const Key('valider_plat'));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
  }

  testWidgets('affiche les erreurs de validation', (tester) async {
    await ouvrirFormulaire(tester);
    await valider(tester);

    expect(find.text('Le nom est requis'), findsOneWidget);
    expect(find.text('Le prix est requis'), findsOneWidget);
  });

  testWidgets('refuse un prix nul ou négatif', (tester) async {
    await ouvrirFormulaire(tester);
    await tester.enterText(find.byKey(const Key('champ_nom_plat')), 'Burger');
    await tester.enterText(find.byKey(const Key('champ_prix_plat')), '0');
    await valider(tester);

    expect(find.text('Le prix doit être supérieur à 0'), findsOneWidget);
  });

  testWidgets('crée un plat quand le formulaire est valide', (tester) async {
    when(() => mockMenuRepository.creerMenu(any()))
        .thenAnswer((_) async => 'food-x');

    await ouvrirFormulaire(tester);
    await tester.enterText(find.byKey(const Key('champ_nom_plat')), 'Burger');
    await tester.enterText(find.byKey(const Key('champ_prix_plat')), '1500');
    await valider(tester);
    await tester.pumpAndSettle();

    final capture =
        verify(() => mockMenuRepository.creerMenu(captureAny())).captured.single
            as FoodModel;
    expect(capture.nom, 'Burger');
    expect(capture.prix, 1500);
    expect(capture.idCommercant, 'user-004');
  });

  testWidgets('utilise la catégorie personnalisée quand "Autre" est choisi', (
    tester,
  ) async {
    when(() => mockMenuRepository.creerMenu(any()))
        .thenAnswer((_) async => 'food-x');

    await ouvrirFormulaire(tester);
    await tester.enterText(find.byKey(const Key('champ_nom_plat')), 'Tacos');
    await tester.enterText(find.byKey(const Key('champ_prix_plat')), '2000');

    final dropdown = find.byKey(const Key('champ_categorie_plat'));
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Autre').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('champ_categorie_autre')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('champ_categorie_autre')),
      'Cuisine locale',
    );
    await valider(tester);
    await tester.pumpAndSettle();

    final capture =
        verify(() => mockMenuRepository.creerMenu(captureAny())).captured.single
            as FoodModel;
    expect(capture.categorie, 'Cuisine locale');
  });
}
