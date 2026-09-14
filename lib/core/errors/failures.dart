/// Erreur métier générique à remonter depuis les repositories vers les
/// controllers/UI. Permet d'afficher un message utilisateur sans exposer
/// les détails de FirebaseException dans les widgets.
class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, {this.cause});

  factory Failure.fromException(Object error) {
    return Failure('Une erreur est survenue. Réessayez.', cause: error);
  }

  @override
  String toString() => 'Failure: $message';
}

/// Levée quand une transition de statut de commande est interdite
/// (ex: annulation demandée alors que statut != EN_ATTENTE).
class InvalidOrderTransition extends Failure {
  const InvalidOrderTransition(super.message);
}
