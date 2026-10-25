class RoomModel {
  final int id;
  final String name;
  final String? description;
  final String? coverUrl;
  final int ownerId;
  final String ownerUsername;
  final String? ownerAvatar;
  final int maxSeats;
  final bool isLive;
  final bool isPrivate;
  final String? password;
  final int viewerCount;
  final int totalGiftsReceived;
  final String category;
  final DateTime createdAt;
  final List<RoomSeat> seats;

  RoomModel({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.ownerId,
    required this.ownerUsername,
    this.ownerAvatar,
    required this.maxSeats,
    required this.isLive,
    required this.isPrivate,
    this.password,
    required this.viewerCount,
    required this.totalGiftsReceived,
    required this.category,
    required this.createdAt,
    required this.seats,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    List<RoomSeat> seatList = [];
    if (json['seats'] != null) {
      seatList = (json['seats'] as List)
          .map((s) => RoomSeat.fromJson(s))
          .toList();
    }

    return RoomModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      coverUrl: json['cover_url'],
      ownerId: json['owner_id'] ?? 0,
      ownerUsername: json['owner_username'] ?? '',
      ownerAvatar: json['owner_avatar'],
      maxSeats: json['max_seats'] ?? 5,
      isLive: json['is_live'] ?? false,
      isPrivate: json['is_private'] ?? false,
      password: json['password'],
      viewerCount: json['viewer_count'] ?? 0,
      totalGiftsReceived: json['total_gifts_received'] ?? 0,
      category: json['category'] ?? 'general',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      seats: seatList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_url': coverUrl,
      'owner_id': ownerId,
      'owner_username': ownerUsername,
      'owner_avatar': ownerAvatar,
      'max_seats': maxSeats,
      'is_live': isLive,
      'is_private': isPrivate,
      'viewer_count': viewerCount,
      'total_gifts_received': totalGiftsReceived,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Asientos ocupados
  List<RoomSeat> get occupiedSeats =>
      seats.where((s) => s.userId != null).toList();

  // Asientos libres
  List<RoomSeat> get freeSeats =>
      seats.where((s) => s.userId == null).toList();

  bool get hasFreeSeats => freeSeats.isNotEmpty;

  // Etiqueta de categoría
  String get categoryLabel {
    switch (category) {
      case 'music':
        return '🎵 Música';
      case 'gaming':
        return '🎮 Gaming';
      case 'chat':
        return '💬 Chat';
      case 'education':
        return '📚 Educación';
      case 'entertainment':
        return '🎭 Entretenimiento';
      default:
        return '🌐 General';
    }
  }

  RoomModel copyWith({
    bool? isLive,
    int? viewerCount,
    int? totalGiftsReceived,
    List<RoomSeat>? seats,
    String? coverUrl,
    String? name,
    String? description,
  }) {
    return RoomModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      ownerId: ownerId,
      ownerUsername: ownerUsername,
      ownerAvatar: ownerAvatar,
      maxSeats: maxSeats,
      isLive: isLive ?? this.isLive,
      isPrivate: isPrivate,
      password: password,
      viewerCount: viewerCount ?? this.viewerCount,
      totalGiftsReceived: totalGiftsReceived ?? this.totalGiftsReceived,
      category: category,
      createdAt: createdAt,
      seats: seats ?? this.seats,
    );
  }
}

// ─────────────────────────────────────────────
// MODELO DE ASIENTO
// ─────────────────────────────────────────────
class RoomSeat {
  final int seatNumber;
  final int? userId;
  final String? username;
  final String? avatarUrl;
  final bool isMuted;
  final bool isLocked;
  final int levelSent;
  final int levelReceived;

  RoomSeat({
    required this.seatNumber,
    this.userId,
    this.username,
    this.avatarUrl,
    required this.isMuted,
    required this.isLocked,
    required this.levelSent,
    required this.levelReceived,
  });

  factory RoomSeat.fromJson(Map<String, dynamic> json) {
    return RoomSeat(
      seatNumber: json['seat_number'] ?? 0,
      userId: json['user_id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      isMuted: json['is_muted'] ?? false,
      isLocked: json['is_locked'] ?? false,
      levelSent: json['level_sent'] ?? 1,
      levelReceived: json['level_received'] ?? 1,
    );
  }

  bool get isEmpty => userId == null;
  bool get isOccupied => userId != null;

  RoomSeat copyWith({
    int? userId,
    String? username,
    String? avatarUrl,
    bool? isMuted,
    bool? isLocked,
  }) {
    return RoomSeat(
      seatNumber: seatNumber,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMuted: isMuted ?? this.isMuted,
      isLocked: isLocked ?? this.isLocked,
      levelSent: levelSent,
      levelReceived: levelReceived,
    );
  }
}