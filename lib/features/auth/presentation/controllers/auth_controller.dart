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
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authRepository.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Identifiants invalides ou problème réseau.";
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
      _errorMessage = "Erreur lors de l'inscription. Veuillez réessayer.";
      _setLoading(false);
      return false;
    }
  }
}
