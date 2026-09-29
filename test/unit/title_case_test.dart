import 'package:flutter_test/flutter_test.dart';
import 'package:circle/models/title_case.dart';

void main() {
  group('titleCase', () {
    test('leaves an empty string empty', () {
      expect(titleCase(''), '');
    });

    test('capitalises each word and lowercases the rest', () {
      expect(titleCase('maya chen'), 'Maya Chen');
      expect(titleCase('MAYA CHEN'), 'Maya Chen');
      expect(titleCase('mAyA cHeN'), 'Maya Chen');
    });

    test('capitalises the segment after an apostrophe', () {
      expect(titleCase("o'brien"), "O'Brien");
    });

    test('capitalises the segment after a hyphen', () {
      expect(titleCase('mary-jane'), 'Mary-Jane');
    });

    test('does not attempt to lowercase name particles', () {
      expect(titleCase('van der berg'), 'Van Der Berg');
    });

    test('preserves whitespace as typed', () {
      expect(titleCase('  los angeles'), '  Los Angeles');
      expect(titleCase('los  angeles'), 'Los  Angeles');
    });

    test('is idempotent', () {
      expect(titleCase(titleCase('maya chen')), 'Maya Chen');
    });

    test('handles digits and punctuation', () {
      expect(titleCase('jane doe 2'), 'Jane Doe 2');
      expect(titleCase('sr.'), 'Sr.');
    });
  });
}
