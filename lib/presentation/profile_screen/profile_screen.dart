import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teamsync_calendar/services/supabase_service.dart';
import 'widgets/avatar_widget.dart';
import 'widgets/change_avatar_button.dart';
import 'widgets/logout_button.dart';
import '../../core/app_export.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SupabaseClient supabase;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    supabase = SupabaseService.instance.client;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single() as Map<String, dynamic>;

      setState(() {
        userProfile = profile;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while loading profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userProfile == null) {
      return const Scaffold(
        body: Center(child: Text('not logged in')),
      );
    }

    final userId = userProfile!['id'] as String;
    final avatarUrl = userProfile!['avatar_url'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AvatarWidget(avatarUrl: avatarUrl),
                    SizedBox(height: 2.h),
                    Text(
                      userProfile!['full_name'] as String,
                      style: AppTheme.lightTheme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    ChangeAvatarButton(userId: userId),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: Center(
                child: SizedBox(
                  width: 50.w,
                  child: LogoutButton(
                    onLogout: () async {
                      await supabase.auth.signOut();
                      if (mounted)
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
