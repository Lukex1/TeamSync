import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teamsync_calendar/services/supabase_service.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/attendance_widget.dart';
import './widgets/comments_widget.dart';
import './widgets/creator_badge_widget.dart';
import './widgets/event_description_widget.dart';
import './widgets/event_header_widget.dart';
import './widgets/location_widget.dart';
import './widgets/participants_widget.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late SupabaseClient supabase;

  Map<String, dynamic>? _eventData;
  List<Map<String, dynamic>> _comments = [];

  String _currentUserAttendance = "pending";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    supabase = SupabaseService.instance.client;
    _animationController.forward();
    _loadEventData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadEventData() async {
    setState(() => _isLoading = true);
    try {
      final eventResult = await supabase.from('events').select('''
            id,
            title,
            description,
            location,
            event_date,
            duration_minutes,
            creator_id,
            user_profiles(full_name, avatar_url, role),
            event_attendees(user_id, attendance_status, user_profiles(full_name, avatar_url)),
            event_comments(id, content, created_at, user_profiles(full_name, avatar_url))
          ''').eq('id', widget.eventId).single();

      if (eventResult == null) {
        if (mounted) {
          // You can show a message or redirect the user.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event not found.')),
          );
        }
        return; // Exit the function gracefully
      }

      _eventData = {
        'id': eventResult['id'],
        'title': eventResult['title'],
        'description': eventResult['description'],
        'date': DateTime.parse(eventResult['event_date']),
        'time': _formatTimeRange(
            eventResult['event_date'], eventResult['duration_minutes']),
        'location': eventResult['location'],
        'creator': {
          'id': eventResult['creator_id'],
          'name': eventResult['user_profiles']['full_name'],
          'role': eventResult['user_profiles']['role'],
          'avatar': eventResult['user_profiles']['avatar_url']
        },
        'participants': (eventResult['event_attendees'] as List)
            .map((e) => {
                  'id': e['user_id'],
                  'name': e['user_profiles']['full_name'],
                  'avatar': e['user_profiles']['avatar_url'],
                  'attendance': e['attendance_status']
                })
            .toList(),
      };

      _comments = (eventResult['event_comments'] as List)
          .map((comment) => {
                'id': comment['id'],
                'content': comment['content'],
                'timestamp': DateTime.parse(comment['created_at']),
                'author': comment['user_profiles']['full_name'],
                'avatar': comment['user_profiles']['avatar_url']
              })
          .toList();

      final currentUserAttendance = (_eventData!['participants'] as List)
          .firstWhere((p) => p['id'] == supabase.auth.currentUser!.id,
              orElse: () => {'attendance': 'pending'})['attendance'];

      _currentUserAttendance = currentUserAttendance;
    } on PostgrestException catch (e) {
      if (mounted) {
        if (e.code == 'PGRST116') {
          // Handle the specific case of no rows returned.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event not found.')),
          );
        } else {
          // Handle other database errors.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load event data: ${e.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load event data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _eventData == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
      );
    }

    final String currentUserId = supabase.auth.currentUser!.id;
    final Map<String, dynamic> creator =
        (_eventData!['creator'] as Map<String, dynamic>?) ?? {};
    final bool isCreator = (creator['id'] ?? '') == currentUserId;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            // Now, we wrap the Column with LayoutBuilder to give it constraints
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    // Header
                    EventHeaderWidget(
                      eventTitle: (_eventData!['title'] as String?) ?? '',
                      eventDate: _eventData!['date'] as DateTime,
                      eventTime: (_eventData!['time'] as String?) ?? '',
                      onClose: () => Navigator.pop(context),
                      onEdit: isCreator ? _handleEditEvent : null,
                      canEdit: isCreator,
                    ),
                    // Main scrolling content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CreatorBadgeWidget(
                              creator: (_eventData!['creator']
                                      as Map<String, dynamic>?) ??
                                  {},
                            ),
                            EventDescriptionWidget(
                              description:
                                  (_eventData!['description'] as String?) ?? '',
                            ),
                            ParticipantsWidget(
                              participants: (_eventData!['participants']
                                      as List<Map<String, dynamic>>?) ??
                                  [],
                              currentUserId: currentUserId,
                            ),
                            LocationWidget(
                              location:
                                  (_eventData!['location'] as String?) ?? '',
                              onOpenMaps: _handleOpenMaps,
                            ),
                            AttendanceWidget(
                              currentAttendance: _currentUserAttendance,
                              onAttendanceChanged: _handleAttendanceChanged,
                            ),
                            CommentsWidget(
                              comments: _comments,
                              onAddComment: _handleAddComment,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Buttons stay at the bottom
                    ActionButtonsWidget(
                      canEdit: isCreator,
                      canDelete: isCreator,
                      onEdit: isCreator ? _handleEditEvent : null,
                      onDelete: isCreator ? _handleDeleteEvent : null,
                      onAddToCalendar: _handleAddToCalendar,
                      onShare: _handleShareEvent,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleEditEvent() {
    Navigator.pushNamed(context, '/create-event-screen', arguments: _eventData);
  }

  void _handleDeleteEvent() {
    // Implement delete logic with supabase
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event deleted successfully'),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/calendar-dashboard',
      (route) => false,
    );
  }

  void _handleOpenMaps() {
    // Simulate opening maps
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening location in maps...'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _handleAttendanceChanged(String attendanceStatus) async {
    try {
      await supabase
          .from('event_attendees')
          .update({'attendance_status': attendanceStatus}).match({
        'event_id': widget.eventId,
        'user_id': supabase.auth.currentUser!.id
      });

      // Update local state to reflect change
      setState(() {
        _currentUserAttendance = attendanceStatus;
        final participant = (_eventData!['participants'] as List).firstWhere(
            (p) => p['id'] == supabase.auth.currentUser!.id,
            orElse: () =>
                {'id': supabase.auth.currentUser!.id, 'attendance': 'pending'});
        if (participant.isNotEmpty) {
          participant['attendance'] = attendanceStatus;
        }
      });
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance updated successfully!'),
          backgroundColor: AppTheme.getSuccessColor(true),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update attendance: $e')),
        );
      }
    }
  }

  Future<void> _handleAddComment(String commentContent) async {
    try {
      final newComment = await supabase.from('event_comments').insert({
        'event_id': widget.eventId,
        'author_id': supabase.auth.currentUser!.id,
        'content': commentContent,
      }).select('''
            id,
            content,
            created_at,
            user_profiles(full_name, avatar_url)
          ''').single();

      setState(() {
        _comments.insert(0, {
          'id': newComment['id'],
          'content': newComment['content'],
          'timestamp': DateTime.parse(newComment['created_at']),
          'author': newComment['user_profiles']['full_name'],
          'avatar': newComment['user_profiles']['avatar_url'],
        });
      });
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment added successfully!'),
          backgroundColor: AppTheme.getSuccessColor(true),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    }
  }

  void _handleAddToCalendar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event added to your calendar'),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleShareEvent() {
    final eventTitle = _eventData?['title'] as String? ?? '';
    final eventDate = _eventData?['date'] as DateTime;
    final eventTime = _eventData?['time'] as String? ?? '';
    final location = _eventData?['location'] as String? ?? '';

    final shareText = '''
📅 $eventTitle

🗓️ ${eventDate.day}/${eventDate.month}/${eventDate.year}
⏰ $eventTime
📍 $location

Join us for this event! Download TeamSync Calendar to stay updated.
''';

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event details copied to clipboard'),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _formatTimeRange(String eventDateString, int? durationMinutes) {
    final startTime = DateTime.parse(eventDateString);
    final endTime = startTime.add(Duration(minutes: durationMinutes ?? 60));
    final startTimeFormatted =
        TimeOfDay.fromDateTime(startTime).format(context);
    final endTimeFormatted = TimeOfDay.fromDateTime(endTime).format(context);
    return '$startTimeFormatted - $endTimeFormatted';
  }
}
