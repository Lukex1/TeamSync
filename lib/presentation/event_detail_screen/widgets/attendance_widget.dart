import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttendanceWidget extends StatefulWidget {
  final String currentAttendance;
  final Function(String) onAttendanceChanged;

  const AttendanceWidget({
    super.key,
    required this.currentAttendance,
    required this.onAttendanceChanged,
  });

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  late String _selectedAttendance;

  @override
  void initState() {
    super.initState();
    _selectedAttendance = widget.currentAttendance;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'how_to_reg',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Your Attendance',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildAttendanceOption(
                  'going',
                  'Going',
                  'check_circle',
                  AppTheme.getSuccessColor(true),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildAttendanceOption(
                  'maybe',
                  'Maybe',
                  'help',
                  AppTheme.getWarningColor(true),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildAttendanceOption(
                  'not_going',
                  'Can\'t Go',
                  'cancel',
                  AppTheme.getErrorColor(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceOption(
    String value,
    String label,
    String iconName,
    Color color,
  ) {
    final bool isSelected = _selectedAttendance == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAttendance = value;
        });
        widget.onAttendanceChanged(value);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isSelected
                  ? color
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? color
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
