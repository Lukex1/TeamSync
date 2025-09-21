import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    _listenToAuthChanges();
  }

  void _initializeAuth() {
    setState(() {
      _isAuthenticated = AuthService.instance.isAuthenticated;
      _isInitialized = true;
    });
  }

  void _listenToAuthChanges() {
    AuthService.instance.authStateChanges.listen((AuthState data) {
      if (mounted) {
        setState(() {
          _isAuthenticated = data.session != null;
        });

        // Navigate based on auth state
        if (data.event == AuthChangeEvent.signedIn) {
          Navigator.pushReplacementNamed(context, AppRoutes.calendarDashboard);
        } else if (data.event == AuthChangeEvent.signedOut) {
          Navigator.pushReplacementNamed(context, AppRoutes.teamJoin);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // For demo purposes, show login screen if not authenticated
    // but allow navigation to all screens
    if (!_isAuthenticated) {
      final currentRoute = ModalRoute.of(context)?.settings.name;

      // Show login for auth-specific routes
      if (currentRoute == '/login' || currentRoute == '/register') {
        return widget.child;
      }

      // For other routes, show content with auth prompt
      return widget.child;
    }

    return widget.child;
  }
}
