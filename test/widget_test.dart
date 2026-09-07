import 'package:flutter_test/flutter_test.dart';
import 'package:quickeat/app.dart';

void main() {
  testWidgets('Initial app load smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuickEatApp());

    expect(find.byType(QuickEatApp), findsOneWidget);
  });
}
