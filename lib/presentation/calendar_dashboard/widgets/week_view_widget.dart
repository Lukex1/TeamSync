import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class WeekViewWidget extends StatelessWidget {
  final DateTime currentDate;
  final List<Map<String, dynamic>> events;
  final Function(Map<String, dynamic>) onEventTap;
  final Function(Map<String, dynamic>) onEventLongPress;

  const WeekViewWidget({
    super.key,
    required this.currentDate,
    required this.events,
    required this.onEventTap,
    required this.onEventLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final weekStart = _getWeekStart(currentDate);
    final weekDays =
        List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return Container(
      padding: EdgeInsets.all(2.w),
      child: Column(
        children: [
          _buildWeekHeader(weekDays),
          SizedBox(height: 1.h),
          Expanded(
            child: _buildTimeSlots(weekDays),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(List<DateTime> weekDays) {
    return Row(
      children: [
        SizedBox(width: 12.w), // Space for time labels
        ...weekDays.map((day) {
          final isToday = _isToday(day);
          return Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: isToday
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _getDayName(day.weekday),
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    day.day.toString(),
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: isToday
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeSlots(List<DateTime> weekDays) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(24, (hour) {
          return SizedBox(
            height: 8.h,
            child: Row(
              children: [
                SizedBox(
                  width: 12.w,
                  child: Text(
                    _formatHour(hour),
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ...weekDays.map((day) {
                  final dayEvents = _getEventsForDateAndHour(day, hour);
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                          bottom: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: dayEvents.map((event) {
                          return GestureDetector(
                            onTap: () => onEventTap(event),
                            onLongPress: () => onEventLongPress(event),
                            child: Container(
                              margin: EdgeInsets.all(0.5.w),
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: _getEventColor(
                                    event["type"] as String? ?? "meeting"),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                event["title"] as String? ?? "Event",
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday % 7; // Convert to 0-6 where 0 is Sunday
    return date.subtract(Duration(days: weekday));
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  List<Map<String, dynamic>> _getEventsForDateAndHour(DateTime date, int hour) {
    return events.where((event) {
      final eventDate = event["startTime"] as DateTime;
      return eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day &&
          eventDate.hour == hour;
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
