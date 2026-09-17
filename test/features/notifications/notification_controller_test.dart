import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quickeat/data/repositories/notification_repository.dart';
import 'package:quickeat/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:quickeat/models/notification_model.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;
  late NotificationController controller;
  late StreamController<List<NotificationModel>> streamController;

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

  setUp(() {
    repository = MockNotificationRepository();
    streamController = StreamController<List<NotificationModel>>.broadcast();
    when(() => repository.streamNotifications('u1'))
        .thenAnswer((_) => streamController.stream);

    controller = NotificationController(
      repository: repository,
      idUtilisateur: 'u1',
    );
  });

  tearDown(() async {
    controller.dispose();
    await streamController.close();
  });

  test('passe de loading à success avec les notifications', () async {
    controller.startListening();
    expect(controller.status, NotificationStatus.loading);

    final notifications = [
      notification('n1'),
      notification('n2', estLue: true),
    ];
    streamController.add(notifications);
    await Future<void>.delayed(Duration.zero);

    expect(controller.status, NotificationStatus.success);
    expect(controller.notifications, notifications);
    expect(controller.nonLues, 1);
  });

  test('passe en error si le stream échoue', () async {
    controller.startListening();

    streamController.addError(
      FirebaseException(plugin: 'firestore', message: 'denied'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.status, NotificationStatus.error);
    expect(controller.errorMessage, isNotNull);
  });

  test('marquerCommeLue délègue au repository', () async {
    when(
      () =>
          repository.marquerCommeLue(idUtilisateur: 'u1', idNotification: 'n1'),
    ).thenAnswer((_) async {});

    await controller.marquerCommeLue('n1');

    verify(
      () =>
          repository.marquerCommeLue(idUtilisateur: 'u1', idNotification: 'n1'),
    ).called(1);
  });
}
