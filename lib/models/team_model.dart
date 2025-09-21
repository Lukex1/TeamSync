class Team {
  final String id;
  final String name;
  final String? description;
  final String invitationCode;
  final String ownerId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TeamMember>? members;

  Team({
    required this.id,
    required this.name,
    this.description,
    required this.invitationCode,
    required this.ownerId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.members,
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
      members: map['team_members'] != null
          ? (map['team_members'] as List)
              .map((m) => TeamMember.fromMap(m))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'invitation_code': invitationCode,
      'owner_id': ownerId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TeamMember {
  final String id;
  final String teamId;
  final String userId;
  final String role;
  final String invitationStatus;
  final DateTime joinedAt;
  final UserProfile? userProfile;

  TeamMember({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.role,
    required this.invitationStatus,
    required this.joinedAt,
    this.userProfile,
  });

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    return TeamMember(
      id: map['id'] ?? '',
      teamId: map['team_id'] ?? '',
      userId: map['user_id'] ?? '',
      role: map['role'] ?? 'member',
      invitationStatus: map['invitation_status'] ?? 'pending',
      joinedAt:
          DateTime.parse(map['joined_at'] ?? DateTime.now().toIso8601String()),
      userProfile: map['user_profiles'] != null
          ? UserProfile.fromMap(map['user_profiles'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'team_id': teamId,
      'user_id': userId,
      'role': role,
      'invitation_status': invitationStatus,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

// Import UserProfile model
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
