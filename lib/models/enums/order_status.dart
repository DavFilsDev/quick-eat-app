enum OrderStatus {
  enAttente('EN_ATTENTE', 'En attente'),
  acceptee('ACCEPTEE', 'Acceptée'),
  enCoursDeLivraison('EN_COURS_DE_LIVRAISON', 'En cours de livraison'),
  livree('LIVREE', 'Livrée'),
  terminee('TERMINEE', 'Terminée'),
  recu('RECU', 'Reçue'),
  annulee('ANNULEE', 'Annulée');

  const OrderStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static OrderStatus fromDbValue(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.dbValue == value,
      orElse: () => OrderStatus.enAttente,
    );
  }
}
