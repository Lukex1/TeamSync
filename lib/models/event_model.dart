class Event {
  final String id;
  final String title;
  final String? description;
  final String? location;
  final DateTime eventDate;
  final int durationMinutes;
  final String eventStatus;
  final String? creatorId;
  final String teamId;
  final int? maxParticipants;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? creator;
  final Team? team;
  final List<EventAttendee>? attendees;
  final List<EventComment>? comments;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.eventDate,
    required this.durationMinutes,
    required this.eventStatus,
    this.creatorId,
    required this.teamId,
    this.maxParticipants,
    required this.isRecurring,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
    this.team,
    this.attendees,
    this.comments,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      location: map['location'],
      eventDate:
          DateTime.parse(map['event_date'] ?? DateTime.now().toIso8601String()),
      durationMinutes: map['duration_minutes'] ?? 60,
      eventStatus: map['event_status'] ?? 'draft',
      creatorId: map['creator_id'],
      teamId: map['team_id'] ?? '',
      maxParticipants: map['max_participants'],
      isRecurring: map['is_recurring'] ?? false,
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
      creator:
          map['creator'] != null ? UserProfile.fromMap(map['creator']) : null,
      team: map['team'] != null ? Team.fromMap(map['team']) : null,
      attendees: map['event_attendees'] != null
          ? (map['event_attendees'] as List)
              .map((a) => EventAttendee.fromMap(a))
              .toList()
          : null,
      comments: map['event_comments'] != null
          ? (map['event_comments'] as List)
              .map((c) => EventComment.fromMap(c))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'event_date': eventDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'event_status': eventStatus,
      'creator_id': creatorId,
      'team_id': teamId,
      'max_participants': maxParticipants,
      'is_recurring': isRecurring,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class EventAttendee {
  final String id;
  final String eventId;
  final String userId;
  final String attendanceStatus;
  final DateTime responseDate;
  final String? notes;
  final UserProfile? userProfile;

  EventAttendee({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.attendanceStatus,
    required this.responseDate,
    this.notes,
    this.userProfile,
  });

  factory EventAttendee.fromMap(Map<String, dynamic> map) {
    return EventAttendee(
      id: map['id'] ?? '',
      eventId: map['event_id'] ?? '',
      userId: map['user_id'] ?? '',
      attendanceStatus: map['attendance_status'] ?? 'pending',
      responseDate: DateTime.parse(
          map['response_date'] ?? DateTime.now().toIso8601String()),
      notes: map['notes'],
      userProfile: map['user_profiles'] != null
          ? UserProfile.fromMap(map['user_profiles'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'attendance_status': attendanceStatus,
      'response_date': responseDate.toIso8601String(),
      'notes': notes,
    };
  }
}

class EventComment {
  final String id;
  final String eventId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? author;

  EventComment({
    required this.id,
    required this.eventId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory EventComment.fromMap(Map<String, dynamic> map) {
    return EventComment(
      id: map['id'] ?? '',
      eventId: map['event_id'] ?? '',
      authorId: map['author_id'] ?? '',
      content: map['content'] ?? '',
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
      author: map['author'] != null ? UserProfile.fromMap(map['author']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'author_id': authorId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Import required models
class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      role: map['role'] ?? 'member',
      avatarUrl: map['avatar_url'],
      isActive: map['is_active'] ?? true,
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Team {
  final String id;
  final String name;
  final String? description;
  final String invitationCode;
  final String ownerId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Team({
    required this.id,
    required this.name,
    this.description,
    required this.invitationCode,
    required this.ownerId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      invitationCode: map['invitation_code'] ?? '',
      ownerId: map['owner_id'] ?? '',
      isActive: map['is_active'] ?? true,
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
