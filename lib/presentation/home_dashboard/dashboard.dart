import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import 'widgets/action_tile_widget.dart';
import 'widgets/team_list_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late SupabaseClient supabase;
  String? username;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    supabase = SupabaseService.instance.client;
    currentUserId = supabase.auth.currentUser!.id;
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select('full_name')
          .eq('id', currentUserId)
          .single();

      if (mounted) {
        setState(() {
          username = response['full_name'] as String;
        });
      }
    } catch (e) {
      print('Failed to load username: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> _teamsStream() {
    return supabase
        .from('user_teams')
        .stream(primaryKey: ['team_id', 'user_id'])
        .eq('user_id', currentUserId)
        .map((userTeams) {
          return userTeams.map((team) {
            return {'id': team['team_id'], 'name': team['team_name']};
          }).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    if (username == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Welcome back, $username')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ActionTileWidget(
                    title: 'Teams',
                    icon: Icons.people_alt,
                    route: '/team-join-screen'),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _teamsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final teams = snapshot.data ?? [];
                return TeamListWidget(teams: teams, isLoading: false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
