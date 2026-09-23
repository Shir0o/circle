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
    String location = '',
  }) {
    return Person(
      id: id,
      name: name,
      stage: stage,
      bMonth: bMonth,
      bDay: bDay,
      location: location,
    );
  }

  Future<void> openOverview(
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
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();
  }

  testWidgets('header shows the title and subtitle', (
    WidgetTester tester,
  ) async {
    await openOverview(tester, people: [], fixed: DateTime(2026, 7, 4));

    expect(find.text('Your circle'), findsOneWidget);
    expect(find.text('A quick look at everyone'), findsOneWidget);
  });

  testWidgets('neutral tile shows the total with a people total label', (
    WidgetTester tester,
  ) async {
    await openOverview(
      tester,
      people: [
        person(id: 1, name: 'Maya Chen'),
        person(id: 2, name: 'Sofia Reyes'),
      ],
      fixed: DateTime(2026, 7, 4),
    );

    final total = tester.widget<Text>(find.byKey(const Key('overview-total')));
    expect(total.data, '2');
    expect(find.text('people total'), findsOneWidget);
  });

  testWidgets('birthdays-this-month count follows the injected clock month', (
    WidgetTester tester,
  ) async {
    await openOverview(
      tester,
      people: [
        person(id: 1, name: 'Maya Chen', bMonth: 7),
        person(id: 2, name: 'Sofia Reyes', bMonth: 7),
        person(id: 3, name: 'Diego Morales', bMonth: 4),
      ],
      fixed: DateTime(2026, 7, 4),
    );

    final bdays = tester.widget<Text>(
      find.byKey(const Key('overview-birthdays')),
    );
    expect(bdays.data, '2');
    expect(find.text('birthdays this month'), findsOneWidget);
  });

  testWidgets('accent tile uses accent background, border and deep label', (
    WidgetTester tester,
  ) async {
    await openOverview(
      tester,
      people: [person(id: 1, name: 'Maya Chen')],
      fixed: DateTime(2026, 7, 4),
    );

    final tile = tester.widget<Container>(
      find.byKey(const Key('overview-birthday-tile')),
    );
    final deco = tile.decoration! as BoxDecoration;
    expect(deco.color, DesignTokens.light.accentBg);
    expect((deco.border! as Border).top.color, DesignTokens.light.accentBorder);

    final bdays = tester.widget<Text>(
      find.byKey(const Key('overview-birthdays')),
    );
    expect(bdays.style!.color, DesignTokens.light.accent);

    final label = tester.widget<Text>(find.text('birthdays this month'));
    expect(label.style!.color, DesignTokens.light.accentDeep);
  });

  testWidgets(
    'life stage card shows one row per stage with bars and no percentage',
    (WidgetTester tester) async {
      await openOverview(
        tester,
        people: [
          person(id: 1, name: 'Sofia', stage: LifeStage.kids),
          person(id: 2, name: 'Leo', stage: LifeStage.kids),
          person(id: 3, name: 'Noah', stage: LifeStage.teens),
        ],
        fixed: DateTime(2026, 7, 4),
      );

      expect(find.text('BY LIFE STAGE'), findsOneWidget);
      final kidsCount = tester.widget<Text>(
        find.byKey(const Key('overview-stage-count-child')),
      );
      expect(kidsCount.data, '2');
      final teensCount = tester.widget<Text>(
        find.byKey(const Key('overview-stage-count-teen')),
      );
      expect(teensCount.data, '1');
      expect(find.textContaining('%'), findsNothing);

      final kidsBar = tester.widget<FractionallySizedBox>(
        find.byKey(const Key('overview-stage-bar-child')),
      );
      expect(kidsBar.widthFactor, closeTo(2 / 3, 0.0001));
      final teensBar = tester.widget<FractionallySizedBox>(
        find.byKey(const Key('overview-stage-bar-teen')),
      );
      expect(teensBar.widthFactor, closeTo(1 / 3, 0.0001));
    },
  );

  testWidgets('top locations lists plain rows with no pin icon or pill', (
    WidgetTester tester,
  ) async {
    await openOverview(
      tester,
      people: [
        person(id: 1, name: 'a', location: 'Portland'),
        person(id: 2, name: 'b', location: 'Portland'),
        person(id: 3, name: 'c', location: 'Seattle'),
        person(id: 4, name: 'd', location: 'Seattle'),
        person(id: 5, name: 'e', location: 'Seattle'),
        person(id: 6, name: 'f', location: 'Austin'),
      ],
      fixed: DateTime(2026, 7, 4),
    );

    expect(find.text('TOP LOCATIONS'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_rounded), findsNothing);
    expect(find.text('Seattle'), findsOneWidget);
    expect(find.text('Portland'), findsOneWidget);
    expect(find.text('Austin'), findsOneWidget);
  });

  testWidgets('an empty circle renders zeroes and empty bars without errors', (
    WidgetTester tester,
  ) async {
    await openOverview(tester, people: [], fixed: DateTime(2026, 7, 4));

    final total = tester.widget<Text>(find.byKey(const Key('overview-total')));
    expect(total.data, '0');
    final bdays = tester.widget<Text>(
      find.byKey(const Key('overview-birthdays')),
    );
    expect(bdays.data, '0');
    expect(find.text('BY LIFE STAGE'), findsOneWidget);
    expect(find.text('TOP LOCATIONS'), findsOneWidget);
    final kidsBar = tester.widget<FractionallySizedBox>(
      find.byKey(const Key('overview-stage-bar-child')),
    );
    expect(kidsBar.widthFactor, 0);
  });
}
