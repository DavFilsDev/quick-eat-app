import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../models/user_model.dart';
import '../controllers/profile_controller.dart';

class ProfileEditDialog extends StatefulWidget {
  const ProfileEditDialog({
    super.key,
    required this.controller,
    required this.user,
  });

  final ProfileController controller;
  final UserModel user;

  static Future<bool> show(
    BuildContext context, {
    required ProfileController controller,
    required UserModel user,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProfileEditDialog(controller: controller, user: user),
    ).then((resultat) => resultat ?? false);
  }

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _prenomsController;
  late final TextEditingController _nomController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _photoUrlController;
  bool _enregistrement = false;

  @override
  void initState() {
    super.initState();
    _prenomsController = TextEditingController(text: widget.user.prenoms);
    _nomController = TextEditingController(text: widget.user.nom);
    _telephoneController = TextEditingController(
      text: widget.user.telephone ?? '',
    );
    _photoUrlController = TextEditingController(
      text: widget.user.photoUrl ?? '',
    );
  }

  @override
  void dispose() {
    _prenomsController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  String? _champRequis(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enregistrement = true);

    final photoUrl = _photoUrlController.text.trim();
    final succes = await widget.controller.mettreAJourInfos(
      prenoms: _prenomsController.text.trim(),
      nom: _nomController.text.trim(),
      telephone: _telephoneController.text.trim(),
      photoUrl: photoUrl.isEmpty ? null : photoUrl,
    );

    if (!mounted) return;
    setState(() => _enregistrement = false);
    if (succes) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modifier mes informations',
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('champ_prenoms'),
                  controller: _prenomsController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Prénoms',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      _champRequis(value, 'Les prénoms sont requis'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('champ_nom'),
                  controller: _nomController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      _champRequis(value, 'Le nom est requis'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('champ_telephone'),
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      _champRequis(value, 'Le téléphone est requis'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('champ_photo_url'),
                  controller: _photoUrlController,
                  decoration: const InputDecoration(
                    labelText: "URL de la photo (optionnel)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('valider_infos'),
                    onPressed: _enregistrement ? null : _soumettre,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _enregistrement
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Enregistrer'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    key: const Key('annuler_infos'),
                    onPressed: _enregistrement
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
