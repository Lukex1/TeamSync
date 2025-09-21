import 'dart:async';
import 'package:flutter/material.dart';
import 'package:teamsync_calendar/core/app_export.dart';
import 'package:teamsync_calendar/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    // Subskrybujemy strumień zmian stanu uwierzytelnienia
    _authStateSubscription =
        SupabaseService.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.initialSession) {
        // Ta logika jest wywoływana tylko raz, po załadowaniu początkowej sesji
        _checkAuthAndLoadData(data.session);
      }
    });
  }

  // Nowa asynchroniczna funkcja do sprawdzania sesji i ładowania danych
  Future<void> _checkAuthAndLoadData(Session? session) async {
    // Upewniamy się, że widget nadal jest w drzewie
    if (!mounted) return;

    if (session != null) {
      // Użytkownik jest zalogowany, więc pobieramy dane z bazy
      try {
        final userData = await _fetchUserData(session.user.id);
        // Po pomyślnym załadowaniu danych przechodzimy do pulpitu
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.homeDashboard,
            arguments: userData,
          );
        }
      } catch (e) {
        // Obsługa błędu, np. przekierowanie do strony błędu lub logowanie
        debugPrint('Błąd podczas ładowania danych użytkownika: $e');
        if (mounted) {
          // Na wypadek błędu przekierowujemy na ekran rejestracji
          Navigator.of(context).pushReplacementNamed(AppRoutes.registration);
        }
      }
    } else {
      // Użytkownik nie jest zalogowany
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.registration);
      }
    }
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    final response = await SupabaseService.instance.client
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
