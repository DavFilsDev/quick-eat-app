import 'package:flutter_test/flutter_test.dart';

import 'package:quickeat/mock/mock_data.dart';
import 'package:quickeat/models/enums/order_status.dart';
import 'package:quickeat/models/enums/user_role.dart';

void main() {
  group('MockData', () {
    test('contient des utilisateurs avec campus et prenoms renseignés', () {
      expect(MockData.utilisateurs, isNotEmpty);

      for (final user in MockData.utilisateurs) {
        expect(
          user.campus,
          isNotEmpty,
          reason: 'campus manquant: ${user.idUser}',
        );
        expect(
          user.prenoms,
          isNotEmpty,
          reason: 'prenoms manquants: ${user.idUser}',
        );
      }
    });

    test('contient étudiants et commerçants', () {
      expect(MockData.etudiants, isNotEmpty);
      expect(MockData.commercants, isNotEmpty);
      expect(
        MockData.etudiants.every((u) => u.role == UserRole.student),
        isTrue,
      );
      expect(
        MockData.commercants.every((u) => u.role == UserRole.merchant),
        isTrue,
      );
    });

    test('contient des plats disponibles et indisponibles', () {
      expect(MockData.plats, isNotEmpty);
      expect(MockData.plats.any((plat) => plat.disponible), isTrue);
      expect(MockData.plats.any((plat) => !plat.disponible), isTrue);
      expect(MockData.plats.every((plat) => plat.prix > 0), isTrue);
    });

    test('chaque commande référence un étudiant et un commerçant valides', () {
      expect(MockData.commandes, isNotEmpty);

      for (final commande in MockData.commandes) {
        final etudiantExiste = MockData.etudiants.any(
          (u) => u.idUser == commande.idEtudiant,
        );
        final commercantExiste = MockData.commercants.any(
          (u) => u.idUser == commande.idCommercant,
        );

        expect(
          etudiantExiste,
          isTrue,
          reason: 'étudiant inconnu: ${commande.idEtudiant}',
        );
        expect(
          commercantExiste,
          isTrue,
          reason: 'commerçant inconnu: ${commande.idCommercant}',
        );
      }
    });

    test('chaque ligne de commande référence un plat valide', () {
      for (final commande in MockData.commandes) {
        for (final item in commande.items) {
          final platExiste = MockData.plats.any((p) => p.idFood == item.idFood);
          expect(
            platExiste,
            isTrue,
            reason: 'plat inconnu: ${item.idFood} (${commande.idCommande})',
          );
          expect(item.quantite, greaterThan(0));
          expect(item.sousTotal, item.quantite * item.prixUnitaire);
        }
      }
    });

    test('commandes couvrant tous les statuts du flux', () {
      final statuts = MockData.commandes.map((c) => c.statut).toSet();
      expect(
        statuts,
        containsAll(<OrderStatus>[
          OrderStatus.enAttente,
          OrderStatus.acceptee,
          OrderStatus.terminee,
          OrderStatus.enCoursDeLivraison,
          OrderStatus.livree,
          OrderStatus.recu,
        ]),
      );
    });
  });
}
