/// Injectable "today" abstraction. Date-only, local time.
///
/// Defaults to the system clock; tests can inject a fixed [now] so all
/// date-derived logic (ages, countdowns, "turns N", ordering, birthdays this
/// month) is deterministic.
class Clock {
  final DateTime Function() _now;

  Clock([DateTime Function()? now]) : _now = now ?? _systemNow;

  /// The current local date with time-of-day zeroed out.
  DateTime get today {
    final n = _now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime _systemNow() => DateTime.now();
}
