import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

// ─────────────────────────────────────────────
// FORMATO DE NÚMEROS
// ─────────────────────────────────────────────
class NumberHelpers {
  // 1500 → "1.5K" | 1000000 → "1M"
  static String compact(int number) {
    if (number >= 1000000) {
      final val = number / 1000000;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      final val = number / 1000;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)}K';
    }
    return '$number';
  }

  // 1500 → "1,500"
  static String withCommas(int number) {
    return NumberFormat('#,###').format(number);
  }

  // Monedas con ícono
  static String coins(int amount) => '🪙 ${compact(amount)}';

  // Diamantes con ícono
  static String diamonds(int amount) => '💎 ${compact(amount)}';

  // USD formateado
  static String usd(double amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Porcentaje
  static String percent(double value) =>
      '${(value * 100).toStringAsFixed(1)}%';
}

// ─────────────────────────────────────────────
// FORMATO DE FECHAS
// ─────────────────────────────────────────────
class DateHelpers {
  // "hace 5 minutos" / "hace 2 horas" / "hace 3 días"
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'ahora mismo';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    if (diff.inDays < 30) return 'hace ${(diff.inDays / 7).floor()}sem';
    if (diff.inDays < 365) return 'hace ${(diff.inDays / 30).floor()}mes';
    return 'hace ${(diff.inDays / 365).floor()}año';
  }

  // "14:35"
  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date.toLocal());
  }

  // "26 ago 2026"
  static String date(DateTime date) {
    return DateFormat('d MMM yyyy', 'es').format(date.toLocal());
  }

  // "26 ago 2026 · 14:35"
  static String full(DateTime date) {
    return DateFormat('d MMM yyyy · HH:mm', 'es').format(date.toLocal());
  }

  // Desde string ISO
  static String timeAgoFromString(String? isoString) {
    if (isoString == null) return '';
    try {
      return timeAgo(DateTime.parse(isoString));
    } catch (_) {
      return '';
    }
  }

  static String timeFromString(String? isoString) {
    if (isoString == null) return '';
    try {
      return time(DateTime.parse(isoString));
    } catch (_) {
      return '';
    }
  }
}

// ─────────────────────────────────────────────
// VALIDACIONES
// ─────────────────────────────────────────────
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'El email es requerido';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Email inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.isEmpty) return 'El usuario es requerido';
    if (value.length < 3) return 'Mínimo 3 caracteres';
    if (value.length > 20) return 'Máximo 20 caracteres';
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!regex.hasMatch(value)) {
      return 'Solo letras, números y guión bajo';
    }
    return null;
  }

  static String? required(String? value, [String field = 'Este campo']) {
    if (value == null || value.trim().isEmpty) return '$field es requerido';
    return null;
  }

  static String? minAmount(int? value, int min) {
    if (value == null) return 'Ingresa un monto';
    if (value < min) return 'Mínimo ${NumberHelpers.compact(min)}';
    return null;
  }
}

// ─────────────────────────────────────────────
// SNACKBARS Y DIÁLOGOS
// ─────────────────────────────────────────────
class UIHelpers {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Diálogo de confirmación
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        title: Text(title,
            style: AppTextStyles.h3.copyWith(color: Colors.white)),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText,
                style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDanger ? AppColors.error : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Loading dialog
  static void showLoading(BuildContext context, [String msg = 'Cargando...']) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(width: 16),
            Text(msg, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

// ─────────────────────────────────────────────
// HELPERS DE NIVEL
// ─────────────────────────────────────────────
class LevelHelpers {
  // Color Flutter según nombre de color
  static Color colorFromName(String colorName) {
    switch (colorName) {
      case 'blue':
        return AppColors.levelBlue;
      case 'purple':
        return AppColors.levelPurple;
      case 'gold':
        return AppColors.levelGold;
      case 'red':
        return AppColors.levelRed;
      default:
        return AppColors.levelGrey;
    }
  }

  // Progreso XP al siguiente nivel (0.0 a 1.0)
  static double xpProgress(int currentXp, int currentLevel) {
    if (currentLevel >= AppLevels.maxLevel) return 1.0;
    final currentRequired = _xpForLevel(currentLevel);
    final nextRequired = _xpForLevel(currentLevel + 1);
    final progress = (currentXp - currentRequired) /
        (nextRequired - currentRequired);
    return progress.clamp(0.0, 1.0);
  }

  static int _xpForLevel(int level) {
    double total = 0;
    double base = AppLevels.baseXp.toDouble();
    for (int i = 1; i < level; i++) {
      total += base * pow(1 + AppLevels.incrementPerLevel, i - 1);
    }
    return total.round();
  }

  static double pow(double base, double exp) {
    if (exp == 0) return 1;
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}

// ─────────────────────────────────────────────
// HELPERS DE IMAGEN
// ─────────────────────────────────────────────
class ImageHelpers {
  // Iniciales para avatar placeholder
  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Valida si una URL es válida
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }
}