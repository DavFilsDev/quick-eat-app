import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../models/enums/user_role.dart';
import '../../routes/app_router.dart';
import '../widgets/loading_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = FirebaseAuthRepository();
    final userRepository = FirestoreUserRepository();

    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        final firebaseUser = authSnapshot.data;
        if (firebaseUser == null) {
          return const LoginScreen();
        }

        return StreamBuilder(
          stream: userRepository.streamUtilisateur(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }

            final user = userSnapshot.data;
            if (user == null) {
              // Compte Firebase Auth créé mais document Firestore pas
              // encore écrit (cas transitoire pendant l'inscription).
              return const LoadingView();
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                user.role == UserRole.merchant
                    ? AppRouter.merchantHome
                    : AppRouter.studentHome,
                (route) => false,
              );
            });
            return const LoadingView();
          },
        );
      },
    );
  }
}
