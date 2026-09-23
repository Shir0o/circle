import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:circle/main.dart';
import 'package:circle/models/clock.dart';
import 'package:circle/models/life_stage.dart';
import 'package:circle/models/person.dart';
import 'package:circle/screens/directory_screen.dart';
import 'package:circle/screens/form_screen.dart';

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

  const accent = Color(0xFFFF6B4A);

  BoxDecoration dotDecoration(WidgetTester tester, String id) {
    final container = tester.widget<Container>(find.byKey(Key('tab-dot-$id')));
    return container.decoration! as BoxDecoration;
  }

  testWidgets(
    'tab bar shows four text tabs with a dot on the active tab only',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('circle-tab-bar')), findsOneWidget);
      expect(find.text('Directory'), findsOneWidget);
      expect(find.text('Birthdays'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      // Active tab (Directory) gets the accent dot; the rest are transparent.
      expect(dotDecoration(tester, 'directory').color, accent);
      expect(dotDecoration(tester, 'birthdays').color, Colors.transparent);
      expect(dotDecoration(tester, 'overview').color, Colors.transparent);
      expect(dotDecoration(tester, 'add').color, Colors.transparent);
    },
  );

  testWidgets('tapping a tab switches the screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Birthdays'));
    await tester.pumpAndSettle();

    expect(dotDecoration(tester, 'birthdays').color, accent);
    expect(dotDecoration(tester, 'directory').color, Colors.transparent);
    expect(find.text('Next up in your circle'), findsOneWidget);
  });

  testWidgets('tapping Add opens the form and does not change the tab', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();

    // Move to a non-default tab first.
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();
    expect(dotDecoration(tester, 'overview').color, accent);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.byType(FormScreen), findsOneWidget);
    expect(find.text('Add person'), findsOneWidget);

    // Closing the form returns to Overview: the tab selection did not change.
    await tester.tap(find.byKey(const Key('form-cancel')));
    await tester.pumpAndSettle();
    expect(dotDecoration(tester, 'overview').color, accent);
    expect(find.text('A quick look at everyone'), findsOneWidget);
  });

  testWidgets('tab bar is hidden on Profile and on the form', (
    WidgetTester tester,
  ) async {
    final people = [
      person(id: 1, name: 'Maya Chen', stage: LifeStage.college, bMonth: 3),
    ];
    final prefs = await prefsWith(people);

    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();

    // On a tab screen the bar is visible.
    expect(find.byKey(const Key('circle-tab-bar')), findsOneWidget);

    // Open a Profile.
    await tester.tap(find.text('Maya Chen'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('circle-tab-bar')), findsNothing);

    // Go back and open the Add form.
    await tester.tap(find.byKey(const Key('profile-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.byType(FormScreen), findsOneWidget);
    expect(find.byKey(const Key('circle-tab-bar')), findsNothing);
  });

  testWidgets('theme toggle is reachable on every screen and persists', (
    WidgetTester tester,
  ) async {
    final people = [
      person(id: 1, name: 'Maya Chen', stage: LifeStage.college, bMonth: 3),
    ];
    final prefs = await prefsWith(people);

    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();

    // Shell (covers Directory / Birthdays / Overview tabs): light shows ☾.
    expect(find.byKey(const Key('theme-toggle')), findsOneWidget);
    expect(find.text('☾'), findsOneWidget);

    // Toggle to dark.
    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('☀'), findsOneWidget);
    expect(prefs.getBool('circle_theme_v1'), isTrue);

    // Reachable on Profile.
    await tester.tap(find.text('Maya Chen'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('theme-toggle')), findsOneWidget);

    // Back, then reachable on the form.
    await tester.tap(find.byKey(const Key('profile-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('theme-toggle')), findsOneWidget);

    // Persists across restart with the same storage.
    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();
    expect(find.text('☀'), findsOneWidget);
  });

  testWidgets('shell wires a tab-switch mechanism to the Directory screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();

    final directory = tester.widget<DirectoryScreen>(
      find.byType(DirectoryScreen),
    );
    expect(directory.onSwitchTab, isNotNull);
  });
}
