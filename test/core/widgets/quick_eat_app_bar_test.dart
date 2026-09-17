import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/core/widgets/quick_eat_app_bar.dart';
import 'package:quickeat/models/enums/user_role.dart';
import 'package:quickeat/models/user_model.dart';
import 'package:quickeat/routes/app_router.dart';

void main() {
  const utilisateur = UserModel(
    idUser: 'u1',
    prenoms: 'Marie',
    nom: 'Kouassi',
    email: 'marie@example.com',
    role: UserRole.student,
    campus: 'Campus A',
  );

  Widget sujet({
    Stream<UserModel?>? stream,
    Future<void> Function()? onLogout,
  }) {
    return MaterialApp(
      home: Scaffold(
        appBar: QuickEatAppBar(
          userStream: stream ?? Stream.value(utilisateur),
          onLogout: onLogout,
        ),
      ),
    );
  }

  testWidgets('Affiche le titre QuickEat et l\'avatar', (tester) async {
    await tester.pumpWidget(sujet());
    await tester.pump();

    expect(find.text('QuickEat'), findsOneWidget);
    expect(find.text('MK'), findsOneWidget);
  });

  testWidgets(
    'Déconnexion : le menu propose "Déconnexion" et exécute onLogout',
    (tester) async {
      var deconnecte = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: QuickEatAppBar(
              userStream: Stream.value(utilisateur),
              onLogout: () async => deconnecte = true,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('avatar_menu')));
      await tester.pumpAndSettle();

      expect(find.text('Déconnexion'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);

      await tester.tap(find.text('Déconnexion'));
      await tester.pumpAndSettle();

      expect(deconnecte, isTrue);
    },
  );

  testWidgets('Redirection vers la route /login après déconnexion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == AppRouter.login) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Écran Connexion')),
            );
          }
          return MaterialPageRoute(builder: (_) => const SizedBox());
        },
        home: Scaffold(
          appBar: QuickEatAppBar(
            userStream: Stream.value(utilisateur),
            onLogout: () async {
              Navigator.of(tester.element(find.byType(QuickEatAppBar)))
                  .pushNamedAndRemoveUntil(AppRouter.login, (r) => false);
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('avatar_menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();

    expect(find.text('Écran Connexion'), findsOneWidget);
    expect(find.byType(QuickEatAppBar), findsNothing);
  });
}
