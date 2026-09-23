import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:circle/models/clock.dart';
import 'package:circle/models/life_stage.dart';
import 'package:circle/models/person.dart';
import 'package:circle/providers/people_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final clock = Clock(() => DateTime(2026, 7, 4));

  Person person({
    required int id,
    required String name,
    LifeStage stage = LifeStage.working,
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

  group('PeopleProvider storage', () {
    test('fresh install has zero people and does not write storage', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = PeopleProvider(prefs: prefs, clock: clock);
      await provider.init();

      expect(provider.people, isEmpty);
      expect(prefs.getString('circle_people_v1'), isNull);
    });

    test('corrupt stored JSON is backed up and the app starts empty', () async {
      const corrupt = '{this is "not" valid json';
      SharedPreferences.setMockInitialValues({'circle_people_v1': corrupt});
      final prefs = await SharedPreferences.getInstance();
      final provider = PeopleProvider(prefs: prefs, clock: clock);
      await provider.init();

      expect(provider.people, isEmpty);
      expect(prefs.getString('circle_people_v1_backup'), corrupt);
      // Original key is never overwritten on read.
      expect(prefs.getString('circle_people_v1'), corrupt);
    });

    test('valid stored data loads into people', () async {
      final stored = [
        person(id: 1, name: 'Maya Chen', stage: LifeStage.college, bMonth: 3),
        person(id: 2, name: 'Diego Morales', bMonth: 4),
      ];
      SharedPreferences.setMockInitialValues({
        'circle_people_v1': jsonEncode(stored.map((p) => p.toJson()).toList()),
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = PeopleProvider(prefs: prefs, clock: clock);
      await provider.init();

      expect(provider.people.map((p) => p.name), [
        'Maya Chen',
        'Diego Morales',
      ]);
    });

    test('first save writes to storage', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = PeopleProvider(prefs: prefs, clock: clock);
      await provider.init();

      expect(prefs.getString('circle_people_v1'), isNull);
      await provider.savePerson(person(id: 7, name: 'New Member'));

      expect(prefs.getString('circle_people_v1'), isNotNull);
    });
  });

  group('PeopleProvider date logic uses the injected clock', () {
    test('next birthday banner, ordering and birthdays-this-month', () async {
      final stored = [
        person(id: 1, name: 'Maya Chen', bMonth: 7, bDay: 4, bYear: 2000),
        person(id: 2, name: 'Sofia Reyes', bMonth: 7, bDay: 5, bYear: 2016),
        person(id: 3, name: 'Diego Morales', bMonth: 4, bDay: 3, bYear: 1995),
      ];
      SharedPreferences.setMockInitialValues({
        'circle_people_v1': jsonEncode(stored.map((p) => p.toJson()).toList()),
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = PeopleProvider(prefs: prefs, clock: clock);
      await provider.init();

      // Jul 4 2026: Maya's birthday is today, she turns 26.
      expect(provider.nextBirthdayBannerText, 'Maya turns 26 today! 🎉');
      // Ordering: Maya (0), Sofia (1), Diego (later).
      expect(provider.upcomingBirthdays.map((e) => e.key.name).toList(), [
        'Maya Chen',
        'Sofia Reyes',
        'Diego Morales',
      ]);
      // July has two birthdays (Maya and Sofia).
      expect(provider.overviewStats.birthdaysThisMonth, 2);
      expect(provider.overviewStats.total, 3);
    });
  });

  group('PeopleProvider selection', () {
    test(
      'selecting a missing id never falls back or throws on empty list',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final provider = PeopleProvider(prefs: prefs, clock: clock);
        await provider.init();

        expect(provider.selectedPerson, isNull);
        expect(() => provider.selectPersonById(99), returnsNormally);
        expect(provider.selectedPerson, isNull);
      },
    );

    test('selecting a missing id is null when people exist', () async {
      SharedPreferences.setMockInitialValues({
        'circle_people_v1': jsonEncode([
          person(id: 1, name: 'Maya Chen').toJson(),
        ]),
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = PeopleProvider(prefs: prefs, clock: clock);
      await provider.init();

      provider.selectPersonById(999);
      expect(provider.selectedPerson, isNull);
    });
  });

  group('PeopleProvider directory sort', () {
    test('is case-insensitive', () async {
      SharedPreferences.setMockInitialValues({
        'circle_people_v1': jsonEncode([
          person(id: 1, name: 'alice').toJson(),
          person(id: 2, name: 'Bob').toJson(),
          person(id: 3, name: 'charlie').toJson(),
          person(id: 4, name: 'Amy').toJson(),
        ]),
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = PeopleProvider(prefs: prefs, clock: clock);
      await provider.init();

      expect(provider.filteredPeople.map((p) => p.name).toList(), [
        'alice',
        'Amy',
        'Bob',
        'charlie',
      ]);
    });
  });
}
