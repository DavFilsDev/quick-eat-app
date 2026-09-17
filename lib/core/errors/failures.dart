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

class InvalidOrderTransition extends Failure {
  const InvalidOrderTransition(super.message);
}
