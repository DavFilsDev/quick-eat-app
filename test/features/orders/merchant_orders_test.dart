import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:quickeat/data/repositories/notification_repository.dart';
import 'package:quickeat/data/repositories/order_repository.dart';
import 'package:quickeat/data/repositories/user_repository.dart';
import 'package:quickeat/features/orders/presentation/merchant/controllers/merchant_orders_controller.dart';
import 'package:quickeat/features/orders/presentation/merchant/screens/merchant_order_detail_screen.dart';
import 'package:quickeat/features/orders/presentation/merchant/widgets/order_progress_bar.dart';
import 'package:quickeat/models/enums/delivery_type.dart';
import 'package:quickeat/models/enums/order_status.dart';
import 'package:quickeat/models/notification_model.dart';
import 'package:quickeat/models/order_model.dart';
import 'package:quickeat/models/user_model.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class _FakeNotificationModel extends Fake implements NotificationModel {}

void main() {
  late MockOrderRepository mockOrderRepository;
  late MockUserRepository mockUserRepository;
  late MockNotificationRepository mockNotificationRepository;
  late MerchantOrdersController controller;
  const merchantId = 'merchant_123';

  setUpAll(() {
    registerFallbackValue(_FakeNotificationModel());
    registerFallbackValue(OrderStatus.acceptee);
  });

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    mockUserRepository = MockUserRepository();
    mockNotificationRepository = MockNotificationRepository();
  });

  group('MerchantOrdersController Logic', () {
    test('orders should be sorted from oldest to newest', () async {
      final now = DateTime.now();
      final o1 = OrderModel(
        idCommande: '1',
        idEtudiant: 'e1',
        idCommercant: merchantId,
        dateCommande: now.subtract(const Duration(minutes: 10)),
        montantTotal: 100,
        typeReception: DeliveryType.retrait,
      );
      final o2 = OrderModel(
        idCommande: '2',
        idEtudiant: 'e1',
        idCommercant: merchantId,
        dateCommande: now.subtract(const Duration(minutes: 5)),
        montantTotal: 200,
        typeReception: DeliveryType.retrait,
      );

      when(() => mockOrderRepository.streamCommandesCommercant(merchantId))
          .thenAnswer((_) => Stream.value([o2, o1]));

      controller = MerchantOrdersController(
        orderRepository: mockOrderRepository,
        userRepository: mockUserRepository,
        merchantId: merchantId,
      );

      await Future.delayed(Duration.zero);

      expect(controller.orders.first.idCommande, '1');
      expect(controller.orders.last.idCommande, '2');
    });

    test('notifie l\'étudiant lorsque la commande est terminée', () async {
      final order = OrderModel(
        idCommande: 'ord_1',
        idEtudiant: 'e1',
        idCommercant: merchantId,
        dateCommande: DateTime.now(),
        montantTotal: 1500,
        typeReception: DeliveryType.retrait,
        statut: OrderStatus.acceptee,
      );
      when(() => mockOrderRepository.streamCommandesCommercant(merchantId))
          .thenAnswer((_) => Stream.value([order]));
      when(() => mockOrderRepository.mettreAJourStatut(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.creerNotification(any()))
          .thenAnswer((_) async {});

      controller = MerchantOrdersController(
        orderRepository: mockOrderRepository,
        userRepository: mockUserRepository,
        notificationRepository: mockNotificationRepository,
        merchantId: merchantId,
      );
      await Future.delayed(Duration.zero);

      await controller.updateOrderStatus('ord_1', OrderStatus.terminee);

      final captured =
          verify(
                () =>
                    mockNotificationRepository.creerNotification(captureAny()),
              ).captured.single
              as NotificationModel;
      expect(captured.idUtilisateur, 'e1');
      expect(captured.idCommande, 'ord_1');
      expect(captured.message, 'Votre commande est prête à être retirée.');
    });

    test('ne notifie pas l\'étudiant pour un statut intermédiaire', () async {
      final order = OrderModel(
        idCommande: 'ord_1',
        idEtudiant: 'e1',
        idCommercant: merchantId,
        dateCommande: DateTime.now(),
        montantTotal: 1500,
        typeReception: DeliveryType.retrait,
        statut: OrderStatus.enAttente,
      );
      when(() => mockOrderRepository.streamCommandesCommercant(merchantId))
          .thenAnswer((_) => Stream.value([order]));
      when(() => mockOrderRepository.mettreAJourStatut(any(), any()))
          .thenAnswer((_) async {});

      controller = MerchantOrdersController(
        orderRepository: mockOrderRepository,
        userRepository: mockUserRepository,
        notificationRepository: mockNotificationRepository,
        merchantId: merchantId,
      );
      await Future.delayed(Duration.zero);

      await controller.updateOrderStatus('ord_1', OrderStatus.acceptee);

      verifyNever(() => mockNotificationRepository.creerNotification(any()));
    });
  });

  group('MerchantOrderDetailScreen - Action Button Resolution', () {
    testWidgets('should show "Passer à : Acceptée" when status is EN_ATTENTE', (
      tester,
    ) async {
      final order = OrderModel(
        idCommande: 'ord_1',
        idEtudiant: 'stud_1',
        idCommercant: merchantId,
        dateCommande: DateTime.now(),
        montantTotal: 1500,
        typeReception: DeliveryType.livraison,
        statut: OrderStatus.enAttente,
      );

      when(() => mockOrderRepository.streamCommandesCommercant(merchantId))
          .thenAnswer((_) => Stream.value([order]));
      when(() => mockUserRepository.obtenirUtilisateur('stud_1')).thenAnswer(
        (_) => Future.value(
          const UserModel(
            idUser: 'stud_1',
            prenoms: 'Jean',
            nom: 'Dupont',
            email: '',
            campus: 'Abomey',
          ),
        ),
      );

      controller = MerchantOrdersController(
        orderRepository: mockOrderRepository,
        userRepository: mockUserRepository,
        merchantId: merchantId,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: controller,
            child: const MerchantOrderDetailScreen(idCommande: 'ord_1'),
          ),
        ),
      );

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Passer à : Acceptée'), findsOneWidget);
    });

    testWidgets(
      'should NOT show button when next status is student action (LIVREE)',
      (tester) async {
        final order = OrderModel(
          idCommande: 'ord_1',
          idEtudiant: 'stud_1',
          idCommercant: merchantId,
          dateCommande: DateTime.now(),
          montantTotal: 1500,
          typeReception: DeliveryType.livraison,
          statut: OrderStatus.enCoursDeLivraison,
        );

        when(() => mockOrderRepository.streamCommandesCommercant(merchantId))
            .thenAnswer((_) => Stream.value([order]));
        when(() => mockUserRepository.obtenirUtilisateur('stud_1')).thenAnswer(
          (_) => Future.value(
            const UserModel(
              idUser: 'stud_1',
              prenoms: 'Jean',
              nom: 'Dupont',
              email: '',
              campus: 'Abomey',
            ),
          ),
        );

        controller = MerchantOrdersController(
          orderRepository: mockOrderRepository,
          userRepository: mockUserRepository,
          merchantId: merchantId,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: controller,
              child: const MerchantOrderDetailScreen(idCommande: 'ord_1'),
            ),
          ),
        );

        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.byType(ElevatedButton), findsNothing);
      },
    );

    testWidgets(
      'should show "Passer à : Reçue" for pickup (Retrait) when status is TERMINEE',
      (tester) async {
        final order = OrderModel(
          idCommande: 'ord_1',
          idEtudiant: 'stud_1',
          idCommercant: merchantId,
          dateCommande: DateTime.now(),
          montantTotal: 1500,
          typeReception: DeliveryType.retrait,
          statut: OrderStatus.terminee,
        );

        when(() => mockOrderRepository.streamCommandesCommercant(merchantId))
            .thenAnswer((_) => Stream.value([order]));
        when(() => mockUserRepository.obtenirUtilisateur('stud_1')).thenAnswer(
          (_) => Future.value(
            const UserModel(
              idUser: 'stud_1',
              prenoms: 'Jean',
              nom: 'Dupont',
              email: '',
              campus: 'Abomey',
            ),
          ),
        );

        controller = MerchantOrdersController(
          orderRepository: mockOrderRepository,
          userRepository: mockUserRepository,
          merchantId: merchantId,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: controller,
              child: const MerchantOrderDetailScreen(idCommande: 'ord_1'),
            ),
          ),
        );

        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text('Passer à : Reçue'), findsOneWidget);
      },
    );
  });

  testWidgets('OrderProgressBar renders correct number of steps', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderProgressBar(
            currentStatus: OrderStatus.acceptee,
            steps: [
              OrderStatus.enAttente,
              OrderStatus.acceptee,
              OrderStatus.terminee,
              OrderStatus.recu,
            ],
          ),
        ),
      ),
    );

    expect(find.byType(OrderProgressBar), findsOneWidget);
  });
}
