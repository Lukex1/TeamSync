import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teamsync_calendar/services/supabase_service.dart';
import '../../core/app_export.dart';
import './widgets/activity_feed_widget.dart';
import './widgets/invitation_code_widget.dart';
import './widgets/member_list_item_widget.dart';
import './widgets/team_header_widget.dart';
import './widgets/team_settings_bottom_sheet.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _teamName = "Development Team";
  String _currentThemeColor = "blue";
  String _invitationCode = "";
  bool _notificationsEnabled = true;
  bool _isCurrentUserAdmin = false;
  late SupabaseClient supabase;
  late String currentUserId;
  String _teamId = '';
  String _teamOwnerId = '';
  List<Map<String, dynamic>> _teamMembers = [];
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    supabase = SupabaseService.instance.client;
    currentUserId = supabase.auth.currentUser!.id;
  }

  bool _isDataLoaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      final String? args =
          ModalRoute.of(context)?.settings.arguments as String?;
      if (args != null && mounted) {
        setState(() {
          _teamId = args;
        });
        _loadTeamData();
        _isDataLoaded = true;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamData() async {
    if (_teamId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      // 1. Pobierz dane zespołu (bez zbędnego zapytania o team_id)
      final teamData = await supabase
          .from('teams')
          .select('id, name, invitation_code, owner_id')
          .eq('id', _teamId)
          .maybeSingle();

      if (teamData == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 2. Pobierz członków zespołu wraz z profilami
      final membersData = await supabase
          .from('team_members')
          .select('user_id, role, invitation_status, user_profiles(*)')
          .eq('team_id', _teamId);

      // 3. Pobierz ostatnie aktywności
      final activitiesData = await supabase
          .from('event_comments')
          .select('*, author:user_profiles(full_name), event:events(title)')
          .order('created_at', ascending: false)
          .limit(10);

      if (mounted) {
        setState(() {
          _teamName = teamData['name'] as String;
          _teamOwnerId = teamData['owner_id'] as String;
          _invitationCode = teamData['invitation_code'] as String;

          _teamMembers = membersData.map((member) {
            final profile = member['user_profiles'] as Map<String, dynamic>;
            return {
              'id': profile['id'],
              'name': profile['full_name'],
              'role': member['role'],
              'avatar': profile['avatar_url'],
              'isCurrentUser': profile['id'] == currentUserId,
              'isOnline': profile['is_active'],
            };
          }).toList();

          _isCurrentUserAdmin = _teamMembers.firstWhere(
                  (m) => m['isCurrentUser'],
                  orElse: () => {'role': 'member'})['role'] ==
              'admin';

          _recentActivities = activitiesData.map((activity) {
            final author = activity['author'] as Map<String, dynamic>;
            final event = activity['event'] as Map<String, dynamic>;
            return {
              'type': 'comment_added',
              'message':
                  '${author['full_name']} commented on "${event['title']}"',
              'timestamp': DateTime.parse(activity['created_at'] as String),
            };
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load team data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadTeamData();
  }

  void _shareInvitationCode() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Invitation Code',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'message',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('SMS'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Email'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('More Options'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showTeamSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TeamSettingsBottomSheet(
        currentTeamName: _teamName,
        currentThemeColor: _currentThemeColor,
        notificationsEnabled: _notificationsEnabled,
        isAdmin: _isCurrentUserAdmin,
        onLeaveTeam: _leaveTeam,
        onDeleteTeam: _deleteTeam,
        onTeamNameChanged: _updateTeamName,
        onThemeColorChanged: _updateThemeColor,
        onNotificationToggle: _toggleNotifications,
      ),
    );
  }

  Future<void> _removeMember(Map<String, dynamic> member) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${member['name']} from the team?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _teamMembers.removeWhere((m) => m['id'] == member['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${member['name']} has been removed from the team'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getErrorColor(true),
            ),
            child: Text('Remove'),
          ),
        ],
      ),
    );
    await supabase.from('team_members').delete().eq('user_id', member['id']);
  }

  Future<void> _changeRole(Map<String, dynamic> member) async {
    final newRole = member['role'] == 'admin' ? 'member' : 'admin';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role'),
        content: Text(
          'Change ${member['name']}\'s role to $newRole?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index =
                    _teamMembers.indexWhere((m) => m['id'] == member['id']);
                if (index != -1) {
                  _teamMembers[index]['role'] = newRole;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${member['name']} is now a $newRole'),
                ),
              );
            },
            child: Text('Change Role'),
          ),
        ],
      ),
    );
    await supabase
        .from('team_members')
        .update({'role': newRole}).eq('user_id', member['id']);
  }

  Future<void> _leaveTeam() async {
    await supabase.from('team_members').delete().eq('user_id', currentUserId);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/team-join-screen', (route) => false);
    }
  }

  Future<void> _deleteTeam() async {
    if (currentUserId != _teamOwnerId) {
      return;
    }
    await supabase.from('teams').delete().eq('id', _teamId);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/team-join-screen', (route) => false);
    }
  }

  Future<void> _updateTeamName(String newName) async {
    await supabase.from('teams').update({'name': newName}).eq('id', _teamId);
    if (mounted) {
      setState(() {
        _teamName = newName;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Team name updated to "$newName"')),
      );
    }
  }

  void _updateThemeColor(String color) {
    setState(() {
      _currentThemeColor = color;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Theme color updated')),
    );
  }

  void _toggleNotifications(bool enabled) {
    setState(() {
      _notificationsEnabled = enabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled ? 'Notifications enabled' : 'Notifications disabled',
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 2.h),
            Text(
              'Loading team members...',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            InvitationCodeWidget(
              invitationCode: _invitationCode,
              onShare: _shareInvitationCode,
            ),
            SizedBox(height: 2.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'group',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Team Members',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme
                                .lightTheme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_teamMembers.length}',
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _teamMembers.length,
                    itemBuilder: (context, index) {
                      final member = _teamMembers[index];
                      final isCurrentUser =
                          member['isCurrentUser'] as bool? ?? false;

                      return MemberListItemWidget(
                        member: member,
                        isCurrentUser: isCurrentUser,
                        isAdmin: _isCurrentUserAdmin,
                        onRemove:
                            !isCurrentUser ? () => _removeMember(member) : null,
                        onChangeRole:
                            !isCurrentUser ? () => _changeRole(member) : null,
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 2.h),
            Text(
              'Loading activities...',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            ActivityFeedWidget(activities: _recentActivities),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            TeamHeaderWidget(
              teamName: _teamName,
              memberCount: _teamMembers.length,
              onSettingsPressed: _showTeamSettings,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                labelStyle: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle:
                    AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Activity'),
                  Tab(text: 'Members'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActivityTab(),
                  _buildMembersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-event-screen'),
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 20,
        ),
        label: Text('New Event'),
      ),
    );
  }
}
