import 'package:flutter_test/flutter_test.dart';
import 'package:circle/models/person.dart';

void main() {
  group('Person Model Tests', () {
    test('calculate initials correctly', () {
      final person1 = Person(id: 1, name: 'Maya Chen', stage: 'college', bMonth: 3, bDay: 12);
      expect(person1.initials, 'MC');

      final person2 = Person(id: 2, name: 'Jordan', stage: 'working', bMonth: 7, bDay: 8);
      expect(person2.initials, 'J');

      final person3 = Person(id: 3, name: 'Sofia De La Cruz', stage: 'child', bMonth: 1, bDay: 1);
      expect(person3.initials, 'SD');
    });

    test('calculate age based on reference date', () {
      final refDate = DateTime(2026, 7, 4);
      final person = Person(
        id: 1,
        name: 'Maya Chen',
        stage: 'college',
        bMonth: 3,
        bDay: 12,
        bYear: 2004,
      );

      expect(person.getAge(referenceDate: refDate), 22);

      final person2 = Person(
        id: 2,
        name: 'Jordan Ellis',
        stage: 'working',
        bMonth: 8,
        bDay: 10,
        bYear: 2000,
      );
      // Birthday hasn't happened yet in 2026-07-04
      expect(person2.getAge(referenceDate: refDate), 25);
    });

    test('calculate days until birthday', () {
      final refDate = DateTime(2026, 7, 4);
      final personToday = Person(id: 1, name: 'Maya', stage: 'college', bMonth: 7, bDay: 4);
      expect(personToday.daysUntilBirthday(referenceDate: refDate), 0);

      final personTomorrow = Person(id: 2, name: 'Sofia', stage: 'child', bMonth: 7, bDay: 5);
      expect(personTomorrow.daysUntilBirthday(referenceDate: refDate), 1);
    });

    test('subLine formatting per life stage', () {
      final collegePerson = Person(
        id: 1,
        name: 'Maya',
        stage: 'college',
        bMonth: 3,
        bDay: 12,
        year: 'Junior',
        major: 'Psychology',
        school: 'UCLA',
      );
      expect(collegePerson.subLine, 'Junior · Psychology · UCLA');

      final workingPerson = Person(
        id: 2,
        name: 'Noah',
        stage: 'working',
        bMonth: 9,
        bDay: 14,
        occupation: 'Software Engineer',
      );
      expect(workingPerson.subLine, 'Software Engineer');

      final childPerson = Person(
        id: 3,
        name: 'Sofia',
        stage: 'child',
        bMonth: 7,
        bDay: 19,
        bYear: 2016,
        grade: '4th grade',
      );
      expect(childPerson.subLine, 'Age 9 · 4th grade');
    });

    test('toJson and fromJson roundtrip', () {
      final person = Person(
        id: 42,
        name: 'Test Member',
        stage: 'teen',
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
}
