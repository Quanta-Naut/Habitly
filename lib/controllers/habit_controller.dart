import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/habit.dart';
import '../services/habit_repository.dart';
import '../services/notification_service.dart';

enum InsightsRange { overall, week, month }

enum HabitYearCellState { inactive, pending, completed, future }

enum CalendarDayStatus { noHabits, done, missed, future }

class InsightsSummary {
  const InsightsSummary({
    required this.completed,
    required this.remaining,
    required this.stalled,
    required this.score,
  });

  final int completed;
  final int remaining;
  final int stalled;
  final double score;
}

class HabitProgressSnapshot {
  const HabitProgressSnapshot({
    required this.habit,
    required this.completions,
    required this.totalDays,
    required this.streak,
    required this.last7Days,
  });

  final Habit habit;
  final int completions;
  final int totalDays;
  final int streak;
  final List<bool> last7Days;

  double get progress => totalDays == 0 ? 0 : completions / totalDays;
}

class MonthProgressSnapshot {
  const MonthProgressSnapshot({
    required this.monthStart,
    required this.completed,
    required this.total,
  });

  final DateTime monthStart;
  final int completed;
  final int total;

  double get progress => total == 0 ? 0 : completed / total;
}

class LifetimeHabitSnapshot {
  const LifetimeHabitSnapshot({
    required this.habit,
    required this.completedDays,
    required this.totalDays,
    required this.bestStreak,
  });

  final Habit habit;
  final int completedDays;
  final int totalDays;
  final int bestStreak;

  double get progress => totalDays == 0 ? 0 : completedDays / totalDays;
}

class MonthlyHabitSnapshot {
  const MonthlyHabitSnapshot({
    required this.habit,
    required this.completedDays,
    required this.totalDays,
    required this.last7Days,
  });

  final Habit habit;
  final int completedDays;
  final int totalDays;
  final List<bool> last7Days;

  double get progress => totalDays == 0 ? 0 : completedDays / totalDays;
}

class HeatmapDay {
  const HeatmapDay({
    required this.date,
    required this.completed,
    required this.total,
  });

  final DateTime date;
  final int completed;
  final int total;

  double get progress => total == 0 ? 0 : completed / total;
}

class HabitController extends ChangeNotifier {
  HabitController({
    HabitRepository? repository,
    NotificationService? notificationService,
  })  : _repository = repository ?? HabitRepository(),
        _notificationService =
            notificationService ?? NotificationService.instance;

  final HabitRepository _repository;
  final NotificationService _notificationService;

  final List<Habit> _habits = <Habit>[];
  final Map<String, List<String>> _completions = <String, List<String>>{};

  bool _isLoaded = false;
  DateTime _selectedDate = _dateOnly(DateTime.now());
  bool _homeHintDismissed = false;

  bool get isLoaded => _isLoaded;
  DateTime get selectedDate => _selectedDate;
  DateTime get today => _dateOnly(DateTime.now());
  DateTime get earliestEditableDate => today.subtract(const Duration(days: 2));
  List<Habit> get habits => List<Habit>.unmodifiable(_habits);
  bool get showHomeHint => !_homeHintDismissed;

  List<DateTime> get currentWeekDates {
    final start = today.subtract(Duration(days: today.weekday - 1));
    return List<DateTime>.generate(
      7,
      (index) => start.add(Duration(days: index)),
      growable: false,
    );
  }

  List<DateTime> get editableDates => List<DateTime>.generate(
        3,
        (index) => earliestEditableDate.add(Duration(days: index)),
        growable: false,
      );

  List<Habit> get pendingHabitsForSelectedDate => _habits
      .where((habit) => _habitIsActiveOn(habit, _selectedDate))
      .where((habit) => !isCompletedOn(habit.id, _selectedDate))
      .toList(growable: false);

  List<Habit> get completedHabitsForSelectedDate => _habits
      .where((habit) => _habitIsActiveOn(habit, _selectedDate))
      .where((habit) => isCompletedOn(habit.id, _selectedDate))
      .toList(growable: false);

  int get completedCountForSelectedDate =>
      completedHabitsForSelectedDate.length;

