import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileScope extends StatefulWidget {
  const ProfileScope({super.key, required this.child});

  final Widget child;

  @override
  State<ProfileScope> createState() => _ProfileScopeState();
}

class _ProfileScopeState extends State<ProfileScope> {
  ProfileController? _controller;

  ProfileController _creer() {
    return ProfileController(
      userRepository: FirestoreUserRepository(),
      authRepository: FirebaseAuthRepository(),
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
    )..startListening();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dejaFourni =
        context
            .findAncestorWidgetOfExactType<
              ChangeNotifierProvider<ProfileController>
            >() !=
        null;
    if (dejaFourni) return widget.child;

    _controller ??= _creer();
    return ChangeNotifierProvider<ProfileController>.value(
      value: _controller!,
      child: widget.child,
    );
  }
}
