import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/bottom_navigation_widget.dart';
import './widgets/calendar_header_widget.dart';
import './widgets/day_view_widget.dart';
import './widgets/event_quick_actions_widget.dart';
import './widgets/month_view_widget.dart';
import './widgets/week_view_widget.dart';

class CalendarDashboard extends StatefulWidget {
  const CalendarDashboard({super.key});

  @override
  State<CalendarDashboard> createState() => _CalendarDashboardState();
}

class _CalendarDashboardState extends State<CalendarDashboard>
    with TickerProviderStateMixin {
  DateTime _currentDate = DateTime.now();
  String _viewMode = 'Month';
  int _bottomNavIndex = 0;
  bool _isLoading = false;
  bool _isRefreshing = false;
  Map<String, dynamic>? _selectedEvent;
  bool _showQuickActions = false;
  late SupabaseClient supabase;
  String? userId;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late String? teamId = "";
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    supabase = SupabaseService.instance.client;
    userId = supabase.auth.currentUser?.id;
    _initializeAnimations();
  }

  final bool _isDataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    teamId = ModalRoute.of(context)?.settings.arguments as String?;
    _loadEvents();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      teamId = ModalRoute.of(context)?.settings.arguments as String?;

      if (teamId == null) {
        _events = [];
        return;
      }

      final eventsData = await supabase.from('events').select('''
          id,
          title,
          description,
          location,
          event_date,
          duration_minutes,
          event_status,
          creator_id,
          team_id,
          is_recurring,
          event_attendees(user_id, attendance_status)
        ''').eq('event_status', 'published').eq('team_id', teamId!);

      if (eventsData.isEmpty) {
        setState(() {
          _events = [];
        });
        return;
      }

      _events = eventsData.map<Map<String, dynamic>>((event) {
        final attendees =
            (event['event_attendees'] as List).cast<Map<String, dynamic>>();
        return {
          "id": event['id'],
          "title": event['title'],
          "description": event['description'],
          "startTime": DateTime.parse(event['event_date']),
          "endTime": DateTime.parse(event['event_date'])
              .add(Duration(minutes: event['duration_minutes'] ?? 60)),
          "location": event['location'],
          "isRecurring": event['is_recurring'],
          "participants": attendees.map((e) => e['user_id']).toList(),
          "attendanceStatus": attendees.firstWhere(
              (e) => e['user_id'] == userId,
              orElse: () =>
                  {'attendance_status': 'pending'})['attendance_status']
        };
      }).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load events: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshEvents() async {
    setState(() => _isRefreshing = true);
    await _loadEvents();
    setState(() => _isRefreshing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Events updated successfully'),
          backgroundColor: AppTheme.getSuccessColor(true),
        ),
      );
    }
  }

  void _onEventTap(Map<String, dynamic> event) {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, '/event-detail-screen',
        arguments: event['id']);
  }

  void _onEventLongPress(Map<String, dynamic> event) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedEvent = event;
      _showQuickActions = true;
    });
    _slideController.forward();
  }

  void _closeQuickActions() {
    _slideController.reverse().then((_) {
      setState(() {
        _showQuickActions = false;
        _selectedEvent = null;
      });
    });
  }

  void _onEditEvent() {
    _closeQuickActions();
    Navigator.pushNamed(context, '/create-event-screen', arguments: teamId)
        .then((result) {
      if (result == true) {
        _refreshEvents();
      }
    });
  }

  void _onDeleteEvent() {
    _closeQuickActions();
    _showDeleteConfirmation();
  }

  void _onDuplicateEvent() {
    _closeQuickActions();
    Navigator.pushNamed(context, '/create-event-screen', arguments: teamId)
        .then((result) {
      if (result == true) {
        _refreshEvents();
      }
    });
  }

  void _showDeleteConfirmation() {
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
            'Are you sure you want to delete "${_selectedEvent?["title"]}"? This action cannot be undone.',
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_selectedEvent != null && _selectedEvent!['id'] != null) {
                  _deleteEvent(_selectedEvent!['id'].toString());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getErrorColor(true),
              ),
              child: Text(
                'Delete',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await SupabaseService.instance.client
          .from('events')
          .delete()
          .match({'id': eventId});

      setState(() {
        _events.removeWhere((event) => event['id'] == eventId);
      });
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: AppTheme.getSuccessColor(true),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')),
        );
      }
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _bottomNavIndex) return;

    HapticFeedback.selectionClick();
    setState(() => _bottomNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.calendarDashboard,
            arguments: teamId);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.createEvent, arguments: teamId)
            .then((_) => _refreshEvents());
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.teamManagement,
            arguments: teamId);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
    }
  }

  void _onCreateEvent() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/create-event-screen', arguments: teamId)
        .then((result) {
      if (result == true) {
        _refreshEvents(); // odśwież po utworzeniu eventu
      }
    });
  }

  Widget _buildCalendarView() {
    switch (_viewMode) {
      case 'Day':
        return DayViewWidget(
          currentDate: _currentDate,
          events: _events,
          onEventTap: _onEventTap,
          onEventLongPress: _onEventLongPress,
        );
      case 'Week':
        return WeekViewWidget(
          currentDate: _currentDate,
          events: _events,
          onEventTap: _onEventTap,
          onEventLongPress: _onEventLongPress,
        );
      case 'Month':
      default:
        return MonthViewWidget(
          currentDate: _currentDate,
          events: _events,
          onEventTap: _onEventTap,
          onEventLongPress: _onEventLongPress,
        );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'event_available',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 3.h),
          Text(
            'No Events Yet',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Create your first event to get started\nwith team collaboration',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: _onCreateEvent,
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              'Create Event',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        Container(
          height: 8.h,
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(2.w),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.all(0.5.w),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              Column(
                children: [
                  CalendarHeaderWidget(
                    currentDate: _currentDate,
                    viewMode: _viewMode,
                    onPreviousMonth: () {
                      setState(() {
                        _currentDate = DateTime(
                          _currentDate.year,
                          _currentDate.month - 1,
                          _currentDate.day,
                        );
                      });
                    },
                    onNextMonth: () {
                      setState(() {
                        _currentDate = DateTime(
                          _currentDate.year,
                          _currentDate.month + 1,
                          _currentDate.day,
                        );
                      });
                    },
                    onViewModeChanged: (mode) {
                      setState(() => _viewMode = mode);
                    },
                  ),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingSkeleton()
                        : RefreshIndicator(
                            onRefresh: _refreshEvents,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            child: _events.isEmpty
                                ? _buildEmptyState()
                                : _buildCalendarView(),
                          ),
                  ),
                ],
              ),
              if (_showQuickActions && _selectedEvent != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeQuickActions,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: EventQuickActionsWidget(
                              event: _selectedEvent!,
                              onEdit: _onEditEvent,
                              onDelete: _onDeleteEvent,
                              onDuplicate: _onDuplicateEvent,
                              onClose: _closeQuickActions,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateEvent,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
