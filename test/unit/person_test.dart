import 'package:flutter_test/flutter_test.dart';
import 'package:circle/models/person.dart';
import 'package:circle/models/life_stage.dart';

void main() {
  group('Person Model Tests', () {
    test('calculate initials correctly', () {
      final person1 = Person(
        id: 1,
        name: 'Maya Chen',
        stage: LifeStage.college,
        bMonth: 3,
        bDay: 12,
      );
      expect(person1.initials, 'MC');

      final person2 = Person(
        id: 2,
        name: 'Jordan',
        stage: LifeStage.working,
        bMonth: 7,
        bDay: 8,
      );
      expect(person2.initials, 'J');

      final person3 = Person(
        id: 3,
        name: 'Sofia De La Cruz',
        stage: LifeStage.kids,
        bMonth: 1,
        bDay: 1,
      );
      expect(person3.initials, 'SD');
    });

    test('calculate age based on reference date', () {
      final refDate = DateTime(2026, 7, 4);
      final person = Person(
        id: 1,
        name: 'Maya Chen',
        stage: LifeStage.college,
        bMonth: 3,
        bDay: 12,
        bYear: 2004,
      );

      expect(person.getAge(referenceDate: refDate), 22);

      final person2 = Person(
        id: 2,
        name: 'Jordan Ellis',
        stage: LifeStage.working,
        bMonth: 8,
        bDay: 10,
        bYear: 2000,
      );
      // Birthday hasn't happened yet in 2026-07-04
      expect(person2.getAge(referenceDate: refDate), 25);
    });

    test('calculate days until birthday', () {
      final refDate = DateTime(2026, 7, 4);
      final personToday = Person(
        id: 1,
        name: 'Maya',
        stage: LifeStage.college,
        bMonth: 7,
        bDay: 4,
      );
      expect(personToday.daysUntilBirthday(referenceDate: refDate), 0);

      final personTomorrow = Person(
        id: 2,
        name: 'Sofia',
        stage: LifeStage.kids,
        bMonth: 7,
        bDay: 5,
      );
      expect(personTomorrow.daysUntilBirthday(referenceDate: refDate), 1);
    });

    group('Feb 29 leap-year handling', () {
      final leap = Person(
        id: 1,
        name: 'Leap',
        stage: LifeStage.working,
        bMonth: 2,
        bDay: 29,
        bYear: 2000,
      );

      test('counts down to Feb 28 in a non-leap year', () {
        // 2023 is not a leap year: the next celebration is Feb 28.
        expect(leap.daysUntilBirthday(referenceDate: DateTime(2023, 2, 27)), 1);
        expect(leap.daysUntilBirthday(referenceDate: DateTime(2023, 2, 28)), 0);
      });

      test('counts down to Feb 29 in a leap year', () {
        // 2024 is a leap year: Feb 29 exists.
        expect(leap.daysUntilBirthday(referenceDate: DateTime(2024, 2, 28)), 1);
        expect(leap.daysUntilBirthday(referenceDate: DateTime(2024, 2, 29)), 0);
      });

      test('orders a Feb 29 birthday correctly in a non-leap year', () {
        final feb28 = Person(
          id: 2,
          name: 'Feb28',
          stage: LifeStage.working,
          bMonth: 2,
          bDay: 28,
        );
        // Reference Feb 27, 2023: both celebrate on Feb 28 (leap maps to Feb 28).
        expect(
          feb28.daysUntilBirthday(referenceDate: DateTime(2023, 2, 27)),
          1,
        );
        expect(leap.daysUntilBirthday(referenceDate: DateTime(2023, 2, 27)), 1);
      });
    });

    test('subLine formatting per life stage', () {
      final refDate = DateTime(2026, 7, 4);
      final collegePerson = Person(
        id: 1,
        name: 'Maya',
        stage: LifeStage.college,
        bMonth: 3,
        bDay: 12,
        year: 'Junior',
        major: 'Psychology',
        school: 'UCLA',
      );
      expect(
        collegePerson.subLine(referenceDate: refDate),
        'Junior · Psychology · UCLA',
      );

      final workingPerson = Person(
        id: 2,
        name: 'Noah',
        stage: LifeStage.working,
        bMonth: 9,
        bDay: 14,
        occupation: 'Software Engineer',
      );
      expect(
        workingPerson.subLine(referenceDate: refDate),
        'Software Engineer',
      );

      final childPerson = Person(
        id: 3,
        name: 'Sofia',
        stage: LifeStage.kids,
        bMonth: 7,
        bDay: 19,
        bYear: 2016,
        grade: '4th grade',
      );
      expect(childPerson.subLine(referenceDate: refDate), 'Age 9 · 4th grade');
    });

    test('toJson and fromJson roundtrip', () {
      final person = Person(
        id: 42,
        name: 'Test Member',
        stage: LifeStage.teens,
        bMonth: 11,
        bDay: 2,
        bYear: 2010,
        grade: '10th grade',
        school: 'Lincoln HS',
        location: 'Portland',
        interests: ['Basketball', 'Gaming'],
        dietary: ['Vegetarian'],
        howKnow: 'Neighbor',
        notes: 'Test note',
      );

      final json = person.toJson();
      final restored = Person.fromJson(json);

      expect(restored.id, person.id);
      expect(restored.name, person.name);
      expect(restored.stage, person.stage);
      expect(restored.bMonth, person.bMonth);
      expect(restored.bDay, person.bDay);
      expect(restored.bYear, person.bYear);
      expect(restored.grade, person.grade);
      expect(restored.interests, person.interests);
      expect(restored.dietary, person.dietary);
      expect(restored.notes, person.notes);
    });
  });

  group('LifeStage', () {
    test('serialises to existing storage strings', () {
      expect(LifeStage.kids.serialized, 'child');
      expect(LifeStage.teens.serialized, 'teen');
      expect(LifeStage.college.serialized, 'college');
      expect(LifeStage.working.serialized, 'working');
    });

    test('exposes the display labels', () {
      expect(LifeStage.kids.label, 'Kids');
      expect(LifeStage.teens.label, 'Teens');
      expect(LifeStage.college.label, 'College');
      expect(LifeStage.working.label, 'Working');
    });

    test('fromStorage resolves each known storage string', () {
      expect(LifeStage.fromStorage('child'), LifeStage.kids);
      expect(LifeStage.fromStorage('teen'), LifeStage.teens);
      expect(LifeStage.fromStorage('college'), LifeStage.college);
      expect(LifeStage.fromStorage('working'), LifeStage.working);
    });

    test('fromStorage falls back to College for unknown values', () {
      expect(LifeStage.fromStorage('alien'), LifeStage.college);
      expect(LifeStage.fromStorage(''), LifeStage.college);
      expect(LifeStage.fromStorage(null), LifeStage.college);
    });

    test(
      'round-trips through toJson and fromJson keeping the same stage string',
      () {
        final person = Person(
          id: 1,
          name: 'Test',
          stage: LifeStage.kids,
          bMonth: 1,
          bDay: 1,
        );
        final json = person.toJson();
        expect(json['stage'], 'child');
        final restored = Person.fromJson(json);
        expect(restored.stage, LifeStage.kids);
      },
    );

    test('fromJson falls back to College for unknown stored stage', () {
      final restored = Person.fromJson({
        'id': 1,
        'name': 'Test',
        'stage': 'alien',
        'bMonth': 1,
        'bDay': 1,
      });
      expect(restored.stage, LifeStage.college);
    });
  });
}
