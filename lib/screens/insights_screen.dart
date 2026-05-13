import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_ring_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key, required this.controller});

  final HabitController controller;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  InsightsRange _range = InsightsRange.overall;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RangeTabs(
            range: _range,
            onChanged: (range) => setState(() => _range = range),
          ),
          const SizedBox(height: 26),
          if (_range == InsightsRange.overall)
            _OverallView(controller: widget.controller)
          else if (_range == InsightsRange.week)
            _WeekView(controller: widget.controller)
          else
            _MonthView(controller: widget.controller),
        ],
      ),
    );
  }
}

class _OverallView extends StatelessWidget {
  const _OverallView({required this.controller});

  final HabitController controller;

  @override
  Widget build(BuildContext context) {
    final months = controller.buildMonthlyProgress();
    final totalCompleted =
        months.fold<int>(0, (sum, item) => sum + item.completed);
    final totalSlots = months.fold<int>(0, (sum, item) => sum + item.total);
    final overallRate = totalSlots == 0 ? 0.0 : totalCompleted / totalSlots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navy, Color(0xFF353A57)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Month-wise progress across your active habits.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      label: 'Completion Rate',
                      value: '${(overallRate * 100).round()}%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HeroStat(
                      label: 'Active Habits',
                      value: '${controller.habits.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HeroStat(
                      label: 'Best Streak',
                      value: '${controller.bestStreak}d',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Month by Month',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        if (months.every((item) => item.total == 0))
          const _InsightsEmptyState(
            message:
                'Monthly progress will show up here once your habits start collecting check-ins.',
          )
        else
          ...months.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _monthLabel(item.monthStart),
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${item.completed}/${item.total == 0 ? 0 : item.total}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: item.progress,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFEFEDF3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(item.progress * 100).round()}% completion this month',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({required this.controller});

  final HabitController controller;

  @override
  Widget build(BuildContext context) {
    final summary = controller.buildInsightsSummary(InsightsRange.week);
    final progress = controller.buildProgressSnapshots(InsightsRange.week);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Week',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _LegendRow(
                      color: AppColors.accent,
                      label: 'Completed',
                      value: summary.completed,
                    ),
                    const SizedBox(height: 10),
                    _LegendRow(
                      color: const Color(0xFFFFD466),
                      label: 'Remaining',
                      value: summary.remaining,
                    ),
                    const SizedBox(height: 10),
                    _LegendRow(
                      color: AppColors.navy,
                      label: 'No check-ins',
                      value: summary.stalled,
                    ),
                  ],
                ),
              ),
              HabitRingChart(
                completed: summary.completed,
                remaining: summary.remaining,
                stalled: summary.stalled,
                score: summary.score,
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Weekly Habit Breakdown',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        if (progress.isEmpty)
          const _InsightsEmptyState(
            message:
                'Add habits to see how many days you completed them this week.',
          )
        else
          ...progress.map(
            (snapshot) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _WeeklyHabitCard(snapshot: snapshot),
            ),
          ),
      ],
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({required this.controller});

  final HabitController controller;

  @override
  Widget build(BuildContext context) {
    final heatmap = controller.buildMonthlyHeatmap();
    final bestDay = heatmap.fold<int>(
        0, (best, item) => item.completed > best ? item.completed : best);
    final activeDays = heatmap.where((item) => item.completed > 0).length;
    final totalCompleted =
        heatmap.fold<int>(0, (sum, item) => sum + item.completed);
    final totalSlots = heatmap.fold<int>(0, (sum, item) => sum + item.total);
    final rate = totalSlots == 0 ? 0.0 : totalCompleted / totalSlots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This Month',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'GitHub-style check-in intensity for the last 5 weeks.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Best Day',
                      value: '$bestDay',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Checked-in Days',
                      value: '$activeDays',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Completion',
                      value: '${(rate * 100).round()}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _HeatmapGrid(days: heatmap),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Less',
                      style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  SizedBox(width: 8),
                  _HeatmapLegend(),
                  SizedBox(width: 8),
                  Text('More',
                      style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RangeTabs extends StatelessWidget {
  const _RangeTabs({required this.range, required this.onChanged});

  final InsightsRange range;
  final ValueChanged<InsightsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <_RangeItem>[
      const _RangeItem(InsightsRange.overall, 'Overall'),
      const _RangeItem(InsightsRange.week, 'This Week'),
      const _RangeItem(InsightsRange.month, 'This Month'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: items.map((item) {
          final selected = item.range == range;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item.range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      selected ? const Color(0xFFF1EFF5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? AppColors.ink : AppColors.muted,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RangeItem {
  const _RangeItem(this.range, this.label);

  final InsightsRange range;
  final String label;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WeeklyHabitCard extends StatelessWidget {
  const _WeeklyHabitCard({required this.snapshot});

  final HabitProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: snapshot.habit.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(snapshot.habit.icon, color: snapshot.habit.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.habit.title,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${snapshot.completions}/${snapshot.totalDays} days completed',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F1F6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${(snapshot.progress * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: snapshot.progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFEFEDF3),
              valueColor: AlwaysStoppedAnimation<Color>(snapshot.habit.color),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekLabels.asMap().entries.map((entry) {
              final done = snapshot.last7Days[entry.key];
              return Column(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color:
                          done ? snapshot.habit.color : const Color(0xFFF1EFF5),
                      shape: BoxShape.circle,
                    ),
                    child: done
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 15)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.value,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2F6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.days});

  final List<HeatmapDay> days;

  @override
  Widget build(BuildContext context) {
    final weeks = <List<HeatmapDay>>[];
    for (var index = 0; index < days.length; index += 7) {
      weeks.add(days.sublist(index, index + 7));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weeks.map((week) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              children: week.map((day) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _heatColor(day.progress),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [0.0, 0.25, 0.5, 0.75, 1.0].map((value) {
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _heatColor(value),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

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
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsEmptyState extends StatelessWidget {
  const _InsightsEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.muted),
      ),
    );
  }
}

Color _heatColor(double progress) {
  if (progress <= 0) {
    return const Color(0xFFEEEAF1);
  }
  if (progress < 0.25) {
    return const Color(0xFFFFD6DF);
  }
  if (progress < 0.5) {
    return const Color(0xFFFFA7B9);
  }
  if (progress < 0.75) {
    return const Color(0xFFFF6B86);
  }
  return const Color(0xFFCC3F66);
}

String _monthLabel(DateTime date) {
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
  return '${months[date.month - 1]} ${date.year}';
}

const List<String> _weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
