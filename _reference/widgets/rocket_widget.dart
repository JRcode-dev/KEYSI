import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class RocketWidget extends StatefulWidget {
  final int roomId;
  final Function(Map<String, dynamic>) onRocketLaunched;

  const RocketWidget({
    super.key,
    required this.roomId,
    required this.onRocketLaunched,
  });

  @override
  State<RocketWidget> createState() => _RocketWidgetState();
}

class _RocketWidgetState extends State<RocketWidget>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _currentRocket;
  List<Map<String, dynamic>> _topContributors = [];
  bool _isLoading = true;
  bool _isSending = false;
  int _contributionAmount = 0;
  final TextEditingController _amountController = TextEditingController();

  // Animación del cohete
  late AnimationController _rocketController;
  late Animation<double> _rocketAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rocketAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _rocketController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _loadRocketData();
  }

  @override
  void dispose() {
    _rocketController.dispose();
    _glowController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadRocketData() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/rockets/room/${widget.roomId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentRocket = data['rocket'];
          _topContributors =
              List<Map<String, dynamic>>.from(data['contributors'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error loading rocket: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _contribute() async {
    if (_contributionAmount <= 0) {
      UIHelpers.showError(context, 'Ingresa un monto válido');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final myDiamonds = auth.user?['diamonds'] ?? 0;

    if (myDiamonds < _contributionAmount) {
      UIHelpers.showError(context, 'Diamantes insuficientes');
      return;
    }

    final rocketLevel = _currentRocket?['level'] ?? 1;
    final rocketData = AppRockets.getRocket(rocketLevel);
    final cost = rocketData['cost'] as int;

    final confirm = await UIHelpers.showConfirmDialog(
      context,
      title: 'Contribuir al cohete',
      message:
          'Contribuir 💎 ${NumberHelpers.compact(_contributionAmount)}\nMeta del cohete: 💎 ${NumberHelpers.compact(cost)}',
      confirmText: 'Contribuir',
    );
    if (!confirm) return;

    setState(() => _isSending = true);
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/rockets/contribute'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'room_id': widget.roomId,
          'amount': _contributionAmount,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        widget.onRocketLaunched(data);
        UIHelpers.showSuccess(
          context,
          '🚀 Contribuiste 💎 ${NumberHelpers.compact(_contributionAmount)}',
        );
        _amountController.clear();
        setState(() => _contributionAmount = 0);
        await _loadRocketData();
      } else {
        final data = json.decode(response.body);
        UIHelpers.showError(
            context, data['error'] ?? 'Error al contribuir');
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
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.rocket))
          : SingleChildScrollView(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('🚀',
                                style: TextStyle(fontSize: 22)),
                            SizedBox(width: 8),
                            Text(
                              'Cohete',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        _DiamondsDisplay(),
                      ],
                    ),
                  ),

                  // Cohete animado + progreso
                  _buildRocketSection(),

                  const SizedBox(height: 16),

                  // Top contribuidores
                  _buildTopContributors(),

                  const SizedBox(height: 16),

                  // Input de contribución
                  _buildContributeSection(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildRocketSection() {
    if (_currentRocket == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Sin cohete activo en esta sala',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final level = _currentRocket!['level'] ?? 1;
    final collected = _currentRocket!['collected'] ?? 0;
    final rocketData = AppRockets.getRocket(level);
    final cost = rocketData['cost'] as int;
    final progress = (collected / cost).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.rocket.withOpacity(0.2),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: AppColors.rocket.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Nivel del cohete
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.rocket.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
            child: Text(
              'Cohete Nivel $level',
              style: const TextStyle(
                color: AppColors.rocket,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cohete animado
          AnimatedBuilder(
            animation: _rocketController,
            builder: (ctx, child) => Transform.translate(
              offset: Offset(0, _rocketAnimation.value),
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (ctx, child) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rocket
                            .withOpacity(_glowAnimation.value * 0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Text(
                    '🚀',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Barra de progreso
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '💎 ${NumberHelpers.compact(collected)}',
                    style: const TextStyle(
                      color: AppColors.diamonds,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Meta: 💎 ${NumberHelpers.compact(cost)}',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.cardLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.rocket),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toStringAsFixed(1)}% completado',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Premios top 3
          _buildPrizes(rocketData),
        ],
      ),
    );
  }

  Widget _buildPrizes(Map<String, dynamic> rocketData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _PrizeTile(
          position: 1,
          emoji: '🥇',
          amount: rocketData['top1'] as int,
        ),
        _PrizeTile(
          position: 2,
          emoji: '🥈',
          amount: rocketData['top2'] as int,
        ),
        _PrizeTile(
          position: 3,
          emoji: '🥉',
          amount: rocketData['top3'] as int,
        ),
      ],
    );
  }

  Widget _buildTopContributors() {
    if (_topContributors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Sé el primero en contribuir 🚀',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Top contribuidores',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _topContributors.length > 5
              ? 5
              : _topContributors.length,
          itemBuilder: (ctx, i) {
            final contributor = _topContributors[i];
            final medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
            return ListTile(
              dense: true,
              leading: Text(
                medals[i],
                style: const TextStyle(fontSize: 20),
              ),
              title: Text(
                contributor['username'] ?? 'Usuario',
                style: const TextStyle(
                    color: Colors.white, fontSize: 13),
              ),
              trailing: Text(
                '💎 ${NumberHelpers.compact(contributor['amount'] ?? 0)}',
                style: const TextStyle(
                  color: AppColors.diamonds,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContributeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu contribución (💎 diamantes)',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
          const SizedBox(height: 10),

          // Montos rápidos
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              10000, 50000, 100000, 200000, 500000
            ].map((amount) => _QuickAmountChip(
              amount: amount,
              isSelected: _contributionAmount == amount,
              onTap: () => setState(() {
                _contributionAmount = amount;
                _amountController.text =
                    NumberHelpers.compact(amount);
              }),
            )).toList(),
          ),

          const SizedBox(height: 12),

          // Input personalizado
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Otro monto...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixText: '💎 ',
                    prefixStyle: const TextStyle(
                        color: AppColors.diamonds),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMD),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(
                            val.replaceAll(',', '').replaceAll('.', '')) ??
                        0;
                    setState(() => _contributionAmount = parsed);
                  },
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _isSending ? null : _contribute,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: _isSending
                        ? Colors.grey
                        : AppColors.rocket,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Contribuir',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TILE DE PREMIO
// ─────────────────────────────────────────────
class _PrizeTile extends StatelessWidget {
  final int position;
  final String emoji;
  final int amount;

  const _PrizeTile({
    required this.position,
    required this.emoji,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          'Top $position',
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        Text(
          '🪙 ${NumberHelpers.compact(amount)}',
          style: const TextStyle(
            color: AppColors.coins,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CHIP DE MONTO RÁPIDO
// ─────────────────────────────────────────────
class _QuickAmountChip extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.rocket.withOpacity(0.2)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusRound),
          border: Border.all(
            color: isSelected ? AppColors.rocket : Colors.transparent,
          ),
        ),
        child: Text(
          '💎 ${NumberHelpers.compact(amount)}',
          style: TextStyle(
            color: isSelected ? AppColors.rocket : Colors.grey,
            fontSize: 12,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISPLAY DE DIAMANTES
// ─────────────────────────────────────────────
class _DiamondsDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final diamonds = auth.user?['diamonds'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
      ),
      child: Row(
        children: [
          const Text('💎', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            NumberHelpers.compact(diamonds),
            style: const TextStyle(
              color: AppColors.diamonds,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}