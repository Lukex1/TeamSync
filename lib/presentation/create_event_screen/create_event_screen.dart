import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teamsync_calendar/services/supabase_service.dart';

import '../../core/app_export.dart';
import './widgets/event_form_widget.dart';
import './widgets/event_settings_widget.dart';
import './widgets/participant_selection_widget.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  late SupabaseClient supabase;
  late User? currentUser;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  List<Map<String, dynamic>> allParticipants = [];
  List<String> _selectedParticipants = [];
  Color _selectedColor = const Color(0xFF2563EB);
  String _selectedReminder = "1hour";
  late String? teamId;
  bool _isLoading = false;
  String? _titleError;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    supabase = SupabaseService.instance.client;
    currentUser = supabase.auth.currentUser;
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day);
    _startTime = TimeOfDay(hour: now.hour + 1, minute: 0);
    _endTime = TimeOfDay(hour: now.hour + 2, minute: 0);
    LoadParticipants();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    teamId = ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> LoadParticipants() async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select('id, full_name, email, role') // Prawidłowe zapytanie
          .neq('id', currentUser!.id);
      if (response != null) {
        setState(() {
          allParticipants = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('Error loading participants: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme,
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // Auto-adjust end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
        _timeError = null;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme,
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        _timeError = null;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme,
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _timeError = null;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme,
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
        _timeError = null;
      });
    }
  }

  bool _validateForm() {
    bool isValid = true;

    // Validate title
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _titleError = 'Event title is required';
      });
      isValid = false;
    } else {
      setState(() {
        _titleError = null;
      });
    }

    // Validate date and time
    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      setState(() {
        _timeError = 'Please select both start and end date/time';
      });
      isValid = false;
    } else {
      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      if (endDateTime.isBefore(startDateTime) ||
          endDateTime.isAtSameMomentAs(startDateTime)) {
        setState(() {
          _timeError = 'End time must be after start time';
        });
        isValid = false;
      } else {
        setState(() {
          _timeError = null;
        });
      }
    }

    return isValid;
  }

  Future<void> _saveEvent() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (currentUser == null || teamId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Authentication or team data is missing. Please log in again.')),
          );
        }
        return;
      }

      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final duration = endDateTime.difference(startDateTime).inMinutes;

      // --- Step 1: Insert the Event ---
      final List<Map<String, dynamic>> eventDataList =
          await supabase.from('events').insert({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'event_date': startDateTime.toIso8601String(),
        'duration_minutes': duration,
        'creator_id': currentUser!.id,
        'event_color': _selectedColor.value,
        'reminder_time': _selectedReminder,
        'event_status': 'published',
        'team_id': teamId,
      }).select('id');

      if (eventDataList.isEmpty) {
        throw Exception('Failed to retrieve event ID after insertion.');
      }
      final eventId = eventDataList.first['id'] as String;

      // --- Step 2: Prepare and Insert Attendees ---
      final List<Map<String, dynamic>> attendees = [
        {
          'event_id': eventId,
          'user_id': currentUser!.id,
          'attendance_status': 'going',
        },
        ..._selectedParticipants.map((participantId) => {
              'event_id': eventId,
              'user_id': participantId,
              'attendance_status': 'pending',
            })
      ];

      if (attendees.isNotEmpty) {
        await supabase.from('event_attendees').insert(attendees);
      }

      // --- Step 3: Success and Navigation ---
      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Event "${_titleController.text}" created successfully!'),
            backgroundColor: AppTheme.getSuccessColor(true),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Catch the specific Supabase error and print it
      debugPrint('Detailed error creating event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to create event. Please try again. Error: ${e.toString()}'),
            backgroundColor: AppTheme.getErrorColor(true),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cancelEvent() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Event',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: _cancelEvent,
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEvent,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          SizedBox(width: 2.w),
        ],
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Form Section
                EventFormWidget(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                  locationController: _locationController,
                  startDate: _startDate,
                  startTime: _startTime,
                  endDate: _endDate,
                  endTime: _endTime,
                  onStartDateTap: _selectStartDate,
                  onStartTimeTap: _selectStartTime,
                  onEndDateTap: _selectEndDate,
                  onEndTimeTap: _selectEndTime,
                  titleError: _titleError,
                  timeError: _timeError,
                ),
                SizedBox(height: 4.h),

                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      )
                    : ParticipantSelectionWidget(
                        allParticipants: allParticipants,
                        selectedParticipants: _selectedParticipants,
                        onParticipantsChanged: (participants) {
                          setState(() {
                            _selectedParticipants = participants;
                          });
                        },
                      ),
                SizedBox(height: 4.h),

                // Event Settings Section
                EventSettingsWidget(
                  selectedColor: _selectedColor,
                  selectedReminder: _selectedReminder,
                  onColorChanged: (color) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  onReminderChanged: (reminder) {
                    setState(() {
                      _selectedReminder = reminder;
                    });
                  },
                ),
                SizedBox(height: 6.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveEvent,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Creating Event...',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'event',
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Create Event',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
