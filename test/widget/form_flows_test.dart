import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:circle/main.dart';
import 'package:circle/models/clock.dart';
import 'package:circle/models/life_stage.dart';
import 'package:circle/models/person.dart';
import 'package:circle/providers/people_provider.dart';
import 'package:circle/screens/form_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final clock = Clock(() => DateTime(2026, 7, 4));

  Person collegePerson({String name = 'Maya Chen'}) {
    return Person(
      id: 1,
      name: name,
      stage: LifeStage.college,
      bMonth: 5,
      bDay: 20,
      bYear: 2003,
    );
  }

  Future<void> pumpCircle(
    WidgetTester tester, {
    List<Person> people = const [],
  }) async {
    SharedPreferences.setMockInitialValues(
      people.isEmpty
          ? {}
          : {
              'circle_people_v1': jsonEncode(
                people.map((p) => p.toJson()).toList(),
              ),
            },
    );
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();
  }

  Future<void> openForm(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('tab-add')));
    await tester.pumpAndSettle();
  }

  Future<void> revealBirthday(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('add-birthday')));
    await tester.pumpAndSettle();
  }

  Future<void> pickMonth(WidgetTester tester, String month) async {
    await tester.tap(find.byKey(const Key('field-birthday-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(month).last);
    await tester.pumpAndSettle();
  }

  Future<void> saveWithName(WidgetTester tester, String name) async {
    await tester.enterText(find.byKey(const Key('field-name')), name);
    await tester.pumpAndSettle();
  }

  Future<void> openProfileAndEdit(WidgetTester tester) async {
    await tester.tap(find.text('Maya Chen'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-edit')));
    await tester.pumpAndSettle();
  }

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

  group('navigation outcomes', () {
    testWidgets('Add then Save opens the new person profile', (
      WidgetTester tester,
    ) async {
      await pumpCircle(tester);
      await openForm(tester);
      await saveWithName(tester, 'Maya Chen');
      await tester.tap(find.byKey(const Key('form-save')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-edit')), findsOneWidget);
      expect(find.text('Maya Chen'), findsOneWidget);
      expect(find.byKey(const Key('form-save')), findsNothing);
    });

    testWidgets('Edit then Save returns to the updated profile', (
      WidgetTester tester,
    ) async {
      await pumpCircle(tester, people: [collegePerson()]);
      await openProfileAndEdit(tester);
      await tester.enterText(
        find.byKey(const Key('field-name')),
        'Maya Renamed',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('form-save')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-edit')), findsOneWidget);
      expect(find.text('Maya Renamed'), findsOneWidget);
      expect(find.text('Maya Chen'), findsNothing);
    });

    testWidgets(
      'Cancel in add mode returns to the Directory and persists nothing',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
        await tester.pumpAndSettle();
        await openForm(tester);
        await tester.enterText(
          find.byKey(const Key('field-name')),
          'Maya Chen',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('form-cancel')));
        await tester.pumpAndSettle();

        expect(find.text('Circle'), findsOneWidget);
        expect(find.byKey(const Key('circle-tab-bar')), findsOneWidget);
        expect(prefs.getString('circle_people_v1'), isNull);
      },
    );

    testWidgets(
      'Cancel in edit mode returns to the profile and persists nothing',
      (WidgetTester tester) async {
        await pumpCircle(tester, people: [collegePerson()]);
        await openProfileAndEdit(tester);
        await tester.enterText(
          find.byKey(const Key('field-name')),
          'Maya Changed',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('form-cancel')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('profile-edit')), findsOneWidget);
        expect(find.text('Maya Chen'), findsOneWidget);
        expect(find.text('Maya Changed'), findsNothing);

        final prefs = await SharedPreferences.getInstance();
        final stored = jsonDecode(prefs.getString('circle_people_v1')!) as List;
        expect((stored.single as Map)['name'], 'Maya Chen');
      },
    );

    testWidgets(
      'Delete then confirm lands on the Directory and removes the person',
      (WidgetTester tester) async {
        await pumpCircle(tester, people: [collegePerson()]);
        await openProfileAndEdit(tester);

        await tester.ensureVisible(find.byKey(const Key('delete-person')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('delete-person')));
        await tester.pumpAndSettle();
        expect(find.text('Delete Person'), findsOneWidget);

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Circle'), findsOneWidget);
        expect(find.text('Your circle is empty'), findsOneWidget);
        expect(find.byKey(const Key('profile-edit')), findsNothing);

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString('circle_people_v1');
        expect(stored, isNotNull);
        expect(jsonDecode(stored!) as List, isEmpty);
      },
    );
  });

  group('validation', () {
    testWidgets('an empty name blocks saving with an inline message', (
      WidgetTester tester,
    ) async {
      await pumpForm(tester);
      await tester.tap(find.byKey(const Key('form-save')));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
      expect(find.byKey(const Key('form-save')), findsOneWidget);
    });

    testWidgets(
      'an invalid day for the month blocks saving with an inline message',
      (WidgetTester tester) async {
        await pumpForm(tester);
        await revealBirthday(tester);
        await pickMonth(tester, 'Feb');
        await tester.enterText(
          find.byKey(const Key('field-birthday-year')),
          '2024',
        );
        await tester.tap(find.byKey(const Key('add-day-checkbox')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('field-birthday-day')),
          '31',
        );
        await saveWithName(tester, 'Maya Chen');

        await tester.tap(find.byKey(const Key('form-save')));
        await tester.pumpAndSettle();

        expect(find.textContaining('Invalid day'), findsOneWidget);
        expect(find.byKey(const Key('form-save')), findsOneWidget);
      },
    );

    testWidgets('Feb 29 in a leap year is a valid day', (
      WidgetTester tester,
    ) async {
      await pumpForm(tester);
      await revealBirthday(tester);
      await pickMonth(tester, 'Feb');
      await tester.enterText(
        find.byKey(const Key('field-birthday-year')),
        '2024',
      );
      await tester.tap(find.byKey(const Key('add-day-checkbox')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('field-birthday-day')), '29');
      await saveWithName(tester, 'Maya Chen');

      await tester.tap(find.byKey(const Key('form-save')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Invalid day'), findsNothing);
    });

    testWidgets('a future birth year blocks saving with an inline message', (
      WidgetTester tester,
    ) async {
      await pumpForm(tester);
      await revealBirthday(tester);
      await pickMonth(tester, 'May');
      await tester.enterText(
        find.byKey(const Key('field-birthday-year')),
        '2099',
      );
      await saveWithName(tester, 'Maya Chen');

      await tester.tap(find.byKey(const Key('form-save')));
      await tester.pumpAndSettle();

      expect(find.textContaining('future'), findsOneWidget);
      expect(find.byKey(const Key('form-save')), findsOneWidget);
    });
  });

  group('optional birthday', () {
    testWidgets('a name-only person saves and shows no birthday line', (
      WidgetTester tester,
    ) async {
      await pumpForm(tester);
      await saveWithName(tester, 'maya chen');
      await tester.tap(find.byKey(const Key('form-save')));
      await tester.pumpAndSettle();

      expect(find.text('Maya Chen'), findsOneWidget);
      expect(find.byKey(const Key('detail-value-Birthday')), findsNothing);
    });

    testWidgets('a day-less birthday saves and shows month and year', (
      WidgetTester tester,
    ) async {
      await pumpForm(tester);
      await saveWithName(tester, 'Diego Morales');
      await revealBirthday(tester);
      await pickMonth(tester, 'Mar');
      await tester.enterText(
        find.byKey(const Key('field-birthday-year')),
        '1990',
      );
      await tester.tap(find.byKey(const Key('form-save')));
      await tester.pumpAndSettle();

      expect(find.text('Mar 1990'), findsOneWidget);
    });

    testWidgets('the Add day checkbox reveals and hides the day field', (
      WidgetTester tester,
    ) async {
      await pumpForm(tester);
      await revealBirthday(tester);

      expect(find.byKey(const Key('field-birthday-day')), findsNothing);
      await tester.tap(find.byKey(const Key('add-day-checkbox')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('field-birthday-day')), findsOneWidget);

      await tester.tap(find.byKey(const Key('add-day-checkbox')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('field-birthday-day')), findsNothing);
    });

    testWidgets('removing the birthday collapses the editor', (
      WidgetTester tester,
    ) async {
      await pumpForm(tester);
      await revealBirthday(tester);

      await tester.tap(find.byKey(const Key('remove-birthday')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('add-birthday')), findsOneWidget);
      expect(find.byKey(const Key('field-birthday-month')), findsNothing);
    });

    testWidgets('month and year are required once the birthday is revealed', (
      WidgetTester tester,
    ) async {
      await pumpForm(tester);
      await revealBirthday(tester);
      await saveWithName(tester, 'Maya Chen');
      await tester.tap(find.byKey(const Key('form-save')));
      await tester.pumpAndSettle();

      expect(find.text('Month is required'), findsOneWidget);
      expect(find.text('Year is required'), findsOneWidget);
    });

    testWidgets('the location field is title-cased live', (
      WidgetTester tester,
    ) async {
      await pumpForm(tester);
      await tester.enterText(
        find.byKey(const Key('field-location')),
        'los angeles',
      );
      await tester.pumpAndSettle();

      final location = tester.widget<TextFormField>(
        find.byKey(const Key('field-location')),
      );
      expect(location.controller!.text, 'Los Angeles');
    });
  });
}
