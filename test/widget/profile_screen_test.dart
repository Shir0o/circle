import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:circle/main.dart';
import 'package:circle/models/clock.dart';
import 'package:circle/models/life_stage.dart';
import 'package:circle/models/person.dart';
import 'package:circle/theme/design_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final clock = Clock(() => DateTime(2026, 7, 4));

  Person collegePerson({
    String name = 'Maya Chen',
    LifeStage stage = LifeStage.college,
    int? bYear = 2003,
    int bMonth = 5,
    int bDay = 20,
    String year = 'Junior',
    String major = 'Psychology',
    String school = 'UCLA',
    String location = 'Los Angeles',
    List<String> interests = const ['Hiking', 'Piano'],
    List<String> dietary = const ['Vegetarian'],
    String howKnow = 'College friend',
    String notes = 'Loves jazz concerts',
  }) {
    return Person(
      id: 1,
      name: name,
      stage: stage,
      bMonth: bMonth,
      bDay: bDay,
      bYear: bYear,
      year: year,
      major: major,
      school: school,
      location: location,
      interests: interests,
      dietary: dietary,
      howKnow: howKnow,
      notes: notes,
    );
  }

  Future<void> openProfile(WidgetTester tester, Person person) async {
    SharedPreferences.setMockInitialValues({
      'circle_people_v1': jsonEncode([person.toJson()]),
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();
    await tester.tap(find.text(person.name));
    await tester.pumpAndSettle();
  }

  testWidgets('profile has no app bar or title, only the design header', (
    WidgetTester tester,
  ) async {
    await openProfile(tester, collegePerson());

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Profile'), findsNothing);
    expect(find.text('Member Profile'), findsNothing);
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.byKey(const Key('profile-back')), findsOneWidget);
    expect(find.byKey(const Key('profile-edit')), findsOneWidget);
  });

  testWidgets('identity block shows avatar, name and howKnow without prefix', (
    WidgetTester tester,
  ) async {
    await openProfile(tester, collegePerson());

    expect(find.text('MC'), findsOneWidget);
    expect(find.text('Maya Chen'), findsOneWidget);
    expect(find.text('College friend'), findsOneWidget);
    expect(find.textContaining('Connection:'), findsNothing);
  });

  testWidgets('stage pill shows the age when there is a birth year', (
    WidgetTester tester,
  ) async {
    await openProfile(tester, collegePerson());

    expect(find.text('College · 23 yrs'), findsOneWidget);
  });

  testWidgets('stage pill shows an em dash when there is no birth year', (
    WidgetTester tester,
  ) async {
    await openProfile(tester, collegePerson(bYear: null, bMonth: 1, bDay: 1));

    expect(find.text('College · —'), findsOneWidget);
  });

  testWidgets('college rows show Year, Major, College, Birthday and Location', (
    WidgetTester tester,
  ) async {
    await openProfile(tester, collegePerson());

    expect(find.text('YEAR'), findsOneWidget);
    expect(find.text('Junior'), findsOneWidget);
    expect(find.text('MAJOR'), findsOneWidget);
    expect(find.text('Psychology'), findsOneWidget);
    expect(find.text('COLLEGE'), findsOneWidget);
    expect(find.text('UCLA'), findsOneWidget);
    expect(find.text('BIRTHDAY'), findsOneWidget);
    expect(find.text('May 20, 2003'), findsOneWidget);
    expect(find.text('LOCATION'), findsOneWidget);
    expect(find.text('Los Angeles'), findsOneWidget);
  });

  testWidgets('teens rows show Grade and School', (WidgetTester tester) async {
    await openProfile(
      tester,
      Person(
        id: 1,
        name: 'Sofia Reyes',
        stage: LifeStage.teens,
        bMonth: 3,
        bDay: 12,
        bYear: 2012,
        grade: '10th grade',
        school: 'Lincoln HS',
      ),
    );

    expect(find.text('GRADE'), findsOneWidget);
    expect(find.text('10th grade'), findsOneWidget);
    expect(find.text('SCHOOL'), findsOneWidget);
    expect(find.text('Lincoln HS'), findsOneWidget);
    expect(find.text('OCCUPATION'), findsNothing);
  });

  testWidgets('working rows show Occupation', (WidgetTester tester) async {
    await openProfile(
      tester,
      Person(
        id: 1,
        name: 'Diego Morales',
        stage: LifeStage.working,
        bMonth: 4,
        bDay: 2,
        bYear: 1994,
        occupation: 'Nurse',
      ),
    );

    expect(find.text('OCCUPATION'), findsOneWidget);
    expect(find.text('Nurse'), findsOneWidget);
    expect(find.text('GRADE'), findsNothing);
    expect(find.text('COLLEGE'), findsNothing);
  });

  testWidgets('empty sections are hidden', (WidgetTester tester) async {
    await openProfile(
      tester,
      Person(
        id: 1,
        name: 'Maya Chen',
        stage: LifeStage.college,
        bMonth: 1,
        bDay: 1,
        bYear: 2003,
      ),
    );

    expect(find.text('INTERESTS'), findsNothing);
    expect(find.text('DIETARY'), findsNothing);
    expect(find.text('NOTES & PREFERENCES'), findsNothing);
  });

  testWidgets('interests use warm tags and dietary use mint tags in light', (
    WidgetTester tester,
  ) async {
    await openProfile(tester, collegePerson());

    final hiking = tester.widget<Container>(
      find.byKey(const Key('interest-pill-Hiking')),
    );
    expect(
      (hiking.decoration! as BoxDecoration).color,
      DesignTokens.light.tagWarmBg,
    );

    final vegetarian = tester.widget<Container>(
      find.byKey(const Key('dietary-pill-Vegetarian')),
    );
    expect(
      (vegetarian.decoration! as BoxDecoration).color,
      DesignTokens.light.tagMintBg,
    );
  });

  testWidgets('interests use warm tags and dietary use mint tags in dark', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'circle_people_v1': jsonEncode([collegePerson().toJson()]),
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Maya Chen'));
    await tester.pumpAndSettle();

    final hiking = tester.widget<Container>(
      find.byKey(const Key('interest-pill-Hiking')),
    );
    expect(
      (hiking.decoration! as BoxDecoration).color,
      DesignTokens.dark.tagWarmBg,
    );

    final vegetarian = tester.widget<Container>(
      find.byKey(const Key('dietary-pill-Vegetarian')),
    );
    expect(
      (vegetarian.decoration! as BoxDecoration).color,
      DesignTokens.dark.tagMintBg,
    );
  });

  testWidgets('back control returns to the directory', (
    WidgetTester tester,
  ) async {
    await openProfile(tester, collegePerson());

    await tester.tap(find.byKey(const Key('profile-back')));
    await tester.pumpAndSettle();

    expect(find.text('Circle'), findsOneWidget);
    expect(find.byKey(const Key('circle-tab-bar')), findsOneWidget);
  });
}
