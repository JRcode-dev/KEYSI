import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// COLORES PRINCIPALES
// ─────────────────────────────────────────────
class AppColors {
  // Fondos
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color card = Color(0xFF1E1E3A);
  static const Color cardLight = Color(0xFF2A2A4A);

  // Primarios
  static const Color primary = Color(0xFFE91E8C);
  static const Color primaryDark = Color(0xFFB0166A);
  static const Color secondary = Color(0xFF7C4DFF);

  // Texto
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF666666);

  // Estado
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Niveles - color por rango
  static const Color levelGrey = Color(0xFF9E9E9E);
  static const Color levelBlue = Color(0xFF2196F3);
  static const Color levelPurple = Color(0xFF9C27B0);
  static const Color levelGold = Color(0xFFFFD700);
  static const Color levelRed = Color(0xFFF44336);

  // Economía
  static const Color coins = Color(0xFFFFD700);      // monedas doradas
  static const Color diamonds = Color(0xFF00BCD4);   // diamantes cyan

  // Cohetes
  static const Color rocket = Color(0xFFFF5722);
}

// ─────────────────────────────────────────────
// TAMAÑOS Y ESPACIADOS
// ─────────────────────────────────────────────
class AppSizes {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 12.0;
  static const double paddingLG = 16.0;
  static const double paddingXL = 24.0;
  static const double paddingXXL = 32.0;

  // Border radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  // Iconos
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // Avatar
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 96.0;

  // Asientos en sala
  static const double seatSize = 64.0;
}

// ─────────────────────────────────────────────
// TEXTOS Y FUENTES
// ─────────────────────────────────────────────
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h2 = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h3 = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  static const TextStyle bodySmall = TextStyle(
    color: Color(0xFFB0B0B0),
    fontSize: 12,
  );

  static const TextStyle caption = TextStyle(
    color: Color(0xFF666666),
    fontSize: 11,
  );

  static const TextStyle button = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle coins = TextStyle(
    color: Color(0xFFFFD700),
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle diamonds = TextStyle(
    color: Color(0xFF00BCD4),
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}

// ─────────────────────────────────────────────
// ECONOMÍA
// ─────────────────────────────────────────────
class AppEconomy {
  // Conversión
  static const int coinsPerUsd = 25000;
  static const int diamondsPerUsd = 25000;
  static const int diamondsToWithdrawPerUsd = 50000;
  static const int minWithdrawDiamonds = 500000; // = 10 USD

  // Lucky Gifts
  static const double luckyGiftDiamondPercent = 0.10; // 10%
  static const int luckyGiftXpMultiplier = 10; // XP suma 10x menos

  // Conversión diamantes → monedas
  static const double diamondsToCoinsRate = 0.50; // 50% pérdida

  static String formatCoins(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    }
    return '$amount';
  }

  static String formatUsd(double usd) {
    if (usd >= 1000) {
      return '\$${(usd / 1000).toStringAsFixed(1)}K';
    }
    return '\$${usd.toStringAsFixed(2)}';
  }

  static double coinsToUsd(int coins) => coins / coinsPerUsd;
  static double diamondsToUsd(int diamonds) =>
      diamonds / diamondsToWithdrawPerUsd;
  static int usdToCoins(double usd) => (usd * coinsPerUsd).round();
}

// ─────────────────────────────────────────────
// NIVELES
// ─────────────────────────────────────────────
class AppLevels {
  static const int maxLevel = 125;
  static const int baseXp = 10000;
  static const double incrementPerLevel = 0.15;

  static Color getLevelColor(int level) {
    if (level <= 25) return AppColors.levelGrey;
    if (level <= 50) return AppColors.levelBlue;
    if (level <= 75) return AppColors.levelPurple;
    if (level <= 100) return AppColors.levelGold;
    return AppColors.levelRed;
  }

  static String getLevelColorName(int level) {
    if (level <= 25) return 'grey';
    if (level <= 50) return 'blue';
    if (level <= 75) return 'purple';
    if (level <= 100) return 'gold';
    return 'red';
  }

  static String getTitle(int xpSent) {
    final usd = xpSent / AppEconomy.coinsPerUsd;
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

  static Color getTitleColor(String title) {
    switch (title) {
      case 'Newcomer':
        return AppColors.levelGrey;
      case 'Supporter':
        return AppColors.levelBlue;
      case 'Fan':
        return AppColors.levelPurple;
      case 'Super Fan':
        return AppColors.levelGold;
      case 'VIP':
        return const Color(0xFFFF9800);
      case 'Elite':
        return AppColors.levelRed;
      case 'Diamond':
        return const Color(0xFF00BCD4);
      case 'Aristocrat':
        return const Color(0xFFFFD700);
      case 'Legend':
        return const Color(0xFFFF1744);
      case 'Vivra King/Queen':
        return AppColors.primary;
      default:
        return AppColors.levelGrey;
    }
  }
}

// ─────────────────────────────────────────────
// COHETES
// ─────────────────────────────────────────────
class AppRockets {
  static const List<Map<String, dynamic>> rockets = [
    {
      'level': 1,
      'cost': 200000,
      'top1': 4000,
      'top2': 3000,
      'top3': 2500,
    },
    {
      'level': 2,
      'cost': 400000,
      'top1': 10000,
      'top2': 7500,
      'top3': 5000,
    },
    {
      'level': 3,
      'cost': 700000,
      'top1': 25000,
      'top2': 17500,
      'top3': 12500,
    },
    {
      'level': 4,
      'cost': 1200000,
      'top1': 62500,
      'top2': 50000,
      'top3': 37500,
    },
    {
      'level': 5,
      'cost': 2000000,
      'top1': 125000,
      'top2': 100000,
      'top3': 75000,
    },
    {
      'level': 6,
      'cost': 3500000,
      'top1': 250000,
      'top2': 200000,
      'top3': 150000,
    },
    {
      'level': 7,
      'cost': 6000000,
      'top1': 150000,
      'top2': 125000,
      'top3': 100000,
    },
  ];

  static Map<String, dynamic> getRocket(int level) {
    final idx = (level - 1) % rockets.length;
    return rockets[idx];
  }
}

// ─────────────────────────────────────────────
// ANIMACIONES
// ─────────────────────────────────────────────
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration gift2s = Duration(seconds: 2);
  static const Duration gift3s = Duration(seconds: 3);
  static const Duration gift5s = Duration(seconds: 5);
}

// ─────────────────────────────────────────────
// CATEGORÍAS DE SALAS
// ─────────────────────────────────────────────
class AppRoomCategories {
  static const List<Map<String, String>> categories = [
    {'id': 'general', 'label': 'General', 'emoji': '🌐'},
    {'id': 'music', 'label': 'Música', 'emoji': '🎵'},
    {'id': 'gaming', 'label': 'Gaming', 'emoji': '🎮'},
    {'id': 'chat', 'label': 'Chat', 'emoji': '💬'},
    {'id': 'education', 'label': 'Educación', 'emoji': '📚'},
    {'id': 'entertainment', 'label': 'Entretenimiento', 'emoji': '🎭'},
  ];

  static String getEmoji(String categoryId) {
    final cat = categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => {'emoji': '🌐'},
    );
    return cat['emoji'] ?? '🌐';
  }

  static String getLabel(String categoryId) {
    final cat = categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => {'label': 'General'},
    );
    return cat['label'] ?? 'General';
  }
}