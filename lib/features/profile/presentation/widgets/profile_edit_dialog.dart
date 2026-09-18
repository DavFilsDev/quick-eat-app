import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../models/user_model.dart';
import '../controllers/profile_controller.dart';

class ProfileEditDialog extends StatefulWidget {
  const ProfileEditDialog({
    super.key,
    required this.controller,
    required this.user,
    this.imagePickerService,
  });

  final ProfileController controller;
  final UserModel user;
  final ImagePickerService? imagePickerService;

  static Future<bool> show(
    BuildContext context, {
    required ProfileController controller,
    required UserModel user,
    ImagePickerService? imagePickerService,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProfileEditDialog(
        controller: controller,
        user: user,
        imagePickerService: imagePickerService,
      ),
    ).then((resultat) => resultat ?? false);
  }

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late final ImagePickerService _pickerService;
  late final TextEditingController _prenomsController;
  late final TextEditingController _nomController;
  late final TextEditingController _telephoneController;
  String? _photoUrl;
  bool _enregistrement = false;
  bool _choixImage = false;

  @override
  void initState() {
    super.initState();
    _pickerService = widget.imagePickerService ?? DeviceImagePickerService();
    _prenomsController = TextEditingController(text: widget.user.prenoms);
    _nomController = TextEditingController(text: widget.user.nom);
    _telephoneController = TextEditingController(
      text: widget.user.telephone ?? '',
    );
    _photoUrl = widget.user.photoUrl;
  }

  @override
  void dispose() {
    _prenomsController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  String? _champRequis(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  Future<void> _choisirPhoto() async {
    setState(() => _choixImage = true);
    final selection = await _pickerService.choisirImage();
    if (!mounted) return;
    setState(() {
      _choixImage = false;
      if (selection != null) {
        _photoUrl = selection.dataUri;
      }
    });
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enregistrement = true);

    final photoUrl = _photoUrl;
    final succes = await widget.controller.mettreAJourInfos(
      prenoms: _prenomsController.text.trim(),
      nom: _nomController.text.trim(),
      telephone: _telephoneController.text.trim(),
      photoUrl: photoUrl == null || photoUrl.isEmpty ? null : photoUrl,
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
                const SizedBox(height: 20),
                Center(
                  child: _ChampPhoto(
                    photoUrl: _photoUrl,
                    nom: widget.user.nomComplet,
                    enCours: _choixImage,
                    onChoisir: _choisirPhoto,
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('valider_infos'),
                    onPressed: _enregistrement || _choixImage
                        ? null
                        : _soumettre,
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

class _ChampPhoto extends StatelessWidget {
  const _ChampPhoto({
    required this.photoUrl,
    required this.nom,
    required this.enCours,
    required this.onChoisir,
  });

  final String? photoUrl;
  final String nom;
  final bool enCours;
  final VoidCallback onChoisir;

  @override
  Widget build(BuildContext context) {
    final valeur = photoUrl;

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.primary,
          child: ClipOval(
            child: valeur == null || valeur.isEmpty
                ? _Initiales(nom: nom)
                : AppImage(
                    value: valeur,
                    width: 96,
                    height: 96,
                    placeholder: _Initiales(nom: nom),
                    errorWidget: _Initiales(nom: nom),
                  ),
          ),
        ),
        if (enCours)
          const Positioned(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              key: const Key('choisir_photo_profil'),
              customBorder: const CircleBorder(),
              onTap: enCours ? null : onChoisir,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Initiales extends StatelessWidget {
  const _Initiales({required this.nom});

  final String nom;

  @override
  Widget build(BuildContext context) {
    final parties = nom.trim().split(RegExp(r'\s+'));
    final initiales = parties
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      color: AppColors.primary,
      child: initiales.isEmpty
          ? const Icon(Icons.person, color: Colors.white, size: 40)
          : Text(
              initiales,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
