/// Mode de réception d'une commande.
enum DeliveryType {
  livraison('LIVRAISON', 'Livraison'),
  retrait('RETRAIT', 'Retrait');

  const DeliveryType(this.dbValue, this.label);

  /// Valeur stockée dans Firestore.
  final String dbValue;

  /// Libellé affiché dans l'interface.
  final String label;

  /// Retourne le type correspondant à une valeur Firestore.
  static DeliveryType fromDbValue(String value) {
    return DeliveryType.values.firstWhere(
      (type) => type.dbValue == value,
      orElse: () => DeliveryType.retrait,
    );
  }
}
