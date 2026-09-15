import 'package:flutter/material.dart';

/// Chip de filtre réutilisable pour les catégories ou les restaurants.
/// [labels] sont les libellés affichés (ex: ['Tous', 'Fast Food', 'Pizza', 'Boisson', 'Snack']).
/// [onSelected] est appelé lorsqu'un chip est sélectionné.
class CategoryFilterChip extends StatelessWidget {
  final List<String> labels;
  final ValueChanged<String?> onSelected;
  final String? selectedLabel;

  const CategoryFilterChip({
    super.key,
    required this.labels,
    required this.onSelected,
    this.selectedLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((label) {
        return FilterChip(
          label: Text(label),
          selected: selectedLabel == label,
          onSelected: (selected) => onSelected(selected ? label : null),
        );
      }).toList(),
    );
  }
}
