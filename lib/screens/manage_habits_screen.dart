import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class ManageHabitsScreen extends StatelessWidget {
  const ManageHabitsScreen({
    super.key,
    required this.controller,
    required this.onAddHabit,
    required this.onEditHabit,
  });

  final HabitController controller;
  final Future<void> Function([Habit? habit]) onAddHabit;
  final Future<void> Function(Habit habit) onEditHabit;

  @override
  Widget build(BuildContext context) {
    final reminderCount =
        controller.habits.where((habit) => habit.hasReminder).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navy, Color(0xFF343957)],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Habits',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Edit reminders, clean up routines, and keep your tracker sharp.',
                          style: TextStyle(color: Color(0xFFD4D8E8)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => onAddHabit(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      label: 'Active',
                      value: '${controller.habits.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HeroMetric(
                      label: 'Reminders',
                      value: '$reminderCount',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HeroMetric(
                      label: 'Best Streak',
                      value: '${controller.bestStreak}d',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_calendar_rounded,
                    color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quick check-off follows the same rule as Home: today plus the previous 2 days only.',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Your Routines',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        if (controller.habits.isEmpty)
          const _ManageEmptyState()
        else
          ...controller.habits.map(
            (habit) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ManageCard(
                habit: habit,
                isDone:
                    controller.isCompletedOn(habit.id, controller.selectedDate),
                streak: controller.streakForHabit(habit.id),
                onToggle: () => controller.toggleCompletion(
                  habit.id,
                  date: controller.selectedDate,
                ),
                onEdit: () => onEditHabit(habit),
                onDelete: () => _confirmDelete(context, habit),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Habit habit) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete habit?'),
          content:
              Text('Remove "${habit.title}" and all of its saved check-ins?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (approved == true) {
      await controller.deleteHabit(habit.id);
    }
  }
}

class _ManageCard extends StatelessWidget {
  const _ManageCard({
    required this.habit,
    required this.isDone,
    required this.streak,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Habit habit;
  final bool isDone;
  final int streak;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: habit.color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(26)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: habit.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(habit.icon, color: habit.color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            habit.reminderLabel == null
                                ? habit.frequencyLabel
                                : '${habit.frequencyLabel}  •  ${habit.reminderLabel}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoChip(label: '$streak day streak'),
                    const SizedBox(width: 10),
                    _InfoChip(
                        label:
                            habit.hasReminder ? 'Reminder on' : 'No reminder'),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1F6),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Day Status',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isDone ? 'Checked off' : 'Still pending',
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                          value: isDone, onChanged: (_) => onToggle()),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: const BorderSide(color: Color(0xFFE4E1E9)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isDone ? onToggle : onToggle,
                        icon: Icon(
                            isDone ? Icons.close_rounded : Icons.check_rounded),
                        label: Text(isDone ? 'Undo' : 'Check Off'),
                        style: FilledButton.styleFrom(
                          backgroundColor: habit.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD4D8E8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ManageEmptyState extends StatelessWidget {
  const _ManageEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Text(
        'No habits yet. Use the Add button above to create your first routine.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.muted, fontSize: 16),
      ),
    );
  }
}
