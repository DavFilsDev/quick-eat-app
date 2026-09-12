/// Statut d'évolution d'une commande.
///
/// Flux complet :
/// EN_ATTENTE → ACCEPTEE → TERMINEE → EN_COURS_DE_LIVRAISON → LIVREE → RECU
/// En mode retrait, la commande passe de TERMINEE directement à RECU.
enum OrderStatus {
  enAttente('EN_ATTENTE', 'En attente'),
  acceptee('ACCEPTEE', 'Acceptée'),
  enCoursDeLivraison('EN_COURS_DE_LIVRAISON', 'En cours de livraison'),
  livree('LIVREE', 'Livrée'),
  terminee('TERMINEE', 'Terminée'),
  recu('RECU', 'Reçue'),
  annulee('ANNULEE', 'Annulée');

  const OrderStatus(this.dbValue, this.label);

  /// Valeur stockée dans Firestore.
  final String dbValue;

  /// Libellé affiché dans l'interface.
  final String label;

  /// Retourne le statut correspondant à une valeur Firestore.
  static OrderStatus fromDbValue(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.dbValue == value,
      orElse: () => OrderStatus.enAttente,
    );
  }
}
