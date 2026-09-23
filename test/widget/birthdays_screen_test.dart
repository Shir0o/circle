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

  Person person({
    required int id,
    required String name,
    LifeStage stage = LifeStage.college,
    int bMonth = 1,
    int bDay = 1,
    int? bYear,
  }) {
    return Person(
      id: id,
      name: name,
      stage: stage,
      bMonth: bMonth,
      bDay: bDay,
      bYear: bYear,
    );
  }

  Future<void> openBirthdays(
    WidgetTester tester, {
    required List<Person> people,
    required DateTime fixed,
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
    await tester.pumpWidget(CircleApp(clock: Clock(() => fixed), prefs: prefs));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Birthdays'));
    await tester.pumpAndSettle();
  }

  BoxDecoration rowDecoration(WidgetTester tester, int id) {
    final container = tester.widget<Container>(
      find.byKey(Key('birthday-row-$id')),
    );
    return container.decoration! as BoxDecoration;
  }

  Color countColor(WidgetTester tester, int id) {
    final text = tester.widget<Text>(find.byKey(Key('birthday-count-$id')));
    return text.style!.color!;
  }

  testWidgets('header shows the Birthdays title and Next up in your circle', (
    WidgetTester tester,
  ) async {
    await openBirthdays(tester, people: [], fixed: DateTime(2026, 7, 4));

    expect(find.text('Birthdays'), findsNWidgets(2));
    expect(find.text('Next up in your circle'), findsOneWidget);
  });

  testWidgets(
    'orders rows by next occurrence and highlights within 30 days across a year boundary',
    (WidgetTester tester) async {
      await openBirthdays(
        tester,
        fixed: DateTime(2026, 12, 15),
        people: [
          // Feb 10, 2027: 57 days out, beyond the 30-day highlight.
          person(
            id: 1,
            name: 'Diego Morales',
            bMonth: 2,
            bDay: 10,
            bYear: 1995,
          ),
          // Jan 5, 2027: 21 days out, across the year boundary, still soon.
          person(id: 2, name: 'Sofia Reyes', bMonth: 1, bDay: 5, bYear: 2016),
          // Dec 20, 2026: 5 days out, next up.
          person(id: 3, name: 'Maya Chen', bMonth: 12, bDay: 20, bYear: 2003),
        ],
      );

      // Counts are the real next-occurrence day counts.
      expect(find.text('5'), findsOneWidget);
      expect(find.text('21'), findsOneWidget);
      expect(find.text('57'), findsOneWidget);

      // Row order is Maya (5d), Sofia (21d), Diego (57d).
      final mayaY = tester
          .getTopLeft(find.byKey(const Key('birthday-row-3')))
          .dy;
      final sofiaY = tester
          .getTopLeft(find.byKey(const Key('birthday-row-2')))
          .dy;
      final diegoY = tester
          .getTopLeft(find.byKey(const Key('birthday-row-1')))
          .dy;
      expect(mayaY, lessThan(sofiaY));
      expect(sofiaY, lessThan(diegoY));

      // Within 30 days: accent-soft card, accent border and accent count.
      for (final id in [2, 3]) {
        final deco = rowDecoration(tester, id);
        expect(deco.color, DesignTokens.light.accentSoft);
        expect(
          (deco.border! as Border).top.color,
          DesignTokens.light.accentBorder,
        );
        expect(countColor(tester, id), DesignTokens.light.accent);
      }

      // Beyond 30 days: surface card, border and text count.
      final diegoDeco = rowDecoration(tester, 1);
      expect(diegoDeco.color, DesignTokens.light.surface);
      expect(
        (diegoDeco.border! as Border).top.color,
        DesignTokens.light.border,
      );
      expect(countColor(tester, 1), DesignTokens.light.text);
    },
  );

  testWidgets('today shows a celebration and one day out shows a day unit', (
    WidgetTester tester,
  ) async {
    await openBirthdays(
      tester,
      fixed: DateTime(2026, 7, 4),
      people: [
        person(id: 1, name: 'Maya Chen', bMonth: 7, bDay: 4, bYear: 2000),
        person(id: 2, name: 'Sofia Reyes', bMonth: 7, bDay: 5, bYear: 2016),
      ],
    );

    expect(find.text('🎉'), findsOneWidget);
    expect(find.text('today'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('day'), findsOneWidget);
    expect(find.text('days'), findsNothing);
  });

  testWidgets(
    'date line includes turns with a birth year and omits it without',
    (WidgetTester tester) async {
      await openBirthdays(
        tester,
        fixed: DateTime(2026, 7, 4),
        people: [
          person(id: 1, name: 'Maya Chen', bMonth: 7, bDay: 4, bYear: 2000),
          person(id: 2, name: 'Sofia Reyes', bMonth: 7, bDay: 5),
        ],
      );

      expect(find.text('Jul 4 · turns 26'), findsOneWidget);
      expect(find.text('Jul 5'), findsOneWidget);
    },
  );

  testWidgets('tapping a birthday row opens that person profile', (
    WidgetTester tester,
  ) async {
    await openBirthdays(
      tester,
      fixed: DateTime(2026, 7, 4),
      people: [
        person(id: 1, name: 'Maya Chen', bMonth: 7, bDay: 4, bYear: 2000),
      ],
    );

    await tester.tap(find.byKey(const Key('birthday-row-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-back')), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Maya Chen'), findsOneWidget);
  });

  testWidgets('shows an empty state when the circle has no people', (
    WidgetTester tester,
  ) async {
    await openBirthdays(tester, people: [], fixed: DateTime(2026, 7, 4));

    expect(find.text('No birthdays yet'), findsOneWidget);
    expect(
      find.text(
        'Add people to your circle and their birthdays will show up here',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('birthday-row-1')), findsNothing);
  });
}
