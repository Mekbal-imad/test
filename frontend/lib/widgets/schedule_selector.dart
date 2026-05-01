import 'package:flutter/material.dart';
import 'package:job_bit/models/time_range.dart';
import 'package:job_bit/theme/app_theme.dart';

/// ScheduleSelector allows users to select working days and set time ranges.
class ScheduleSelector extends StatelessWidget {
  final List<String> weekDays;
  final Map<String, TimeRange> selectedSchedule;
  final ValueChanged<String> onDayTap;

  const ScheduleSelector({
    super.key,
    required this.weekDays,
    required this.selectedSchedule,
    required this.onDayTap,
  });

  String _formatRange(BuildContext context, TimeRange range) {
    return '${range.start.format(context)} - ${range.end.format(context)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        Text(
          'Tap a day to set hours, tap again to remove.',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: AppTheme.spacingSmall,
          runSpacing: AppTheme.spacingSmall,
          children: weekDays.map((day) {
            final range = selectedSchedule[day];
            final isSelected = range != null;

            return GestureDetector(
              onTap: () => onDayTap(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : cs.surface,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                  border: Border.all(
                    color: isSelected ? cs.primary : cs.outlineVariant,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        color: isSelected ? cs.onPrimary : cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatRange(context, range),
                        style: TextStyle(
                          color: cs.onPrimary.withValues(alpha: 0.85),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}