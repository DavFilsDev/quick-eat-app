import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quickeat/core/services/image_picker_service.dart';
import 'package:quickeat/data/repositories/menu_repository.dart';
import 'package:quickeat/features/menu_management/presentation/controllers/menu_management_controller.dart';
import 'package:quickeat/features/menu_management/presentation/widgets/menu_form_dialog.dart';
import 'package:quickeat/models/food_model.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class FakeFoodModel extends Fake implements FoodModel {}

class FakeImagePickerService extends Fake implements ImagePickerService {
  @override
  Future<ImageSelection?> choisirImage() async {
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    );
    return ImageSelection(
      bytes: bytes,
      dataUri: ImageSelection.versDataUri(bytes),
    );
  }
}

const _pngDataUri =
    'data:image/jpeg;base64,'
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

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

  Future<void> ouvrirFormulaire(
    WidgetTester tester, {
    FoodModel? plat,
    ImagePickerService? imagePickerService,
  }) async {
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
                imagePickerService: imagePickerService,
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

  testWidgets('enregistre une image choisie via le sélecteur', (tester) async {
    when(() => mockMenuRepository.creerMenu(any()))
        .thenAnswer((_) async => 'food-x');
    final picker = FakeImagePickerService();

    await ouvrirFormulaire(tester, imagePickerService: picker);
    await tester.enterText(find.byKey(const Key('champ_nom_plat')), 'Pizza');
    await tester.enterText(find.byKey(const Key('champ_prix_plat')), '4500');

    await tester.tap(find.byKey(const Key('zone_image_plat')));
    await tester.pumpAndSettle();

    await valider(tester);
    await tester.pumpAndSettle();

    final capture =
        verify(() => mockMenuRepository.creerMenu(captureAny())).captured.single
            as FoodModel;
    expect(capture.imageUrl, startsWith('data:image/jpeg;base64,'));
    expect(capture.nom, 'Pizza');
  });

  testWidgets('conserve l\'image existante par URL en édition', (tester) async {
    when(() => mockMenuRepository.mettreAJourMenu(any()))
        .thenAnswer((_) async {});

    const plat = FoodModel(
      idFood: 'food-1',
      nom: 'Pizza',
      prix: 4500,
      imageUrl: 'https://exemple.com/pizza.jpg',
      categorie: 'Fast Food',
      idCommercant: 'user-004',
    );

    await ouvrirFormulaire(tester, plat: plat);
    await valider(tester);
    await tester.pumpAndSettle();

    final capture =
        verify(() => mockMenuRepository.mettreAJourMenu(captureAny()))
                .captured
                .single
            as FoodModel;
    expect(capture.imageUrl, 'https://exemple.com/pizza.jpg');
    expect(capture.nom, 'Pizza');
  });

  testWidgets('remplace une image par le sélecteur en édition', (tester) async {
    when(() => mockMenuRepository.mettreAJourMenu(any()))
        .thenAnswer((_) async {});
    final picker = FakeImagePickerService();

    const plat = FoodModel(
      idFood: 'food-1',
      nom: 'Pizza',
      prix: 4500,
      imageUrl: 'https://exemple.com/pizza.jpg',
      categorie: 'Fast Food',
      idCommercant: 'user-004',
    );

    await ouvrirFormulaire(tester, plat: plat, imagePickerService: picker);
    await tester.tap(find.byKey(const Key('zone_image_plat')));
    await tester.pumpAndSettle();
    await valider(tester);
    await tester.pumpAndSettle();

    final capture =
        verify(() => mockMenuRepository.mettreAJourMenu(captureAny()))
                .captured
                .single
            as FoodModel;
    expect(capture.imageUrl, _pngDataUri);
  });

  testWidgets('affiche une image locale choisie en aperçu', (tester) async {
    final picker = FakeImagePickerService();

    await ouvrirFormulaire(tester, imagePickerService: picker);
    await tester.tap(find.byKey(const Key('zone_image_plat')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('zone_image_plat')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('zone_image_plat')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
  });
}
