import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/features/auth/domain/country_dial_code.dart';
import 'package:quickeat/features/auth/presentation/widgets/country_code_picker.dart';

void main() {
  testWidgets('recherche un pays par son nom et le sélectionne', (
    tester,
  ) async {
    CountryDialCode? choisi;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CountryCodePicker(
            indicatifSelectionne: '+261',
            onIndicatifChange: (pays) => choisi = pays,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('selecteur_indicatif')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('recherche_indicatif')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('recherche_indicatif')),
      'sene',
    );
    await tester.pump();

    expect(find.byKey(const Key('pays_SN')), findsOneWidget);
    expect(find.byKey(const Key('pays_MG')), findsNothing);

    await tester.tap(find.byKey(const Key('pays_SN')));
    await tester.pumpAndSettle();

    expect(choisi?.indicatif, '+221');
    expect(find.byKey(const Key('recherche_indicatif')), findsNothing);
  });

  testWidgets('recherche un pays par son indicatif', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CountryCodePicker(
            indicatifSelectionne: '+261',
            onIndicatifChange: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('selecteur_indicatif')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('recherche_indicatif')), '234');
    await tester.pump();

    expect(find.byKey(const Key('pays_NG')), findsOneWidget);
    expect(find.byKey(const Key('pays_MG')), findsNothing);
  });
}
