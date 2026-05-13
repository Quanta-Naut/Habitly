import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HabitRingChart extends StatelessWidget {
  const HabitRingChart({
    super.key,
    required this.completed,
    required this.remaining,
    required this.stalled,
    required this.score,
  });

  final int completed;
  final int remaining;
  final int stalled;
  final double score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(140),
            painter: _RingPainter(
              completed: completed,
              remaining: remaining,
              stalled: stalled,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Habit Score',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 2),
              Text(
                '${(score * 100).round()}%',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.completed,
    required this.remaining,
    required this.stalled,
  });

  final int completed;
  final int remaining;
  final int stalled;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 16.0;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final total = max(1, completed + remaining + stalled);
    const gap = 0.10;
    var start = -pi / 2;

    final segments = [
      _Segment(color: AppColors.accent, value: completed / total),
      _Segment(color: const Color(0xFFFFD466), value: remaining / total),
      _Segment(color: AppColors.navy, value: stalled / total),
    ];

    final background = Paint()
      ..color = const Color(0xFFEBE9EF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * pi, false, background);

    for (final segment in segments) {
      if (segment.value <= 0) {
        continue;
      }

      final sweep = max(0.12, (2 * pi * segment.value) - gap);
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return completed != oldDelegate.completed ||
        remaining != oldDelegate.remaining ||
        stalled != oldDelegate.stalled;
  }
}

class _Segment {
  const _Segment({required this.color, required this.value});

  final Color color;
  final double value;
}
