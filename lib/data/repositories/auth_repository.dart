import 'package:firebase_auth/firebase_auth.dart';

/// Contrat d'authentification. Les widgets/controllers ne doivent JAMAIS
/// appeler `FirebaseAuth.instance` directement — toujours passer par ici.
abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  Future<UserCredential> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}
