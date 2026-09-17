import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../models/food_model.dart';
import '../controllers/menu_management_controller.dart';

class MenuFormDialog extends StatefulWidget {
  const MenuFormDialog({super.key, required this.controller, this.plat});

  final MenuManagementController controller;
  final FoodModel? plat;

  static Future<bool> show(
    BuildContext context, {
    required MenuManagementController controller,
    FoodModel? plat,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MenuFormDialog(controller: controller, plat: plat),
    ).then((resultat) => resultat ?? false);
  }

  @override
  State<MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<MenuFormDialog> {
  static const _categoriesPredefinies = <String>[
    'Fast Food',
    'Pizza',
    'Boisson',
    'Snack',
    'Salé',
    'Sucré',
    'Autre',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prixController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _categorieAutreController;
  late final List<String> _categories;
  late String _categorie;
  late bool _disponible;
  bool _enregistrement = false;

  bool get _isEdition => widget.plat != null;

  @override
  void initState() {
    super.initState();
    final plat = widget.plat;
    final categoriePlat = plat?.categorie;
    _nomController = TextEditingController(text: plat?.nom ?? '');
    _descriptionController = TextEditingController(
      text: plat?.description ?? '',
    );
    _prixController = TextEditingController(
      text: plat != null ? plat.prix.toStringAsFixed(0) : '',
    );
    _imageUrlController = TextEditingController(text: plat?.imageUrl ?? '');
    _categories = List<String>.of(_categoriesPredefinies);
    _categorie = categoriePlat == null || _categories.contains(categoriePlat)
        ? (categoriePlat ?? _categories.first)
        : 'Autre';
    _categorieAutreController = TextEditingController(
      text:
          _categorie == 'Autre' &&
              categoriePlat != null &&
              categoriePlat != 'Autre'
          ? categoriePlat
          : '',
    );
    _disponible = plat?.disponible ?? true;

    _imageUrlController.addListener(_rafraichirApercu);
  }

  void _rafraichirApercu() => setState(() {});

  @override
  void dispose() {
    _imageUrlController.removeListener(_rafraichirApercu);
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _imageUrlController.dispose();
    _categorieAutreController.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enregistrement = true);

    final description = _descriptionController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final categorie = _categorie == 'Autre'
        ? _categorieAutreController.text.trim()
        : _categorie;
    final plat = FoodModel(
      idFood: widget.plat?.idFood ?? '',
      nom: _nomController.text.trim(),
      description: description.isEmpty ? null : description,
      prix: double.parse(_prixController.text.replaceAll(',', '.').trim()),
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      categorie: categorie,
      disponible: _disponible,
      idCommercant: widget.plat?.idCommercant ?? '',
    );

    final succes = _isEdition
        ? await widget.controller.modifier(plat)
        : await widget.controller.ajouter(plat);

    if (!mounted) return;
    setState(() => _enregistrement = false);
    if (succes) Navigator.of(context).pop(true);
  }

  String? _validerNom(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le nom est requis';
    return null;
  }

  String? _validerPrix(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le prix est requis';
    final prix = double.tryParse(value.replaceAll(',', '.').trim());
    if (prix == null) return 'Prix invalide';
    if (prix <= 0) return 'Le prix doit être supérieur à 0';
    return null;
  }

  String? _validerCategorieAutre(String? value) {
    if (_categorie != 'Autre') return null;
    if (value == null || value.trim().isEmpty) {
      return 'La catégorie est requise';
    }
    return null;
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEdition ? 'Modifier le plat' : 'Ajouter un plat',
                        style: AppTextStyles.heading1,
                      ),
                    ),
                    IconButton(
                      key: const Key('fermer_modale_plat'),
                      onPressed: _enregistrement
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('champ_nom_plat'),
                  controller: _nomController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nom du plat',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validerNom,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('champ_description_plat'),
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('champ_prix_plat'),
                  controller: _prixController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Prix (FCFA)',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validerPrix,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('champ_categorie_plat'),
                  initialValue: _categorie,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map(
                        (categorie) => DropdownMenuItem(
                          value: categorie,
                          child: Text(categorie),
                        ),
                      )
                      .toList(),
                  onChanged: (valeur) {
                    if (valeur != null) setState(() => _categorie = valeur);
                  },
                ),
                if (_categorie == 'Autre') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('champ_categorie_autre'),
                    controller: _categorieAutreController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Préciser la catégorie',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validerCategorieAutre,
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('champ_image_plat'),
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: "URL de l'image (optionnel)",
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_imageUrlController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: _imageUrlController.text.trim(),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SwitchListTile(
                  key: const Key('champ_disponible_plat'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disponible'),
                  value: _disponible,
                  onChanged: (valeur) => setState(() => _disponible = valeur),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('valider_plat'),
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
                        : Text(_isEdition ? 'Enregistrer' : 'Ajouter'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    key: const Key('annuler_plat'),
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
