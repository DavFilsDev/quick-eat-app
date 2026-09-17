import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../routes/app_router.dart';
import '../controllers/profile_controller.dart';
import 'profile_edit_dialog.dart';
import 'profile_header.dart';
import 'profile_info_tile.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.estCommercant});

  final bool estCommercant;

  Future<void> _modifierInfos(
    BuildContext context,
    ProfileController controller,
  ) async {
    final user = controller.user;
    if (user == null) return;

    final succes = await ProfileEditDialog.show(
      context,
      controller: controller,
      user: user,
    );
    if (succes && context.mounted) {
      _afficherMessage(context, 'Informations mises à jour.');
    }
  }

  Future<void> _changerMotDePasse(
    BuildContext context,
    ProfileController controller,
  ) async {
    final succes = await controller.envoyerReinitialisationMotDePasse();
    if (!context.mounted) return;
    _afficherMessage(
      context,
      succes
          ? 'Email de réinitialisation envoyé.'
          : (controller.errorMessage ?? 'Une erreur est survenue.'),
    );
  }

  Future<void> _deconnecter(
    BuildContext context,
    ProfileController controller,
  ) async {
    await controller.seDeconnecter();
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
  }

  void _afficherMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        if (controller.status == ProfileStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.status == ProfileStatus.error) {
          return Center(
            child: Text(
              controller.errorMessage ?? 'Erreur de chargement.',
              style: AppTextStyles.body,
            ),
          );
        }

        final user = controller.user;
        if (user == null) {
          return const Center(
            child: Text('Profil indisponible.', style: AppTextStyles.body),
          );
        }

        final campus = user.campus.isEmpty ? 'Non renseigné' : user.campus;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(user: user),
              const SizedBox(height: 24),
              const _TitreSection('Informations personnelles'),
              Card(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    ProfileInfoTile(
                      icon: Icons.person_outline,
                      label: 'Nom complet',
                      value: user.nomComplet,
                    ),
                    ProfileInfoTile(
                      icon: Icons.email_outlined,
                      label: 'Adresse email',
                      value: user.email,
                    ),
                    ProfileInfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: (user.telephone ?? '').isEmpty
                          ? 'Non renseigné'
                          : user.telephone!,
                    ),
                    if (!estCommercant)
                      ProfileInfoTile(
                        icon: Icons.school_outlined,
                        label: 'Campus',
                        value: campus,
                      ),
                  ],
                ),
              ),
              if (estCommercant) ...[
                const SizedBox(height: 24),
                const _TitreSection('Mon stand'),
                Card(
                  elevation: 0,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      ProfileInfoTile(
                        icon: Icons.storefront_outlined,
                        label: 'Nom du stand',
                        value: user.nomComplet,
                      ),
                      const ProfileInfoTile(
                        icon: Icons.schedule_outlined,
                        label: "Horaires d'ouverture",
                        value: 'Lundi - Vendredi, 08h00 - 20h00',
                      ),
                      ProfileInfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Emplacement',
                        value: campus,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const _TitreSection('Paramètres & préférences'),
              Card(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    ListTile(
                      key: const Key('modifier_informations'),
                      leading: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                      ),
                      title: const Text('Modifier les informations'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _modifierInfos(context, controller),
                    ),
                    ListTile(
                      key: const Key('changer_mot_de_passe'),
                      leading: const Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                      ),
                      title: const Text('Changer de mot de passe'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _changerMotDePasse(context, controller),
                    ),
                    SwitchListTile(
                      key: const Key('toggle_notifications'),
                      secondary: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primary,
                      ),
                      title: const Text('Notifications'),
                      value: controller.notificationsActivees,
                      onChanged: controller.basculerNotifications,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  key: const Key('bouton_deconnexion'),
                  onPressed: () => _deconnecter(context, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusCancelled,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Déconnexion',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _TitreSection extends StatelessWidget {
  const _TitreSection(this.titre);

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        titre.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
