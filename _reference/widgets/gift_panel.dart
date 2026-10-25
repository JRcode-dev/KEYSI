import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/gift_model.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/wallet_provider.dart';

// ─────────────────────────────────────────────
// EMOJIS POR NOMBRE DE REGALO
// ─────────────────────────────────────────────
String giftEmoji(String name) {
  final map = {
    'Rosa': '🌹', 'Corazón': '❤️', 'Estrella': '⭐', 'Beso': '💋',
    'Abrazo': '🤗', 'Pastel': '🎂', 'Corona': '👑', 'Diamante': '💎',
    'Trofeo': '🏆', 'Cohete': '🚀', 'Fuegos artificiales': '🎆',
    'Arcoíris': '🌈', 'Unicornio': '🦄', 'Dragón': '🐉', 'Galaxia': '🌌',
    'Lluvia de estrellas': '🌠', 'Mariposa': '🦋', 'Fénix': '🔥',
    'León dorado': '🦁', 'Castillo': '🏰', 'Nave espacial': '🛸',
    'Tornado': '🌪️', 'Supernova': '💥', 'Rey del universo': '👸',
    'Imperio': '⚜️', 'Leyenda': '🌟', 'Dios del amor': '💝',
    'Vivra VIP': '💫', 'Maestro': '🎓', 'Vivra King': '👑',
    'Lucky Spark': '✨', 'Lucky Leaf': '🍀', 'Lucky Coin': '🪙',
    'Lucky Star': '⭐', 'Lucky Heart': '💖', 'Lucky Moon': '🌙',
    'Lucky Sun': '☀️', 'Lucky Rose': '🌹', 'Lucky Candy': '🍬',
    'Lucky Gem': '💎', 'Lucky Bear': '🐻', 'Lucky Fox': '🦊',
    'Lucky Owl': '🦉', 'Lucky Wolf': '🐺', 'Lucky Tiger': '🐯',
    'Lucky Panda': '🐼', 'Lucky Lion': '🦁', 'Lucky Eagle': '🦅',
    'Lucky Dragon': '🐉', 'Lucky Phoenix': '🔥', 'Lucky Unicorn': '🦄',
    'Lucky Meteor': '☄️', 'Lucky Nova': '💥', 'Lucky Aurora': '🌌',
    'Lucky Thunder': '⚡', 'Lucky Galaxy': '🌌', 'Lucky Diamond': '💎',
    'Lucky Universe': '🌍', 'Lucky Legend': '🌟', 'Lucky Vivra': '👑',
  };
  return map[name] ?? '🎁';
}

class GiftPanel extends StatefulWidget {
  final int roomId;
  final List<Map<String, dynamic>> seats;
  final Function(Map<String, dynamic>) onGiftSent;

  const GiftPanel({
    super.key,
    required this.roomId,
    required this.seats,
    required this.onGiftSent,
  });

  @override
  State<GiftPanel> createState() => _GiftPanelState();
}

