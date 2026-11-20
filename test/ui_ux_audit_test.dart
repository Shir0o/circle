import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:circle/main.dart';
import 'package:circle/models/clock.dart';
import 'package:circle/models/life_stage.dart';
import 'package:circle/models/person.dart';
import 'package:circle/screens/form_screen.dart';
import 'package:circle/screens/main_screen.dart';
import 'package:circle/screens/profile_screen.dart';

/// UI/UX audit harness for the Circle app.
///
/// Runs the real `CircleApp` (with seeded storage, a fixed clock and no network
/// dependencies) at three representative device profiles and asserts the
/// Flutter accessibility guidelines plus a zero-overflow budget on each one.
/// A click-through then exercises the primary navigation and captures the
/// resulting screen.
///
/// Goldens are only written when the suite runs with `--update-goldens`
/// (i.e. when [autoUpdateGoldenFiles] is true), so a plain `flutter test` run
/// never fails on a missing baseline image.
class _Variant {
  const _Variant({
    required this.name,
    required this.size,
    required this.textScale,
    required this.brightness,
  });

  final String name;
  final Size size;
  final double textScale;
  final Brightness brightness;
}

const _variants = <_Variant>[
  _Variant(
    name: 'phone_light',
    size: Size(390, 844),
    textScale: 1.0,
    brightness: Brightness.light,
  ),
  _Variant(
    name: 'phone_dark',
    size: Size(390, 844),
    textScale: 1.0,
    brightness: Brightness.dark,
  ),
  _Variant(
    name: 'small_large_font',
    size: Size(320, 568),
    textScale: 1.6,
    brightness: Brightness.light,
  ),
];

final _clock = Clock(() => DateTime(2026, 7, 4));

/// Enough data that the home screen renders headers, chips, search and a
/// populated list rather than an empty state.
final _people = <Person>[
  Person(
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
  ),
  Person(
    id: 2,
    name: 'Diego Morales',
    stage: LifeStage.working,
    bMonth: 7,
    bDay: 18,
    bYear: 1991,
    occupation: 'Product designer',
    location: 'San Francisco',
  ),
  Person(
    id: 3,
    name: 'Sofia Reyes',
    stage: LifeStage.kids,
    bMonth: 11,
    bDay: 2,
    bYear: 2016,
    grade: '4th grade',
    location: 'Austin',
  ),
  Person(
    id: 4,
    name: 'Elliot Park',
    stage: LifeStage.teens,
    bMonth: 2,
    bDay: 9,
    bYear: 2009,
    grade: 'Sophomore',
    school: 'Lincoln High',
    location: 'Seattle',
  ),
];

/// Pumps [CircleApp] for [variant] with a deterministic provider.
///
/// The provider is backed by mock `SharedPreferences`, so no platform channel
/// or real disk access is touched, and a fixed clock keeps birthday copy and
/// countdowns stable across runs.
Future<void> _pumpCircle(WidgetTester tester, _Variant variant) async {
  tester.view.physicalSize = variant.size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  tester.platformDispatcher.textScaleFactorTestValue = variant.textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  tester.platformDispatcher.platformBrightnessTestValue = variant.brightness;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

  SharedPreferences.setMockInitialValues({
    'circle_people_v1': jsonEncode(_people.map((p) => p.toJson()).toList()),
  });
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(CircleApp(clock: _clock, prefs: prefs));
  await tester.pumpAndSettle();

  // Prove the harness (not the app default) drives the profile under test.
  final context = tester.element(find.byType(MainScreen));
  final media = MediaQuery.of(context);
  expect(media.size, variant.size, reason: 'surface size was not applied');
  expect(
    media.platformBrightness,
    variant.brightness,
    reason: 'platform brightness was not applied',
  );
  expect(
    media.textScaler.scale(100),
    closeTo(100 * variant.textScale, 0.01),
    reason: 'text scale was not applied',
  );
  expect(Theme.of(context).brightness, variant.brightness);
}

/// Fails with the offending message instead of a bare non-null exception, so
/// an overflow points straight at the screen that produced it.
void _expectNoOverflow(WidgetTester tester, String variantName) {
  final exception = tester.takeException();
  expect(
    exception,
    isNull,
    reason:
        '[$variantName] layout threw instead of rendering cleanly: '
        '$exception',
  );
}

/// Captures the whole app surface to `test/goldens/<file>` when the suite is
/// run with `--update-goldens`; skipped otherwise.
Future<void> _maybeGolden(
  WidgetTester tester,
  String file, {
  required bool enabled,
}) async {
  if (!enabled) return;
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$file'),
  );
}

