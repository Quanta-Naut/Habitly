import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});

  final HabitController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'A quick summary of your consistency and cleanup tools.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _StatTile(
                label: 'Active habits', value: '${controller.habits.length}'),
            _StatTile(
              label: 'Done today',
              value: '${controller.completedCountForSelectedDate}',
            ),
            _StatTile(label: 'Best streak', value: '${controller.bestStreak}'),
            _StatTile(
              label: 'Total check-ins',
              value: '${controller.totalCompletionCount}',
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ActionCard(
          title: 'Clear selected day',
          subtitle: 'Remove all completions for the day currently in focus.',
          icon: Icons.event_busy_rounded,
          onTap: () => _confirmClearDay(context),
        ),
        const SizedBox(height: 14),
        _ActionCard(
          title: 'Reset all data',
          subtitle: 'Delete every habit, reminder, and completion history.',
          icon: Icons.delete_forever_rounded,
          danger: true,
          onTap: () => _confirmResetAll(context),
        ),
      ],
    );
  }

  Future<void> _confirmClearDay(BuildContext context) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear selected day?'),
          content:
              const Text('This removes all check-ins for the selected date.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (approved == true) {
      await controller.clearSelectedDay();
    }
  }

  Future<void> _confirmResetAll(BuildContext context) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset all data?'),
          content: const Text(
            'This action cannot be undone. All habits, reminders, and progress will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (approved == true) {
      await controller.resetAllData();
    }
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 54) / 2;

    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: danger
                      ? Colors.redAccent.withOpacity(0.1)
                      : AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: danger ? Colors.redAccent : AppColors.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: danger ? Colors.redAccent : AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
