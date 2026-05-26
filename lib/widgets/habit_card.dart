import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.streakText,
    required this.isCompleted,
    required this.yearGrid,
    required this.onToggle,
    required this.onOpenDetails,
  });

  final Habit habit;
  final String streakText;
  final bool isCompleted;
  final List<HabitYearCellState> yearGrid;
  final VoidCallback onToggle;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenDetails,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: habit.color.withValues(alpha: isCompleted ? 0.38 : 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: habit.color.withValues(alpha: 0.14),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: habit.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(habit.icon, color: AppColors.ink, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          streakText,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CardActionButton(
                    color: habit.color,
                    onTap: onToggle,
                    filled: isCompleted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _GridPanel(
                color: habit.color,
                yearGrid: yearGrid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.color,
    required this.onTap,
    required this.filled,
  });

  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: filled ? color : color.withValues(alpha: 0.14),
        foregroundColor: filled ? Colors.white : AppColors.ink,
        fixedSize: const Size(42, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.check_rounded, size: 21),
    );
  }
}

class _GridPanel extends StatefulWidget {
  const _GridPanel({
    required this.color,
    required this.yearGrid,
  });

  final Color color;
  final List<HabitYearCellState> yearGrid;

  @override
  State<_GridPanel> createState() => _GridPanelState();
}

class _GridPanelState extends State<_GridPanel> {
  final ScrollController _scrollController = ScrollController();
  double? _lastAppliedOffset;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const rowCount = 7;
    final today = DateTime.now();
    final yearStart = DateTime(today.year, 1, 1);
    final calendarStart =
        yearStart.subtract(Duration(days: yearStart.weekday - 1));
    final visibleDayCount = today.difference(calendarStart).inDays + 1;
    final columnCount = (visibleDayCount / rowCount).ceil();

    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 5.0;
          const dotSize = 13.0;
          final contentWidth =
              (columnCount * dotSize) + ((columnCount - 1) * spacing);
          final maxScrollExtent =
              (contentWidth - constraints.maxWidth).clamp(0.0, double.infinity);

          if (_lastAppliedOffset != maxScrollExtent) {
            _lastAppliedOffset = maxScrollExtent;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_scrollController.hasClients) {
                return;
              }
              _scrollController.jumpTo(maxScrollExtent);
            });
          }

          return SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(columnCount, (column) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: column == columnCount - 1 ? 0 : spacing,
                  ),
                  child: Column(
                    children: List<Widget>.generate(rowCount, (row) {
                      final date = calendarStart.add(
                        Duration(days: (column * rowCount) + row),
                      );
                      final isVisibleDate =
                          !date.isBefore(yearStart) && !date.isAfter(today);
                      final isTodayDate = date.year == today.year &&
                          date.month == today.month &&
                          date.day == today.day;

                      final HabitYearCellState? state = isVisibleDate
                          ? widget.yearGrid[date.difference(yearStart).inDays]
                          : null;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: row == rowCount - 1 ? 0 : spacing,
                        ),
                        child: Container(
                          width: dotSize,
                          height: dotSize,
                          decoration: BoxDecoration(
                            color: _cellColor(state, widget.color),
                            borderRadius: BorderRadius.circular(4),
                            border: isTodayDate
                                ? Border.all(
                                    color: widget.color.withValues(alpha: 0.6),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Color _cellColor(HabitYearCellState? state, Color color) {
    if (state == null) {
      return Colors.transparent;
    }

    switch (state) {
      case HabitYearCellState.completed:
        return color;
      case HabitYearCellState.pending:
        return color.withValues(alpha: 0.2);
      case HabitYearCellState.future:
        return AppColors.border.withValues(alpha: 0.55);
      case HabitYearCellState.inactive:
        return color.withValues(alpha: 0.08);
    }
  }
}