  double get completionRateForSelectedDate {
    if (_habits.isEmpty) {
      return 0;
    }
    return completedCountForSelectedDate / _habits.length;
  }

  int get totalCompletionCount =>
      _completions.values.fold<int>(0, (count, items) => count + items.length);

  int get bestStreak {
    if (_habits.isEmpty) {
      return 0;
    }
    return _habits.map((habit) => streakForHabit(habit.id)).fold<int>(0, max);
  }

  Future<void> initialize() async {
    final store = await _repository.load();
    _habits
      ..clear()
      ..addAll(store.habits);
    _completions
      ..clear()
      ..addAll(store.completions);
    _homeHintDismissed = await _repository.loadHomeHintDismissed();
    _selectedDate = _clampEditableDate(_selectedDate);
    _sortHabits();
    _isLoaded = true;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = _clampEditableDate(date);
    notifyListeners();
  }

  bool canEditDate(DateTime date) {
    final normalized = _dateOnly(date);
    return !normalized.isBefore(earliestEditableDate) &&
        !normalized.isAfter(today);
  }

  int editableDaysLeft(DateTime date) {
    final normalized = _dateOnly(date);
    final age = today.difference(normalized).inDays;
    final remaining = 2 - age;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> dismissHomeHint() async {
    if (_homeHintDismissed) {
      return;
    }
    _homeHintDismissed = true;
    await _repository.saveHomeHintDismissed(true);
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    final preparedHabit = await _prepareReminder(habit: habit);
    _habits.add(preparedHabit);
    _markHabitCompleted(preparedHabit.id, _habitStartDate(preparedHabit));
    _sortHabits();
    await _save();
    notifyListeners();
  }

  Future<void> updateHabit(Habit updated) async {
    final index = _habits.indexWhere((habit) => habit.id == updated.id);
    if (index == -1) {
      return;
    }

    final current = _habits[index];
    final preparedHabit =
        await _prepareReminder(habit: updated, previous: current);
    _habits[index] = preparedHabit;
    _sortHabits();
    await _save();
    notifyListeners();
  }

  Future<void> deleteHabit(String habitId) async {
    final existing = _habits.where((habit) => habit.id == habitId).firstOrNull;
    if (existing == null) {
      return;
    }

    if (existing.notificationId != null) {
      await _notificationService.cancelNotification(existing.notificationId!);
    }

    _habits.removeWhere((habit) => habit.id == habitId);
    for (final entry in _completions.entries.toList()) {
      entry.value.removeWhere((id) => id == habitId);
      if (entry.value.isEmpty) {
        _completions.remove(entry.key);
      }
    }

    await _save();
    notifyListeners();
  }

  Future<void> toggleCompletion(String habitId, {DateTime? date}) async {
    final targetDate = _dateOnly(date ?? _selectedDate);
    if (!canEditDate(targetDate)) {
      return;
    }

    final habit = _habits.where((item) => item.id == habitId).firstOrNull;
    if (habit == null || !_habitIsActiveOn(habit, targetDate)) {
      return;
    }

    final key = _dateKey(targetDate);
    final items = List<String>.from(_completions[key] ?? const <String>[]);

    if (items.contains(habitId)) {
      items.remove(habitId);
    } else {
      items.add(habitId);
    }

    if (items.isEmpty) {
      _completions.remove(key);
    } else {
      _completions[key] = items;
    }

    await _save();
    notifyListeners();
  }

  Future<void> clearSelectedDay() async {
    if (!canEditDate(_selectedDate)) {
      return;
    }
    _completions.remove(_dateKey(_selectedDate));
    await _save();
    notifyListeners();
  }

  Future<void> resetAllData() async {
    for (final habit in _habits) {
      if (habit.notificationId != null) {
        await _notificationService.cancelNotification(habit.notificationId!);
      }
    }

    _habits.clear();
    _completions.clear();
    await _repository.clear();
    notifyListeners();
  }

  bool isCompletedOn(String habitId, DateTime date) {
    final key = _dateKey(_dateOnly(date));
    return _completions[key]?.contains(habitId) ?? false;
  }

  int streakForHabit(String habitId) {
    var streak = 0;
    var cursor = _dateOnly(DateTime.now());

    while (isCompletedOn(habitId, cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  List<bool> last7DaysForHabit(String habitId) {
    final start = today.subtract(const Duration(days: 6));
    return List<bool>.generate(7, (index) {
      final date = start.add(Duration(days: index));
      return isCompletedOn(habitId, date);
    }, growable: false);
  }

  List<HabitYearCellState> buildYearGridForHabit(Habit habit) {
    final yearStart = DateTime(today.year, 1, 1);
    final habitStart = _habitStartDate(habit);

    return List<HabitYearCellState>.generate(365, (index) {
      final date = yearStart.add(Duration(days: index));

      if (date.isBefore(habitStart)) {
        return HabitYearCellState.inactive;
      }
      if (date.isAfter(today)) {
        return HabitYearCellState.future;
      }
      if (isCompletedOn(habit.id, date)) {
        return HabitYearCellState.completed;
      }
      return HabitYearCellState.pending;
    }, growable: false);
  }

  int completedHabitsOn(DateTime date) {
    final normalized = _dateOnly(date);
    final activeIds =
        _activeHabitsOnDate(normalized).map((habit) => habit.id).toSet();
    final completedIds = _completions[_dateKey(normalized)] ?? const <String>[];
    return completedIds.where(activeIds.contains).length;
  }

  CalendarDayStatus calendarStatusOn(DateTime date) {
    final normalized = _dateOnly(date);
    if (normalized.isAfter(today)) {
      return CalendarDayStatus.future;
    }

    final activeCount = _activeHabitsOnDate(normalized).length;
    if (activeCount == 0) {
      return CalendarDayStatus.noHabits;
    }

    return completedHabitsOn(normalized) == activeCount
        ? CalendarDayStatus.done
        : CalendarDayStatus.missed;
  }

  InsightsSummary buildInsightsSummary(InsightsRange range) {
    if (_habits.isEmpty) {
      return const InsightsSummary(
        completed: 0,
        remaining: 0,
        stalled: 0,
        score: 0,
      );
    }

    final dates = _datesForRange(range);
    final totalSlots = _countTotalSlots(dates);
    final completed = _countCompletedSlots(dates);
    final stalled = _habits
        .where((habit) => _activeCountForHabit(habit, dates) > 0)
        .where((habit) => _completedCountForHabit(habit.id, dates) == 0)
        .length;
    final remaining = max(0, totalSlots - completed);

    return InsightsSummary(
      completed: completed,
      remaining: remaining,
      stalled: stalled,
      score: totalSlots == 0 ? 0 : completed / totalSlots,
    );
  }

  List<HabitProgressSnapshot> buildProgressSnapshots(InsightsRange range) {
    final dates = _datesForRange(range);

    final snapshots = _habits
        .map((habit) {
          final activeDays = _activeCountForHabit(habit, dates);
          return HabitProgressSnapshot(
            habit: habit,
            completions: _completedCountForHabit(habit.id, dates),
            totalDays: activeDays,
            streak: streakForHabit(habit.id),
            last7Days: last7DaysForHabit(habit.id),
          );
        })
        .where((snapshot) => snapshot.totalDays > 0)
        .toList();

    snapshots.sort((left, right) {
      final byCompletion = right.completions.compareTo(left.completions);
      if (byCompletion != 0) {
        return byCompletion;
      }

      final byStreak = right.streak.compareTo(left.streak);
      if (byStreak != 0) {
        return byStreak;
      }

      return left.habit.title.compareTo(right.habit.title);
    });

    return snapshots;
  }

  List<MonthProgressSnapshot> buildMonthlyProgress({int monthCount = 6}) {
    final currentMonth = _monthStart(today);

    return List<MonthProgressSnapshot>.generate(monthCount, (index) {
      final monthStart = _addMonths(currentMonth, index - monthCount + 1);
      final monthEnd = _monthEnd(monthStart);
      final visibleEnd = monthEnd.isAfter(today) ? today : monthEnd;
      final dates = _datesBetween(monthStart, visibleEnd);

      return MonthProgressSnapshot(
        monthStart: monthStart,
        completed: _countCompletedSlots(dates),
        total: _countTotalSlots(dates),
      );
    }, growable: false);
  }

  List<HeatmapDay> buildMonthlyHeatmap() {
    final start = _monthStart(today);
    final end = _monthEnd(today);
    final daysInMonth = end.difference(start).inDays + 1;

    return List<HeatmapDay>.generate(daysInMonth, (index) {
      final date = start.add(Duration(days: index));
      final total = _activeHabitsOnDate(date).length;
      final completed = _completions[_dateKey(date)]?.length ?? 0;
      return HeatmapDay(date: date, completed: completed, total: total);
    }, growable: false);
  }

  List<LifetimeHabitSnapshot> buildLifetimeHabitSnapshots() {
    final snapshots = _habits.map((habit) {
      final dates = _datesBetween(_habitStartDate(habit), today);
      return LifetimeHabitSnapshot(
        habit: habit,
        completedDays: _completedCountForHabit(habit.id, dates),
        totalDays: dates.length,
        bestStreak: bestStreakForHabit(habit.id),
      );
    }).toList();

    snapshots.sort((left, right) {
      final byCompleted = right.completedDays.compareTo(left.completedDays);
      if (byCompleted != 0) {
        return byCompleted;
      }
      return right.bestStreak.compareTo(left.bestStreak);
    });

    return snapshots;
  }

  List<MonthlyHabitSnapshot> buildMonthlyHabitSnapshots() {
    final start = _monthStart(today);
    final end = today;
    final dates = _datesBetween(start, end);

    final snapshots = _habits
        .map((habit) {
          return MonthlyHabitSnapshot(
            habit: habit,
            completedDays: _completedCountForHabit(habit.id, dates),
            totalDays: _activeCountForHabit(habit, dates),
            last7Days: last7DaysForHabit(habit.id),
          );
        })
        .where((snapshot) => snapshot.totalDays > 0)
        .toList();

    snapshots.sort((left, right) {
      final byCompleted = right.completedDays.compareTo(left.completedDays);
      if (byCompleted != 0) {
        return byCompleted;
      }
      return left.habit.title.compareTo(right.habit.title);
    });

    return snapshots;
  }

  int bestStreakForHabit(String habitId) {
    final dates = _completions.keys
        .map(_parseDateKey)
        .whereType<DateTime>()
        .toList()
      ..sort();

    var best = 0;
    var current = 0;
    DateTime? previous;

    for (final date in dates) {
      if (!isCompletedOn(habitId, date)) {
        continue;
      }

      if (previous != null && date.difference(previous).inDays == 1) {
        current += 1;
      } else {
        current = 1;
      }

      if (current > best) {
        best = current;
      }
      previous = date;
    }

    return best;
  }

  int totalActiveHabitsOn(DateTime date) =>
      _activeHabitsOnDate(_dateOnly(date)).length;

  Future<Habit> _prepareReminder({
    required Habit habit,
    Habit? previous,
  }) async {
    if (previous?.notificationId != null &&
        (habit.reminderHour == null || habit.reminderMinute == null)) {
      await _notificationService.cancelNotification(previous!.notificationId!);
      return habit.copyWith(clearNotification: true);
    }

    if (habit.reminderHour == null || habit.reminderMinute == null) {
      return habit.copyWith(clearNotification: true);
    }

    final currentNotificationId = previous?.notificationId ??
        habit.notificationId ??
        _nextNotificationId();

    if (previous?.notificationId != null) {
      await _notificationService.cancelNotification(previous!.notificationId!);
    }

    await _notificationService.scheduleDailyNotification(
      id: currentNotificationId,
      hour: habit.reminderHour!,
      minute: habit.reminderMinute!,
      title: 'Habit reminder',
      body: habit.title,
    );

    return habit.copyWith(notificationId: currentNotificationId);
  }

  void _markHabitCompleted(String habitId, DateTime date) {
    final targetDate = _dateOnly(date);
    final key = _dateKey(targetDate);
    final items = List<String>.from(_completions[key] ?? const <String>[]);

    if (!items.contains(habitId)) {
      items.add(habitId);
      _completions[key] = items;
    }
  }

  int _countCompletedSlots(List<DateTime> dates) {
    var count = 0;
    for (final date in dates) {
      final activeIds =
          _activeHabitsOnDate(date).map((habit) => habit.id).toSet();
      final completedIds = _completions[_dateKey(date)] ?? const <String>[];
      count += completedIds.where(activeIds.contains).length;
    }
    return count;
  }

  int _countTotalSlots(List<DateTime> dates) {
    var count = 0;
    for (final date in dates) {
      count += _activeHabitsOnDate(date).length;
    }
    return count;
  }

  int _completedCountForHabit(String habitId, List<DateTime> dates) {
    var count = 0;
    for (final date in dates) {
      final habit = _habits.where((item) => item.id == habitId).firstOrNull;
      if (habit != null &&
          _habitIsActiveOn(habit, date) &&
          isCompletedOn(habitId, date)) {
        count += 1;
      }
    }
    return count;
  }

  int _activeCountForHabit(Habit habit, List<DateTime> dates) {
    var count = 0;
    for (final date in dates) {
      if (_habitIsActiveOn(habit, date)) {
        count += 1;
      }
    }
    return count;
  }

  List<DateTime> _datesForRange(InsightsRange range) {
    final end = today;
    int totalDays;
    switch (range) {
      case InsightsRange.overall:
        totalDays = 90;
        break;
      case InsightsRange.week:
        totalDays = 7;
        break;
      case InsightsRange.month:
        totalDays = 30;
        break;
    }

    return List<DateTime>.generate(
      totalDays,
      (index) => end.subtract(Duration(days: totalDays - index - 1)),
      growable: false,
    );
  }

  List<Habit> _activeHabitsOnDate(DateTime date) {
    return _habits
        .where((habit) => _habitIsActiveOn(habit, date))
        .toList(growable: false);
  }

  bool _habitIsActiveOn(Habit habit, DateTime date) {
    return !date.isBefore(_habitStartDate(habit));
  }

  DateTime _habitStartDate(Habit habit) {
    final createdAt = DateTime.tryParse(habit.createdAt);
    if (createdAt == null) {
      return today;
    }
    return _dateOnly(createdAt);
  }

  DateTime _clampEditableDate(DateTime date) {
    final normalized = _dateOnly(date);
    if (normalized.isBefore(earliestEditableDate)) {
      return earliestEditableDate;
    }
    if (normalized.isAfter(today)) {
      return today;
    }
    return normalized;
  }

  Future<void> _save() {
    return _repository.save(habits: _habits, completions: _completions);
  }

  void _sortHabits() {
    _habits.sort((left, right) {
      final reminderLeft = left.reminderHour ?? 99;
      final reminderRight = right.reminderHour ?? 99;
      final compareReminder = reminderLeft.compareTo(reminderRight);
      if (compareReminder != 0) {
        return compareReminder;
      }
      return left.title.toLowerCase().compareTo(right.title.toLowerCase());
    });
  }

  int _nextNotificationId() {
    return DateTime.now().microsecondsSinceEpoch.remainder(1 << 31);
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _monthStart(DateTime date) => DateTime(date.year, date.month);

DateTime _monthEnd(DateTime date) => DateTime(date.year, date.month + 1, 0);

DateTime _addMonths(DateTime date, int months) {
  final rawMonth = date.month + months;
  final year = date.year + ((rawMonth - 1) ~/ 12);
  final month = ((rawMonth - 1) % 12) + 1;
  return DateTime(year, month);
}

List<DateTime> _datesBetween(DateTime start, DateTime end) {
  if (end.isBefore(start)) {
    return const <DateTime>[];
  }

  final dayCount = end.difference(start).inDays + 1;
  return List<DateTime>.generate(
    dayCount,
    (index) => start.add(Duration(days: index)),
    growable: false,
  );
}

DateTime? _parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) {
    return null;
  }

  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return null;
  }

  return DateTime(year, month, day);
}

String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
