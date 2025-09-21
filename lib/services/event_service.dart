import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class EventService {
  static EventService? _instance;
  static EventService get instance => _instance ??= EventService._();

  EventService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get events for user's teams
  Future<List<Map<String, dynamic>>> getUserEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client.from('events').select('''
            *,
            creator:user_profiles!creator_id(
              id,
              full_name,
              avatar_url
            ),
            team:teams(
              id,
              name
            ),
            event_attendees(
              id,
              user_id,
              attendance_status
            )
          ''');

      // Apply date filters if provided
      if (startDate != null) {
        query = query.gte('event_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('event_date', endDate.toIso8601String());
      }

      final response = await query.order('event_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch events: $error');
    }
  }

  // Get events for specific team
  Future<List<Map<String, dynamic>>> getTeamEvents(String teamId) async {
    try {
      final response = await _client.from('events').select('''
            *,
            creator:user_profiles!creator_id(
              id,
              full_name,
              avatar_url
            ),
            event_attendees(
              id,
              user_id,
              attendance_status,
              user_profiles(
                id,
                full_name,
                avatar_url
              )
            )
          ''').eq('team_id', teamId).order('event_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch team events: $error');
    }
  }

  // Create new event
  Future<Map<String, dynamic>> createEvent({
    required String title,
    String? description,
    String? location,
    required DateTime eventDate,
    int durationMinutes = 60,
    required String teamId,
    int? maxParticipants,
    bool isRecurring = false,
  }) async {
    try {
      final response = await _client
          .from('events')
          .insert({
            'title': title,
            'description': description,
            'location': location,
            'event_date': eventDate.toIso8601String(),
            'duration_minutes': durationMinutes,
            'creator_id': _client.auth.currentUser!.id,
            'team_id': teamId,
            'max_participants': maxParticipants,
            'is_recurring': isRecurring,
            'event_status': 'published',
          })
          .select()
          .single();

      // Automatically add creator as attendee
      await _client.from('event_attendees').insert({
        'event_id': response['id'],
        'user_id': _client.auth.currentUser!.id,
        'attendance_status': 'going',
      });

      return response;
    } catch (error) {
      throw Exception('Failed to create event: $error');
    }
  }

  // Get event details
  Future<Map<String, dynamic>> getEventDetails(String eventId) async {
    try {
      final response = await _client.from('events').select('''
            *,
            creator:user_profiles!creator_id(
              id,
              full_name,
              avatar_url
            ),
            team:teams(
              id,
              name
            ),
            event_attendees(
              id,
              user_id,
              attendance_status,
              response_date,
              notes,
              user_profiles(
                id,
                full_name,
                avatar_url
              )
            ),
            event_comments(
              id,
              content,
              created_at,
              author:user_profiles!author_id(
                id,
                full_name,
                avatar_url
              )
            )
          ''').eq('id', eventId).single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch event details: $error');
    }
  }

  // Update event attendance
  Future<void> updateAttendance({
    required String eventId,
    required String status,
    String? notes,
  }) async {
    try {
      final existingAttendance = await _client
          .from('event_attendees')
          .select()
          .eq('event_id', eventId)
          .eq('user_id', _client.auth.currentUser!.id)
          .maybeSingle();

      if (existingAttendance != null) {
        // Update existing attendance
        await _client.from('event_attendees').update({
          'attendance_status': status,
          'notes': notes,
          'response_date': DateTime.now().toIso8601String(),
        }).eq('id', existingAttendance['id']);
      } else {
        // Create new attendance record
        await _client.from('event_attendees').insert({
          'event_id': eventId,
          'user_id': _client.auth.currentUser!.id,
          'attendance_status': status,
          'notes': notes,
        });
      }
    } catch (error) {
      throw Exception('Failed to update attendance: $error');
    }
  }

  // Add comment to event
  Future<Map<String, dynamic>> addComment({
    required String eventId,
    required String content,
  }) async {
    try {
      final response = await _client.from('event_comments').insert({
        'event_id': eventId,
        'author_id': _client.auth.currentUser!.id,
        'content': content,
      }).select('''
            *,
            author:user_profiles!author_id(
              id,
              full_name,
              avatar_url
            )
          ''').single();

      return response;
    } catch (error) {
      throw Exception('Failed to add comment: $error');
    }
  }

  // Update event
  Future<void> updateEvent({
    required String eventId,
    String? title,
    String? description,
    String? location,
    DateTime? eventDate,
    int? durationMinutes,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (location != null) updateData['location'] = location;
      if (eventDate != null) {
        updateData['event_date'] = eventDate.toIso8601String();
      }
      if (durationMinutes != null) {
        updateData['duration_minutes'] = durationMinutes;
      }
      if (status != null) updateData['event_status'] = status;

      await _client
          .from('events')
          .update(updateData)
          .eq('id', eventId)
          .eq('creator_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to update event: $error');
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _client
          .from('events')
          .delete()
          .eq('id', eventId)
          .eq('creator_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to delete event: $error');
    }
  }

  // Get upcoming events for user
  Future<List<Map<String, dynamic>>> getUpcomingEvents({int limit = 10}) async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            creator:user_profiles!creator_id(
              id,
              full_name
            ),
            team:teams(
              id,
              name
            )
          ''')
          .gte('event_date', DateTime.now().toIso8601String())
          .eq('event_status', 'published')
          .order('event_date', ascending: true)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch upcoming events: $error');
    }
  }
}
