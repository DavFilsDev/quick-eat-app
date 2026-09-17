import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
      titre: 'Nouvelle commande',
      message: 'Nouvelle commande pour "Riz".',
      dateCreation: DateTime(2026, 1, 1),
      estLue: estLue,
    );
  }

  Future<void> ouvrirEcran(
    WidgetTester tester,
    List<NotificationModel> notifications,
  ) async {
    when(() => repository.streamNotifications('u1'))
        .thenAnswer((_) => Stream.value(notifications));
    when(
      () => repository.marquerCommeLue(
        idUtilisateur: 'u1',
        idNotification: any(named: 'idNotification'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NotificationScreen(
                      idUtilisateur: 'u1',
                      notificationRepository: repository,
                    ),
                  ),
                ),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('affiche l\'état vide quand il n\'y a aucune notification', (
    tester,
  ) async {
    await ouvrirEcran(tester, const []);

    expect(find.text('Aucune notification pour le moment.'), findsOneWidget);
  });

  testWidgets('affiche les notifications avec l\'indicateur non lu', (
    tester,
  ) async {
    await ouvrirEcran(tester, [
      notification('n1'),
      notification('n2', estLue: true),
    ]);

    expect(find.byKey(const Key('notification_n1')), findsOneWidget);
    expect(find.byKey(const Key('notification_n2')), findsOneWidget);
    expect(find.byKey(const Key('notification_non_lue_n1')), findsOneWidget);
    expect(find.byKey(const Key('notification_non_lue_n2')), findsNothing);
  });

  testWidgets('marque la notification comme lue et ferme l\'écran au tap', (
    tester,
  ) async {
    await ouvrirEcran(tester, [notification('n1')]);

    await tester.tap(find.byKey(const Key('notification_n1')));
    await tester.pumpAndSettle();

    verify(
      () =>
          repository.marquerCommeLue(idUtilisateur: 'u1', idNotification: 'n1'),
    ).called(1);
    expect(find.byType(NotificationScreen), findsNothing);
  });
}
