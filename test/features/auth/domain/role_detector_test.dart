import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/features/auth/domain/role_detector.dart';
import 'package:quickeat/models/enums/user_role.dart';

void main() {
  group('RoleDetector Tests', () {
    test('Email académique doit retourner UserRole.student', () {
      final role = RoleDetector.detectFromEmail('etudiant@ankatso.mg');
      expect(role, equals(UserRole.student));
    });

    test('Email grand public (Gmail) doit retourner null', () {
      final role = RoleDetector.detectFromEmail('etudiant@gmail.com');
      expect(role, isNull);
    });

    test('Email domaine privé entreprise doit retourner UserRole.merchant', () {
      final role = RoleDetector.detectFromEmail('contact@mami-resto.com');
      expect(role, equals(UserRole.merchant));
    });
  });
}
