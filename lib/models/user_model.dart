import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums/user_role.dart';

/// Modèle d'un utilisateur (étudiant ou commerçant).
///
/// Stocké dans la collection Firestore `users`.
class UserModel {
  /// Identifiant unique (clé primaire).
  final String idUser;

  /// Prénom(s) de l'utilisateur (affiché sur la page profil).
  final String prenoms;

  /// Nom de famille de l'utilisateur.
  final String nom;

  /// Adresse email.
  final String email;

  /// Numéro de téléphone.
  final String? telephone;

  /// Rôle : étudiant ou commerçant.
  final UserRole role;

  /// URL de la photo de profil.
  final String? photoUrl;

  /// Campus d'inscription de l'utilisateur.
  final String campus;

  /// Date de création du compte.
  final DateTime? dateCreation;

  const UserModel({
    required this.idUser,
    required this.prenoms,
    required this.nom,
    required this.email,
    this.telephone,
    this.role = UserRole.student,
    this.photoUrl,
    required this.campus,
    this.dateCreation,
  });

  /// Nom complet prénom(s) + nom.
  String get nomComplet => '$prenoms $nom'.trim();

  /// Construit un [UserModel] depuis un document Firestore.
  factory UserModel.fromMap(Map<String, dynamic> data, {required String id}) {
    return UserModel(
      idUser: data['idUser'] as String? ?? id,
      prenoms: data['prenoms'] as String? ?? '',
      nom: data['nom'] as String? ?? '',
      email: data['email'] as String? ?? '',
      telephone: data['telephone'] as String?,
      role: UserRole.fromDbValue(data['role'] as String? ?? 'STUDENT'),
      photoUrl: data['photoUrl'] as String?,
      campus: data['campus'] as String? ?? '',
      dateCreation: _parseDate(data['dateCreation']),
    );
  }

  /// Convertit le modèle en document Firestore.
  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'prenoms': prenoms,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'role': role.dbValue,
      'photoUrl': photoUrl,
      'campus': campus,
      'dateCreation': dateCreation,
    };
  }

  /// Construit un [UserModel] depuis un JSON (API REST).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromMap(json, id: json['idUser'] as String? ?? '');
  }

  /// Convertit le modèle en JSON (API REST).
  Map<String, dynamic> toJson() => toMap();

  /// Copie du modèle en modifiant certains champs.
  UserModel copyWith({
    String? prenoms,
    String? nom,
    String? email,
    String? telephone,
    UserRole? role,
    String? photoUrl,
    String? campus,
    DateTime? dateCreation,
  }) {
    return UserModel(
      idUser: idUser,
      prenoms: prenoms ?? this.prenoms,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      campus: campus ?? this.campus,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  /// Parse une date venant de Firestore (Timestamp) ou d'un JSON (String).
  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }

  @override
  String toString() => 'UserModel($nomComplet — $role — $campus)';
}
