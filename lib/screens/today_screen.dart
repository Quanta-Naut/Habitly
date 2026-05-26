import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_card.dart';
import 'habit_detail_screen.dart';

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
    final habits = controller.activeHabitsForSelectedDate;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFCFBFF), Color(0xFFF6F2FB)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _todayLabel(controller.today),
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _TopActionButton(
                    icon: Icons.calendar_month_rounded,
                    onTap: () => _openCalendar(context, controller),
                    outlined: true,
                  ),
                  const SizedBox(width: 10),
                  _TopActionButton(
                    icon: Icons.add_rounded,
                    onTap: () => onAddHabit(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: controller.currentWeekDates.map((date) {
                  final isSelected = _isSameDate(date, controller.selectedDate);
                  final isToday = _isSameDate(date, controller.today);
                  final isEnabled = controller.canEditDate(date);
                  final totalHabits = controller.totalActiveHabitsOn(date);
                  final progress = totalHabits == 0
                      ? 0.0
                      : controller.completedHabitsOn(date) / totalHabits;

                  return Expanded(
                    child: _WeekDateTile(
                      date: date,
                      isSelected: isSelected,
                      isToday: isToday,
                      isEnabled: isEnabled,
                      progress: progress,
                      onTap:
                          isEnabled ? () => controller.selectDate(date) : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: habits.isEmpty
                  ? _EmptyState(onAddHabit: () => onAddHabit())
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: habits.length,
                      buildDefaultDragHandles: false,
                      onReorder: controller.reorderHabits,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        final streak = controller.streakForHabit(habit.id);
                        final isCompleted = controller.isCompletedOn(
                          habit.id,
                          controller.selectedDate,
                        );

                        return Padding(
                          key: ValueKey(habit.id),
                          padding: EdgeInsets.only(
                            bottom: index == habits.length - 1 ? 0 : 16,
                          ),
                          child: ReorderableDelayedDragStartListener(
                            index: index,
                            child: HabitCard(
                              habit: habit,
                              streakText:
                                  'Streak: $streak day${streak == 1 ? '' : 's'}',
                              isCompleted: isCompleted,
                              yearGrid: controller.buildYearGridForHabit(habit),
                              onToggle: () => controller.toggleCompletion(
                                habit.id,
                                date: controller.selectedDate,
                              ),
                              onOpenDetails: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => HabitDetailScreen(
                                      controller: controller,
                                      habit: habit,
                                      onEditHabit: onAddHabit,
                                      onDeleteHabit: onDeleteHabit,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor:
            outlined ? Colors.white.withValues(alpha: 0.94) : AppColors.accent,
        foregroundColor: outlined ? AppColors.ink : Colors.white,
        fixedSize: const Size(44, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: outlined ? const BorderSide(color: AppColors.border) : null,
      ),
      icon: Icon(icon, size: 22),
    );
  }
}

class _WeekDateTile extends StatelessWidget {
  const _WeekDateTile({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isEnabled,
    required this.progress,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isEnabled;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final circleColor = Colors.white.withValues(alpha: isEnabled ? 0.92 : 0.6);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isEnabled || isToday ? 1 : 0.58,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Text(
                _weekdayLabel(date),
                style: TextStyle(
                  color: isSelected ? AppColors.ink : AppColors.muted,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _DateProgressPainter(
                        progress: progress,
                        isToday: isToday,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: circleColor,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.14,
                                    ),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateProgressPainter extends CustomPainter {
  const _DateProgressPainter({
    required this.progress,
    required this.isToday,
  });

  final double progress;
  final bool isToday;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.0;
    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = AppColors.accent
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        -1.5708,
        6.28318 * progress.clamp(0.0, 1.0),
        false,
        progressPaint,
      );
    }

    if (isToday) {
      final todayPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.28)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius + 2.5, todayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DateProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isToday != isToday;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddHabit});

  final VoidCallback onAddHabit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: AppColors.accent,
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
            const Text(
              'Tap the plus button to add your first habit.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAddHabit,
              child: const Text('Add Habit'),
            ),
          ],
        ),
      ),
    );
  }
}

String _todayLabel(DateTime date) {
  return 'Today, ${date.day}${_ordinalSuffix(date.day)} ${_monthLabel(date.month)}';
}

String _weekdayLabel(DateTime date) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[date.weekday - 1];
}

String _monthLabel(int month) {
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
  return labels[month - 1];
}

String _monthYearLabel(DateTime date) {
  return '${_monthLabel(date.month)} ${date.year}';
}

String _ordinalSuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }

  return switch (day % 10) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
}

bool _isSameDate(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
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
    builder: (_) => _CalendarSheet(controller: controller),
  );
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
    final monthDates = List<DateTime>.generate(
      daysInMonth,
      (index) => DateTime(_visibleMonth.year, _visibleMonth.month, index + 1),
      growable: false,
    );
    final activeDays = monthDates
        .where((date) => widget.controller.totalActiveHabitsOn(date) > 0)
        .length;
    final fullyCompletedDays = monthDates.where((date) {
      final total = widget.controller.totalActiveHabitsOn(date);
      return total > 0 && widget.controller.completedHabitsOn(date) == total;
    }).length;

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
                  'Calendar',
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
                _monthYearLabel(_visibleMonth),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _CalendarStatCard(
                  value: '$fullyCompletedDays',
                  label: 'Days Completed',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CalendarStatCard(
                  value: '$activeDays',
                  label: 'Active Days',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              _WeekdayHeader('M'),
              _WeekdayHeader('T'),
              _WeekdayHeader('W'),
              _WeekdayHeader('T'),
              _WeekdayHeader('F'),
              _WeekdayHeader('S'),
              _WeekdayHeader('S'),
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
                    final totalHabits = widget.controller.totalActiveHabitsOn(
                      date,
                    );
                    final progress = totalHabits == 0
                        ? 0.0
                        : widget.controller.completedHabitsOn(date) /
                            totalHabits;
                    final isToday = _isSameDate(date, widget.controller.today);

                    return _CalendarDayCell(
                      day: dayNumber,
                      progress: progress,
                      isToday: isToday,
                      hasHabits: totalHabits > 0,
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

class _CalendarStatCard extends StatelessWidget {
  const _CalendarStatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader(this.label);

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

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.progress,
    required this.isToday,
    required this.hasHabits,
  });

  final int day;
  final double progress;
  final bool isToday;
  final bool hasHabits;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasHabits)
          CustomPaint(
            painter: _DateProgressPainter(
              progress: progress,
              isToday: isToday,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: hasHabits
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: hasHabits ? AppColors.ink : AppColors.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
