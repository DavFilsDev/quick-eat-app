/// Rôle d'un utilisateur dans QuickEat.
enum UserRole {
  student('STUDENT', 'Étudiant'),
  merchant('MERCHANT', 'Commerçant');

  const UserRole(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static UserRole fromDbValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.dbValue == value,
      orElse: () => UserRole.student,
    );
  }
}
