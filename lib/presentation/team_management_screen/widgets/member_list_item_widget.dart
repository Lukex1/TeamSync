import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MemberListItemWidget extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool isCurrentUser;
  final bool isAdmin;
  final VoidCallback? onRemove;
  final VoidCallback? onChangeRole;

  const MemberListItemWidget({
    super.key,
    required this.member,
    this.isCurrentUser = false,
    this.isAdmin = false,
    this.onRemove,
    this.onChangeRole,
  });

  String _getTimeAgo(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberName = member['name'] as String? ?? 'Unknown';
    final memberRole = member['role'] as String? ?? 'Member';
    final memberAvatar = member['avatar'] as String? ?? '';
    final lastActive = member['lastActive'] as DateTime? ?? DateTime.now();
    final isOnline = member['isOnline'] as bool? ?? false;

    Widget memberTile = Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 6.w,
                backgroundColor:
                    AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                child: memberAvatar.isNotEmpty
                    ? CustomImageWidget(
                        imageUrl: memberAvatar,
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.cover,
                      )
                    : CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 3.w,
                    height: 3.w,
                    decoration: BoxDecoration(
                      color: AppTheme.getSuccessColor(true),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        memberName,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'You',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: memberRole == 'Admin'
                            ? AppTheme.getWarningColor(true)
                                .withValues(alpha: 0.1)
                            : AppTheme
                                .lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        memberRole,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: memberRole == 'Admin'
                              ? AppTheme.getWarningColor(true)
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _getTimeAgo(lastActive),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isAdmin && !isCurrentUser) {
      return Slidable(
        key: ValueKey(member['id']),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onChangeRole?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.admin_panel_settings,
              label: memberRole == 'Admin' ? 'Remove Admin' : 'Make Admin',
            ),
            SlidableAction(
              onPressed: (_) => onRemove?.call(),
              backgroundColor: AppTheme.getErrorColor(true),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Remove',
            ),
          ],
        ),
        child: memberTile,
      );
    }

    return memberTile;
  }
}
