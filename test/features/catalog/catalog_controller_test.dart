import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quickeat/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:quickeat/models/enums/user_role.dart';
import 'package:quickeat/models/food_model.dart';
import 'package:quickeat/models/user_model.dart';
import 'package:quickeat/data/repositories/menu_repository.dart';
import 'package:quickeat/data/repositories/user_repository.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockUserRepository extends Mock implements UserRepository {}

UserModel _utilisateur({
  required String id,
  required String prenoms,
  required String nom,
  required String campus,
  UserRole role = UserRole.merchant,
}) {
  return UserModel(
    idUser: id,
    prenoms: prenoms,
    nom: nom,
    email: '$id@test.com',
    role: role,
    campus: campus,
  );
}

void main() {
  group('CatalogController', () {
    late CatalogController controller;
    late StreamController<List<FoodModel>> streamController;
    late MockMenuRepository mockMenuRepository;
    late MockUserRepository mockUserRepository;

    setUp(() {
      streamController = StreamController<List<FoodModel>>.broadcast();
      mockMenuRepository = MockMenuRepository();
      mockUserRepository = MockUserRepository();
      when(() => mockMenuRepository.streamMenus())
          .thenAnswer((_) => streamController.stream);
      when(() => mockUserRepository.obtenirUtilisateur(any()))
          .thenAnswer((_) => Future.value(null));
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

    test(
      'filtre strictement plats et restaurants selon le campus étudiant',
      () async {
        when(() => mockUserRepository.obtenirUtilisateur(any()))
            .thenAnswer((invocation) async {
              final id = invocation.positionalArguments.first as String;
              return switch (id) {
                'etudiant-1' => _utilisateur(
                  id: 'etudiant-1',
                  prenoms: 'Moussa',
                  nom: 'Ndiaye',
                  campus: 'Campus de Ngoa-Ekéllé',
                  role: UserRole.student,
                ),
                'user-004' => _utilisateur(
                  id: 'user-004',
                  prenoms: 'Amina',
                  nom: 'Diallo',
                  campus: 'Campus de Ngoa-Ekéllé',
                ),
                'user-005' => _utilisateur(
                  id: 'user-005',
                  prenoms: 'Jean-Paul',
                  nom: 'Mbarga',
                  campus: 'Campus de Melen',
                ),
                _ => null,
              };
            });

        controller.dispose();
        controller = CatalogController(
          menuRepository: mockMenuRepository,
          userRepository: mockUserRepository,
          idEtudiant: 'etudiant-1',
        );
        await _viderMicrotaches();

        streamController.add(<FoodModel>[
          FoodModel(
            idFood: 'food-001',
            nom: 'Burger Poulet',
            prix: 1500,
            disponible: true,
            idCommercant: 'user-004',
          ),
          FoodModel(
            idFood: 'food-002',
            nom: 'Pizza Margherita',
            prix: 3500,
            disponible: true,
            idCommercant: 'user-005',
          ),
        ]);
        await _viderMicrotaches();

        expect(controller.plats.length, 1);
        expect(controller.plats.single.idCommercant, 'user-004');
        expect(controller.restaurantsDisponibles, ['user-004']);
        expect(controller.getNomRestaurant('user-004'), 'Amina Diallo');
        expect(controller.nomsRestaurants, isNot(contains('Restaurant')));
      },
    );

    test(
      'charge les noms réels et filtre par restaurant sélectionné',
      () async {
        when(() => mockUserRepository.obtenirUtilisateur(any()))
            .thenAnswer((invocation) async {
              final id = invocation.positionalArguments.first as String;
              return switch (id) {
                'user-004' => _utilisateur(
                  id: 'user-004',
                  prenoms: 'Amina',
                  nom: 'Diallo',
                  campus: 'Campus de Ngoa-Ekéllé',
                ),
                'user-005' => _utilisateur(
                  id: 'user-005',
                  prenoms: 'Jean-Paul',
                  nom: 'Mbarga',
                  campus: 'Campus de Melen',
                ),
                _ => null,
              };
            });

        streamController.add(<FoodModel>[
          FoodModel(
            idFood: 'food-001',
            nom: 'Burger Poulet',
            prix: 1500,
            disponible: true,
            idCommercant: 'user-004',
          ),
          FoodModel(
            idFood: 'food-002',
            nom: 'Pizza Margherita',
            prix: 3500,
            disponible: true,
            idCommercant: 'user-005',
          ),
        ]);
        await _viderMicrotaches();

        expect(controller.nomsRestaurants, contains('Amina Diallo'));
        expect(controller.nomsRestaurants, contains('Jean-Paul Mbarga'));
        expect(controller.nomsRestaurants, isNot(contains('Restaurant')));

        controller.setRestaurantParNom('Amina Diallo');

        expect(controller.plats.length, 1);
        expect(controller.plats.single.idCommercant, 'user-004');
      },
    );

    test(
      'isLoading reste vrai tant que le chargement initial pas terminé',
      () async {
        expect(controller.isLoading, isTrue);

        streamController.add(<FoodModel>[
          FoodModel(
            idFood: 'food-001',
            nom: 'Burger Poulet',
            prix: 1500,
            disponible: true,
            idCommercant: 'user-004',
          ),
        ]);
        await _viderMicrotaches();

        expect(controller.isLoading, isFalse);
        expect(controller.plats.length, 1);
      },
    );

    test(
      'isLoading passe à faux après émission et charge campus/commerçants',
      () async {
        when(() => mockUserRepository.obtenirUtilisateur(any()))
            .thenAnswer((invocation) async {
              final id = invocation.positionalArguments.first as String;
              return switch (id) {
                'etudiant-1' => _utilisateur(
                  id: 'etudiant-1',
                  prenoms: 'Moussa',
                  nom: 'Ndiaye',
                  campus: 'Campus de Ngoa-Ekéllé',
                  role: UserRole.student,
                ),
                'user-004' => _utilisateur(
                  id: 'user-004',
                  prenoms: 'Amina',
                  nom: 'Diallo',
                  campus: 'Campus de Ngoa-Ekéllé',
                ),
                _ => null,
              };
            });

        controller.dispose();
        controller = CatalogController(
          menuRepository: mockMenuRepository,
          userRepository: mockUserRepository,
          idEtudiant: 'etudiant-1',
        );
        await _viderMicrotaches();

        expect(controller.isLoading, isTrue);

        streamController.add(<FoodModel>[
          FoodModel(
            idFood: 'food-001',
            nom: 'Burger Poulet',
            prix: 1500,
            disponible: true,
            idCommercant: 'user-004',
          ),
        ]);
        await _viderMicrotaches();

        expect(controller.isLoading, isFalse);
        expect(controller.plats.length, 1);
        expect(controller.plats.single.idCommercant, 'user-004');
      },
    );
  });
}

Future<void> _viderMicrotaches() async {
  for (var i = 0; i < 6; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
