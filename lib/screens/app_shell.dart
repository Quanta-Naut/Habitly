import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../widgets/add_habit_sheet.dart';
import 'today_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final HabitController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HabitController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          body: _controller.isLoaded
              ? TodayScreen(
                  controller: _controller,
                  onAddHabit: _openHabitEditor,
                  onDeleteHabit: (habit) => _controller.deleteHabit(habit.id),
                )
              : const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFF0A1020)),
                  child: Center(child: CircularProgressIndicator()),
                ),
        );
      },
    );
  }

  Future<void> _openHabitEditor([Habit? habit]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddHabitSheet(
          initialHabit: habit,
          onSave: (savedHabit) async {
            if (habit == null) {
              await _controller.addHabit(savedHabit);
            } else {
              await _controller.updateHabit(savedHabit);
            }
          },
        );
      },
    );
  }
}
