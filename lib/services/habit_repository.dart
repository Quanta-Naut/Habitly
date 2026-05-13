import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class HabitRepository {
  static const String _habitsKey = 'habits';
  static const String _completionsKey = 'completions';
  static const String _homeHintDismissedKey = 'home_hint_dismissed';

  Future<HabitStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawHabits = prefs.getString(_habitsKey);
    final rawCompletions = prefs.getString(_completionsKey);

    final habits = rawHabits == null
        ? <Habit>[]
        : (jsonDecode(rawHabits) as List<dynamic>)
            .whereType<Map>()
            .map((item) => Habit.fromJson(Map<String, dynamic>.from(item)))
            .toList();

    final completions = <String, List<String>>{};
    if (rawCompletions != null) {
      final decoded = jsonDecode(rawCompletions) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        completions[entry.key] =
            List<String>.from(entry.value as List<dynamic>);
      }
    }

    return HabitStore(habits: habits, completions: completions);
  }

  Future<void> save({
    required List<Habit> habits,
    required Map<String, List<String>> completions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _habitsKey,
      jsonEncode(habits.map((habit) => habit.toJson()).toList()),
    );
    await prefs.setString(_completionsKey, jsonEncode(completions));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_habitsKey);
    await prefs.remove(_completionsKey);
    await prefs.remove(_homeHintDismissedKey);
  }

  Future<bool> loadHomeHintDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_homeHintDismissedKey) ?? false;
  }

  Future<void> saveHomeHintDismissed(bool dismissed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homeHintDismissedKey, dismissed);
  }
}

class HabitStore {
  const HabitStore({required this.habits, required this.completions});

  final List<Habit> habits;
  final Map<String, List<String>> completions;
}
