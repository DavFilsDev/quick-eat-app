import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../models/user_model.dart';

enum ProfileStatus { loading, success, error }

class ProfileController extends ChangeNotifier {
  ProfileController({
    required this._userRepository,
    required this._authRepository,
    required this._userId,
  });

  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final String _userId;

  StreamSubscription<UserModel?>? _subscription;
  ProfileStatus _status = ProfileStatus.loading;
  UserModel? _user;
  String? _errorMessage;
  bool _isSaving = false;
  bool _notificationsActivees = true;

  ProfileStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get notificationsActivees => _notificationsActivees;

  void startListening() {
    _status = ProfileStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _userRepository
        .streamUtilisateur(_userId)
        .listen(
          (user) {
            _user = user;
            _notificationsActivees = user?.notificationsActivees ?? true;
            _status = ProfileStatus.success;
            notifyListeners();
          },
          onError: (Object error) {
            _errorMessage = _messageFrom(error);
            _status = ProfileStatus.error;
            notifyListeners();
          },
        );
  }

  Future<bool> mettreAJourInfos({
    required String prenoms,
    required String nom,
    required String telephone,
    String? photoUrl,
  }) async {
    final actuel = _user;
    if (actuel == null) return false;

    _isSaving = true;
    notifyListeners();
    try {
      await _userRepository.creerOuMettreAJourUtilisateur(
        actuel.copyWith(
          prenoms: prenoms,
          nom: nom,
          telephone: telephone,
          photoUrl: photoUrl,
        ),
      );
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error);
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> envoyerReinitialisationMotDePasse() async {
    final email = _user?.email;
    if (email == null || email.isEmpty) {
      _errorMessage = 'Adresse email indisponible.';
      notifyListeners();
      return false;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error);
      notifyListeners();
      return false;
    }
  }

  Future<void> seDeconnecter() => _authRepository.signOut();

  Future<void> basculerNotifications(bool value) async {
    _notificationsActivees = value;
    notifyListeners();

    final actuel = _user;
    if (actuel == null) return;

    try {
      await _userRepository.creerOuMettreAJourUtilisateur(
        actuel.copyWith(notificationsActivees: value),
      );
    } catch (error) {
      _errorMessage = _messageFrom(error);
      notifyListeners();
    }
  }

  String _messageFrom(Object error) => Failure.fromException(error).message;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
