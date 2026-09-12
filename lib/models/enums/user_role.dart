/// Rôle d'un utilisateur dans l'application.
enum UserRole {
  student('STUDENT', 'Étudiant'),
  merchant('MERCHANT', 'Commerçant');

  const UserRole(this.dbValue, this.label);

  /// Valeur stockée dans Firestore.
  final String dbValue;

  /// Libellé affiché dans l'interface.
  final String label;

  /// Retourne le rôle correspondant à une valeur Firestore.
  static UserRole fromDbValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.dbValue == value,
      orElse: () => UserRole.student,
    );
  }
}
