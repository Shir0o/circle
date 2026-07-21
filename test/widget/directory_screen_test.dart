import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circle/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CircleApp renders directory with seed members and allows search', (WidgetTester tester) async {
    await tester.pumpWidget(const CircleApp());
    await tester.pumpAndSettle();

    // Verify App Bar Title
    expect(find.text('Circle'), findsOneWidget);

    // Verify Seed Members are rendered
    expect(find.text('Aiden Park'), findsOneWidget);
    expect(find.text('Diego Morales'), findsOneWidget);

    // Enter search text 'Aiden'
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Aiden');
    await tester.pumpAndSettle();

    // Aiden Park should still be visible, Diego Morales should not
    expect(find.text('Aiden Park'), findsOneWidget);
    expect(find.text('Diego Morales'), findsNothing);

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();
    expect(find.text('Diego Morales'), findsOneWidget);
  });

  testWidgets('Filter chips switch stage views correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const CircleApp());
    await tester.pumpAndSettle();

    // Find and tap 'Kids' chip
    final kidsChip = find.textContaining('Kids');
    expect(kidsChip, findsOneWidget);
    await tester.tap(kidsChip);
    await tester.pumpAndSettle();

    // Sofia Reyes (child) should be shown, Maya Chen (college) should not
    expect(find.text('Sofia Reyes'), findsOneWidget);
    expect(find.text('Maya Chen'), findsNothing);
  });
}
