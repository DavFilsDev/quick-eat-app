import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:quickeat/core/services/image_picker_service.dart';
import 'package:quickeat/data/repositories/auth_repository.dart';
import 'package:quickeat/data/repositories/user_repository.dart';
import 'package:quickeat/features/profile/presentation/controllers/profile_controller.dart';
import 'package:quickeat/features/profile/presentation/widgets/profile_edit_dialog.dart';
import 'package:quickeat/models/enums/user_role.dart';
import 'package:quickeat/models/user_model.dart';

class MockUserRepository extends Mock implements UserRepository {}

class FakeImagePickerService extends Fake implements ImagePickerService {
  @override
  Future<ImageSelection?> choisirImage() async {
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    );
    return ImageSelection(
      bytes: bytes,
      dataUri: ImageSelection.versDataUri(bytes),
    );
  }
}

void main() {
  late MockUserRepository mockUserRepository;
  late ProfileController controller;

  const utilisateur = UserModel(
    idUser: 'user-001',
    prenoms: 'Awa',
    nom: 'Diop',
    email: 'awa.diop@test.com',
    telephone: '770000000',
    role: UserRole.student,
    campus: 'Dakar',
  );

  setUpAll(() {
    registerFallbackValue(
      const UserModel(
        idUser: 'fallback',
        prenoms: 'Fallback',
        nom: 'User',
        email: 'fallback@test.com',
        role: UserRole.student,
        campus: 'Dakar',
      ),
    );
  });

  setUp(() {
    mockUserRepository = MockUserRepository();
    when(() => mockUserRepository.streamUtilisateur(utilisateur.idUser))
        .thenAnswer((_) => Stream.value(utilisateur));
    controller = ProfileController(
      userRepository: mockUserRepository,
      authRepository: _MockAuthRepository(),
      userId: utilisateur.idUser,
    );
    controller.startListening();
  });

  tearDown(() => controller.dispose());

  Future<void> ouvrirDialogue(
    WidgetTester tester, {
    ImagePickerService? imagePickerService,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ProfileController>.value(
          value: controller,
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                key: const Key('ouvrir_edition'),
                onPressed: () => ProfileEditDialog.show(
                  context,
                  controller: controller,
                  user: utilisateur,
                  imagePickerService: imagePickerService,
                ),
                child: const Text('Modifier'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('ouvrir_edition')));
    await tester.pumpAndSettle();
  }

  testWidgets('enregistre une photo choisie via le sélecteur', (tester) async {
    when(() => mockUserRepository.creerOuMettreAJourUtilisateur(any()))
        .thenAnswer((_) async {});
    final picker = FakeImagePickerService();

    await ouvrirDialogue(tester, imagePickerService: picker);
    await tester.tap(find.byKey(const Key('choisir_photo_profil')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('valider_infos')));
    await tester.pumpAndSettle();

    final capture =
        verify(
              () => mockUserRepository.creerOuMettreAJourUtilisateur(
                captureAny(),
              ),
            ).captured.single
            as UserModel;
    expect(capture.photoUrl, startsWith('data:image/jpeg;base64,'));
  });

  testWidgets('conserve la photo existante par URL lors de la sauvegarde', (
    tester,
  ) async {
    when(() => mockUserRepository.creerOuMettreAJourUtilisateur(any()))
        .thenAnswer((_) async {});

    await ouvrirDialogue(tester);
    await tester.tap(find.byKey(const Key('valider_infos')));
    await tester.pumpAndSettle();

    final capture =
        verify(
              () => mockUserRepository.creerOuMettreAJourUtilisateur(
                captureAny(),
              ),
            ).captured.single
            as UserModel;
    expect(capture.photoUrl, isNull);
    expect(capture.prenoms, 'Awa');
  });

  testWidgets('affiche un aperçu lorsque la photo locale est choisie', (
    tester,
  ) async {
    final picker = FakeImagePickerService();

    await ouvrirDialogue(tester, imagePickerService: picker);
    await tester.tap(find.byKey(const Key('choisir_photo_profil')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(CircleAvatar),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
  });
}

class _MockAuthRepository extends Mock implements AuthRepository {}
