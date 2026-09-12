import '../models/enums/delivery_type.dart';
import '../models/enums/order_status.dart';
import '../models/enums/user_role.dart';
import '../models/food_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

/// Données locales qui remplacent Firebase pendant le développement.
///
/// Utiliser ces listes permet de tester l'application sans Firestore :
/// le jour de la mise en production, on remplace simplement la source
/// de données par les appels Firestore.
class MockData {
  MockData._();

  /// Tous les utilisateurs (étudiants et commerçants).
  static final List<UserModel> utilisateurs = <UserModel>[
    UserModel(
      idUser: 'user-001',
      prenoms: 'Moussa',
      nom: 'Ndiaye',
      email: 'moussa@gmail.com',
      telephone: '+237 690 00 00 01',
      role: UserRole.student,
      campus: 'Campus de Ngoa-Ekéllé',
      dateCreation: _joursAvant(60),
    ),
    UserModel(
      idUser: 'user-002',
      prenoms: 'Fatou',
      nom: 'Kone',
      email: 'fatou@gmail.com',
      telephone: '+237 690 00 00 02',
      role: UserRole.student,
      campus: 'Campus de Melen',
      dateCreation: _joursAvant(45),
    ),
    UserModel(
      idUser: 'user-003',
      prenoms: 'Brice',
      nom: 'Onana',
      email: 'brice@gmail.com',
      telephone: '+237 690 00 00 03',
      role: UserRole.student,
      campus: 'Campus de Melen',
      dateCreation: _joursAvant(30),
    ),
    UserModel(
      idUser: 'user-004',
      prenoms: 'Amina',
      nom: 'Diallo',
      email: 'amina.diallo@gmail.com',
      telephone: '+237 690 00 00 04',
      role: UserRole.merchant,
      campus: 'Campus de Ngoa-Ekéllé',
      dateCreation: _joursAvant(120),
    ),
    UserModel(
      idUser: 'user-005',
      prenoms: 'Jean-Paul',
      nom: 'Mbarga',
      email: 'jp.mbarga@gmail.com',
      telephone: '+237 690 00 00 05',
      role: UserRole.merchant,
      campus: 'Campus de Melen',
      dateCreation: _joursAvant(90),
    ),
  ];

  /// Liste des étudiants (dérivée de [utilisateurs]).
  static List<UserModel> get etudiants =>
      utilisateurs.where((user) => user.role == UserRole.student).toList();

  /// Liste des commerçants (dérivée de [utilisateurs]).
  static List<UserModel> get commercants =>
      utilisateurs.where((user) => user.role == UserRole.merchant).toList();

  /// Plats proposés par les commerçants.
  static final List<FoodModel> plats = <FoodModel>[
    FoodModel(
      idFood: 'food-001',
      nom: 'Burger Poulet',
      description: 'Steak de poulet, salade, tomate, sauce maison.',
      prix: 1500,
      categorie: 'Fast Food',
      idCommercant: 'user-004',
    ),
    FoodModel(
      idFood: 'food-002',
      nom: 'Sandwich Döner',
      description: 'Viande döner, frites, crudités, sauce blanche.',
      prix: 1200,
      categorie: 'Fast Food',
      idCommercant: 'user-004',
    ),
    FoodModel(
      idFood: 'food-003',
      nom: 'Pizza Margherita',
      description: 'Sauce tomate, mozzarella, origan.',
      prix: 3500,
      categorie: 'Pizza',
      idCommercant: 'user-005',
    ),
    FoodModel(
      idFood: 'food-004',
      nom: 'Boisson gazeuse',
      description: 'Coca-Cola, Fanta ou Sprite en 50cl.',
      prix: 500,
      categorie: 'Boisson',
      idCommercant: 'user-005',
    ),
    FoodModel(
      idFood: 'food-005',
      nom: 'Beignets',
      description: 'Beignets sucrés servis chauds.',
      prix: 300,
      categorie: 'Snack',
      disponible: false,
      idCommercant: 'user-004',
    ),
  ];

