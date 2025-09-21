import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DayViewWidget extends StatelessWidget {
  final DateTime currentDate;
  final List<Map<String, dynamic>> events;
  final Function(Map<String, dynamic>) onEventTap;
  final Function(Map<String, dynamic>) onEventLongPress;

  const DayViewWidget({
    super.key,
    required this.currentDate,
    required this.events,
    required this.onEventTap,
    required this.onEventLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final dayEvents = _getEventsForDate(currentDate);

    return Container(
      padding: EdgeInsets.all(2.w),
      child: Column(
        children: [
          _buildDayHeader(),
          SizedBox(height: 2.h),
          Expanded(
            child: _buildHourlyTimeline(dayEvents),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader() {
    final isToday = _isToday(currentDate);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: isToday
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                _getDayName(currentDate.weekday),
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                currentDate.day.toString(),
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  color: isToday
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (isToday) ...[
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Today',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHourlyTimeline(List<Map<String, dynamic>> dayEvents) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: List.generate(24, (hour) {
          final hourEvents = _getEventsForHour(dayEvents, hour);
          final currentHour = DateTime.now().hour;
          final isCurrentHour = _isToday(currentDate) && hour == currentHour;

          return SizedBox(
            height: 10.h, // sztywna wysokość dla każdej godziny
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 15.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatHour(hour),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: isCurrentHour
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isCurrentHour ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (isCurrentHour)
                        Container(
                          width: 2.w,
                          height: 2.w,
                          margin: EdgeInsets.only(top: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    children: hourEvents.map((event) {
                      return GestureDetector(
                        onTap: () => onEventTap(event),
                        onLongPress: () => onEventLongPress(event),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 1.h),
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: _getEventColor(
                                event["type"] as String? ?? "meeting"),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event["title"] as String? ?? "Event",
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (event["description"] != null) ...[
                                SizedBox(height: 0.5.h),
                                Text(
                                  event["description"] as String,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'access_time',
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 12,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    _formatEventTime(event),
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  Spacer(),
                                  if (event["participants"] != null)
                                    Row(
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'people',
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          size: 12,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          '${(event["participants"] as List).length}',
                                          style: AppTheme
                                              .lightTheme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
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

  List<Map<String, dynamic>> _getEventsForHour(
      List<Map<String, dynamic>> dayEvents, int hour) {
    return dayEvents.where((event) {
      final eventDate = event["startTime"] as DateTime;
      return eventDate.hour == hour;
    }).toList();
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  String _formatEventTime(Map<String, dynamic> event) {
    final startTime = event["startTime"] as DateTime;
    final endTime = event["endTime"] as DateTime;
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
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
