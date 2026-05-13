import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.subtitle,
    required this.isCompleted,
    required this.yearGrid,
    required this.onToggle,
  });

  final Habit habit;
  final String subtitle;
  final bool isCompleted;
  final List<HabitYearCellState> yearGrid;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isCompleted
              ? habit.color.withValues(alpha: 0.5)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: habit.color.withValues(alpha: isCompleted ? 0.18 : 0.12),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  habit.icon,
                  color: AppColors.ink,
                  size: 22,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? habit.color
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCompleted ? habit.color : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: isCompleted ? Colors.white : habit.color,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _GridPanel(
            color: habit.color,
            yearGrid: yearGrid,
          ),
        ],
      ),
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
    const cellSize = 11.0;
    const spacing = 3.0;
    final yearGrid = widget.yearGrid;
    final color = widget.color;
    final columnCount = (yearGrid.length / rowCount).ceil();
    final todayIndex = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays
        .clamp(0, yearGrid.length - 1);
    final todayColumn = todayIndex ~/ rowCount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.lerp(color, Colors.white, 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final step = cellSize + spacing;
          final contentWidth =
              (columnCount * cellSize) + ((columnCount - 1) * spacing);
          final maxScrollExtent =
              (contentWidth - constraints.maxWidth).clamp(0.0, double.infinity);
          final desiredOffset =
              (todayColumn * step - (constraints.maxWidth * 0.6))
                  .clamp(0.0, maxScrollExtent);

          if (_lastAppliedOffset != desiredOffset) {
            _lastAppliedOffset = desiredOffset;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_scrollController.hasClients) {
                return;
              }
              _scrollController.jumpTo(desiredOffset);
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
                      final index = column * rowCount + row;
                      final state = index < yearGrid.length
                          ? yearGrid[index]
                          : HabitYearCellState.inactive;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: row == rowCount - 1 ? 0 : spacing,
                        ),
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: _cellDecoration(
                            state: state,
                            color: color,
                            isToday: index == todayIndex,
                            isPlaceholder: index >= yearGrid.length,
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

  BoxDecoration _cellDecoration({
    required HabitYearCellState state,
    required Color color,
    required bool isToday,
    required bool isPlaceholder,
  }) {
    if (isPlaceholder) {
      return BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      );
    }

    final fillColor = _cellColor(state, color);
    final borderColor = switch (state) {
      HabitYearCellState.completed => color.withValues(alpha: 0.9),
      HabitYearCellState.pending => color.withValues(alpha: 0.24),
      HabitYearCellState.future => AppColors.border,
      HabitYearCellState.inactive => AppColors.border.withValues(alpha: 0.6),
    };

    return BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: isToday ? AppColors.ink : borderColor,
        width: isToday ? 1.4 : 0.8,
      ),
    );
  }

  Color _cellColor(HabitYearCellState state, Color color) {
    switch (state) {
      case HabitYearCellState.completed:
        return color;
      case HabitYearCellState.pending:
        return Colors.white;
      case HabitYearCellState.future:
        return const Color(0xFFF4E9F0);
      case HabitYearCellState.inactive:
        return const Color(0xFFEEE2EA);
    }
  }
}