  /// Commandes passées, couvrant tous les statuts.
  static final List<OrderModel> commandes = <OrderModel>[
    OrderModel(
      idCommande: 'cmd-001',
      idEtudiant: 'user-001',
      idCommercant: 'user-004',
      dateCommande: _joursAvant(0, heures: -2),
      montantTotal: 1500,
      typeReception: DeliveryType.livraison,
      adresseLivraison: 'Résidence Campus Ngoa, chambre 12',
      statut: OrderStatus.enAttente,
      items: <OrderItemModel>[
        const OrderItemModel(
          idItem: 'item-001',
          idFood: 'food-001',
          nom: 'Burger Poulet',
          quantite: 1,
          prixUnitaire: 1500,
        ),
      ],
    ),
    OrderModel(
      idCommande: 'cmd-002',
      idEtudiant: 'user-002',
      idCommercant: 'user-004',
      dateCommande: _joursAvant(1, heures: -1),
      montantTotal: 2400,
      typeReception: DeliveryType.retrait,
      statut: OrderStatus.acceptee,
      items: <OrderItemModel>[
        const OrderItemModel(
          idItem: 'item-002',
          idFood: 'food-002',
          nom: 'Sandwich Döner',
          quantite: 2,
          prixUnitaire: 1200,
        ),
      ],
    ),
    OrderModel(
      idCommande: 'cmd-003',
      idEtudiant: 'user-003',
      idCommercant: 'user-005',
      dateCommande: _joursAvant(2, heures: -3),
      montantTotal: 4000,
      typeReception: DeliveryType.livraison,
      adresseLivraison: 'Amphi 300, Campus Melen',
      statut: OrderStatus.enCoursDeLivraison,
      items: <OrderItemModel>[
        const OrderItemModel(
          idItem: 'item-003',
          idFood: 'food-003',
          nom: 'Pizza Margherita',
          quantite: 1,
          prixUnitaire: 3500,
        ),
        const OrderItemModel(
          idItem: 'item-004',
          idFood: 'food-004',
          nom: 'Boisson gazeuse',
          quantite: 1,
          prixUnitaire: 500,
        ),
      ],
    ),
    OrderModel(
      idCommande: 'cmd-004',
      idEtudiant: 'user-001',
      idCommercant: 'user-005',
      dateCommande: _joursAvant(3, heures: -4),
      montantTotal: 3500,
      typeReception: DeliveryType.retrait,
      statut: OrderStatus.terminee,
      items: <OrderItemModel>[
        const OrderItemModel(
          idItem: 'item-005',
          idFood: 'food-003',
          nom: 'Pizza Margherita',
          quantite: 1,
          prixUnitaire: 3500,
        ),
      ],
    ),
    OrderModel(
      idCommande: 'cmd-005',
      idEtudiant: 'user-002',
      idCommercant: 'user-004',
      dateCommande: _joursAvant(4, heures: -5),
      montantTotal: 1800,
      typeReception: DeliveryType.livraison,
      adresseLivraison: 'Résidence Campus Melen, bloc B',
      statut: OrderStatus.livree,
      items: <OrderItemModel>[
        const OrderItemModel(
          idItem: 'item-006',
          idFood: 'food-001',
          nom: 'Burger Poulet',
          quantite: 1,
          prixUnitaire: 1500,
        ),
        const OrderItemModel(
          idItem: 'item-007',
          idFood: 'food-005',
          nom: 'Beignets',
          quantite: 1,
          prixUnitaire: 300,
        ),
      ],
    ),
    OrderModel(
      idCommande: 'cmd-006',
      idEtudiant: 'user-003',
      idCommercant: 'user-005',
      dateCommande: _joursAvant(5, heures: -6),
      montantTotal: 500,
      typeReception: DeliveryType.livraison,
      adresseLivraison: 'Résidence Campus Melen, bloc A',
      statut: OrderStatus.recu,
      items: <OrderItemModel>[
        const OrderItemModel(
          idItem: 'item-008',
          idFood: 'food-004',
          nom: 'Boisson gazeuse',
          quantite: 1,
          prixUnitaire: 500,
        ),
      ],
    ),
  ];

  /// Retourne un [DateTime] il y a [jours] jours (+ [heures] peut être négatif).
  static DateTime _joursAvant(int jours, {int heures = 0}) {
    return DateTime.now()
        .subtract(Duration(days: jours, hours: -heures))
        .copyWith(second: 0, millisecond: 0, microsecond: 0);
  }
}
