class UserModel {
  final int id;
  final String username;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final int coins;
  final int diamonds;
  final int xpSent;
  final int xpReceived;
  final int levelSent;
  final int levelReceived;
  final String role;
  final String? agencyId;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.bio,
    required this.coins,
    required this.diamonds,
    required this.xpSent,
    required this.xpReceived,
    required this.levelSent,
    required this.levelReceived,
    required this.role,
    this.agencyId,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      coins: json['coins'] ?? 0,
      diamonds: json['diamonds'] ?? 0,
      xpSent: json['xp_sent'] ?? 0,
      xpReceived: json['xp_received'] ?? 0,
      levelSent: json['level_sent'] ?? 1,
      levelReceived: json['level_received'] ?? 1,
      role: json['role'] ?? 'user',
      agencyId: json['agency_id']?.toString(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
      'coins': coins,
      'diamonds': diamonds,
      'xp_sent': xpSent,
      'xp_received': xpReceived,
      'level_sent': levelSent,
      'level_received': levelReceived,
      'role': role,
      'agency_id': agencyId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Título según USD enviados
  String get title {
    final usd = xpSent / 25000;
    if (usd >= 50000) return 'Vivra King/Queen';
    if (usd >= 25000) return 'Legend';
    if (usd >= 10000) return 'Aristocrat';
    if (usd >= 5000) return 'Diamond';
    if (usd >= 2000) return 'Elite';
    if (usd >= 500) return 'VIP';
    if (usd >= 200) return 'Super Fan';
    if (usd >= 50) return 'Fan';
    if (usd >= 10) return 'Supporter';
    return 'Newcomer';
  }

  // Color del nivel enviado
  String get levelSentColor {
    if (levelSent <= 25) return 'grey';
    if (levelSent <= 50) return 'blue';
    if (levelSent <= 75) return 'purple';
    if (levelSent <= 100) return 'gold';
    return 'red';
  }

  // Color del nivel recibido
  String get levelReceivedColor {
    if (levelReceived <= 25) return 'grey';
    if (levelReceived <= 50) return 'blue';
    if (levelReceived <= 75) return 'purple';
    if (levelReceived <= 100) return 'gold';
    return 'red';
  }

  bool get isAdmin => role == 'admin';
  bool get isHost => role == 'host' || role == 'admin';

  UserModel copyWith({
    int? coins,
    int? diamonds,
    int? xpSent,
    int? xpReceived,
    int? levelSent,
    int? levelReceived,
    String? avatarUrl,
    String? bio,
    String? username,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      xpSent: xpSent ?? this.xpSent,
      xpReceived: xpReceived ?? this.xpReceived,
      levelSent: levelSent ?? this.levelSent,
      levelReceived: levelReceived ?? this.levelReceived,
      role: role,
      agencyId: agencyId,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}