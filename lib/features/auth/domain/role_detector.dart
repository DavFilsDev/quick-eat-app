import '../../../models/enums/user_role.dart';

class RoleDetector {
  static const List<String> _studentDomains = [
    'uac.bj',
    'ngoa-ekelle.cm',
    'ankatso.mg',
    'univ-antananarivo.mg',
    '.edu',
    '.ac.',
  ];

  static const List<String> _publicDomains = [
    'gmail.com',
    'yahoo.fr',
    'yahoo.com',
    'outlook.com',
    'hotmail.com',
    'icloud.com',
  ];

  /// Analyse l'email pour suggérer un rôle.
  static UserRole? detectFromEmail(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final parts = cleanEmail.split('@');

    if (parts.length != 2) return null;

    final domain = parts[1];

    // Domaine académique connu -> Étudiant
    for (final studentDomain in _studentDomains) {
      if (domain.contains(studentDomain)) {
        return UserRole.student;
      }
    }

    // Email grand public (Gmail, Yahoo...) -> Indéterminé (Null)
    // On laisse le RoleToggle manuel faire son travail
    if (_publicDomains.contains(domain)) {
      return null;
    }

    // Domaine privé/entreprise -> Commerçant potentiel
    return UserRole.merchant;
  }
}
