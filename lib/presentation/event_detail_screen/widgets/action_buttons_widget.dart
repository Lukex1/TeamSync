import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final bool canEdit;
  final bool canDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onAddToCalendar;
  final VoidCallback onShare;

  const ActionButtonsWidget({
    super.key,
    required this.canEdit,
    required this.canDelete,
    this.onEdit,
    this.onDelete,
    required this.onAddToCalendar,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.only(bottom: 2.h),
      child: Column(
        children: [
          // Primary actions row
          Row(
            children: [
              if (canEdit && onEdit != null)
                Expanded(
                  child: _buildPrimaryButton(
                    label: 'Edit Event',
                    iconName: 'edit',
                    onTap: onEdit!,
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                    textColor: Colors.white,
                  ),
                ),
              if (canEdit && canDelete) SizedBox(width: 3.w),
              if (canDelete && onDelete != null)
                Expanded(
                  child: _buildPrimaryButton(
                    label: 'Delete',
                    iconName: 'delete',
                    onTap: () => _showDeleteConfirmation(context),
                    backgroundColor: AppTheme.getErrorColor(true),
                    textColor: Colors.white,
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          // Secondary actions row
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  label: 'Add to Calendar',
                  iconName: 'event',
                  onTap: onAddToCalendar,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildSecondaryButton(
                  label: 'Share Event',
                  iconName: 'share',
                  onTap: onShare,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required String iconName,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: textColor,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required String iconName,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Event',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this event? This action cannot be undone.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDelete != null) onDelete!();
              },
              child: Text(
                'Delete',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.getErrorColor(true),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
