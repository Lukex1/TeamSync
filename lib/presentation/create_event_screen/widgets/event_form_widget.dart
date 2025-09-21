import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EventFormWidget extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final VoidCallback onStartDateTap;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndDateTap;
  final VoidCallback onEndTimeTap;
  final String? titleError;
  final String? timeError;

  const EventFormWidget({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    required this.onStartDateTap,
    required this.onStartTimeTap,
    required this.onEndDateTap,
    required this.onEndTimeTap,
    this.titleError,
    this.timeError,
  });

  @override
  State<EventFormWidget> createState() => _EventFormWidgetState();
}

class _EventFormWidgetState extends State<EventFormWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Title Field
        Text(
          'Event Title *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.titleController,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Enter event title',
            errorText: widget.titleError,
            counterStyle: AppTheme.lightTheme.textTheme.bodySmall,
          ),
          style: AppTheme.lightTheme.textTheme.bodyLarge,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 3.h),

        // Description Field
        Text(
          'Description',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.descriptionController,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Add event description (optional)',
            alignLabelWithHint: true,
          ),
          style: AppTheme.lightTheme.textTheme.bodyLarge,
          textInputAction: TextInputAction.newline,
        ),
        SizedBox(height: 3.h),

        // Date and Time Section
        Text(
          'Date & Time *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),

        // Start Date and Time Row
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: widget.onStartDateTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          widget.startDate != null
                              ? '${widget.startDate!.day}/${widget.startDate!.month}/${widget.startDate!.year}'
                              : 'Start Date',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: widget.startDate != null
                                ? AppTheme.lightTheme.colorScheme.onSurface
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: InkWell(
                onTap: widget.onStartTimeTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          widget.startTime != null
                              ? widget.startTime!.format(context)
                              : 'Start Time',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: widget.startTime != null
                                ? AppTheme.lightTheme.colorScheme.onSurface
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),

        // End Date and Time Row
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: widget.onEndDateTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          widget.endDate != null
                              ? '${widget.endDate!.day}/${widget.endDate!.month}/${widget.endDate!.year}'
                              : 'End Date',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: widget.endDate != null
                                ? AppTheme.lightTheme.colorScheme.onSurface
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: InkWell(
                onTap: widget.onEndTimeTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          widget.endTime != null
                              ? widget.endTime!.format(context)
                              : 'End Time',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: widget.endTime != null
                                ? AppTheme.lightTheme.colorScheme.onSurface
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Time Error Message
        widget.timeError != null
            ? Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Text(
                  widget.timeError!,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
              )
            : const SizedBox.shrink(),

        SizedBox(height: 3.h),

        // Location Field
        Text(
          'Location',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.locationController,
          decoration: const InputDecoration(
            hintText: 'Add location (optional)',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          style: AppTheme.lightTheme.textTheme.bodyLarge,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
