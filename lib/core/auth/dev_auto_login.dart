import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repositories/user_repository.dart';
import '../../models/enums/user_role.dart';
import '../../models/user_model.dart';

Future<void> devAutoLogin({
  required String role,
  required UserRepository userRepository,
}) async {
  final String email = 'dev.$role@quickeat.local';
  const String password = 'dev12345';
  final auth = FirebaseAuth.instance;

  UserCredential credential;
  try {
    credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException {
    credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  final uid = credential.user!.uid;
  await userRepository.creerOuMettreAJourUtilisateur(
    UserModel(
      idUser: uid,
      prenoms: 'Dev',
      nom: role == 'merchant' ? 'Test Commerçant' : 'Test Étudiant',
      email: email,
      telephone: '+22900000000',
      role: role == 'merchant' ? UserRole.merchant : UserRole.student,
      campus: 'Campus UAC - Abomey-Calavi',
      dateCreation: DateTime.now(),
    ),
  );
}
