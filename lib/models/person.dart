import 'life_stage.dart';
import 'month_names.dart';

class Person {
  final int id;
  final String name;
  final LifeStage stage;
  final int? bMonth;
  final int? bDay;
  final int? bYear;
  final String year;
  final String major;
  final String school;
  final String grade;
  final String occupation;
  final String location;
  final List<String> interests;
  final List<String> dietary;
  final String howKnow;
  final String notes;

  Person({
    required this.id,
    required this.name,
    required this.stage,
    this.bMonth,
    this.bDay,
    this.bYear,
    this.year = '',
    this.major = '',
    this.school = '',
    this.grade = '',
    this.occupation = '',
    this.location = '',
    this.interests = const [],
    this.dietary = const [],
    this.howKnow = '',
    this.notes = '',
  });

  String get initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  /// Whether this person has any birthday recorded. A birthday may still be
  /// day-less (month and year known, day unknown).
  bool get hasBirthday => bMonth != null;

  /// Human-readable birthday: `March 12, 1990` for a full date, `March 1990`
  /// for a day-less birthday, or null when no birthday is recorded.
  String? get birthdayLabel {
    final month = bMonth;
    if (month == null) return null;
    final monthName = monthNames[month - 1];
    final day = bDay;
    final year = bYear;
    if (day == null) return year == null ? monthName : '$monthName $year';
    return year == null ? '$monthName $day' : '$monthName $day, $year';
  }

  int? getAge({required DateTime referenceDate}) {
    final year = bYear;
    final month = bMonth;
    if (year == null || month == null) return null;
    var age = referenceDate.year - year;
    final day = bDay;
    if (day == null) {
      // No day known: fall back to month precision.
      if (referenceDate.month < month) age--;
    } else if (referenceDate.month < month ||
        (referenceDate.month == month && referenceDate.day < day)) {
      age--;
    }
    return age;
  }

  /// Days until the next birthday celebration, or null when there is no
  /// birthday or no day is known (a day-less birthday has no countable date).
  int? daysUntilBirthday({required DateTime referenceDate}) {
    final month = bMonth;
    final day = bDay;
    if (month == null || day == null) return null;
    final today = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    var next = _birthdayInYear(today.year, month, day);
    if (next.isBefore(today)) {
      next = _birthdayInYear(today.year + 1, month, day);
    }
    return next.difference(today).inDays;
  }

  int? turnsAge({required DateTime referenceDate}) {
    final year = bYear;
    final month = bMonth;
    if (year == null || month == null) return null;
    final day = bDay;
    final turnYear = day == null
        // No day known: treat the birth month as the turning point.
        ? (month >= referenceDate.month
              ? referenceDate.year
              : referenceDate.year + 1)
        : ((month > referenceDate.month ||
                  (month == referenceDate.month && day >= referenceDate.day))
              ? referenceDate.year
              : referenceDate.year + 1);
    return turnYear - year;
  }

  /// The date of this person's birthday within [year], mapping Feb 29 to
  /// Feb 28 in non-leap years so countdowns and ordering stay correct.
  DateTime _birthdayInYear(int year, int month, int day) {
    if (month == 2 && day == 29 && !_isLeapYear(year)) {
      return DateTime(year, 2, 28);
    }
    return DateTime(year, month, day);
  }

  static bool _isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  String subLine({required DateTime referenceDate}) {
    if (stage == LifeStage.kids) {
      final a = getAge(referenceDate: referenceDate);
      final parts = <String>[];
      if (a != null) parts.add('Age $a');
      if (grade.isNotEmpty) parts.add(grade);
      return parts.join(' · ');
    } else if (stage == LifeStage.teens) {
      final parts = [
        if (grade.isNotEmpty) grade,
        if (school.isNotEmpty) school,
      ];
      return parts.join(' · ');
    } else if (stage == LifeStage.college) {
      final parts = [
        if (year.isNotEmpty) year,
        if (major.isNotEmpty) major,
        if (school.isNotEmpty) school,
      ];
      return parts.join(' · ');
    } else {
      return occupation.isNotEmpty ? occupation : 'Working';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stage': stage.serialized,
      'bMonth': bMonth,
      'bDay': bDay,
      'bYear': bYear,
      'year': year,
      'major': major,
      'school': school,
      'grade': grade,
      'occupation': occupation,
      'location': location,
      'interests': interests,
      'dietary': dietary,
      'howKnow': howKnow,
      'notes': notes,
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      stage: LifeStage.fromStorage(json['stage'] as String?),
      bMonth: json['bMonth'] as int?,
      bDay: json['bDay'] as int?,
      bYear: json['bYear'] as int?,
      year: json['year'] as String? ?? '',
      major: json['major'] as String? ?? '',
      school: json['school'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      location: json['location'] as String? ?? '',
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dietary:
          (json['dietary'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      howKnow: json['howKnow'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Person copyWith({
    int? id,
    String? name,
    LifeStage? stage,
    int? bMonth,
    int? bDay,
    int? bYear,
    String? year,
    String? major,
    String? school,
    String? grade,
    String? occupation,
    String? location,
    List<String>? interests,
    List<String>? dietary,
    String? howKnow,
    String? notes,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      bMonth: bMonth ?? this.bMonth,
      bDay: bDay ?? this.bDay,
      bYear: bYear ?? this.bYear,
      year: year ?? this.year,
      major: major ?? this.major,
      school: school ?? this.school,
      grade: grade ?? this.grade,
      occupation: occupation ?? this.occupation,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      dietary: dietary ?? this.dietary,
      howKnow: howKnow ?? this.howKnow,
      notes: notes ?? this.notes,
    );
  }
}
