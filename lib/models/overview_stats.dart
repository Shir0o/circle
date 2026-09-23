import 'life_stage.dart';
import 'person.dart';

/// Typed statistics for the Overview screen.
///
/// Computed from the people list and the injected clock's "today" so the
/// birthdays-this-month count always follows the current calendar month.
class OverviewStats {
  final int total;
  final int birthdaysThisMonth;
  final List<StageStat> stageStats;
  final List<LocationStat> topLocations;

  OverviewStats({
    required this.total,
    required this.birthdaysThisMonth,
    required this.stageStats,
    required this.topLocations,
  });

  factory OverviewStats.fromPeople(List<Person> people, DateTime today) {
    final total = people.length;
    final birthdaysThisMonth = people
        .where((p) => p.bMonth == today.month)
        .length;

    final stageStats = <StageStat>[];
    for (final stage in LifeStage.values) {
      final count = people.where((p) => p.stage == stage).length;
      stageStats.add(
        StageStat(
          stage: stage,
          count: count,
          fraction: total == 0 ? 0 : count / total,
        ),
      );
    }

    final locationCounts = <String, int>{};
    for (final p in people) {
      if (p.location.isNotEmpty) {
        locationCounts[p.location] = (locationCounts[p.location] ?? 0) + 1;
      }
    }
    final sorted = locationCounts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    final topLocations = sorted
        .take(5)
        .map((e) => LocationStat(name: e.key, count: e.value))
        .toList();

    return OverviewStats(
      total: total,
      birthdaysThisMonth: birthdaysThisMonth,
      stageStats: stageStats,
      topLocations: topLocations,
    );
  }
}

class StageStat {
  final LifeStage stage;
  final int count;
  final double fraction;

  const StageStat({
    required this.stage,
    required this.count,
    required this.fraction,
  });
}

class LocationStat {
  final String name;
  final int count;

  const LocationStat({required this.name, required this.count});
}
