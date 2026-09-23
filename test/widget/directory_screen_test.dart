import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:circle/main.dart';
import 'package:circle/models/clock.dart';
import 'package:circle/models/life_stage.dart';
import 'package:circle/models/person.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final clock = Clock(() => DateTime(2026, 7, 4));

  Person person({
    required int id,
    required String name,
    LifeStage stage = LifeStage.college,
    int bMonth = 1,
    int bDay = 1,
  }) {
    return Person(id: id, name: name, stage: stage, bMonth: bMonth, bDay: bDay);
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

  testWidgets('fresh install shows the first-run empty state', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('circle-tab-bar')), findsOneWidget);
    expect(find.text('Your circle is empty'), findsOneWidget);
    expect(find.text('Add your first person to get started'), findsOneWidget);
    expect(find.text('No people found'), findsNothing);
    expect(prefs.getString('circle_people_v1'), isNull);
  });

  testWidgets('header shows the title and a shown-of-total count line', (
    WidgetTester tester,
  ) async {
    await pumpCircle(
      tester,
      people: [
        person(id: 1, name: 'Maya Chen', stage: LifeStage.college),
        person(id: 2, name: 'Sofia Reyes', stage: LifeStage.kids),
      ],
    );

    expect(find.text('Circle'), findsOneWidget);
    expect(find.text('2 of 2 people'), findsOneWidget);
  });

  testWidgets('count line updates with search and stage filter', (
    WidgetTester tester,
  ) async {
    await pumpCircle(
      tester,
      people: [
        person(id: 1, name: 'Maya Chen', stage: LifeStage.college),
        person(id: 2, name: 'Sofia Reyes', stage: LifeStage.kids),
      ],
    );

    expect(find.text('2 of 2 people'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Sofia');
    await tester.pumpAndSettle();
    expect(find.text('1 of 2 people'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('2 of 2 people'), findsOneWidget);

    await tester.tap(find.byKey(const Key('chip-child')));
    await tester.pumpAndSettle();
    expect(find.text('1 of 2 people'), findsOneWidget);
  });

  testWidgets('tapping the next-birthday hint lands on the Birthdays tab', (
    WidgetTester tester,
  ) async {
    await pumpCircle(
      tester,
      people: [
        person(id: 1, name: 'Maya Chen', stage: LifeStage.college, bMonth: 3),
      ],
    );

    expect(find.text('Next up in your circle'), findsNothing);

    await tester.tap(find.byKey(const Key('next-birthday-hint')));
    await tester.pumpAndSettle();

    expect(find.text('Next up in your circle'), findsOneWidget);
  });

  testWidgets('chips show dimmed counts and a dot only when inactive', (
    WidgetTester tester,
  ) async {
    await pumpCircle(
      tester,
      people: [
        person(id: 1, name: 'Maya Chen', stage: LifeStage.college),
        person(id: 2, name: 'Sofia Reyes', stage: LifeStage.kids),
      ],
    );

    // All is active by default: no dot, dimmed count of 2.
    expect(find.byKey(const Key('chip-dot-all')), findsNothing);
    expect(find.text('2'), findsOneWidget);
    final allCount = tester.widget<Opacity>(
      find.ancestor(
        of: find.byKey(const Key('chip-count-all')),
        matching: find.byType(Opacity),
      ),
    );
    expect(allCount.opacity, 0.5);

    // Kids is inactive: its dot is shown and its count is dimmed.
    expect(find.byKey(const Key('chip-dot-child')), findsOneWidget);
    final kidsCount = tester.widget<Opacity>(
      find.ancestor(
        of: find.byKey(const Key('chip-count-child')),
        matching: find.byType(Opacity),
      ),
    );
    expect(kidsCount.opacity, 0.5);

    // Activating Kids hides its dot and reveals All's dot.
    await tester.tap(find.byKey(const Key('chip-child')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chip-dot-child')), findsNothing);
    expect(find.byKey(const Key('chip-dot-all')), findsOneWidget);
  });

  testWidgets('a search with no matches shows the no-match empty state', (
    WidgetTester tester,
  ) async {
    await pumpCircle(
      tester,
      people: [person(id: 1, name: 'Maya Chen', stage: LifeStage.college)],
    );

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No one matches that yet.'), findsOneWidget);
    expect(find.text('Your circle is empty'), findsNothing);
    expect(find.text('Maya Chen'), findsNothing);
  });

  testWidgets('renders stored fixtures and allows search', (
    WidgetTester tester,
  ) async {
    await pumpCircle(
      tester,
      people: [
        person(id: 1, name: 'Maya Chen', stage: LifeStage.college, bMonth: 3),
        person(
          id: 2,
          name: 'Diego Morales',
          stage: LifeStage.working,
          bMonth: 4,
        ),
      ],
    );

    expect(find.text('Maya Chen'), findsOneWidget);
    expect(find.text('Diego Morales'), findsOneWidget);

    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Maya');
    await tester.pumpAndSettle();

    expect(find.text('Maya Chen'), findsOneWidget);
    expect(find.text('Diego Morales'), findsNothing);

    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();
    expect(find.text('Diego Morales'), findsOneWidget);
  });

  testWidgets('filter chips switch stage views correctly with fixtures', (
    WidgetTester tester,
  ) async {
    await pumpCircle(
      tester,
      people: [
        person(id: 1, name: 'Maya Chen', stage: LifeStage.college, bMonth: 3),
        person(id: 2, name: 'Sofia Reyes', stage: LifeStage.kids, bMonth: 7),
      ],
    );

    await tester.tap(find.byKey(const Key('chip-child')));
    await tester.pumpAndSettle();

    expect(find.text('Sofia Reyes'), findsOneWidget);
    expect(find.text('Maya Chen'), findsNothing);
  });
}
