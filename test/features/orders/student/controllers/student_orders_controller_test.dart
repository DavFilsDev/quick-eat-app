import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quickeat/core/errors/failures.dart';
import 'package:quickeat/data/repositories/notification_repository.dart';
import 'package:quickeat/data/repositories/order_repository.dart';
import 'package:quickeat/features/orders/presentation/student/controllers/student_orders_controller.dart';
import 'package:quickeat/models/enums/delivery_type.dart';
import 'package:quickeat/models/enums/order_status.dart';
import 'package:quickeat/models/food_model.dart';
import 'package:quickeat/models/notification_model.dart';
import 'package:quickeat/models/order_model.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class _FakeOrderModel extends Fake implements OrderModel {}

class _FakeNotificationModel extends Fake implements NotificationModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeOrderModel());
    registerFallbackValue(_FakeNotificationModel());
    registerFallbackValue(OrderStatus.livree);
  });

  late MockOrderRepository mockRepository;
  late MockNotificationRepository mockNotificationRepository;
  late StudentOrdersController controller;
  late StreamController<List<OrderModel>> streamController;

  const food = FoodModel(
    idFood: 'food1',
    nom: 'Riz sauce arachide',
    prix: 2500,
    idCommercant: 'com1',
  );

  setUp(() {
    mockRepository = MockOrderRepository();
    mockNotificationRepository = MockNotificationRepository();
    streamController = StreamController<List<OrderModel>>.broadcast();
    when(() => mockRepository.streamCommandesEtudiant(any()))
        .thenAnswer((_) => streamController.stream);

    controller = StudentOrdersController(
      orderRepository: mockRepository,
      notificationRepository: mockNotificationRepository,
      idEtudiant: 'etu1',
    );
  });

  tearDown(() async {
    controller.dispose();
    await streamController.close();
  });

  group('startListening', () {
    test(
      'démarre en loading puis passe à success avec les commandes',
      () async {
        controller.startListening();
        expect(controller.status, StudentOrdersStatus.loading);

        final commandes = [
          OrderModel(
            idCommande: 'c1',
            idEtudiant: 'etu1',
            idCommercant: 'com1',
            dateCommande: DateTime.now(),
            montantTotal: 2500,
            typeReception: DeliveryType.retrait,
          ),
        ];
        streamController.add(commandes);
        await Future<void>.delayed(Duration.zero);

        expect(controller.status, StudentOrdersStatus.success);
        expect(controller.orders, commandes);
      },
    );

    test('passe à error si le stream échoue', () async {
      controller.startListening();

      streamController.addError(
        FirebaseException(plugin: 'firestore', message: 'denied'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.status, StudentOrdersStatus.error);
      expect(controller.errorMessage, isNotNull);
    });

    test('annule proprement l\'ancien abonnement au redémarrage', () async {
      controller.startListening();
      controller.startListening();

      streamController.add(const []);
      await Future<void>.delayed(Duration.zero);

      expect(controller.status, StudentOrdersStatus.success);
    });
  });

  group('creerCommande', () {
    test(
      'retourne true et appelle le repository avec la commande attendue',
      () async {
        when(() => mockRepository.creerCommande(any()))
            .thenAnswer((_) async => 'cmd123');

        final resultat = await controller.creerCommande(
          food: food,
          typeReception: DeliveryType.livraison,
          quantite: 3,
        );

        expect(resultat, isTrue);
        expect(controller.isCreatingOrder, isFalse);
        expect(controller.creationErrorMessage, isNull);

        final captured =
            verify(() => mockRepository.creerCommande(captureAny()))
                    .captured
                    .single
                as OrderModel;
        expect(captured.montantTotal, 7500); // 3 × 2500
        expect(captured.typeReception, DeliveryType.livraison);
        expect(captured.statut, OrderStatus.enAttente);
        expect(captured.items.single.quantite, 3);
      },
    );

    test(
      'retourne false et renseigne un message en cas de FirebaseException',
      () async {
        when(
          () => mockRepository.creerCommande(any()),
        ).thenThrow(FirebaseException(plugin: 'firestore', message: 'denied'));

        final resultat = await controller.creerCommande(
          food: food,
          typeReception: DeliveryType.retrait,
          quantite: 1,
        );

        expect(resultat, isFalse);
        expect(controller.creationErrorMessage, isNotNull);
      },
    );

    test('notifie le commerçant après une création réussie', () async {
      when(() => mockRepository.creerCommande(any()))
          .thenAnswer((_) async => 'cmd123');
      when(() => mockNotificationRepository.creerNotification(any()))
          .thenAnswer((_) async {});

      await controller.creerCommande(
        food: food,
        typeReception: DeliveryType.retrait,
        quantite: 1,
      );

      final captured =
          verify(
                () =>
                    mockNotificationRepository.creerNotification(captureAny()),
              ).captured.single
              as NotificationModel;

      expect(captured.idUtilisateur, 'com1');
      expect(captured.idCommande, 'cmd123');
    });

    test('reste un succès si la notification échoue', () async {
      when(() => mockRepository.creerCommande(any()))
          .thenAnswer((_) async => 'cmd123');
      when(() => mockNotificationRepository.creerNotification(any()))
          .thenThrow(Exception('offline'));

      final resultat = await controller.creerCommande(
        food: food,
        typeReception: DeliveryType.retrait,
        quantite: 1,
      );

      expect(resultat, isTrue);
    });
  });

  group('annulerCommande', () {
    test('retourne true si le repository confirme', () async {
      when(() => mockRepository.annulerCommande(any()))
          .thenAnswer((_) async {});

      final resultat = await controller.annulerCommande('c1');

      expect(resultat, isTrue);
    });

    test('retourne false avec le message métier si InvalidOrderTransition', () async {
      when(() => mockRepository.annulerCommande(any())).thenThrow(
        const InvalidOrderTransition(
          'Cette commande ne peut plus être annulée (préparation déjà lancée).',
        ),
      );

      final resultat = await controller.annulerCommande('c1');

      expect(resultat, isFalse);
      expect(
        controller.errorMessage,
        'Cette commande ne peut plus être annulée (préparation déjà lancée).',
      );
    });

    test('retourne false avec le message si Failure', () async {
      when(() => mockRepository.annulerCommande(any()))
          .thenThrow(const Failure('Commande introuvable.'));

      final resultat = await controller.annulerCommande('');

      expect(resultat, isFalse);
      expect(controller.errorMessage, 'Commande introuvable.');
    });
  });

  group('confirmerReception', () {
    test('appelle mettreAJourStatut avec OrderStatus.livree', () async {
      when(() => mockRepository.mettreAJourStatut(any(), any()))
          .thenAnswer((_) async {});

      final resultat = await controller.confirmerReception('c1');

      expect(resultat, isTrue);
      verify(() => mockRepository.mettreAJourStatut('c1', OrderStatus.livree))
          .called(1);
    });

    test('retourne false avec le message si Failure', () async {
      when(() => mockRepository.mettreAJourStatut(any(), any()))
          .thenThrow(const Failure('Commande introuvable.'));

      final resultat = await controller.confirmerReception('');

      expect(resultat, isFalse);
      expect(controller.errorMessage, 'Commande introuvable.');
    });
  });
}
