import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ParticipantsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final String currentUserId;

  const ParticipantsWidget({
    super.key,
    required this.participants,
    required this.currentUserId,
  });

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'group',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Participants',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${participants.length}',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 12.h,
            child: Material(
              color:
                  Colors.transparent, // zapewnia kontekst Material dla InkWell
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: participants.length,
                separatorBuilder: (_, __) => SizedBox(width: 3.w),
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  final isCurrentUser = participant['id'] == currentUserId;
                  final attendanceStatus =
                      participant['attendance'] as String? ?? 'pending';

                  return Column(
                    children: [
                      Stack(
                        children: [
                          InkWell(
                            // jeśli chcesz kliknięcie w avatar
                            onTap: () {
                              // np. pokaz profil uczestnika
                            },
                            child: Container(
                              width: 15.w,
                              height: 15.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCurrentUser
                                      ? AppTheme.lightTheme.primaryColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: participant['avatar'] != null
                                    ? CustomImageWidget(
                                        imageUrl:
                                            participant['avatar'] as String,
                                        width: 15.w,
                                        height: 15.w,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(color: Colors.grey),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 4.w,
                              height: 4.w,
                              decoration: BoxDecoration(
                                color: _getAttendanceColor(attendanceStatus),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      AppTheme.lightTheme.colorScheme.surface,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      SizedBox(
                        width: 15.w,
                        child: Text(
                          (participant['name'] as String?) ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: isCurrentUser
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Color _getAttendanceColor(String status) {
    switch (status.toLowerCase()) {
      case 'going':
        return AppTheme.getSuccessColor(true);
      case 'not_going':
        return AppTheme.getErrorColor(true);
      case 'maybe':
        return AppTheme.getWarningColor(true);
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }
}
