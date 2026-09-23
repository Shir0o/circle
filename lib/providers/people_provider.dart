import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clock.dart';
import '../models/life_stage.dart';
import '../models/overview_stats.dart';
import '../models/person.dart';

class PeopleProvider extends ChangeNotifier {
  static const String _storageKey = 'circle_people_v1';
  static const String _themeKey = 'circle_theme_v1';
  static const String _backupKey = 'circle_people_v1_backup';

  final Clock _clock;
  final SharedPreferences? _prefs;

  List<Person> _people = [];
  String _searchQuery = '';
  String _stageFilter = 'all';
  ThemeMode _themeMode = ThemeMode.light;
  Person? _selectedPerson;
  bool _isInitialized = false;

  List<Person> get people => _people;
  String get searchQuery => _searchQuery;
  String get stageFilter => _stageFilter;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
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
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

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

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
    notifyListeners();
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
    if (_people.isEmpty) return 'No birthdays yet';
    final today = _clock.today;
    final sorted =
        _people
            .map((p) => MapEntry(p, p.daysUntilBirthday(referenceDate: today)))
            .toList()
          ..sort((a, b) => a.value.compareTo(b.value));

    final next = sorted.first;
    final person = next.key;
    final days = next.value;

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

  List<MapEntry<Person, int>> get upcomingBirthdays {
    final today = _clock.today;
    final list =
        _people
            .map((p) => MapEntry(p, p.daysUntilBirthday(referenceDate: today)))
            .toList()
          ..sort((a, b) => a.value.compareTo(b.value));
    return list;
  }

  OverviewStats get overviewStats =>
      OverviewStats.fromPeople(_people, _clock.today);
}
