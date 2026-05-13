import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/habit_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.controller,
    required this.onAddHabit,
    required this.onDeleteHabit,
  });

  final HabitController controller;
  final Future<void> Function([Habit? habit]) onAddHabit;
  final Future<void> Function(Habit habit) onDeleteHabit;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final today = controller.today;
        final habits = [
          ...controller.pendingHabitsForSelectedDate,
          ...controller.completedHabitsForSelectedDate,
        ];
        final completedCount = controller.completedCountForSelectedDate;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFCFBFF), Color(0xFFF4F2FB)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good ${_greeting()}',
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completedCount completed out of ${habits.length}',
                              style: TextStyle(
                                color: ThemeController.instance.accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _HeaderActionButton(
                            icon: Icons.edit_rounded,
                            onTap: () => _openEditHabitPicker(
                              context,
                              habits,
                              onAddHabit,
                              onDeleteHabit,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _HeaderActionButton(
                            icon: Icons.calendar_month_rounded,
                            onTap: () => _openCalendar(context, controller),
                          ),
                          const SizedBox(width: 10),
                          _HeaderActionButton(
                            icon: Icons.add_rounded,
                            onTap: () => onAddHabit(),
                            filled: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: habits.isEmpty
                      ? _EmptyState(onAddHabit: () => onAddHabit())
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: habits.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            return HabitCard(
                              habit: habit,
                              subtitle: _subtitle(habit),
                              isCompleted:
                                  controller.isCompletedOn(habit.id, today),
                              yearGrid: controller.buildYearGridForHabit(habit),
                              onToggle: () => controller.toggleCompletion(
                                habit.id,
                                date: today,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddHabit});

  final VoidCallback onAddHabit;

  @override
  Widget build(BuildContext context) {
    final accentColor = ThemeController.instance.accentColor;
    final accentSoft = Color.lerp(accentColor, Colors.white, 0.82)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                color: accentColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No habits yet',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first habit from the top right and track it with a single tap.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAddHabit,
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Habit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final accentColor = ThemeController.instance.accentColor;

    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor:
            filled ? accentColor : Colors.white.withValues(alpha: 0.86),
        foregroundColor: filled ? Colors.white : accentColor,
        fixedSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: accentColor),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icon, size: icon == Icons.add_rounded ? 24 : 20),
    );
  }
}

String _subtitle(Habit habit) {
  return habit.reminderLabel ?? habit.frequencyLabel;
}

Future<void> _openCalendar(
  BuildContext context,
  HabitController controller,
) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CalendarSheet(controller: controller),
  );
}

Future<void> _openEditHabitPicker(
  BuildContext context,
  List<Habit> habits,
  Future<void> Function([Habit? habit]) onEditHabit,
  Future<void> Function(Habit habit) onDeleteHabit,
) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFCFBFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Edit Habit',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _openAccentPicker(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: ThemeController.instance.accentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color:
                              ThemeController.instance.accentColor.withValues(
                            alpha: 0.28,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              habits.isEmpty
                  ? 'Add a habit first to edit it.'
                  : 'Choose a habit to edit.',
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (habits.isNotEmpty) ...[
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: habits.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.of(context).pop();
                          onEditHabit(habit);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final navigator = Navigator.of(context);
                                  final approved = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Delete habit?'),
                                        content: Text(
                                          'Remove "${habit.title}" and all of its saved check-ins?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(true),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: ThemeController
                                                  .instance.accentColor,
                                              side: BorderSide(
                                                color: ThemeController
                                                    .instance.accentColor,
                                              ),
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (approved == true) {
                                    navigator.pop();
                                    await onDeleteHabit(habit);
                                  }
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFEEF0),
                                  foregroundColor: const Color(0xFFD14B63),
                                  fixedSize: const Size(40, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: habit.color.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  habit.icon,
                                  color: AppColors.ink,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habit.title,
                                      style: const TextStyle(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      habit.reminderLabel ??
                                          habit.frequencyLabel,
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.muted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

Future<void> _openAccentPicker(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFCFBFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accent Color',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose a color for the app accent.',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ThemeController.presetColors.map((color) {
                final selected =
                    ThemeController.instance.accentColor.toARGB32() ==
                        color.toARGB32();
                return GestureDetector(
                  onTap: () async {
                    await ThemeController.instance.setAccentColor(color);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.ink : Colors.white,
                        width: selected ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.24),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    },
  );
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

class _CalendarSheet extends StatefulWidget {
  const _CalendarSheet({required this.controller});

  final HabitController controller;

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final today = widget.controller.today;
    _visibleMonth = DateTime(today.year, today.month);
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday - 1;
    final totalSlots = ((leadingEmpty + daysInMonth + 6) ~/ 7) * 7;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFCFBFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Habit Calendar',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month - 1,
                  );
                }),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Text(
                _monthLabel(_visibleMonth),
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month + 1,
                  );
                }),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              _WeekdayLabel('Mon'),
              _WeekdayLabel('Tue'),
              _WeekdayLabel('Wed'),
              _WeekdayLabel('Thu'),
              _WeekdayLabel('Fri'),
              _WeekdayLabel('Sat'),
              _WeekdayLabel('Sun'),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const rowCount = 6;
              const spacing = 8.0;
              final cellSize = (constraints.maxWidth - (spacing * 6)) / 7;
              final gridHeight =
                  (cellSize * rowCount) + (spacing * (rowCount - 1));

              return SizedBox(
                height: gridHeight,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalSlots,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final dayNumber = index - leadingEmpty + 1;
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox.shrink();
                    }

                    final date = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month,
                      dayNumber,
                    );
                    final status = widget.controller.calendarStatusOn(date);
                    final isToday = _isSameDay(date, widget.controller.today);

                    return Container(
                      decoration: BoxDecoration(
                        color: _calendarCellColor(status),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isToday
                              ? AppColors.ink
                              : _calendarBorderColor(status),
                          width: isToday ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            color: _calendarTextColor(status),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _monthLabel(DateTime month) {
  const labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${labels[month.month - 1]} ${month.year}';
}

Color _calendarCellColor(CalendarDayStatus status) {
  switch (status) {
    case CalendarDayStatus.done:
      return AppColors.currentAccent;
    case CalendarDayStatus.missed:
      return const Color(0xFFFF7B7B);
    case CalendarDayStatus.future:
      return const Color(0xFFF7F4FB);
    case CalendarDayStatus.noHabits:
      return const Color(0xFFF1EDF6);
  }
}

Color _calendarBorderColor(CalendarDayStatus status) {
  switch (status) {
    case CalendarDayStatus.done:
      return AppColors.currentAccent;
    case CalendarDayStatus.missed:
      return const Color(0xFFFF7B7B);
    case CalendarDayStatus.future:
      return const Color(0xFFE6E0EF);
    case CalendarDayStatus.noHabits:
      return const Color(0xFFE1D8EA);
  }
}

Color _calendarTextColor(CalendarDayStatus status) {
  switch (status) {
    case CalendarDayStatus.done:
      return Colors.white;
    case CalendarDayStatus.missed:
      return Colors.white;
    case CalendarDayStatus.future:
      return const Color(0xFFA498B3);
    case CalendarDayStatus.noHabits:
      return AppColors.muted;
  }
}
