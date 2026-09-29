import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clock.dart';
import '../models/life_stage.dart';
import '../models/overview_stats.dart';
import '../models/person.dart';

class PeopleProvider extends ChangeNotifier {
  static const String _storageKey = 'circle_people_v1';
  static const String _backupKey = 'circle_people_v1_backup';

  final Clock _clock;
  final SharedPreferences? _prefs;

  List<Person> _people = [];
  String _searchQuery = '';
  String _stageFilter = 'all';
  Person? _selectedPerson;
  bool _isInitialized = false;

  List<Person> get people => _people;
  String get searchQuery => _searchQuery;
  String get stageFilter => _stageFilter;
  Person? get selectedPerson => _selectedPerson;
  bool get isInitialized => _isInitialized;
  DateTime get today => _clock.today;

  PeopleProvider({Clock? clock, SharedPreferences? prefs})
    : _clock = clock ?? Clock(),
      // ignore: prefer_initializing_formals
      _prefs = prefs {
    init();
  }

  Future<void> init() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonString);
        if (decoded is! List) {
          throw const FormatException('stored data is not a list');
        }
        _people = decoded
            .map((e) => Person.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Preserve the raw payload under a backup key; start empty and never
        // overwrite the original key on read.
        await prefs.setString(_backupKey, jsonString);
        _people = [];
      }
    } else {
      // First run: stay empty, nothing is written until the first save.
      _people = [];
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_people.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStageFilter(String filter) {
    _stageFilter = filter;
    notifyListeners();
  }

  void selectPerson(Person? person) {
    _selectedPerson = person;
    notifyListeners();
  }

  void selectPersonById(int id) {
    Person? found;
    for (final p in _people) {
      if (p.id == id) {
        found = p;
        break;
      }
    }
    _selectedPerson = found;
    notifyListeners();
  }

  Future<void> savePerson(Person person) async {
    final index = _people.indexWhere((p) => p.id == person.id);
    if (index >= 0) {
      _people[index] = person;
    } else {
      _people.add(person);
    }
    _selectedPerson = person;
    await _persist();
    notifyListeners();
  }

  Future<void> deletePerson(int id) async {
    _people.removeWhere((p) => p.id == id);
    if (_selectedPerson?.id == id) {
      _selectedPerson = null;
    }
    await _persist();
    notifyListeners();
  }

  List<Person> get filteredPeople {
    final q = _searchQuery.trim().toLowerCase();
    final filter = _stageFilter;
    final list = _people.where((p) {
      final matchesStage = (filter == 'all' || p.stage.serialized == filter);
      final matchesQuery = q.isEmpty || p.name.toLowerCase().contains(q);
      return matchesStage && matchesQuery;
    }).toList();

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Map<String, int> get stageCounts {
    final counts = <String, int>{'all': _people.length};
    for (final stage in LifeStage.values) {
      counts[stage.serialized] = _people.where((p) => p.stage == stage).length;
    }
    return counts;
  }

  String get nextBirthdayBannerText {
    final today = _clock.today;
    // Only day-bearing birthdays can be counted down; a day-less birthday has
    // no specific date to count to.
    final dated = _people
        .map((p) => MapEntry(p, p.daysUntilBirthday(referenceDate: today)))
        .where((e) => e.value != null)
        .toList();
    if (dated.isEmpty) return 'No birthdays yet';

    dated.sort((a, b) => a.value!.compareTo(b.value!));
    final person = dated.first.key;
    final days = dated.first.value!;

    final turns = person.turnsAge(referenceDate: today);
    final firstName = person.name.split(' ').first;
    final turnsStr = turns != null ? ' turns $turns' : '';

    if (days == 0) {
      return '$firstName$turnsStr today! 🎉';
    } else if (days == 1) {
      return '$firstName$turnsStr tomorrow';
    } else {
      return '$firstName$turnsStr in $days days';
    }
  }

  /// Every person with a birthday, ordered by how soon it arrives. A day-less
  /// birthday is ordered at the start of its birth month; its value is null
  /// because there is no countable day, and callers should render it without a
  /// day countdown.
  List<MapEntry<Person, int?>> get upcomingBirthdays {
    final today = _clock.today;
    final list = _people.where((p) => p.hasBirthday).toList()
      ..sort((a, b) {
        final bySoon = _birthdaySortKey(
          a,
          today,
        ).compareTo(_birthdaySortKey(b, today));
        return bySoon != 0
            ? bySoon
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return [
      for (final p in list)
        MapEntry(p, p.daysUntilBirthday(referenceDate: today)),
    ];
  }

  /// Ordering key in days: the birthday itself when a day is known, otherwise
  /// the first of the birth month.
  int _birthdaySortKey(Person p, DateTime today) {
    final days = p.daysUntilBirthday(referenceDate: today);
    if (days != null) return days;
    final start = DateTime(today.year, today.month, today.day);
    var first = DateTime(today.year, p.bMonth!, 1);
    if (first.isBefore(start)) first = DateTime(today.year + 1, p.bMonth!, 1);
    return first.difference(start).inDays;
  }

  OverviewStats get overviewStats =>
      OverviewStats.fromPeople(_people, _clock.today);
}
