import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quickeat/core/widgets/quick_eat_app_bar.dart';
import 'package:quickeat/data/repositories/notification_repository.dart';
import 'package:quickeat/features/notifications/presentation/screens/notification_screen.dart';
import 'package:quickeat/models/notification_model.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;

  setUp(() {
    repository = MockNotificationRepository();
  });

  NotificationModel notification(String id, {bool estLue = false}) {
    return NotificationModel(
      idNotification: id,
      idUtilisateur: 'u1',
      titre: 'Titre',
      message: 'Message',
      dateCreation: DateTime(2026, 1, 1),
      estLue: estLue,
    );
  }

  Widget sujet({List<NotificationModel>? notifications}) {
    when(() => repository.streamNotifications('u1'))
        .thenAnswer((_) => Stream.value(notifications ?? const []));

    return MaterialApp(
      home: Scaffold(
        appBar: QuickEatAppBar(
          idUtilisateur: 'u1',
          notificationRepository: repository,
        ),
      ),
    );
  }

  testWidgets('affiche le titre QuickEat et la cloche de notifications', (
    tester,
  ) async {
    await tester.pumpWidget(sujet());
    await tester.pump();

    expect(find.text('QuickEat'), findsOneWidget);
    expect(find.byKey(const Key('icone_notifications')), findsOneWidget);
    expect(find.byKey(const Key('badge_notifications')), findsNothing);
  });

  testWidgets('affiche le badge avec le nombre de notifications non lues', (
    tester,
  ) async {
    await tester.pumpWidget(
      sujet(
        notifications: [
          notification('n1'),
          notification('n2'),
          notification('n3', estLue: true),
        ],
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('badge_notifications')), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('ne montre aucun badge lorsque tout est lu', (tester) async {
    await tester.pumpWidget(
      sujet(notifications: [notification('n1', estLue: true)]),
    );
    await tester.pump();

    expect(find.byKey(const Key('badge_notifications')), findsNothing);
  });

  testWidgets('ouvre l\'écran des notifications au clic sur la cloche', (
    tester,
  ) async {
    await tester.pumpWidget(sujet());
    await tester.pump();

    await tester.tap(find.byKey(const Key('icone_notifications')));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationScreen), findsOneWidget);
  });
}
