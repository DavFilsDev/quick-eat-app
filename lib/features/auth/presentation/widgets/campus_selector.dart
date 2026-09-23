import 'package:flutter/material.dart';

import '../../domain/campus_options.dart';
import 'auth_text_field.dart';

class CampusSelector extends StatelessWidget {
  final String? selection;
  final ValueChanged<String?> onChanged;
  final TextEditingController customController;

  const CampusSelector({
    super.key,
    required this.selection,
    required this.onChanged,
    required this.customController,
  });

  bool get _estAutre => selection == optionCampusAutre;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: const Key('campus_dropdown'),
          initialValue: selection,
          decoration: const InputDecoration(
            labelText: 'Ton Campus principal',
            prefixIcon: Icon(Icons.school_outlined),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          items: [
            for (final campus in [...campusesPredefinis, optionCampusAutre])
              DropdownMenuItem<String>(value: campus, child: Text(campus)),
          ],
          onChanged: onChanged,
        ),
        if (_estAutre) ...[
          const SizedBox(height: 14),
          AuthTextField(
            key: const Key('champ_campus_autre'),
            controller: customController,
            label: 'Préciser votre campus',
            prefixIcon: Icons.edit_location_alt_outlined,
            validator: (val) =>
                (val == null || val.trim().isEmpty) ? 'Campus requis' : null,
          ),
        ],
      ],
    );
  }
}
