class CountryDialCode {
  final String pays;
  final String indicatif;
  final String isoCode;

  const CountryDialCode({
    required this.pays,
    required this.indicatif,
    required this.isoCode,
  });

  String get drapeau {
    final base = 0x1F1E6;
    final runes = isoCode.toUpperCase().runes.map(
      (rune) => base + (rune - 0x41),
    );
    return String.fromCharCodes(runes);
  }

  String get libelle => '$drapeau $indicatif';
}

const Map<String, String> _diacritiques = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'ç': 'c',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'î': 'i',
  'ï': 'i',
  'ô': 'o',
  'ö': 'o',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'œ': 'oe',
};

String normaliserTexte(String valeur) {
  final buffer = StringBuffer();
  for (final rune in valeur.toLowerCase().runes) {
    final caractere = String.fromCharCode(rune);
    buffer.write(_diacritiques[caractere] ?? caractere);
  }
  return buffer.toString();
}
