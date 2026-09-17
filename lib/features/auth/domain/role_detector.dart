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

  static UserRole? detectFromEmail(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final parts = cleanEmail.split('@');

    if (parts.length != 2) return null;

    final domain = parts[1];

    for (final studentDomain in _studentDomains) {
      if (domain.contains(studentDomain)) {
        return UserRole.student;
      }
    }

    if (_publicDomains.contains(domain)) {
      return null;
    }

    return UserRole.merchant;
  }
}
