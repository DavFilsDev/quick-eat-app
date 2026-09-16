import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quickeat/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:quickeat/models/food_model.dart';
import 'package:quickeat/data/repositories/menu_repository.dart';
import 'package:quickeat/data/repositories/user_repository.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('CatalogController', () {
    late CatalogController controller;
    late StreamController<List<FoodModel>> streamController;
    late MockMenuRepository mockMenuRepository;
    late MockUserRepository mockUserRepository;

    setUp(() {
      streamController = StreamController<List<FoodModel>>();
      mockMenuRepository = MockMenuRepository();
      mockUserRepository = MockUserRepository();
      when(
        () => mockMenuRepository.streamMenus(),
      ).thenAnswer((_) => streamController.stream);
      when(
        () => mockUserRepository.obtenirUtilisateur(any()),
      ).thenAnswer((_) => Future.value(null));
      controller = CatalogController(
        menuRepository: mockMenuRepository,
        userRepository: mockUserRepository,
      );
    });

    tearDown(() {
      streamController.close();
      controller.dispose();
    });

    test(
      'regroupement des plats par idCommercant (restaurantsDisponibles)',
      () async {
        final plats = <FoodModel>[
          FoodModel(
            idFood: 'food-001',
            nom: 'Burger Poulet',
            prix: 1500,
            categorie: 'Fast Food',
            disponible: true,
            idCommercant: 'user-004',
          ),
          FoodModel(
            idFood: 'food-002',
            nom: 'Sandwich Döner',
            prix: 1200,
            categorie: 'Fast Food',
            disponible: true,
            idCommercant: 'user-004',
          ),
          FoodModel(
            idFood: 'food-003',
            nom: 'Pizza Margherita',
            prix: 3500,
            categorie: 'Pizza',
            disponible: true,
            idCommercant: 'user-005',
          ),
        ];
        streamController.add(plats);
        await Future.delayed(Duration.zero);
        expect(controller.restaurantsDisponibles, contains('user-004'));
        expect(controller.restaurantsDisponibles, contains('user-005'));
        expect(controller.restaurantsDisponibles.length, 2);
      },
    );

    test('catégories dynamiques extraites des plats', () async {
      final plats = <FoodModel>[
        FoodModel(
          idFood: 'food-001',
          nom: 'Burger',
          prix: 1500,
          categorie: 'Fast Food',
          disponible: true,
          idCommercant: 'user-004',
        ),
        FoodModel(
          idFood: 'food-002',
          nom: 'Pizza',
          prix: 3500,
          categorie: 'Pizza',
          disponible: true,
          idCommercant: 'user-005',
        ),
      ];
      streamController.add(plats);
      await Future.delayed(Duration.zero);
      expect(controller.categories, contains('Fast Food'));
      expect(controller.categories, contains('Pizza'));
      expect(controller.categories, contains('Tous'));
    });

    test('filtrage par catégorie', () async {
      final plats = <FoodModel>[
        FoodModel(
          idFood: 'food-001',
          nom: 'Burger',
          prix: 1500,
          categorie: 'Fast Food',
          disponible: true,
          idCommercant: 'user-004',
        ),
        FoodModel(
          idFood: 'food-002',
          nom: 'Pizza',
          prix: 3500,
          categorie: 'Pizza',
          disponible: true,
          idCommercant: 'user-004',
        ),
      ];
      streamController.add(plats);
      await Future.delayed(Duration.zero);
      controller.setCategorie('Fast Food');
      expect(controller.plats.length, 1);
      expect(controller.plats.first.nom, 'Burger');
    });

    test('filtrage par recherche texte', () async {
      final plats = <FoodModel>[
        FoodModel(
          idFood: 'food-001',
          nom: 'Burger Poulet',
          prix: 1500,
          categorie: 'Fast Food',
          disponible: true,
          idCommercant: 'user-004',
        ),
        FoodModel(
          idFood: 'food-002',
          nom: 'Pizza Margherita',
          prix: 3500,
          categorie: 'Pizza',
          disponible: true,
          idCommercant: 'user-005',
        ),
      ];
      streamController.add(plats);
      await Future.delayed(Duration.zero);
      controller.setRecherche('pizza');
      expect(controller.plats.length, 1);
      expect(controller.plats.first.nom, 'Pizza Margherita');
    });
  });
}
