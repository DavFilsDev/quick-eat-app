import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/core/theme/app_theme.dart';

void main() {
  test('Le thème de l\'application se construit sans erreur', () {
    expect(AppTheme.lightTheme, isNotNull);
  });
}
