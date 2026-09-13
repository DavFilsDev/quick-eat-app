import 'package:flutter/material.dart';

/// Palette de couleurs QuickEat, alignée sur les maquettes Figma.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFB3401E); // orange brûlé "QuickEat"
  static const Color secondary = Colors.orangeAccent;

  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);

  // Couleurs des badges de statut de commande.
  static const Color statusPending = Color(0xFFF5A623); // EN_ATTENTE
  static const Color statusAccepted = Color(0xFF2E7D32); // ACCEPTEE
  static const Color statusInProgress = Color(
    0xFFB3401E,
  ); // EN_COURS_DE_LIVRAISON
  static const Color statusDone = Color(0xFF2E7D32); // LIVREE / TERMINEE / RECU
  static const Color statusCancelled = Color(0xFFB00020); // ANNULEE
}
