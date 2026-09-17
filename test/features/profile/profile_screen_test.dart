import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:quickeat/data/repositories/auth_repository.dart';
import 'package:quickeat/data/repositories/user_repository.dart';
import 'package:quickeat/features/profile/presentation/controllers/profile_controller.dart';
import 'package:quickeat/features/profile/presentation/widgets/profile_view.dart';
import 'package:quickeat/models/enums/user_role.dart';
import 'package:quickeat/models/user_model.dart';
import 'package:quickeat/routes/app_router.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class _FakeUserModel extends Fake implements UserModel {}

void main() {
  late MockUserRepository mockUserRepository;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(_FakeUserModel());
  });

  const etudiant = UserModel(
    idUser: 'user-001',
    prenoms: 'Awa',
    nom: 'Diop',
    email: 'awa.diop@test.com',
    telephone: '770000000',
    role: UserRole.student,
    campus: 'Dakar',
  );

  const commercant = UserModel(
    idUser: 'user-004',
    prenoms: 'Moussa',
    nom: 'Ndiaye',
    email: 'moussa.ndiaye@test.com',
    telephone: '771111111',
    role: UserRole.merchant,
    campus: 'Thiès',
  );

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockAuthRepository = MockAuthRepository();
  });

  ProfileController creerController(UserModel user) {
    when(() => mockUserRepository.streamUtilisateur(user.idUser))
        .thenAnswer((_) => Stream.value(user));
    final controller = ProfileController(
      userRepository: mockUserRepository,
      authRepository: mockAuthRepository,
      userId: user.idUser,
    );
    controller.startListening();
    return controller;
  }

  Future<void> afficherVue(
    WidgetTester tester,
    ProfileController controller, {
    bool estCommercant = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == AppRouter.login) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Écran de connexion')),
            );
          }
          return null;
        },
        home: ChangeNotifierProvider<ProfileController>.value(
          value: controller,
          child: Scaffold(body: ProfileView(estCommercant: estCommercant)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('affiche le profil étudiant', (tester) async {
    final controller = creerController(etudiant);
    await afficherVue(tester, controller);

    expect(find.text('Awa Diop'), findsWidgets);
    expect(find.text('Étudiant'), findsOneWidget);
    expect(find.text('Campus'), findsOneWidget);
    expect(find.text('Nom du stand'), findsNothing);
    expect(find.text('Gérer mon menu'), findsNothing);

    controller.dispose();
  });

  testWidgets('affiche le profil commerçant et son stand', (tester) async {
    final controller = creerController(commercant);
    await afficherVue(tester, controller, estCommercant: true);

    expect(find.text('Moussa Ndiaye'), findsWidgets);
    expect(find.text('Commerçant'), findsOneWidget);
    expect(find.text('Nom du stand'), findsOneWidget);
    expect(find.text("Horaires d'ouverture"), findsOneWidget);
    expect(find.text('Emplacement'), findsOneWidget);
    expect(find.text('Gérer mon menu'), findsNothing);
    expect(find.byKey(const Key('gerer_mon_menu')), findsNothing);

    controller.dispose();
  });

  testWidgets('le toggle notifications reflète et persiste la préférence', (
    tester,
  ) async {
    when(() => mockUserRepository.creerOuMettreAJourUtilisateur(any()))
        .thenAnswer((_) async {});
    final controller = creerController(etudiant);
    await afficherVue(tester, controller);

    final toggle = find.byKey(const Key('toggle_notifications'));
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);

    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(controller.notificationsActivees, isFalse);
    verify(() => mockUserRepository.creerOuMettreAJourUtilisateur(any()))
        .called(1);

    controller.dispose();
  });

  testWidgets(
    'le toggle notifications est désactivé si la préférence est false',
    (tester) async {
      const sansNotifications = UserModel(
        idUser: 'user-001',
        prenoms: 'Awa',
        nom: 'Diop',
        email: 'awa.diop@test.com',
        role: UserRole.student,
        campus: 'Dakar',
        notificationsActivees: false,
      );
      final controller = creerController(sansNotifications);
      await afficherVue(tester, controller);

      final toggle = find.byKey(const Key('toggle_notifications'));
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);

      controller.dispose();
    },
  );

  testWidgets('déconnecte puis redirige vers la route login', (tester) async {
    when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
    final controller = creerController(etudiant);
    await afficherVue(tester, controller);

    final bouton = find.byKey(const Key('bouton_deconnexion'));
    await tester.ensureVisible(bouton);
    await tester.pumpAndSettle();
    await tester.tap(bouton);
    await tester.pumpAndSettle();

    verify(() => mockAuthRepository.signOut()).called(1);
    expect(find.text('Écran de connexion'), findsOneWidget);

    controller.dispose();
  });
}
