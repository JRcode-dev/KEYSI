import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

// ─────────────────────────────────────────────
// BADGE DE NIVEL (rectángulo con efecto 3D)
// Muestra nivel enviado (dorado) y recibido (azul)
// ─────────────────────────────────────────────
class LevelBadge extends StatelessWidget {
  final int levelSent;
  final int levelReceived;
  final bool showBoth;
  final double scale;

  const LevelBadge({
    super.key,
    required this.levelSent,
    required this.levelReceived,
    this.showBoth = true,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (showBoth) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SingleBadge(
            level: levelSent,
            isSent: true,
            scale: scale,
          ),
          SizedBox(width: 4 * scale),
          _SingleBadge(
            level: levelReceived,
            isSent: false,
            scale: scale,
          ),
        ],
      );
    }
    return _SingleBadge(
      level: levelSent,
      isSent: true,
      scale: scale,
    );
  }
}

// ─────────────────────────────────────────────
// BADGE INDIVIDUAL
// ─────────────────────────────────────────────
class _SingleBadge extends StatelessWidget {
  final int level;
  final bool isSent;
  final double scale;

  const _SingleBadge({
    required this.level,
    required this.isSent,
    required this.scale,
  });

  Color get _baseColor {
    if (isSent) {
      return AppLevels.getLevelColor(level);
    }
    // Recibido siempre en tonos azules pero con intensidad por nivel
    if (level <= 25) return const Color(0xFF546E7A);
    if (level <= 50) return const Color(0xFF1565C0);
    if (level <= 75) return const Color(0xFF0288D1);
    if (level <= 100) return const Color(0xFF0097A7);
    return const Color(0xFF00838F);
  }

  Color get _lightColor => Color.lerp(_baseColor, Colors.white, 0.4)!;
  Color get _darkColor => Color.lerp(_baseColor, Colors.black, 0.4)!;

  @override
  Widget build(BuildContext context) {
    final width = 38.0 * scale;
    final height = 20.0 * scale;
    final fontSize = 11.0 * scale;
    final radius = 10.0 * scale;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_lightColor, _baseColor, _darkColor],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: _baseColor.withOpacity(0.6),
            blurRadius: 4 * scale,
            offset: Offset(0, 2 * scale),
          ),
          BoxShadow(
            color: _lightColor.withOpacity(0.3),
            blurRadius: 2 * scale,
            offset: Offset(0, -1 * scale),
          ),
        ],
        border: Border.all(
          color: _lightColor.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          '$level',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: _darkColor,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BADGE DE TÍTULO (Newcomer, VIP, Legend, etc.)
// ─────────────────────────────────────────────
class TitleBadge extends StatelessWidget {
  final String title;
  final double scale;

  const TitleBadge({
    super.key,
    required this.title,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppLevels.getTitleColor(title);
    final isRainbow = title == 'Vivra King/Queen';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * scale,
        vertical: 3 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        gradient: isRainbow
            ? const LinearGradient(
                colors: [
                  Color(0xFFFF0000),
                  Color(0xFFFF7700),
                  Color(0xFFFFFF00),
                  Color(0xFF00FF00),
                  Color(0xFF0000FF),
                  Color(0xFF8B00FF),
                ],
              )
            : LinearGradient(
                colors: [
                  Color.lerp(color, Colors.white, 0.3)!,
                  color,
                  Color.lerp(color, Colors.black, 0.3)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 6 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10 * scale,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              color: Colors.black54,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BARRA DE PROGRESO XP
// ─────────────────────────────────────────────
class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int level;
  final bool isSent; // true = dorado, false = azul

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.level,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    final progress = LevelHelpers.xpProgress(currentXp, level);
    final color = isSent
        ? AppLevels.getLevelColor(level)
        : const Color(0xFF0288D1);
    final label = isSent ? 'Enviado' : 'Recibido';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label · Nv $level',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            Text(
              NumberHelpers.compact(currentXp),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.cardLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PERFIL COMPLETO CON NIVELES (para ver en sala)
// ─────────────────────────────────────────────
class UserLevelInfo extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final int levelSent;
  final int levelReceived;
  final int xpSent;
  final int xpReceived;
  final bool showXpBars;

  const UserLevelInfo({
    super.key,
    required this.username,
    this.avatarUrl,
    required this.levelSent,
    required this.levelReceived,
    required this.xpSent,
    required this.xpReceived,
    this.showXpBars = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = AppLevels.getTitle(xpSent);

    return Column(
      children: [
        // Avatar
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CircleAvatar(
              radius: AppSizes.avatarLG / 2,
              backgroundColor: AppColors.cardLight,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      ImageHelpers.initials(username),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            // Badges de nivel superpuestos debajo del avatar
            Positioned(
              bottom: -8,
              child: LevelBadge(
                levelSent: levelSent,
                levelReceived: levelReceived,
                scale: 0.9,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Username
        Text(
          username,
          style: AppTextStyles.h3,
        ),

        const SizedBox(height: 6),

        // Título
        TitleBadge(title: title),

        // Barras XP opcionales
        if (showXpBars) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                XpProgressBar(
                  currentXp: xpSent,
                  level: levelSent,
                  isSent: true,
                ),
                const SizedBox(height: 8),
                XpProgressBar(
                  currentXp: xpReceived,
                  level: levelReceived,
                  isSent: false,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}