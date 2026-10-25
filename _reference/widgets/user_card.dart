import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'level_badge.dart';

// ─────────────────────────────────────────────
// TARJETA DE USUARIO (al tocar un avatar en sala)
// ─────────────────────────────────────────────
class UserCard extends StatefulWidget {
  final int userId;
  final VoidCallback? onClose;

  const UserCard({
    super.key,
    required this.userId,
    this.onClose,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isFollowLoading = false;
  int _followersCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/users/${widget.userId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _user = UserModel.fromJson(data['user']);
          _isFollowing = data['is_following'] ?? false;
          _followersCount = data['followers_count'] ?? 0;
          _followingCount = data['following_count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_user == null) return;
    setState(() => _isFollowLoading = true);
    try {
      final token = await _getToken();
      final endpoint = _isFollowing ? 'unfollow' : 'follow';
      final response = await http.post(
        Uri.parse(
            '${AppConfig.baseUrl}/api/follows/$endpoint/${widget.userId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isFollowing = !_isFollowing;
          _followersCount += _isFollowing ? 1 : -1;
        });
        UIHelpers.showSuccess(
          context,
          _isFollowing
              ? 'Ahora sigues a ${_user!.username}'
              : 'Dejaste de seguir a ${_user!.username}',
        );
      }
    } catch (e) {
      UIHelpers.showError(context, 'Error al actualizar seguimiento');
    } finally {
      setState(() => _isFollowLoading = false);
    }
  }

  void _openProfile() {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/profile',
      arguments: {'userId': widget.userId},
    );
  }

  void _sendMessage() {
    if (_user == null) return;
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'userId': widget.userId,
        'username': _user!.username,
        'avatarUrl': _user!.avatarUrl,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myId = authProvider.user?['id'];
    final isMe = myId == widget.userId;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : _user == null
              ? const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('Usuario no encontrado',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Banner / fondo decorativo
                    _buildBanner(),

                    // Info principal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Username y título
                          Text(
                            _user!.username,
                            style: AppTextStyles.h2,
                          ),
                          const SizedBox(height: 6),
                          TitleBadge(title: _user!.title),

                          const SizedBox(height: 12),

                          // Badges de nivel
                          LevelBadge(
                            levelSent: _user!.levelSent,
                            levelReceived: _user!.levelReceived,
                            scale: 1.3,
                          ),

                          const SizedBox(height: 16),

                          // Estadísticas
                          _buildStats(),

                          const SizedBox(height: 16),

                          // Bio
                          if (_user!.bio != null &&
                              _user!.bio!.isNotEmpty) ...[
                            Text(
                              _user!.bio!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Botones de acción
                          if (!isMe) _buildActions(),

                          if (isMe)
                            OutlinedButton.icon(
                              onPressed: _openProfile,
                              icon: const Icon(Icons.edit,
                                  color: AppColors.primary, size: 16),
                              label: const Text('Ver mi perfil',
                                  style:
                                      TextStyle(color: AppColors.primary)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusRound),
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildBanner() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Fondo degradado
        Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppLevels.getLevelColor(_user!.levelSent)
                    .withOpacity(0.4),
                AppColors.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Avatar
        Positioned(
          top: 20,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    AppLevels.getLevelColor(_user!.levelSent),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppLevels.getLevelColor(_user!.levelSent)
                      .withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: AppSizes.avatarXL / 2,
              backgroundColor: AppColors.cardLight,
              backgroundImage: _user!.avatarUrl != null
                  ? NetworkImage(_user!.avatarUrl!)
                  : null,
              child: _user!.avatarUrl == null
                  ? Text(
                      ImageHelpers.initials(_user!.username),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ),

        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          label: 'Seguidores',
          value: NumberHelpers.compact(_followersCount),
          icon: Icons.people,
        ),
        Container(width: 1, height: 30, color: AppColors.cardLight),
        _StatItem(
          label: 'Siguiendo',
          value: NumberHelpers.compact(_followingCount),
          icon: Icons.person_add,
        ),
        Container(width: 1, height: 30, color: AppColors.cardLight),
        _StatItem(
          label: 'Enviado',
          value: NumberHelpers.usd(
              AppEconomy.coinsToUsd(_user!.xpSent)),
          icon: Icons.monetization_on,
          color: AppColors.coins,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        // Botón seguir / dejar de seguir
        Expanded(
          child: GestureDetector(
            onTap: _isFollowLoading ? null : _toggleFollow,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _isFollowing
                    ? AppColors.cardLight
                    : AppColors.primary,
                borderRadius:
                    BorderRadius.circular(AppSizes.radiusRound),
              ),
              child: Center(
                child: _isFollowLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isFollowing
                                ? Icons.person_remove
                                : Icons.person_add,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isFollowing ? 'Siguiendo' : 'Seguir',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Botón mensaje (solo si son amigos mutuos)
        if (_isFollowing)
          Expanded(
            child: GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusRound),
                  border: Border.all(color: AppColors.cardLight),
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.message, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Mensaje',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        const SizedBox(width: 10),

        // Botón ver perfil
        GestureDetector(
          onTap: _openProfile,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              border: Border.all(color: AppColors.cardLight),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ITEM DE ESTADÍSTICA
// ─────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// FUNCIÓN HELPER PARA MOSTRAR LA TARJETA
// ─────────────────────────────────────────────
void showUserCard(BuildContext context, int userId) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => UserCard(userId: userId),
  );
}