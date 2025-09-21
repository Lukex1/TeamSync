import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TeamSettingsBottomSheet extends StatefulWidget {
  final String currentTeamName;
  final String currentThemeColor;
  final bool notificationsEnabled;
  final bool isAdmin;
  final VoidCallback onLeaveTeam;
  final VoidCallback? onDeleteTeam;
  final Function(String) onTeamNameChanged;
  final Function(String) onThemeColorChanged;
  final Function(bool) onNotificationToggle;

  const TeamSettingsBottomSheet({
    super.key,
    required this.currentTeamName,
    required this.currentThemeColor,
    required this.notificationsEnabled,
    required this.isAdmin,
    required this.onLeaveTeam,
    this.onDeleteTeam,
    required this.onTeamNameChanged,
    required this.onThemeColorChanged,
    required this.onNotificationToggle,
  });

  @override
  State<TeamSettingsBottomSheet> createState() =>
      _TeamSettingsBottomSheetState();
}

class _TeamSettingsBottomSheetState extends State<TeamSettingsBottomSheet> {
  late TextEditingController _teamNameController;
  late String _selectedThemeColor;
  late bool _notificationsEnabled;

  final List<Map<String, dynamic>> _themeColors = [
    {'name': 'Blue', 'color': Colors.blue, 'value': 'blue'},
    {'name': 'Green', 'color': Colors.green, 'value': 'green'},
    {'name': 'Purple', 'color': Colors.purple, 'value': 'purple'},
    {'name': 'Orange', 'color': Colors.orange, 'value': 'orange'},
    {'name': 'Red', 'color': Colors.red, 'value': 'red'},
    {'name': 'Teal', 'color': Colors.teal, 'value': 'teal'},
  ];

  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController(text: widget.currentTeamName);
    _selectedThemeColor = widget.currentThemeColor;
    _notificationsEnabled = widget.notificationsEnabled;
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _showLeaveTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Team'),
        content: Text(
          'Are you sure you want to leave this team? You will lose access to all team events and data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              widget.onLeaveTeam();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getErrorColor(true),
            ),
            child: Text('Leave Team'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTeamDialog() {
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. All team data, events, and member access will be permanently deleted.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              'Type "${widget.currentTeamName}" to confirm:',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                hintText: 'Enter team name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (confirmController.text == widget.currentTeamName) {
                Navigator.pop(context);
                Navigator.pop(context);
                widget.onDeleteTeam?.call();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getErrorColor(true),
            ),
            child: Text('Delete Team'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: 80.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              children: [
                Text(
                  'Team Settings',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Name Section
                  if (widget.isAdmin) ...[
                    Text(
                      'Team Name',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextField(
                      controller: _teamNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter team name',
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (_teamNameController.text.trim().isNotEmpty) {
                              widget.onTeamNameChanged(
                                  _teamNameController.text.trim());
                            }
                          },
                          icon: CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Theme Color Section
                    Text(
                      'Theme Color',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 3.w,
                      runSpacing: 2.h,
                      children: _themeColors.map((theme) {
                        final isSelected =
                            _selectedThemeColor == theme['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedThemeColor = theme['value'];
                            });
                            widget.onThemeColorChanged(theme['value']);
                          },
                          child: Container(
                            width: 20.w,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme['color'].withValues(alpha: 0.1)
                                  : AppTheme.lightTheme.colorScheme
                                      .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? theme['color']
                                    : AppTheme.lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    color: theme['color'],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  theme['name'],
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: isSelected
                                        ? theme['color']
                                        : AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 3.h),
                  ],

                  // Notifications Section
                  Text(
                    'Notifications',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme
                          .lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'notifications',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Team Notifications',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Get notified about team events and updates',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                            widget.onNotificationToggle(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Danger Zone
                  Text(
                    'Danger Zone',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getErrorColor(true),
                    ),
                  ),
                  SizedBox(height: 1.h),

                  // Leave Team Button
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 2.h),
                    child: OutlinedButton.icon(
                      onPressed: _showLeaveTeamDialog,
                      icon: CustomIconWidget(
                        iconName: 'exit_to_app',
                        color: AppTheme.getErrorColor(true),
                        size: 18,
                      ),
                      label: Text('Leave Team'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.getErrorColor(true),
                        side: BorderSide(color: AppTheme.getErrorColor(true)),
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),

                  // Delete Team Button (Admin only)
                  if (widget.isAdmin)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 4.h),
                      child: ElevatedButton.icon(
                        onPressed: _showDeleteTeamDialog,
                        icon: CustomIconWidget(
                          iconName: 'delete_forever',
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text('Delete Team'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getErrorColor(true),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
