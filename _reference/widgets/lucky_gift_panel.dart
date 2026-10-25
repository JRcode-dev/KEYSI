import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/gift_model.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class LuckyGiftPanel extends StatefulWidget {
  final int roomId;
  final Function(LuckyGiftResult) onResult;

  const LuckyGiftPanel({
    super.key,
    required this.roomId,
    required this.onResult,
  });

  @override
  State<LuckyGiftPanel> createState() => _LuckyGiftPanelState();
}

class _LuckyGiftPanelState extends State<LuckyGiftPanel>
    with TickerProviderStateMixin {
  List<GiftModel> _luckyGifts = [];
  bool _isLoading = true;
  bool _isSending = false;
  int? _selectedGiftId;
  LuckyGiftResult? _lastResult;

  // Animación del resultado
  late AnimationController _resultController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeIn),
    );
    _loadLuckyGifts();
  }

  @override
  void dispose() {
    _resultController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadLuckyGifts() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/gifts/catalog'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = (data['gifts'] as List)
            .map((g) => GiftModel.fromJson(g))
            .where((g) => g.isLucky)
            .toList();
        setState(() => _luckyGifts = list);
      }
    } catch (e) {
      debugPrint('Error loading lucky gifts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendLuckyGift() async {
    if (_selectedGiftId == null) {
      UIHelpers.showError(context, 'Selecciona un Lucky Gift');
      return;
    }

    final gift = _luckyGifts.firstWhere((g) => g.id == _selectedGiftId);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final myCoins = auth.user?['coins'] ?? 0;

    if (myCoins < gift.price) {
      UIHelpers.showError(context, 'Monedas insuficientes');
      return;
    }

    setState(() => _isSending = true);
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/lucky-gifts/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'gift_id': _selectedGiftId,
          'room_id': widget.roomId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final result = LuckyGiftResult.fromJson(data);
        setState(() => _lastResult = result);
        _resultController.forward(from: 0);
        widget.onResult(result);
      } else {
        final data = json.decode(response.body);
        UIHelpers.showError(
            context, data['error'] ?? 'Error al enviar Lucky Gift');
      }
    } catch (e) {
      UIHelpers.showError(context, 'Error de conexión');
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🎰', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    const Text(
                      'Lucky Gifts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                _CoinsDisplay(),
              ],
            ),
          ),

          // Info banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.secondary, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Puedes ganar hasta x1000 tu apuesta · 10% en diamantes · Banner mundial si ganas x100+',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Resultado animado
          if (_lastResult != null)
            AnimatedBuilder(
              animation: _resultController,
              builder: (ctx, child) => Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _ResultCard(result: _lastResult!),
                ),
              ),
            ),

          // Grid de lucky gifts
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.secondary))
                : _luckyGifts.isEmpty
                    ? const Center(
                        child: Text(
                          'Sin Lucky Gifts disponibles',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _luckyGifts.length,
                        itemBuilder: (ctx, i) => _LuckyGiftItem(
                          gift: _luckyGifts[i],
                          isSelected: _luckyGifts[i].id == _selectedGiftId,
                          onTap: () => setState(
                              () => _selectedGiftId = _luckyGifts[i].id),
                        ),
                      ),
          ),

          // Botón enviar
          if (_selectedGiftId != null)
            _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    final gift = _luckyGifts.firstWhere((g) => g.id == _selectedGiftId);

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.card,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Text(
                  '🪙 ${NumberHelpers.compact(gift.price)} · Ganar hasta 🪙 ${NumberHelpers.compact(gift.price * 1000)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isSending ? null : _sendLuckyGift,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Row(
                      children: [
                        Text('🎰', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          '¡Probar suerte!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ITEM DE LUCKY GIFT EN GRID
// ─────────────────────────────────────────────
class _LuckyGiftItem extends StatelessWidget {
  final GiftModel gift;
  final bool isSelected;
  final VoidCallback onTap;

  const _LuckyGiftItem({
    required this.gift,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.3),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji o imagen
            gift.imageUrl != null
                ? Image.network(
                    gift.imageUrl!,
                    width: 38,
                    height: 38,
                    errorBuilder: (_, __, ___) => const Text(
                      '🎁',
                      style: TextStyle(fontSize: 32),
                    ),
                  )
                : const Text('🎁', style: TextStyle(fontSize: 32)),

            const SizedBox(height: 4),

            Text(
              gift.name,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 9)),
                const SizedBox(width: 2),
                Text(
                  gift.priceFormatted,
                  style: const TextStyle(
                    color: AppColors.coins,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Multiplicador máximo
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'x1000',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TARJETA DE RESULTADO
// ─────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  final LuckyGiftResult result;

  const _ResultCard({required this.result});

  Color get _resultColor {
    if (result.multiplier >= 100) return Colors.amber;
    if (result.multiplier >= 50) return AppColors.primary;
    if (result.multiplier >= 10) return AppColors.secondary;
    if (result.multiplier >= 5) return AppColors.levelBlue;
    return Colors.grey;
  }

  String get _resultEmoji {
    if (result.multiplier >= 100) return '🌟';
    if (result.multiplier >= 50) return '🔥';
    if (result.multiplier >= 10) return '⭐';
    if (result.multiplier >= 5) return '✨';
    return '💫';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _resultColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: _resultColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_resultEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.isWorldBanner
                    ? '¡BANNER MUNDIAL! 🌍'
                    : '¡Resultado!',
                style: TextStyle(
                  color: _resultColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Text(
                    result.resultLabel,
                    style: TextStyle(
                      color: _resultColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '→ 💎 ${result.winFormatted}',
                    style: const TextStyle(
                      color: AppColors.diamonds,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISPLAY DE MONEDAS
// ─────────────────────────────────────────────
class _CoinsDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final coins = auth.user?['coins'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            NumberHelpers.compact(coins),
            style: const TextStyle(
              color: AppColors.coins,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}