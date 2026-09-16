import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../models/user_model.dart';
import '../../../../models/enums/user_role.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthController({
    required this._authRepository,
    required this._userRepository,
  });

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mapFirebaseError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email ou mot de passe incorrect.';
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé par un autre compte.';
        case 'invalid-email':
          return 'Adresse email invalide.';
        case 'weak-password':
          return 'Mot de passe trop faible (minimum 6 caractères).';
        case 'network-request-failed':
          return 'Connexion réseau impossible. Vérifiez votre accès Internet.';
        case 'too-many-requests':
          return 'Trop de tentatives échouées. Réessayez dans un moment.';
        default:
          return e.message ?? 'Une erreur d\'authentification est survenue.';
      }
    }
    return 'Une erreur inattendue est survenue. Veuillez réessayer.';
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authRepository.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _mapFirebaseError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nom,
    required String prenoms,
    required String telephone,
    required String campus,
    required UserRole role,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final userCredential = await _authRepository.signUp(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final newUser = UserModel(
          idUser: userCredential.user!.uid,
          nom: nom,
          prenoms: prenoms,
          email: email,
          telephone: telephone,
          campus: campus,
          role: role,
          dateCreation: DateTime.now(),
        );
        await _userRepository.creerOuMettreAJourUtilisateur(newUser);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _mapFirebaseError(e);
      _setLoading(false);
      return false;
    }
  }
}