/// Captures a step screenshot of a secondary screen.
///
/// The canonical file name is reserved for the `phone_light` profile; every
/// other profile gets its name appended (for example
/// `circle_step2_birthdays_phone_dark.png`) so the dark and large-font captures
/// do not overwrite the baseline. A plain `flutter test` run writes nothing.
Future<void> _maybeStepGolden(
  WidgetTester tester,
  String file, {
  required _Variant variant,
}) async {
  if (!autoUpdateGoldenFiles) return;
  final suffix = variant.name == 'phone_light' ? '' : '_${variant.name}';
  final name = file.replaceFirst('.png', '$suffix.png');
  await _maybeGolden(tester, name, enabled: true);
}

/// Runs the two accessibility guidelines the audit treats as hard gates.
Future<void> _expectAccessibilityGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final variant in _variants) {
    testWidgets(
      '${variant.name}: meets tap target and text contrast guidelines',
      (tester) async {
        final semantics = tester.ensureSemantics();

        try {
          await _pumpCircle(tester, variant);

          // The shell renders on every profile: home content plus the tab bar.
          expect(find.text('Circle'), findsOneWidget);
          expect(find.byKey(const Key('circle-tab-bar')), findsOneWidget);

          _expectNoOverflow(tester, variant.name);

          // The stage badge wraps to its own run instead of starving the name:
          // the name must keep a measurable width on every profile.
          final personName = find.text('Diego Morales');
          expect(personName, findsOneWidget);
          expect(
            tester.getSize(personName).width,
            greaterThan(50),
            reason:
                '[$variant.name] person name collapsed or was starved of space',
          );

          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));

          await _maybeGolden(
            tester,
            'circle_${variant.name}.png',
            enabled: autoUpdateGoldenFiles,
          );
        } finally {
          // Must be disposed before the end-of-test verifications run.
          semantics.dispose();
        }
      },
    );

    testWidgets('${variant.name}: primary navigation click-through', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      try {
        await _pumpCircle(tester, variant);

        // Birthdays is the first non-default tab in the shell: tapping it
        // exercises the app's primary navigation path.
        await tester.tap(find.byKey(const Key('tab-birthdays')));
        await tester.pumpAndSettle();

        _expectNoOverflow(tester, '${variant.name}_step2_birthdays');
        expect(find.text('Next up in your circle'), findsOneWidget);
        expect(find.byKey(const Key('circle-tab-bar')), findsOneWidget);
        await _expectAccessibilityGuidelines(tester);
        await _maybeStepGolden(
          tester,
          'circle_step2_birthdays.png',
          variant: variant,
        );

        await tester.tap(find.byKey(const Key('tab-overview')));
        await tester.pumpAndSettle();

        _expectNoOverflow(tester, '${variant.name}_step3_overview');
        expect(find.text('Your circle'), findsOneWidget);
        await _expectAccessibilityGuidelines(tester);
        await _maybeStepGolden(
          tester,
          'circle_step3_overview.png',
          variant: variant,
        );

        // Add is a pushed route rather than a tab, so it takes over the shell.
        await tester.tap(find.byKey(const Key('tab-add')));
        await tester.pumpAndSettle();

        _expectNoOverflow(tester, '${variant.name}_step4_add');
        expect(find.byType(FormScreen), findsOneWidget);
        await _expectAccessibilityGuidelines(tester);
        await _maybeStepGolden(
          tester,
          'circle_step4_add.png',
          variant: variant,
        );

        // Cancelling the form returns to the tab that was active before.
        await tester.tap(find.byKey(const Key('form-cancel')));
        await tester.pumpAndSettle();

        _expectNoOverflow(tester, '${variant.name}_step4_back');
        expect(find.text('Your circle'), findsOneWidget);

        // A person row is the second navigation path into a pushed route:
        // directory -> profile. Scroll it into view first so the tap works at
        // the compact 320x568 profile too.
        await tester.tap(find.byKey(const Key('tab-directory')));
        await tester.pumpAndSettle();

        _expectNoOverflow(tester, '${variant.name}_step5_directory');
        final diego = find.text('Diego Morales');
        expect(diego, findsOneWidget);
        await tester.ensureVisible(diego);
        await tester.pumpAndSettle();
        await tester.tap(diego);
        await tester.pumpAndSettle();

        _expectNoOverflow(tester, '${variant.name}_step5_profile');
        expect(find.byType(ProfileScreen), findsOneWidget);
        expect(find.text('Diego Morales'), findsOneWidget);
        expect(
          find.byKey(const Key('detail-value-Occupation')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('circle-tab-bar')), findsNothing);

        await _expectAccessibilityGuidelines(tester);
        await _maybeStepGolden(
          tester,
          'circle_step5_profile.png',
          variant: variant,
        );

        // Back goes to the directory, not to a stale tab.
        await tester.tap(find.byKey(const Key('profile-back')));
        await tester.pumpAndSettle();

        _expectNoOverflow(tester, '${variant.name}_step5_back');
        expect(find.text('Circle'), findsOneWidget);
        expect(find.byKey(const Key('circle-tab-bar')), findsOneWidget);
      } finally {
        // Must be disposed before the end-of-test verifications run.
        semantics.dispose();
      }
    });
  }
}
