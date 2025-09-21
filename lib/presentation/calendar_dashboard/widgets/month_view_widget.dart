import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MonthViewWidget extends StatelessWidget {
  final DateTime currentDate;
  final List<Map<String, dynamic>> events;
  final Function(Map<String, dynamic>) onEventTap;
  final Function(Map<String, dynamic>) onEventLongPress;

  const MonthViewWidget({
    super.key,
    required this.currentDate,
    required this.events,
    required this.onEventTap,
    required this.onEventLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.w),
      child: Column(
        children: [
          _buildWeekDaysHeader(),
          SizedBox(height: 1.h),
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: weekDays.map((day) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final dayIndex = index - firstDayWeekday + 1;

        if (dayIndex < 1 || dayIndex > daysInMonth) {
          return Container(); // Empty cell for days outside current month
        }

        final date = DateTime(currentDate.year, currentDate.month, dayIndex);
        final dayEvents = _getEventsForDate(date);
        final isToday = _isToday(date);

        return GestureDetector(
          onTap: () {
            if (dayEvents.isNotEmpty) {
              onEventTap(dayEvents.first);
            }
          },
          child: Container(
            margin: EdgeInsets.all(0.5.w),
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayIndex.toString(),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isToday
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (dayEvents.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  _buildEventDots(dayEvents),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventDots(List<Map<String, dynamic>> dayEvents) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...dayEvents.take(3).map((event) {
          return Container(
            width: 1.5.w,
            height: 1.5.w,
            margin: EdgeInsets.symmetric(horizontal: 0.2.w),
            decoration: BoxDecoration(
              color: _getEventColor(event["type"] as String? ?? "meeting"),
              shape: BoxShape.circle,
            ),
          );
        }),
        if (dayEvents.length > 3)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${dayEvents.length - 3}',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                fontSize: 8.sp,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    return events.where((event) {
      final eventDate = event["startTime"] as DateTime;
      return eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day;
    }).toList();
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  Color _getEventColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'meeting':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'deadline':
        return AppTheme.getErrorColor(true);
      case 'reminder':
        return AppTheme.getWarningColor(true);
      case 'social':
        return AppTheme.getSuccessColor(true);
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }
}
