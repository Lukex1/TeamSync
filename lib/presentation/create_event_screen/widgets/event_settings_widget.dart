import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EventSettingsWidget extends StatefulWidget {
  final Color selectedColor;
  final String selectedReminder;
  final Function(Color) onColorChanged;
  final Function(String) onReminderChanged;

  const EventSettingsWidget({
    super.key,
    required this.selectedColor,
    required this.selectedReminder,
    required this.onColorChanged,
    required this.onReminderChanged,
  });

  @override
  State<EventSettingsWidget> createState() => _EventSettingsWidgetState();
}

class _EventSettingsWidgetState extends State<EventSettingsWidget> {
  final List<Color> eventColors = [
    const Color(0xFF2563EB), // Blue
    const Color(0xFF059669), // Green
    const Color(0xFFD97706), // Orange
    const Color(0xFFDC2626), // Red
    const Color(0xFF7C3AED), // Purple
    const Color(0xFF0891B2), // Cyan
    const Color(0xFFDB2777), // Pink
    const Color(0xFF65A30D), // Lime
  ];

  final List<Map<String, String>> reminderOptions = [
    {"value": "none", "label": "No reminder"},
    {"value": "15min", "label": "15 minutes before"},
    {"value": "30min", "label": "30 minutes before"},
    {"value": "1hour", "label": "1 hour before"},
    {"value": "2hours", "label": "2 hours before"},
    {"value": "1day", "label": "1 day before"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color Selection
        Text(
          'Event Color',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lightTheme.colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          ),
          child: Wrap(
            spacing: 3.w,
            runSpacing: 2.h,
            children: eventColors.map((color) {
              final isSelected = widget.selectedColor.value == color.value;
              return GestureDetector(
                onTap: () => widget.onColorChanged(color),
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? Center(
                          child: CustomIconWidget(
                            iconName: 'check',
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 3.h),

        // Reminder Selection
        Text(
          'Reminder',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lightTheme.colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.selectedReminder,
              isExpanded: true,
              icon: CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              style: AppTheme.lightTheme.textTheme.bodyLarge,
              dropdownColor: AppTheme.lightTheme.colorScheme.surface,
              items: reminderOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option["value"],
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: option["value"] == "none"
                            ? 'notifications_off'
                            : 'notifications',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          option["label"]!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.onReminderChanged(newValue);
                }
              },
            ),
          ),
        ),
        SizedBox(height: 3.h),

        // Duration Display
        _buildDurationDisplay(),
      ],
    );
  }

  Widget _buildDurationDisplay() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'schedule',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Duration',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Duration will be calculated automatically based on start and end times',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
