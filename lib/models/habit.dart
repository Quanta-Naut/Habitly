import 'package:flutter/material.dart';

class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.colorValue,
    required this.iconCodePoint,
    required this.frequencyLabel,
    required this.createdAt,
    this.reminderHour,
    this.reminderMinute,
    this.notificationId,
  });

  final String id;
  final String title;
  final int colorValue;
  final int iconCodePoint;
  final String frequencyLabel;
  final String createdAt;
  final int? reminderHour;
  final int? reminderMinute;
  final int? notificationId;

  Color get color => Color(colorValue);

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  bool get hasReminder => reminderHour != null && reminderMinute != null;

  String? get reminderLabel {
    if (!hasReminder) {
      return null;
    }

    final hour = reminderHour!;
    final minute = reminderMinute!;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
  }

  Habit copyWith({
    String? id,
    String? title,
    int? colorValue,
    int? iconCodePoint,
    String? frequencyLabel,
    String? createdAt,
    int? reminderHour,
    int? reminderMinute,
    int? notificationId,
    bool clearReminder = false,
    bool clearNotification = false,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      frequencyLabel: frequencyLabel ?? this.frequencyLabel,
      createdAt: createdAt ?? this.createdAt,
      reminderHour: clearReminder ? null : (reminderHour ?? this.reminderHour),
      reminderMinute:
          clearReminder ? null : (reminderMinute ?? this.reminderMinute),
      notificationId:
          clearNotification ? null : (notificationId ?? this.notificationId),
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
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'notificationId': notificationId,
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
      reminderHour: json['reminderHour'] as int?,
      reminderMinute: json['reminderMinute'] as int?,
      notificationId: json['notificationId'] as int?,
    );
  }
}
