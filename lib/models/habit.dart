import 'package:flutter/material.dart';

class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.colorValue,
    required this.iconCodePoint,
    required this.frequencyLabel,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int colorValue;
  final int iconCodePoint;
  final String frequencyLabel;
  final String createdAt;

  Color get color => Color(colorValue);

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Habit copyWith({
    String? id,
    String? title,
    int? colorValue,
    int? iconCodePoint,
    String? frequencyLabel,
    String? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      frequencyLabel: frequencyLabel ?? this.frequencyLabel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'color': colorValue,
      'icon': iconCodePoint,
      'frequency': frequencyLabel,
      'createdAt': createdAt,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: (json['id'] ?? DateTime.now().microsecondsSinceEpoch.toString())
          .toString(),
      title: (json['title'] ?? 'Untitled Habit').toString(),
      colorValue: (json['color'] as int?) ?? 0xFF4B8CF7,
      iconCodePoint: (json['icon'] as int?) ??
          Icons.check_circle_outline_rounded.codePoint,
      frequencyLabel: (json['frequency'] ?? 'Every day').toString(),
      createdAt:
          (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}
