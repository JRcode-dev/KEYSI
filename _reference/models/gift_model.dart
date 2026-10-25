class GiftModel {
  final int id;
  final String name;
  final String? imageUrl;
  final String? animationUrl;
  final int price;
  final bool hasAnimation;
  final int animationDuration;
  final bool isActive;
  final String type; // 'normal' | 'lucky' | 'custom'

  GiftModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.animationUrl,
    required this.price,
    required this.hasAnimation,
    required this.animationDuration,
    required this.isActive,
    required this.type,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'],
      animationUrl: json['animation_url'],
      price: json['price'] ?? 0,
      hasAnimation: json['has_animation'] ?? false,
      animationDuration: json['animation_duration'] ?? 0,
      isActive: json['is_active'] ?? true,
      type: json['type'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'animation_url': animationUrl,
      'price': price,
      'has_animation': hasAnimation,
      'animation_duration': animationDuration,
      'is_active': isActive,
      'type': type,
    };
  }

  bool get isNormal => type == 'normal';
  bool get isLucky => type == 'lucky';
  bool get isCustom => type == 'custom';

  // Precio formateado con separador de miles
  String get priceFormatted {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K';
    }
    return '$price';
  }

  // Duración de animación en segundos
  String get animationLabel {
    if (!hasAnimation) return 'Sin animación';
    return '${animationDuration}s';
  }

  // Categoría por precio
  String get tier {
    if (price <= 100) return 'basic';
    if (price <= 1000) return 'standard';
    if (price <= 10000) return 'premium';
    if (price <= 100000) return 'elite';
    return 'legendary';
  }

  // Color por tier
  int get tierColor {
    switch (tier) {
      case 'basic':
        return 0xFF9E9E9E; // gris
      case 'standard':
        return 0xFF2196F3; // azul
      case 'premium':
        return 0xFF9C27B0; // morado
      case 'elite':
        return 0xFFFFD700; // dorado
      case 'legendary':
        return 0xFFE91E8C; // rosa/rojo
      default:
        return 0xFF9E9E9E;
    }
  }
}

// ─────────────────────────────────────────────
// MODELO DE REGALO ENVIADO (historial)
// ─────────────────────────────────────────────
class GiftTransaction {
  final int id;
  final int senderId;
  final String senderUsername;
  final String? senderAvatar;
  final int receiverId;
  final String receiverUsername;
  final int giftId;
  final String giftName;
  final String? giftImageUrl;
  final int price;
  final int quantity;
  final int totalPrice;
  final DateTime createdAt;

  GiftTransaction({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    this.senderAvatar,
    required this.receiverId,
    required this.receiverUsername,
    required this.giftId,
    required this.giftName,
    this.giftImageUrl,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
  });

  factory GiftTransaction.fromJson(Map<String, dynamic> json) {
    return GiftTransaction(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      senderUsername: json['sender_username'] ?? '',
      senderAvatar: json['sender_avatar'],
      receiverId: json['receiver_id'] ?? 0,
      receiverUsername: json['receiver_username'] ?? '',
      giftId: json['gift_id'] ?? 0,
      giftName: json['gift_name'] ?? '',
      giftImageUrl: json['gift_image_url'],
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 1,
      totalPrice: json['total_price'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
// MODELO DE LUCKY GIFT (resultado)
// ─────────────────────────────────────────────
class LuckyGiftResult {
  final int id;
  final int giftId;
  final String giftName;
  final int betAmount;
  final int multiplier;
  final int winAmount;
  final bool isWorldBanner; // true si multiplier > 100
  final DateTime createdAt;

  LuckyGiftResult({
    required this.id,
    required this.giftId,
    required this.giftName,
    required this.betAmount,
    required this.multiplier,
    required this.winAmount,
    required this.isWorldBanner,
    required this.createdAt,
  });

  factory LuckyGiftResult.fromJson(Map<String, dynamic> json) {
    return LuckyGiftResult(
      id: json['id'] ?? 0,
      giftId: json['gift_id'] ?? 0,
      giftName: json['gift_name'] ?? '',
      betAmount: json['bet_amount'] ?? 0,
      multiplier: json['multiplier'] ?? 1,
      winAmount: json['win_amount'] ?? 0,
      isWorldBanner: (json['multiplier'] ?? 1) > 100,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  String get resultLabel => 'x$multiplier';

  String get winFormatted {
    if (winAmount >= 1000000) {
      return '${(winAmount / 1000000).toStringAsFixed(1)}M';
    }
    if (winAmount >= 1000) {
      return '${(winAmount / 1000).toStringAsFixed(0)}K';
    }
    return '$winAmount';
  }
}