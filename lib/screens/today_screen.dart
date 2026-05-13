import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.controller,
    required this.onAddHabit,
  });

  final HabitController controller;
  final Future<void> Function([Habit? habit]) onAddHabit;

  @override
  Widget build(BuildContext context) {
    final today = controller.today;
    final habits = [
      ...controller.pendingHabitsForSelectedDate,
      ...controller.completedHabitsForSelectedDate,
    ];

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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_greeting()}',
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const _WeatherRow(),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openCalendar(context, controller),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.86),
                      foregroundColor: AppColors.navy,
                      fixedSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.calendar_month_rounded, size: 22),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => onAddHabit(),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 24),
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
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
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
              width: 72,
              height: 72,
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
              child: const Text('Add Habit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherRow extends StatelessWidget {
  const _WeatherRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE7A8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.wb_sunny_rounded,
            color: Color(0xFFF39A22),
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '22°C  •  Sunny and soft',
          style: TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
                onPressed: _canShowNextMonth()
                    ? () => setState(() {
                          _visibleMonth = DateTime(
                            _visibleMonth.year,
                            _visibleMonth.month + 1,
                          );
                        })
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Blue means all habits done. Soft red means not completed.',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalSlots,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leadingEmpty + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date =
                  DateTime(_visibleMonth.year, _visibleMonth.month, dayNumber);
              final status = widget.controller.calendarStatusOn(date);
              final isToday = _isSameDay(date, widget.controller.today);

              return Container(
                decoration: BoxDecoration(
                  color: _calendarCellColor(status),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isToday ? AppColors.ink : _calendarBorderColor(status),
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
          const SizedBox(height: 16),
          const Row(
            children: [
              _LegendDot(color: AppColors.accent, label: 'Done'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFFFD8DE), label: 'Not done'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFF1EDF6), label: 'No habits'),
            ],
          ),
        ],
      ),
    );
  }

  bool _canShowNextMonth() {
    final today = widget.controller.today;
    return _visibleMonth.year < today.year || _visibleMonth.month < today.month;
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
      return AppColors.accentSoft;
    case CalendarDayStatus.missed:
      return const Color(0xFFFFE2E6);
    case CalendarDayStatus.future:
      return const Color(0xFFF7F4FB);
    case CalendarDayStatus.noHabits:
      return const Color(0xFFF1EDF6);
  }
}

Color _calendarBorderColor(CalendarDayStatus status) {
  switch (status) {
    case CalendarDayStatus.done:
      return AppColors.accent.withValues(alpha: 0.45);
    case CalendarDayStatus.missed:
      return const Color(0xFFF3B5BF);
    case CalendarDayStatus.future:
      return const Color(0xFFE6E0EF);
    case CalendarDayStatus.noHabits:
      return const Color(0xFFE1D8EA);
  }
}

Color _calendarTextColor(CalendarDayStatus status) {
  switch (status) {
    case CalendarDayStatus.done:
      return AppColors.accent;
    case CalendarDayStatus.missed:
      return const Color(0xFFC15D72);
    case CalendarDayStatus.future:
      return const Color(0xFFA498B3);
    case CalendarDayStatus.noHabits:
      return AppColors.muted;
  }
}
