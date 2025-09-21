import 'package:flutter/material.dart';
import 'package:teamsync_calendar/presentation/home_dashboard/dashboard.dart';
import 'package:teamsync_calendar/presentation/profile_screen/profile_screen.dart';
import 'package:teamsync_calendar/presentation/splash_screen/splash_screen.dart';
import '../presentation/team_join_screen/team_join_screen.dart';
import '../presentation/team_management_screen/team_management_screen.dart';
import '../presentation/create_event_screen/create_event_screen.dart';
import '../presentation/calendar_dashboard/calendar_dashboard.dart';
import '../presentation/event_detail_screen/event_detail_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/auth/login_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String teamJoin = '/team-join-screen';
  static const String teamManagement = '/team-management-screen';
  static const String createEvent = '/create-event-screen';
  static const String calendarDashboard = '/calendar-dashboard';
  static const String eventDetail = '/event-detail-screen';
  static const String registration = '/registration-screen';
  static const String login = '/login-screen';
  static const String splashScreen = '/splash-screen';
  static const String homeDashboard = "/home-dashboard";
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    registration: (context) => const RegistrationScreen(),
    teamJoin: (context) => const TeamJoinScreen(),
    teamManagement: (context) => const TeamManagementScreen(),
    createEvent: (context) => const CreateEventScreen(),
    calendarDashboard: (context) => const CalendarDashboard(),
    splashScreen: (context) => const SplashScreen(),
    homeDashboard: (context) => const Dashboard(),
    eventDetail: (context) {
      final eventId = ModalRoute.of(context)!.settings.arguments as String;
      return EventDetailScreen(eventId: eventId);
    },
    profile: (context) => const ProfileScreen()
  };
}
