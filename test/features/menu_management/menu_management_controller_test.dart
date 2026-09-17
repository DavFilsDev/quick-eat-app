import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quickeat/data/repositories/menu_repository.dart';
import 'package:quickeat/features/menu_management/presentation/controllers/menu_management_controller.dart';
import 'package:quickeat/models/food_model.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class FakeFoodModel extends Fake implements FoodModel {}

void main() {
  late MockMenuRepository mockMenuRepository;

  const plat = FoodModel(
    idFood: 'food-1',
    nom: 'Burger',
    prix: 1500,
    categorie: 'Fast Food',
    disponible: true,
    idCommercant: 'user-004',
  );

  setUpAll(() => registerFallbackValue(FakeFoodModel()));

  setUp(() {
    mockMenuRepository = MockMenuRepository();
  });

  MenuManagementController creerController() {
    return MenuManagementController(
      menuRepository: mockMenuRepository,
      idCommercant: 'user-004',
    );
  }

  test('charge les plats du commerçant via le stream', () async {
    final controller = creerController();
    when(() => mockMenuRepository.streamMenusParCommercant('user-004'))
        .thenAnswer((_) => Stream.value(const [plat]));

    controller.startListening();
    await Future.delayed(Duration.zero);

    expect(controller.status, MenuManagementStatus.success);
    expect(controller.plats.length, 1);
    expect(controller.plats.first.idFood, 'food-1');

    controller.dispose();
  });

  test('passe en erreur quand le stream échoue', () async {
    final controller = creerController();
    when(() => mockMenuRepository.streamMenusParCommercant('user-004'))
        .thenAnswer((_) => Stream.error(Exception('boom')));

    controller.startListening();
    await Future.delayed(Duration.zero);

    expect(controller.status, MenuManagementStatus.error);
    expect(controller.errorMessage, isNotNull);

    controller.dispose();
  });

  test('bascule la disponibilité d\'un plat', () async {
    final controller = creerController();
    when(() => mockMenuRepository.changerDisponibilite(any(), any()))
        .thenAnswer((_) async {});

    final resultat = await controller.basculerDisponibilite(plat, false);

    expect(resultat, isTrue);
    verify(() => mockMenuRepository.changerDisponibilite('food-1', false))
        .called(1);

    controller.dispose();
  });

  test('supprime un plat', () async {
    final controller = creerController();
    when(() => mockMenuRepository.supprimerMenu(any()))
        .thenAnswer((_) async {});

    final resultat = await controller.supprimer('food-1');

    expect(resultat, isTrue);
    verify(() => mockMenuRepository.supprimerMenu('food-1')).called(1);

    controller.dispose();
  });

  test('retourne false quand la suppression échoue', () async {
    final controller = creerController();
    when(() => mockMenuRepository.supprimerMenu(any()))
        .thenThrow(Exception('boom'));

    final resultat = await controller.supprimer('food-1');

    expect(resultat, isFalse);
    expect(controller.errorMessage, isNotNull);

    controller.dispose();
  });
}
