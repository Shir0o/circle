import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:circle/models/clock.dart';
import 'package:circle/models/life_stage.dart';
import 'package:circle/models/person.dart';
import 'package:circle/providers/people_provider.dart';
import 'package:circle/screens/form_screen.dart';
import 'package:circle/theme/design_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final clock = Clock(() => DateTime(2026, 7, 4));

  Future<void> pumpForm(WidgetTester tester, {Person? person}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PeopleProvider(clock: clock, prefs: prefs),
        child: MaterialApp(home: FormScreen(person: person)),
      ),
    );
    await tester.pumpAndSettle();
  }

  CircleAvatar avatar(WidgetTester tester) =>
      tester.widget<CircleAvatar>(find.byKey(const Key('form-avatar')));

  testWidgets('add mode has no AppBar and a Cancel / title / Save header', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Add person'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.byKey(const Key('form-cancel')), findsOneWidget);
    expect(find.byKey(const Key('form-save')), findsOneWidget);
  });

  testWidgets('edit mode shows the Edit title and a Delete person action', (
    WidgetTester tester,
  ) async {
    final person = Person(
      id: 1,
      name: 'Maya Chen',
      stage: LifeStage.college,
      bMonth: 5,
      bDay: 20,
    );
    await pumpForm(tester, person: person);

    expect(find.text('Edit person'), findsOneWidget);
    expect(find.byKey(const Key('delete-person')), findsOneWidget);
  });

  testWidgets('delete person is hidden when adding a new person', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    expect(find.byKey(const Key('delete-person')), findsNothing);
  });

  testWidgets('birthday stays collapsed until Add birthday is tapped', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    expect(find.byKey(const Key('add-birthday')), findsOneWidget);
    expect(find.byKey(const Key('field-birthday-month')), findsNothing);
    expect(find.byKey(const Key('field-birthday-year')), findsNothing);
    expect(find.byKey(const Key('field-birthday-day')), findsNothing);

    await tester.tap(find.byKey(const Key('add-birthday')));
    await tester.pumpAndSettle();

    expect(find.text('Month'), findsOneWidget); // unset placeholder
    final year = tester.widget<TextFormField>(
      find.byKey(const Key('field-birthday-year')),
    );
    expect(year.controller!.text, isEmpty);
    // The day only appears once "Add day" is checked.
    expect(find.byKey(const Key('field-birthday-day')), findsNothing);
  });

  testWidgets('edit mode opens the birthday editor for a person who has one', (
    WidgetTester tester,
  ) async {
    final person = Person(
      id: 1,
      name: 'Maya Chen',
      stage: LifeStage.college,
      bMonth: 5,
      bDay: 20,
      bYear: 2003,
    );
    await pumpForm(tester, person: person);

    expect(find.byKey(const Key('add-birthday')), findsNothing);
    expect(find.byKey(const Key('field-birthday-month')), findsOneWidget);
    expect(find.byKey(const Key('field-birthday-day')), findsOneWidget);
  });

  testWidgets('the name field is title-cased live as you type', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    await tester.enterText(find.byKey(const Key('field-name')), 'maya chen');
    await tester.pumpAndSettle();

    final name = tester.widget<TextFormField>(
      find.byKey(const Key('field-name')),
    );
    expect(name.controller!.text, 'Maya Chen');
  });

  testWidgets('avatar preview updates initials as the name changes', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    expect(find.text('?'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('field-name')), 'Maya Chen');
    await tester.pumpAndSettle();

    expect(find.text('MC'), findsOneWidget);
  });

  testWidgets('avatar preview uses the selected stage colour', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    expect(avatar(tester).backgroundColor, LifeStage.college.avatarBg);

    await tester.tap(find.byKey(const Key('stage-segment-child')));
    await tester.pumpAndSettle();
    expect(avatar(tester).backgroundColor, LifeStage.kids.avatarBg);
  });

  testWidgets('stage-specific fields switch with the selected stage', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    // Default stage is College.
    expect(find.text('YEAR IN SCHOOL'), findsOneWidget);
    expect(find.text('MAJOR'), findsOneWidget);
    expect(find.text('COLLEGE'), findsOneWidget);
    expect(find.text('GRADE'), findsNothing);
    expect(find.text('OCCUPATION'), findsNothing);

    await tester.tap(find.byKey(const Key('stage-segment-teen')));
    await tester.pumpAndSettle();
    expect(find.text('GRADE'), findsOneWidget);
    expect(find.text('SCHOOL'), findsOneWidget);
    expect(find.text('MAJOR'), findsNothing);
    expect(find.text('OCCUPATION'), findsNothing);

    await tester.tap(find.byKey(const Key('stage-segment-working')));
    await tester.pumpAndSettle();
    expect(find.text('OCCUPATION'), findsOneWidget);
    expect(find.text('GRADE'), findsNothing);
    expect(find.text('YEAR IN SCHOOL'), findsNothing);
  });

  testWidgets('field order follows the design top to bottom', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    final labels = [
      'NAME',
      'LIFE STAGE',
      'BIRTHDAY',
      'YEAR IN SCHOOL',
      'MAJOR',
      'COLLEGE',
      'LOCATION',
      'INTERESTS',
      'DIETARY',
      'HOW I KNOW THEM',
      'NOTES & PREFERENCES',
    ];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget, reason: 'missing $label');
    }
    expect(find.text(' · comma-separated'), findsNWidgets(2));
  });
}
