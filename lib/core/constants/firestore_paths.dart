/// Centralise les noms de collections Firestore. Ne jamais écrire une
/// chaîne de collection "en dur" ailleurs dans le code — importer ceci.
class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String menus = 'menus';
  static const String orders = 'orders';

  /// Sous-collection `orders/{orderId}/items`.
  static const String orderItems = 'items';
}
