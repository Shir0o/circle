import 'package:flutter/material.dart';

class StageMeta {
  final String label;
  final Color bg;
  final Color color;
  final Color avatarBg;
  final Color avatarColor;

  const StageMeta({
    required this.label,
    required this.bg,
    required this.color,
    required this.avatarBg,
    required this.avatarColor,
  });
}

class Person {
  final int id;
  final String name;
  final String stage; // 'child', 'teen', 'college', 'working'
  final int bMonth;
  final int bDay;
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
    required this.bMonth,
    required this.bDay,
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
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  int? getAge({DateTime? referenceDate}) {
    if (bYear == null) return null;
    final today = referenceDate ?? DateTime(2026, 7, 4);
    int age = today.year - bYear!;
    if (today.month < bMonth || (today.month == bMonth && today.day < bDay)) {
      age--;
    }
    return age;
  }

  int daysUntilBirthday({DateTime? referenceDate}) {
    final today = referenceDate ?? DateTime(2026, 7, 4);
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    var next = DateTime(today.year, bMonth, bDay);
    if (next.isBefore(todayDateOnly)) {
      next = DateTime(today.year + 1, bMonth, bDay);
    }
    return next.difference(todayDateOnly).inDays;
  }

  int? turnsAge({DateTime? referenceDate}) {
    if (bYear == null) return null;
    final today = referenceDate ?? DateTime(2026, 7, 4);
    final turnYear = (bMonth > today.month || (bMonth == today.month && bDay >= today.day)) ? today.year : today.year + 1;
    return turnYear - bYear!;
  }

  String get subLine {
    if (stage == 'child') {
      final a = getAge();
      final parts = <String>[];
      if (a != null) parts.add('Age $a');
      if (grade.isNotEmpty) parts.add(grade);
      return parts.join(' · ');
    } else if (stage == 'teen') {
      final parts = [if (grade.isNotEmpty) grade, if (school.isNotEmpty) school];
      return parts.join(' · ');
    } else if (stage == 'college') {
      final parts = [if (year.isNotEmpty) year, if (major.isNotEmpty) major, if (school.isNotEmpty) school];
      return parts.join(' · ');
    } else {
      return occupation.isNotEmpty ? occupation : 'Working';
    }
  }

  static StageMeta getStageMeta(String stage) {
    switch (stage) {
      case 'child':
        return const StageMeta(
          label: 'Kids',
          bg: Color(0xFFFEF1CF),
          color: Color(0xFFB27A00),
          avatarBg: Color(0xFFF5B700),
          avatarColor: Color(0xFF3A2C00),
        );
      case 'teen':
        return const StageMeta(
          label: 'Teens',
          bg: Color(0xFFFFE0EC),
          color: Color(0xFFC13567),
          avatarBg: Color(0xFFFF5D8F),
          avatarColor: Color(0xFF4A0A22),
        );
      case 'college':
        return const StageMeta(
          label: 'College',
          bg: Color(0xFFECE6FF),
          color: Color(0xFF5B3EDA),
          avatarBg: Color(0xFF7C5CFC),
          avatarColor: Color(0xFF1E1147),
        );
      case 'working':
      default:
        return const StageMeta(
          label: 'Working',
          bg: Color(0xFFD6F5EA),
          color: Color(0xFF0B7A56),
          avatarBg: Color(0xFF12B981),
          avatarColor: Color(0xFF04331F),
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stage': stage,
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
      stage: json['stage'] as String? ?? 'college',
      bMonth: json['bMonth'] as int? ?? 1,
      bDay: json['bDay'] as int? ?? 1,
      bYear: json['bYear'] as int?,
      year: json['year'] as String? ?? '',
      major: json['major'] as String? ?? '',
      school: json['school'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      location: json['location'] as String? ?? '',
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dietary: (json['dietary'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      howKnow: json['howKnow'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Person copyWith({
    int? id,
    String? name,
    String? stage,
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
