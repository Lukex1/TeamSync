import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class ParticipantSelectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> allParticipants;
  final List<String> selectedParticipants;
  final Function(List<String>) onParticipantsChanged;

  const ParticipantSelectionWidget({
    super.key,
    required this.allParticipants,
    required this.selectedParticipants,
    required this.onParticipantsChanged,
  });

  @override
  State<ParticipantSelectionWidget> createState() =>
      _ParticipantSelectionWidgetState();
}

class _ParticipantSelectionWidgetState
    extends State<ParticipantSelectionWidget> {
  void _toggleParticipant(String participantId) {
    List<String> updatedParticipants = List.from(widget.selectedParticipants);

    if (updatedParticipants.contains(participantId)) {
      updatedParticipants.remove(participantId);
    } else {
      updatedParticipants.add(participantId);
    }

    widget.onParticipantsChanged(updatedParticipants);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Participants',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${widget.selectedParticipants.length} selected',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),

        // Team Members List
        Container(
          constraints: BoxConstraints(maxHeight: 40.h),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: widget.allParticipants.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final member = widget.allParticipants[index];
              final isSelected =
                  widget.selectedParticipants.contains(member["id"]);

              return InkWell(
                onTap: () => _toggleParticipant(member["id"] as String),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                            .withOpacity(0.05)
                        : AppTheme.lightTheme.colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 6.w,
                        backgroundColor: AppTheme
                            .lightTheme.colorScheme.surfaceContainerHighest,
                        child: Text(
                          member["full_name"][0].toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface),
                        ),
                      ),
                      SizedBox(width: 3.w),

                      // Member Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member["full_name"] as String,
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              member["role"] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              member["email"] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Checkbox
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) =>
                            _toggleParticipant(member["id"] as String),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
