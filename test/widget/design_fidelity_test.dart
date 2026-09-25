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

  final maya = Person(
    id: 1,
    name: 'Maya Chen',
    stage: LifeStage.college,
    bMonth: 5,
    bDay: 20,
    bYear: 2003,
    year: 'Junior',
    major: 'Psychology',
    school: 'UCLA',
    location: 'Los Angeles',
  );

  Map<String, Object> stored(List<Person> people) => {
    'circle_people_v1': jsonEncode(people.map((p) => p.toJson()).toList()),
  };

  Future<void> pumpCircle(WidgetTester tester, List<Person> people) async {
    SharedPreferences.setMockInitialValues(stored(people));
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(CircleApp(clock: clock, prefs: prefs));
    await tester.pumpAndSettle();
  }

  testWidgets('heavy weights use the matching Nunito face, not faux bold', (
    WidgetTester tester,
  ) async {
    await pumpCircle(tester, [maya]);

    // google_fonts registers one family per weight, so a weight-900 title
    // must resolve to the weight-900 family.
    final title = tester.widget<Text>(find.text('Circle'));
    expect(title.style!.fontFamily, 'Nunito_900');

    final name = tester.widget<Text>(find.text('Maya Chen'));
    expect(name.style!.fontFamily, 'Nunito_800');
  });

  testWidgets('profile detail values are right-aligned to the card edge', (
    WidgetTester tester,
  ) async {
    await pumpCircle(tester, [maya]);
    await tester.tap(find.text('Maya Chen'));
    await tester.pumpAndSettle();

    final year = tester.getRect(find.byKey(const Key('detail-value-Year')));
    final birthday = tester.getRect(
      find.byKey(const Key('detail-value-Birthday')),
    );
    final screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;

    // 22 screen padding + 1 card border + 16 row padding.
    expect(year.right, closeTo(screenWidth - 39, 0.5));
    expect(birthday.right, closeTo(year.right, 0.5));
    expect(
      tester.widget<Text>(find.byKey(const Key('detail-value-Year'))).textAlign,
      TextAlign.right,
    );
  });

  testWidgets('returning users never see the first-run empty state flash', (
    WidgetTester tester,
  ) async {
    // No injected prefs: storage loads asynchronously, as in the real app.
    SharedPreferences.setMockInitialValues(stored([maya]));
    await tester.pumpWidget(CircleApp(clock: clock));

    expect(find.text('Your circle is empty'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('Maya Chen'), findsOneWidget);
    expect(find.text('Your circle is empty'), findsNothing);
  });

  testWidgets('tab bar grows by the bottom safe-area inset', (
    WidgetTester tester,
  ) async {
    tester.view.padding = FakeViewPadding(
      bottom: 34 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetPadding);

    await pumpCircle(tester, [maya]);

    final bar = tester.getRect(find.byKey(const Key('circle-tab-bar')));
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(bar.height, 64 + 34);
    expect(bar.bottom, screenHeight);
    // Labels sit above the home indicator.
    expect(
      tester.getRect(find.text('Directory')).bottom,
      lessThan(bar.bottom - 34),
    );
  });

  testWidgets('Feb 29 can be saved without a birth year', (
    WidgetTester tester,
  ) async {
    await pumpCircle(tester, const []);
    await tester.tap(find.byKey(const Key('tab-add')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('field-name')), 'Leap Baby');
    await tester.tap(find.byKey(const Key('field-birthday-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Feb').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('field-birthday-day')), '29');
    await tester.tap(find.byKey(const Key('form-save')));
    await tester.pumpAndSettle();

    expect(find.text('Invalid day for this month'), findsNothing);
    expect(find.text('Leap Baby'), findsOneWidget);
    expect(find.text('Feb 29'), findsOneWidget);
  });
}
