import 'package:flutter_test/flutter_test.dart';

import 'package:circle/models/life_stage.dart';
import 'package:circle/models/overview_stats.dart';
import 'package:circle/models/person.dart';

void main() {
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

  group('OverviewStats', () {
    test('computes total and birthdays in the given month', () {
      final stats = OverviewStats.fromPeople([
        person(id: 1, name: 'Maya Chen', bMonth: 7),
        person(id: 2, name: 'Sofia Reyes', bMonth: 7),
        person(id: 3, name: 'Diego Morales', bMonth: 4),
      ], DateTime(2026, 7, 4));

      expect(stats.total, 3);
      expect(stats.birthdaysThisMonth, 2);
    });

    test('per-stage counts and fractions are correct', () {
      final stats = OverviewStats.fromPeople([
        person(id: 1, name: 'Sofia', stage: LifeStage.kids),
        person(id: 2, name: 'Leo', stage: LifeStage.kids),
        person(id: 3, name: 'Noah', stage: LifeStage.teens),
        person(id: 4, name: 'Maya', stage: LifeStage.working),
      ], DateTime(2026, 7, 4));

      final kids = stats.stageStats.firstWhere(
        (s) => s.stage == LifeStage.kids,
      );
      expect(kids.count, 2);
      expect(kids.fraction, closeTo(0.5, 0.0001));

      final teens = stats.stageStats.firstWhere(
        (s) => s.stage == LifeStage.teens,
      );
      expect(teens.count, 1);
      expect(teens.fraction, closeTo(0.25, 0.0001));

      expect(
        stats.stageStats.fold(0.0, (sum, s) => sum + s.fraction),
        closeTo(1, 0.0001),
      );
    });

    test('top locations are sorted by count and capped at five', () {
      final stats = OverviewStats.fromPeople([
        person(id: 1, name: 'a', location: 'Portland'),
        person(id: 2, name: 'b', location: 'Portland'),
        person(id: 3, name: 'c', location: 'Seattle'),
        person(id: 4, name: 'd', location: 'Seattle'),
        person(id: 5, name: 'e', location: 'Seattle'),
        person(id: 6, name: 'f', location: 'Austin'),
        person(id: 7, name: 'g', location: 'Denver'),
        person(id: 8, name: 'h', location: 'Boston'),
        person(id: 9, name: 'i', location: 'Chicago'),
        person(id: 10, name: 'j', location: 'Miami'),
      ], DateTime(2026, 7, 4));

      expect(stats.topLocations.length, 5);
      expect(stats.topLocations.map((l) => l.name).toList(), [
        'Seattle',
        'Portland',
        'Austin',
        'Boston',
        'Chicago',
      ]);
      expect(
        stats.topLocations.firstWhere((l) => l.name == 'Seattle').count,
        3,
      );
    });

    test('people without a location are excluded from top locations', () {
      final stats = OverviewStats.fromPeople([
        person(id: 1, name: 'No Where'),
        person(id: 2, name: 'Maya', location: 'Portland'),
      ], DateTime(2026, 7, 4));

      expect(stats.topLocations.map((l) => l.name).toList(), ['Portland']);
    });

    test('an empty circle yields zeroes and never divides by zero', () {
      final stats = OverviewStats.fromPeople([], DateTime(2026, 7, 4));

      expect(stats.total, 0);
      expect(stats.birthdaysThisMonth, 0);
      expect(stats.topLocations, isEmpty);
      for (final s in stats.stageStats) {
        expect(s.count, 0);
        expect(s.fraction, 0);
      }
    });
  });
}
