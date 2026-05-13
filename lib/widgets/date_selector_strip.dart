import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DateSelectorStrip extends StatelessWidget {
  const DateSelectorStrip({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.isEnabled,
    required this.onSelect,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final bool Function(DateTime date) isEnabled;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(date, selectedDate);
          final enabled = isEnabled(date);

          return GestureDetector(
            onTap: enabled ? () => onSelect(date) : null,
            child: Container(
              width: 68,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFB3D7), Color(0xFFCDB8FF)],
                      )
                    : null,
                color: isSelected
                    ? null
                    : enabled
                        ? Colors.white.withValues(alpha: 0.82)
                        : const Color(0xFFF9EEF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.45)
                      : enabled
                          ? AppColors.border
                          : const Color(0xFFF0D9E5),
                ),
                boxShadow: [
                  if (enabled)
                    BoxShadow(
                      color: (isSelected ? AppColors.accent : AppColors.navy)
                          .withValues(alpha: isSelected ? 0.18 : 0.06),
                      blurRadius: isSelected ? 20 : 16,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayLabel(date),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : enabled
                              ? AppColors.muted
                              : const Color(0xFFA7A3B4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : enabled
                              ? AppColors.ink
                              : const Color(0xFFA7A3B4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _weekdayLabel(DateTime date) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[date.weekday - 1];
}
