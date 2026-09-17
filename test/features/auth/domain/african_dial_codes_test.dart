import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/features/auth/domain/african_dial_codes.dart';
import 'package:quickeat/features/auth/domain/country_dial_code.dart';

void main() {
  group('indicatifsAfricains', () {
    test('contient les 54 pays africains avec des données valides', () {
      expect(indicatifsAfricains.length, 54);
      for (final pays in indicatifsAfricains) {
        expect(pays.pays, isNotEmpty);
        expect(pays.indicatif, matches(RegExp(r'^\+\d{1,3}$')));
        expect(pays.isoCode, matches(RegExp(r'^[A-Z]{2}$')));
      }
    });

    test('les indicatifs sont uniques', () {
      final codes = indicatifsAfricains.map((pays) => pays.indicatif).toSet();
      expect(codes.length, indicatifsAfricains.length);
    });

    test('indicatifParCode retrouve le pays correspondant', () {
      expect(indicatifParCode('+229')?.pays, 'Bénin');
      expect(indicatifParCode('+261')?.pays, 'Madagascar');
      expect(indicatifParCode('+999'), isNull);
    });
  });

  group('CountryDialCode', () {
    test('drapeau convertit le code ISO en emoji', () {
      const madagascar = CountryDialCode(
        pays: 'Madagascar',
        indicatif: '+261',
        isoCode: 'MG',
      );
      expect(madagascar.drapeau, '🇲🇬');
    });
  });

  group('normaliserTexte', () {
    test('supprime les diacritiques pour la recherche', () {
      expect(normaliserTexte('Sénégal'), 'senegal');
      expect(normaliserTexte("Côte d'Ivoire"), "cote d'ivoire");
    });
  });
}
