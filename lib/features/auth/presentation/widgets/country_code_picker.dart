import 'package:flutter/material.dart';

import '../../domain/african_dial_codes.dart';
import '../../domain/country_dial_code.dart';

class CountryCodePicker extends StatelessWidget {
  final String indicatifSelectionne;
  final ValueChanged<CountryDialCode> onIndicatifChange;

  const CountryCodePicker({
    super.key,
    required this.indicatifSelectionne,
    required this.onIndicatifChange,
  });

  Future<void> _ouvrir(BuildContext context) async {
    final selection = await showModalBottomSheet<CountryDialCode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          _CountryCodeSheet(indicatifSelectionne: indicatifSelectionne),
    );
    if (selection != null) {
      onIndicatifChange(selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courant = indicatifParCode(indicatifSelectionne);

    return InkWell(
      key: const Key('selecteur_indicatif'),
      onTap: () => _ouvrir(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              courant?.drapeau ?? '🌍',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 4),
            Text(indicatifSelectionne, style: const TextStyle(fontSize: 14)),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CountryCodeSheet extends StatefulWidget {
  final String indicatifSelectionne;

  const _CountryCodeSheet({required this.indicatifSelectionne});

  @override
  State<_CountryCodeSheet> createState() => _CountryCodeSheetState();
}

class _CountryCodeSheetState extends State<_CountryCodeSheet> {
  final _rechercheController = TextEditingController();
  String _recherche = '';

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  List<CountryDialCode> get _resultats {
    final requete = normaliserTexte(_recherche.trim());
    if (requete.isEmpty) return indicatifsAfricains;
    return indicatifsAfricains.where((pays) {
      final nom = normaliserTexte(pays.pays);
      final code = pays.indicatif.replaceAll('+', '');
      return nom.contains(requete) || code.contains(requete);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resultats = _resultats;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Indicatif téléphonique',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                key: const Key('recherche_indicatif'),
                controller: _rechercheController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (valeur) => setState(() => _recherche = valeur),
                decoration: InputDecoration(
                  hintText: 'Rechercher un pays',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: resultats.isEmpty
                  ? const Center(child: Text('Aucun pays trouvé.'))
                  : ListView.builder(
                      itemCount: resultats.length,
                      itemBuilder: (context, index) {
                        final pays = resultats[index];
                        final selectionne =
                            pays.indicatif == widget.indicatifSelectionne;
                        return ListTile(
                          key: Key('pays_${pays.isoCode}'),
                          leading: Text(
                            pays.drapeau,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(pays.pays),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                pays.indicatif,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              if (selectionne) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                          onTap: () => Navigator.of(context).pop(pays),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
