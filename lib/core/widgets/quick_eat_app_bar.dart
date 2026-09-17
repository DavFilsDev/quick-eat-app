import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../models/user_model.dart';
import '../../routes/app_router.dart';
import '../constants/app_colors.dart';

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

  final String title;

  final List<Widget> actions;

  final Stream<UserModel?>? userStream;

  final Future<void> Function()? onLogout;

  final AuthRepository? authRepository;
  final UserRepository? userRepository;

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
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
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
