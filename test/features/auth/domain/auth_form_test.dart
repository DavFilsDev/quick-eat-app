import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/features/auth/presentation/widgets/role_toggle.dart';
import 'package:quickeat/models/enums/user_role.dart';

void main() {
  group('RoleToggle Widget Tests', () {
    testWidgets('Bascule le rôle entre Étudiant et Commerçant lors du clic', (
      WidgetTester tester,
    ) async {
      UserRole selectedRole = UserRole.student;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return RoleToggle(
                  selectedRole: selectedRole,
                  onRoleChanged: (newRole) {
                    setState(() {
                      selectedRole = newRole;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Étudiant'), findsOneWidget);
      expect(find.text('Commerçant'), findsOneWidget);

      await tester.tap(find.text('Commerçant'));
      await tester.pump();

      expect(selectedRole, equals(UserRole.merchant));
    });
  });
}
