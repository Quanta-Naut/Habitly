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
  bool _showBrandScreen = true;

  @override
  void initState() {
    super.initState();
    _controller = HabitController();
    _controller.initialize();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _showBrandScreen = false);
      }
    });
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
          body: _controller.isLoaded && !_showBrandScreen
              ? TodayScreen(
                  controller: _controller,
                  onAddHabit: _openHabitEditor,
                  onDeleteHabit: (habit) => _controller.deleteHabit(habit.id),
                )
              : DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFCFBFF), Color(0xFFF6F2FB)],
                    ),
                  ),
                  child: Center(
                    child: const Text(
                      'Habitly.',
                      style: TextStyle(
                        color: Color(0xFF392747),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
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
