import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/features/auth/domain/campus_options.dart';
import 'package:quickeat/features/auth/presentation/widgets/campus_selector.dart';

void main() {
  testWidgets('affiche le champ personnalisé quand Autre est sélectionné', (
    tester,
  ) async {
    final controller = TextEditingController();
    String? selection = campusesPredefinis.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Form(
              child: CampusSelector(
                selection: selection,
                onChanged: (val) => setState(() => selection = val),
                customController: controller,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('champ_campus_autre')), findsNothing);

    await tester.tap(find.byKey(const Key('campus_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(optionCampusAutre).last);
    await tester.pumpAndSettle();

    expect(selection, optionCampusAutre);
    expect(find.byKey(const Key('champ_campus_autre')), findsOneWidget);
    expect(find.text('Préciser votre campus'), findsOneWidget);
  });

  testWidgets('le champ personnalisé est obligatoire avec Autre', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: CampusSelector(
              selection: optionCampusAutre,
              onChanged: (_) {},
              customController: controller,
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Campus requis'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('champ_campus_autre')),
      'Campus de Melen',
    );

    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('masque le champ personnalisé pour un campus prédéfini', (
    tester,
  ) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: CampusSelector(
              selection: campusesPredefinis.last,
              onChanged: (_) {},
              customController: controller,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('champ_campus_autre')), findsNothing);
  });
}
