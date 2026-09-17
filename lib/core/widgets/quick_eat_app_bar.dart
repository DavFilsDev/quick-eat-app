import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../models/user_model.dart';
import '../../routes/app_router.dart';
import '../constants/app_colors.dart';

/// AppBar globale réutilisable QuickEat, présente sur toutes les pages
/// principales (sauf Connexion / Inscription).
///
/// - À gauche : le logo textuel **QuickEat** (couleur primaire).
/// - À droite : les `actions` éventuelles puis l'**avatar de l'utilisateur
///   connecté**, chargé dynamiquement depuis `UserModel.photoUrl`.
/// - Clic sur l'avatar : menu flottant avec l'entrée **Déconnexion**.
///
/// La photo provient du `userStream` (fourni en priorité pour les tests) ou
/// du stream Firestore de l'utilisateur connecté. Sans photo, l'avatar
/// affiche les initiales du nom complet, sinon une icône `Icons.person`.
///
/// La déconnexion (`onLogout`, fourni en priorité pour les tests) signe
/// l'utilisateur hors Firebase puis redirige vers `/login` avec
/// `pushNamedAndRemoveUntil` — l'`AuthGate` étant démonté après connexion,
/// la redirection doit être explicite.
class QuickEatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QuickEatAppBar({
    super.key,
    this.title = 'QuickEat',
    this.actions = const [],
    this.userStream,
    this.onLogout,
    this.authRepository,
    this.userRepository,
    this.automaticallyImplyLeading = true,
  });

  /// Logo textuel affiché à gauche (défaut : `QuickEat`).
  final String title;

  /// Actions additionnelles placées avant l'avatar (ex: badge commerçant).
  final List<Widget> actions;

  /// Stream de l'utilisateur connecté. Prioritaire sur le stream Firestore
  /// (injectable pour les tests).
  final Stream<UserModel?>? userStream;

  /// Logique de déconnexion. Prioritaire sur la déconnexion Firebase par
  /// défaut (injectable pour les tests).
  final Future<void> Function()? onLogout;

  /// Repository d'authentification (défaut : Firestore/Firebase).
  final AuthRepository? authRepository;
  final UserRepository? userRepository;

  /// Affiche la flèche retour implicite quand la page peut "pop" (défaut
  /// `true`). Sur les pages avec retour intégré au design (bannière
  /// restaurant), passer `false` pour éviter le doublon.
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final stream =
        userStream ?? _streamFirestore(authRepository, userRepository);

    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      actions: [
        ...actions,
        _AvatarMenu(
          stream: stream,
          onLogout: onLogout ?? () => _logoutFirebase(context),
        ),
      ],
    );
  }

  /// Stream Firestore de l'utilisateur connecté, évalué paresseusement :
  /// si `userStream` est fourni, aucun appel à Firebase n'est effectué
  /// (utile pour les tests).
  static Stream<UserModel?>? _streamFirestore(
    AuthRepository? authRepository,
    UserRepository? userRepository,
  ) {
    final auth = authRepository ?? FirebaseAuthRepository();
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;
    return (userRepository ?? FirestoreUserRepository()).streamUtilisateur(uid);
  }

  Future<void> _logoutFirebase(BuildContext context) async {
    await FirebaseAuthRepository().signOut();
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
  }
}

class _AvatarMenu extends StatelessWidget {
  const _AvatarMenu({required this.stream, required this.onLogout});

  final Stream<UserModel?>? stream;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    if (stream == null) {
      return _LogoutMenu(
        avatar: const _AvatarFallback(user: null),
        onLogout: onLogout,
      );
    }

    return StreamBuilder<UserModel?>(
      stream: stream,
      builder: (context, snapshot) {
        final user = snapshot.data;
        return _LogoutMenu(
          avatar: user != null
              ? _AvatarPhoto(user: user)
              : _AvatarFallback(user: user),
          onLogout: onLogout,
        );
      },
    );
  }
}

class _LogoutMenu extends StatelessWidget {
  const _LogoutMenu({required this.avatar, required this.onLogout});

  final Widget avatar;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      key: const Key('avatar_menu'),
      tooltip: 'Compte',
      padding: const EdgeInsets.all(12),
      onSelected: (_) => onLogout(),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Déconnexion',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
      child: avatar,
    );
  }
}

/// Avatar réseau : `UserModel.photoUrl`. Si l'URL est absente ou en erreur,
/// bascule sur l'avatar fallback (initiales / icône).
class _AvatarPhoto extends StatelessWidget {
  const _AvatarPhoto({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoUrl;
    if (photoUrl == null || photoUrl.isEmpty) {
      return _AvatarFallback(user: user);
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: photoUrl,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        placeholder: (context, url) => _AvatarFallback(user: user),
        errorWidget: (context, url, error) => _AvatarFallback(user: user),
      ),
    );
  }
}

/// Avatar par défaut : initiales du nom complet, sinon icône `Icons.person`.
class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final initiales = user != null ? _initiales(user!.nomComplet) : '';
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primary,
      child: initiales.isEmpty
          ? const Icon(Icons.person, color: Colors.white, size: 20)
          : Text(
              initiales,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
    );
  }

  static String _initiales(String nomComplet) {
    final parties = nomComplet.trim().split(RegExp(r'\s+'));
    return parties
        .take(2)
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
        .join();
  }
}
