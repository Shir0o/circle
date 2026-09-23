import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/life_stage.dart';
import '../models/person.dart';

class PeopleProvider extends ChangeNotifier {
  static const String _storageKey = 'circle_people_v1';
  static const String _themeKey = 'circle_theme_v1';

  List<Person> _people = _seedData();
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

  PeopleProvider() {
    init();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _people = jsonList.map((e) => Person.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _people = _seedData();
      }
    } else {
      _people = _seedData();
      await _persist();
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_people.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
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
    _selectedPerson = _people.firstWhere(
      (p) => p.id == id,
      orElse: () => _people.first,
    );
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

    list.sort((a, b) => a.name.compareTo(b.name));
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
    final sorted = _people.map((p) => MapEntry(p, p.daysUntilBirthday())).toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final next = sorted.first;
    final person = next.key;
    final days = next.value;

    final turns = person.turnsAge();
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
    final list = _people.map((p) => MapEntry(p, p.daysUntilBirthday())).toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return list;
  }

  Map<String, dynamic> get overviewData {
    final total = _people.length;
    final referenceDate = DateTime(2026, 7, 4); // Jul 4 2026 baseline from spec
    final bdaysThisMonth = _people.where((p) => p.bMonth == referenceDate.month).length;

    final stageBars = LifeStage.values.map((stage) {
      final count = _people.where((p) => p.stage == stage).length;
      final pct = total > 0 ? (count / total * 100).round() : 0;
      return {
        'label': stage.label,
        'count': count,
        'color': stage.avatarBg,
        'pct': '$pct%',
      };
    }).toList();

    final locMap = <String, int>{};
    for (final p in _people) {
      if (p.location.isNotEmpty) {
        locMap[p.location] = (locMap[p.location] ?? 0) + 1;
      }
    }
    final sortedLocs = locMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topLocations = sortedLocs.take(5).map((e) => {'name': e.key, 'count': e.value}).toList();

    return {
      'total': total,
      'bdaysThisMonth': bdaysThisMonth,
      'stageBars': stageBars,
      'locations': topLocations,
    };
  }

  static List<Person> _seedData() {
    return [
      Person(
        id: 1,
        name: 'Maya Chen',
        stage: LifeStage.college,
        bMonth: 3,
        bDay: 12,
        bYear: 2004,
        year: 'Junior',
        major: 'Psychology',
        school: 'UCLA',
        location: 'Los Angeles',
        interests: ['Photography', 'Rock climbing', 'K-pop'],
        dietary: ['Vegetarian'],
        howKnow: 'College friend',
        notes: 'Loves oat-milk lattes. Always down for a museum trip.',
      ),
      Person(
        id: 2,
        name: 'Jordan Ellis',
        stage: LifeStage.working,
        bMonth: 7,
        bDay: 8,
        bYear: 2001,
        occupation: 'Nurse',
        location: 'Seattle',
        interests: ['Trail running', 'Baking'],
        dietary: ['Gluten-free'],
        howKnow: 'Old roommate',
        notes: 'Works night shifts — text before calling.',
      ),
      Person(
        id: 3,
        name: 'Liam Okafor',
        stage: LifeStage.teens,
        bMonth: 11,
        bDay: 2,
        bYear: 2010,
        grade: '10th grade',
        school: 'Lincoln HS',
        location: 'Portland',
        interests: ['Basketball', 'Video games'],
        howKnow: "Neighbor's son",
        notes: 'Saving up for a gaming PC.',
      ),
      Person(
        id: 4,
        name: 'Sofia Reyes',
        stage: LifeStage.kids,
        bMonth: 7,
        bDay: 19,
        bYear: 2016,
        grade: '4th grade',
        location: 'Austin',
        interests: ['Drawing', 'Soccer'],
        dietary: ['No peanuts'],
        howKnow: "Cousin's daughter",
        notes: 'Allergic to peanuts — always check labels.',
      ),
      Person(
        id: 5,
        name: 'Aiden Park',
        stage: LifeStage.college,
        bMonth: 2,
        bDay: 27,
        bYear: 2003,
        year: 'Senior',
        major: 'Computer Science',
        school: 'NYU',
        location: 'New York',
        interests: ['Chess', 'Jazz', 'Startups'],
        howKnow: 'Hackathon teammate',
        notes: 'Graduating this spring, job-hunting.',
      ),
      Person(
        id: 6,
        name: 'Noah Kim',
        stage: LifeStage.working,
        bMonth: 9,
        bDay: 14,
        bYear: 1998,
        occupation: 'Software Engineer',
        location: 'San Francisco',
        interests: ['Cycling', 'Coffee', 'Board games'],
        dietary: ['Pescatarian'],
        howKnow: 'Former coworker',
        notes: 'Great for career advice.',
      ),
      Person(
        id: 7,
        name: 'Emma Wallace',
        stage: LifeStage.teens,
        bMonth: 7,
        bDay: 22,
        bYear: 2012,
        grade: '8th grade',
        school: 'Westview MS',
        location: 'Denver',
        interests: ['Violin', 'Reading'],
        dietary: ['Vegetarian'],
        howKnow: "Friend's daughter",
        notes: 'Playing in the youth orchestra.',
      ),
      Person(
        id: 8,
        name: 'Zara Ahmed',
        stage: LifeStage.college,
        bMonth: 12,
        bDay: 5,
        bYear: 2005,
        year: 'Sophomore',
        major: 'Biology',
        school: 'UT Austin',
        location: 'Austin',
        interests: ['Volunteering', 'Painting'],
        dietary: ['Halal'],
        howKnow: 'Church group',
        notes: 'Pre-med track.',
      ),
      Person(
        id: 9,
        name: 'Diego Morales',
        stage: LifeStage.working,
        bMonth: 4,
        bDay: 3,
        bYear: 1995,
        occupation: 'Teacher',
        location: 'Chicago',
        interests: ['Soccer', 'Cooking', 'Guitar'],
        howKnow: 'College friend',
        notes: 'Teaches 5th grade. Hosts great dinners.',
      ),
      Person(
        id: 10,
        name: 'Lily Nguyen',
        stage: LifeStage.kids,
        bMonth: 1,
        bDay: 30,
        bYear: 2018,
        grade: '2nd grade',
        location: 'San Jose',
        interests: ['Ballet', 'Legos'],
        dietary: ['No shellfish'],
        howKnow: "Sister's kid",
        notes: 'Obsessed with dinosaurs.',
      ),
      Person(
        id: 11,
        name: 'Ethan Brooks',
        stage: LifeStage.working,
        bMonth: 8,
        bDay: 11,
        bYear: 1999,
        occupation: 'Designer',
        location: 'Austin',
        interests: ['Film', 'Vinyl', 'Hiking'],
        dietary: ['Vegan'],
        howKnow: 'Met at a wedding',
        notes: 'Freelances — flexible schedule.',
      ),
      Person(
        id: 12,
        name: 'Priya Patel',
        stage: LifeStage.college,
        bMonth: 10,
        bDay: 9,
        bYear: 2006,
        year: 'Freshman',
        major: 'Chemistry',
        school: 'Rice',
        location: 'Houston',
        interests: ['Debate', 'Tennis'],
        dietary: ['Vegetarian'],
        howKnow: 'Family friend',
        notes: 'First year, settling in well.',
      ),
    ];
  }
}
