import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class TeamService {
  static TeamService? _instance;
  static TeamService get instance => _instance ??= TeamService._();

  TeamService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get all teams for current user
  Future<List<Map<String, dynamic>>> getUserTeams() async {
    try {
      final response = await _client
          .from('teams')
          .select('''
            *,
            team_members!inner(
              role,
              invitation_status,
              joined_at
            )
          ''')
          .eq('team_members.user_id', _client.auth.currentUser!.id)
          .eq('team_members.invitation_status', 'accepted');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch teams: $error');
    }
  }

  // Create a new team
  Future<Map<String, dynamic>> createTeam({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _client
          .from('teams')
          .insert({
            'name': name,
            'description': description,
            'owner_id': _client.auth.currentUser!.id,
          })
          .select()
          .single();

      // Automatically add creator as team member
      await _client.from('team_members').insert({
        'team_id': response['id'],
        'user_id': _client.auth.currentUser!.id,
        'role': 'admin',
        'invitation_status': 'accepted',
      });

      return response;
    } catch (error) {
      throw Exception('Failed to create team: $error');
    }
  }

  // Join team with invitation code
  Future<Map<String, dynamic>> joinTeamWithCode(String invitationCode) async {
    try {
      // Find team by invitation code
      final teamResponse = await _client
          .from('teams')
          .select()
          .eq('invitation_code', invitationCode)
          .eq('is_active', true)
          .single();

      // Check if user is already a member
      final existingMember = await _client
          .from('team_members')
          .select()
          .eq('team_id', teamResponse['id'])
          .eq('user_id', _client.auth.currentUser!.id)
          .maybeSingle();

      if (existingMember != null) {
        throw Exception('You are already a member of this team');
      }

      // Add user to team
      await _client.from('team_members').insert({
        'team_id': teamResponse['id'],
        'user_id': _client.auth.currentUser!.id,
        'role': 'member',
        'invitation_status': 'accepted',
      });

      return teamResponse;
    } catch (error) {
      throw Exception('Failed to join team: $error');
    }
  }

  // Get team details with members
  Future<Map<String, dynamic>> getTeamDetails(String teamId) async {
    try {
      final response = await _client.from('teams').select('''
            *,
            team_members(
              id,
              role,
              invitation_status,
              joined_at,
              user_profiles(
                id,
                full_name,
                email,
                avatar_url
              )
            )
          ''').eq('id', teamId).single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch team details: $error');
    }
  }

  // Get team members
  Future<List<Map<String, dynamic>>> getTeamMembers(String teamId) async {
    try {
      final response = await _client
          .from('team_members')
          .select('''
            *,
            user_profiles(
              id,
              full_name,
              email,
              avatar_url,
              role
            )
          ''')
          .eq('team_id', teamId)
          .eq('invitation_status', 'accepted')
          .order('joined_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch team members: $error');
    }
  }

  // Leave team
  Future<void> leaveTeam(String teamId) async {
    try {
      await _client
          .from('team_members')
          .delete()
          .eq('team_id', teamId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to leave team: $error');
    }
  }

  // Update team details (owner only)
  Future<void> updateTeam({
    required String teamId,
    required String name,
    String? description,
  }) async {
    try {
      await _client
          .from('teams')
          .update({
            'name': name,
            'description': description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', teamId)
          .eq('owner_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to update team: $error');
    }
  }

  // Remove team member (owner only)
  Future<void> removeMember({
    required String teamId,
    required String userId,
  }) async {
    try {
      await _client
          .from('team_members')
          .delete()
          .eq('team_id', teamId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Failed to remove member: $error');
    }
  }

  // Update member role (owner only)
  Future<void> updateMemberRole({
    required String teamId,
    required String userId,
    required String role,
  }) async {
    try {
      await _client
          .from('team_members')
          .update({'role': role})
          .eq('team_id', teamId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Failed to update member role: $error');
    }
  }
}
