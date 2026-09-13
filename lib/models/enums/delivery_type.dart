/// Mode de réception d'une commande.
enum DeliveryType {
  livraison('LIVRAISON', 'Livraison'),
  retrait('RETRAIT', 'Retrait');

  const DeliveryType(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static DeliveryType fromDbValue(String value) {
    return DeliveryType.values.firstWhere(
      (type) => type.dbValue == value,
      orElse: () => DeliveryType.retrait,
    );
  }
}
