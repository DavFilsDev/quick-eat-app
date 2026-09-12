/// Statut d'une commande.
///
/// Flux : EN_ATTENTE → ACCEPTEE → (EN_COURS_DE_LIVRAISON → LIVREE
/// en livraison, ou TERMINEE → RECU en retrait). ANNULEE n'est
/// possible qu'à partir de EN_ATTENTE.
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
