import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({
    super.key,
    required this.controller,
    required this.habit,
    required this.onEditHabit,
    required this.onDeleteHabit,
  });

  final HabitController controller;
  final Habit habit;
  final Future<void> Function([Habit? habit]) onEditHabit;
  final Future<void> Function(Habit habit) onDeleteHabit;

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        controller.isCompletedOn(habit.id, controller.selectedDate);
    final currentStreak = controller.streakForHabit(habit.id);
    final bestStreak = controller.bestStreakForHabit(habit.id);
    final yearGrid = controller.buildYearGridForHabit(habit);
    final totalDays = yearGrid
        .where(
          (state) =>
              state == HabitYearCellState.completed ||
              state == HabitYearCellState.pending,
        )
        .length;
    final completedDays = yearGrid
        .where(
          (state) => state == HabitYearCellState.completed,
        )
        .length;
    final score =
        totalDays == 0 ? 0 : ((completedDays / totalDays) * 100).round();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBF7FF), Color(0xFFF3EDF8)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CircleAction(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    _CircleAction(
                      icon: Icons.delete_outline_rounded,
                      onTap: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Delete habit?'),
                              content: Text(
                                'Do you want to delete "${habit.title}"?',
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
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete == true) {
                          await onDeleteHabit(habit);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    _CircleAction(
                      icon: Icons.edit_rounded,
                      onTap: () async {
                        await onEditHabit(habit);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 102,
                        height: 102,
                        decoration: BoxDecoration(
                          color: habit.color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(habit.icon, color: AppColors.ink, size: 42),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        habit.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? habit.color.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isCompleted
                                ? habit.color.withValues(alpha: 0.3)
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          isCompleted ? 'Completed' : 'Not Completed',
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: '$currentStreak',
                        label: 'Current Streak',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '$bestStreak',
                        label: 'Best Streak',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '$score%',
                        label: 'Score',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: _PrimaryActionButton(
                    icon: Icons.check_circle_outline_rounded,
                    label: isCompleted ? 'Undo' : 'Done',
                    onTap: () => controller.toggleCompletion(
                      habit.id,
                      date: controller.selectedDate,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Center(
                  child: Text(
                    _monthYearLabel(controller.today),
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _TimelineItem(
                  color: habit.color,
                  icon: habit.icon,
                  title: 'Task Started',
                  date: _timelineDateLabel(
                      DateTime.tryParse(habit.createdAt) ?? controller.today),
                ),
                const SizedBox(height: 14),
                _TimelineItem(
                  color: habit.color,
                  icon: isCompleted
                      ? Icons.check_rounded
                      : Icons.schedule_rounded,
                  title: isCompleted ? 'Completed for Today' : 'Pending Today',
                  date: _timelineDateLabel(controller.selectedDate),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.82),
        foregroundColor: AppColors.ink,
        fixedSize: const Size(44, 44),
        shape: const CircleBorder(),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.color,
    required this.icon,
    required this.title,
    required this.date,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.ink, size: 24),
            ),
            Container(
              width: 3,
              height: 72,
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.flag_outlined,
                  color: AppColors.muted,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _monthYearLabel(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

String _timelineDateLabel(DateTime date) {
  const months = [
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
  return '${date.day} ${months[date.month - 1]}';
}
