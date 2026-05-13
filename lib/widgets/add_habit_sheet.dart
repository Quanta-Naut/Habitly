import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

class AddHabitSheet extends StatefulWidget {
  const AddHabitSheet({
    super.key,
    this.initialHabit,
    required this.onSave,
  });

  final Habit? initialHabit;
  final Future<void> Function(Habit habit) onSave;

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  static const _colors = <Color>[
    AppColors.blue,
    AppColors.orange,
    AppColors.purple,
    Color(0xFFFF6B86),
    AppColors.green,
    Color(0xFFEF6C8F),
  ];

  static const _icons = <IconData>[
    Icons.directions_run_rounded,
    Icons.sports_tennis_rounded,
    Icons.hotel_rounded,
    Icons.menu_book_rounded,
    Icons.water_drop_rounded,
    Icons.self_improvement_rounded,
    Icons.fitness_center_rounded,
    Icons.lunch_dining_rounded,
    Icons.music_note_rounded,
    Icons.code_rounded,
    Icons.nightlight_round,
    Icons.local_florist_rounded,
  ];

  late final TextEditingController _titleController;
  late Color _selectedColor;
  late IconData _selectedIcon;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final habit = widget.initialHabit;
    _titleController = TextEditingController(text: habit?.title ?? '');
    _selectedColor = habit?.color ?? AppColors.blue;
    _selectedIcon = habit?.icon ?? Icons.directions_run_rounded;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCFBFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialHabit == null ? 'Add Habit' : 'Edit Habit',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: 'Habit name'),
              ),
              const SizedBox(height: 20),
              const _SectionTitle('Choose Icon'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _icons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  final selected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: _ChoiceTile(
                      selected: selected,
                      activeColor: _selectedColor,
                      child: Icon(
                        icon,
                        color: selected ? Colors.white : AppColors.ink,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const _SectionTitle('Choose Color'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  final selected =
                      color.toARGB32() == _selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.28),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: ThemeController.instance.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    _isSaving
                        ? 'Saving...'
                        : widget.initialHabit == null
                            ? 'Add Habit'
                            : 'Save Changes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    final existing = widget.initialHabit;
    final habit = Habit(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      colorValue: _selectedColor.toARGB32(),
      iconCodePoint: _selectedIcon.codePoint,
      frequencyLabel: existing?.frequencyLabel ?? 'Every day',
      createdAt: existing?.createdAt ?? DateTime.now().toIso8601String(),
      reminderHour: existing?.reminderHour,
      reminderMinute: existing?.reminderMinute,
      notificationId: existing?.notificationId,
    );

    await widget.onSave(habit);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.selected,
    required this.child,
    required this.activeColor,
  });

  final bool selected;
  final Widget child;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: selected ? activeColor : const Color(0xFFF1F2FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? activeColor : AppColors.border,
        ),
      ),
      child: Center(child: child),
    );
  }
}