class _GiftPanelState extends State<GiftPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<GiftModel> _normalGifts = [];
  List<GiftModel> _luckyGifts = [];
  bool _isLoading = true;
  bool _isSending = false;
  int? _selectedGiftId;
  int? _selectedReceiverId;
  String? _selectedReceiverName;
  int _quantity = 1;
  bool _isLuckyTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {
        _isLuckyTab = _tabController.index == 2;
        _selectedGiftId = null;
        _quantity = 1;
      });
    });
    _loadGifts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

  Future<void> _loadGifts() async {
  if (!mounted) return;

  setState(() => _isLoading = true);

  try {
    final token = await _getToken();

    if (!mounted) return;

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/gifts/catalog'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final allGifts = (data['gifts'] as List)
          .map((g) => GiftModel.fromJson(g))
          .toList();

      if (!mounted) return;

      setState(() {
        _normalGifts = allGifts.where((g) => g.isNormal).toList();
        _luckyGifts = allGifts.where((g) => g.isLucky).toList();
      });
    }
  } catch (e) {
    debugPrint('Error loading gifts: $e');
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  Future<void> _sendGift() async {
  if (_selectedGiftId == null) {
    UIHelpers.showError(context, 'Selecciona un regalo');
    return;
  }
  if (_selectedReceiverId == null) {
    UIHelpers.showError(context, 'Selecciona a quién enviar');
    return;
  }

  final allGifts = [..._normalGifts, ..._luckyGifts];
  final gift = allGifts.firstWhere((g) => g.id == _selectedGiftId);
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
      Uri.parse('${AppConfig.baseUrl}/api/gifts/send'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'gift_id': gift.id,
        'receiver_id': _selectedReceiverId,
        'room_id': widget.roomId,
        'quantity': 1,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);

      // Actualizar monedas inmediatamente
      auth.updateWallet(coins: (auth.user?['coins'] ?? 0) - gift.price);

      final walletProvider =
    Provider.of<WalletProvider>(context, listen: false);

await walletProvider.refreshBalance(auth.token ?? '');

      // Cerrar panel y activar QuickGiftSender
      Navigator.pop(context);
      widget.onGiftSent({
        'quick_gift': true,
        'gift_id': gift.id,
        'gift_name': gift.name,
        'gift_emoji': giftEmoji(gift.name),
        'gift_price': gift.price,
        'receiver_id': _selectedReceiverId,
        'receiver_name': _selectedReceiverName,
        'is_lucky': gift.isLucky,
        'first_gift_data': data,
      });
    } else {
      final data = json.decode(response.body);
      UIHelpers.showError(context, data['message'] ?? 'Error al enviar regalo');
    }
  } catch (e) {
    UIHelpers.showError(context, 'Error de conexión');
  } finally {
    if (mounted) setState(() => _isSending = false);
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

          // Header con monedas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Regalos',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                _CoinsDisplay(),
              ],
            ),
          ),

          // Selector de receptor
          _ReceiverSelector(
            seats: widget.seats,
            selectedId: _selectedReceiverId,
            onSelect: (id, name) => setState(() {
              if (_selectedReceiverId == id) {
                _selectedReceiverId = null;
                _selectedReceiverName = null;
              } else {
                _selectedReceiverId = id;
                _selectedReceiverName = name;
              }
            }),
          ),

          const SizedBox(height: 8),

          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Básicos'),
              Tab(text: 'Premium'),
              Tab(text: '🎰 Lucky'),
            ],
          ),

          // Grid de regalos
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGiftGrid(
                          _normalGifts.where((g) => g.price <= 10000).toList(),
                          isLucky: false),
                      _buildGiftGrid(
                          _normalGifts.where((g) => g.price > 10000).toList(),
                          isLucky: false),
                      _buildGiftGrid(_luckyGifts, isLucky: true),
                    ],
                  ),
          ),

          // Barra inferior
          if (_selectedGiftId != null) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildGiftGrid(List<GiftModel> gifts, {required bool isLucky}) {
    if (gifts.isEmpty) {
      return const Center(
        child: Text('Sin regalos disponibles',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: gifts.length,
      itemBuilder: (ctx, i) => _GiftItem(
        gift: gifts[i],
        isSelected: gifts[i].id == _selectedGiftId,
        isLucky: isLucky,
        onTap: () => setState(() {
          if (_selectedGiftId == gifts[i].id) {
            _selectedGiftId = null;
          } else {
            _selectedGiftId = gifts[i].id;
          }
        }),
      ),
    );
  }

  Widget _buildBottomBar() {
    final allGifts = [..._normalGifts, ..._luckyGifts];
    final gift = allGifts.firstWhere((g) => g.id == _selectedGiftId);
    final total = gift.price * _quantity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.card,
      child: Row(
        children: [
          if (!_isLuckyTab)
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Row(
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () {
                      if (_quantity < 99) setState(() => _quantity++);
                    },
                  ),
                ],
              ),
            ),

          if (!_isLuckyTab) const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gift.name,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
                Text(
                  '🪙 ${NumberHelpers.compact(total)}',
                  style: const TextStyle(
                      color: AppColors.coins,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: _isSending ? null : _sendGift,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _isSending
                    ? Colors.grey
                    : _isLuckyTab
                        ? AppColors.secondary
                        : AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _isLuckyTab ? '🎰 Probar' : 'Enviar',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ITEM DE REGALO EN GRID
// ─────────────────────────────────────────────
class _GiftItem extends StatelessWidget {
  final GiftModel gift;
  final bool isSelected;
  final bool isLucky;
  final VoidCallback onTap;

  const _GiftItem({
    required this.gift,
    required this.isSelected,
    required this.isLucky,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = isLucky ? AppColors.secondary : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.2)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            gift.imageUrl != null
                ? Image.network(
                    gift.imageUrl!,
                    width: 36,
                    height: 36,
                    errorBuilder: (_, __, ___) => Text(
                      giftEmoji(gift.name),
                      style: const TextStyle(fontSize: 28),
                    ),
                  )
                : Text(
                    giftEmoji(gift.name),
                    style: const TextStyle(fontSize: 28),
                  ),

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

            if (gift.hasAnimation)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  gift.animationLabel,
                  style: const TextStyle(
                      color: AppColors.secondary, fontSize: 8),
                ),
              ),

            if (isLucky)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'x1000',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 8,
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
// SELECTOR DE RECEPTOR
// ─────────────────────────────────────────────
class _ReceiverSelector extends StatelessWidget {
  final List<Map<String, dynamic>> seats;
  final int? selectedId;
  final Function(int, String) onSelect;

  const _ReceiverSelector({
    required this.seats,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (seats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'No hay usuarios en los asientos',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }

    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: seats.length,
        itemBuilder: (ctx, i) {
          final seat = seats[i];
          final userId = seat['user_id'];
          final username = seat['username'] ?? 'Usuario';
          final avatar = seat['avatar_url'];
          final isSelected = selectedId == userId;

          return GestureDetector(
            onTap: () => onSelect(userId, username),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.cardLight,
                      backgroundImage:
                          avatar != null ? NetworkImage(avatar) : null,
                      child: avatar == null
                          ? Text(
                              username[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    username.length > 6
                        ? '${username.substring(0, 6)}...'
                        : username,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

// ─────────────────────────────────────────────
// BOTÓN DE CANTIDAD
// ─────────────────────────────────────────────
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}