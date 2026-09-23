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

  Future<SharedPreferences> prefsWith(List<Person> people) async {
    SharedPreferences.setMockInitialValues({
      'circle_people_v1': jsonEncode(people.map((p) => p.toJson()).toList()),
    });
    return SharedPreferences.getInstance();
  }

  testWidgets('fresh install shows zero people and leaves storage untouched', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();

    expect(find.text('Circle'), findsOneWidget);
    expect(find.text('No members found'), findsOneWidget);
    expect(prefs.getString('circle_people_v1'), isNull);
  });

  testWidgets('renders stored fixtures and allows search', (
    WidgetTester tester,
  ) async {
    final people = [
      person(id: 1, name: 'Maya Chen', stage: LifeStage.college, bMonth: 3),
      person(id: 2, name: 'Diego Morales', stage: LifeStage.working, bMonth: 4),
    ];
    final prefs = await prefsWith(people);

    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();

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
    final people = [
      person(id: 1, name: 'Maya Chen', stage: LifeStage.college, bMonth: 3),
      person(id: 2, name: 'Sofia Reyes', stage: LifeStage.kids, bMonth: 7),
    ];
    final prefs = await prefsWith(people);

    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();

    final kidsChip = find.text('Kids 1');
    expect(kidsChip, findsOneWidget);
    await tester.tap(kidsChip);
    await tester.pumpAndSettle();

    expect(find.text('Sofia Reyes'), findsOneWidget);
    expect(find.text('Maya Chen'), findsNothing);
  });
}
