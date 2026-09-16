import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quickeat/data/repositories/auth_repository.dart';
import 'package:quickeat/data/repositories/user_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  testWidgets('Smoke test - Démarrage de l\'application', (
    WidgetTester tester,
  ) async {
    final mockAuthRepository = MockAuthRepository();
    final mockUserRepository = MockUserRepository();

    expect(mockAuthRepository, isNotNull);
    expect(mockUserRepository, isNotNull);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('QuickEat Auth'))),
      ),
    );

    expect(find.text('QuickEat Auth'), findsOneWidget);
  });
}
