import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../../models/room_model.dart';
import '../../models/gift_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/socket_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/gift_panel.dart';
import '../../widgets/rocket_widget.dart';
import '../../widgets/user_card.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/quick_gift_sender.dart';

class RoomScreen extends StatefulWidget {
  final Map<String, dynamic> room;
  final Function(Map<String, dynamic>)? onMinimize;

  const RoomScreen({
    super.key,
    required this.room,
    this.onMinimize,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with TickerProviderStateMixin {
  RoomModel? _roomModel;
  bool _isLoading = true;
  bool _isMuted = false;
  bool _isInVoice = false;
  bool _isInSeat = false;
  int? _mySeatNumber;

  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _activeGiftAnimation;
  late AnimationController _giftAnimController;
  late Animation<double> _giftScaleAnim;
  late Animation<double> _giftOpacityAnim;

  // Quick gift sender
  Map<String, dynamic>? _quickGiftData;
  bool _showQuickGift = false;

  @override
  void initState() {
    super.initState();

    _giftAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _giftScaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _giftAnimController, curve: Curves.elasticOut),
    );
    _giftOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _giftAnimController, curve: Curves.easeIn),
    );

    _joinRoom();
    _setupSocketListeners();
    _loadRoomDetails();
  }

  @override
  void dispose() {
    _giftAnimController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _joinRoom() {
    SocketService.joinRoom(widget.room['id']);
  }

  Future<void> _leaveRoomCompletely() async {
    try {
      if (_isInSeat && _mySeatNumber != null) {
        final token = await _getToken();
        await http.post(
          Uri.parse(
              '${AppConfig.baseUrl}/api/rooms/${widget.room['id']}/seats/$_mySeatNumber/leave'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
      if (_isInVoice) {
        SocketService.leaveVoice(widget.room['id']);
      }
      SocketService.leaveRoom();
      if (mounted) {
        setState(() {
          _isInSeat = false;
          _mySeatNumber = null;
          _isInVoice = false;
        });
      }
    } catch (e) {
      debugPrint('Error leaving room: $e');
    }
  }

  Future<void> _loadRoomDetails() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      final roomId = widget.room['id'];
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/rooms/$roomId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          _roomModel = RoomModel.fromJson(
            Map<String, dynamic>.from(data['room']),
          );
        });

        // Verificar si el usuario ya está en un asiento
        final authProvider =
            Provider.of<AuthProvider>(context, listen: false);
        final myId = authProvider.user?['id'];
        for (final seat in _roomModel!.seats) {
          if (seat.userId == myId) {
            setState(() {
              _isInSeat = true;
              _mySeatNumber = seat.seatNumber;
              _isInVoice = true;
            });
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading room: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setupSocketListeners() {
    SocketService.on('room_joined', (data) {
      if (mounted && data['messages'] != null) {
        setState(() {
          _messages.clear();
          _messages.addAll(
            List<Map<String, dynamic>>.from(data['messages']),
          );
        });
        _scrollToBottom();
      }
    });

    SocketService.on('new_message', (data) {
      if (mounted) {
        setState(() {
          _messages.add(Map<String, dynamic>.from(data));
          if (_messages.length > 100) _messages.removeAt(0);
        });
        _scrollToBottom();
      }
    });

    SocketService.on('voice_user_joined', (data) {
      if (mounted && data['voiceUsers'] != null && _roomModel != null) {
        final seats = (data['voiceUsers'] as List)
            .map((s) => RoomSeat.fromJson(s))
            .toList();
        setState(() => _roomModel = _roomModel!.copyWith(seats: seats));
      }
    });

    SocketService.on('voice_user_left', (data) {
      if (mounted && _roomModel != null) {
        final updated = _roomModel!.seats.map((s) {
          if (s.userId == data['userId']) {
            return RoomSeat(
              seatNumber: s.seatNumber,
              userId: null,
              username: null,
              avatarUrl: null,
              isMuted: false,
              isLocked: s.isLocked,
              levelSent: 1,
              levelReceived: 1,
            );
          }
          return s;
        }).toList();
        setState(() => _roomModel = _roomModel!.copyWith(seats: updated));
      }
    });

    SocketService.on('gift_received', (data) {
      if (mounted) _showGiftAnimation(data);
    });

    SocketService.on('lucky_gift_received', (data) {
      if (mounted) _showLuckyGiftResult(data);
    });

    SocketService.on('global_banner', (data) {
      if (mounted) _showGlobalBanner(data);
    });

    SocketService.on('seats_updated', (data) {
      if (mounted && _roomModel != null && data['seats'] != null) {
        final seats = (data['seats'] as List)
            .map((s) => RoomSeat.fromJson(s))
            .toList();
        setState(() => _roomModel = _roomModel!.copyWith(seats: seats));
      }
    });

    SocketService.on('viewer_count_updated', (data) {
      if (mounted && _roomModel != null) {
        setState(() => _roomModel =
            _roomModel!.copyWith(viewerCount: data['viewer_count']));
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    SocketService.sendMessage(_messageController.text.trim());
    _messageController.clear();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    SocketService.toggleMute(widget.room['id'], _isMuted);
  }

  Future<void> _takeSeat(int seatNumber) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(
            '${AppConfig.baseUrl}/api/rooms/${widget.room['id']}/seats/$seatNumber/take'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _isInSeat = true;
          _mySeatNumber = seatNumber;
          _isInVoice = true;
        });
        UIHelpers.showSuccess(context, 'Tomaste el asiento $seatNumber 🎤');
        await _loadRoomDetails();
      } else {
        final data = json.decode(response.body);
        UIHelpers.showError(
            context, data['message'] ?? 'Error al tomar asiento');
      }
    } catch (e) {
      UIHelpers.showError(context, 'Error de conexión');
    }
  }

  Future<void> _leaveSeat() async {
    if (_mySeatNumber == null) return;
    final confirm = await UIHelpers.showConfirmDialog(
      context,
      title: 'Dejar asiento',
      message: '¿Quieres dejar el asiento $_mySeatNumber?',
      confirmText: 'Dejar',
    );
    if (!confirm) return;

    try {
      final token = await _getToken();
      await http.post(
        Uri.parse(
            '${AppConfig.baseUrl}/api/rooms/${widget.room['id']}/seats/$_mySeatNumber/leave'),
        headers: {'Authorization': 'Bearer $token'},
      );
      setState(() {
        _isInSeat = false;
        _mySeatNumber = null;
        _isInVoice = false;
      });
      await _loadRoomDetails();
    } catch (e) {
      debugPrint('Error leaving seat: $e');
    }
  }

  Future<void> _changeSeat(int newSeatNumber) async {
    try {
      final token = await _getToken();
      await http.post(
        Uri.parse(
            '${AppConfig.baseUrl}/api/rooms/${widget.room['id']}/seats/$_mySeatNumber/leave'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final response = await http.post(
        Uri.parse(
            '${AppConfig.baseUrl}/api/rooms/${widget.room['id']}/seats/$newSeatNumber/take'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _mySeatNumber = newSeatNumber;
        });
        await _loadRoomDetails();
      } else {
        final data = json.decode(response.body);
        UIHelpers.showError(
            context, data['message'] ?? 'Error al cambiar asiento');
      }
    } catch (e) {
      UIHelpers.showError(context, 'Error de conexión');
    }
  }

  void _showGiftAnimation(Map<String, dynamic> data) {
    setState(() => _activeGiftAnimation = data);
    _giftAnimController.forward(from: 0);
    final duration = data['animation_duration'] ?? 2;
    Future.delayed(Duration(seconds: duration), () {
      if (mounted) setState(() => _activeGiftAnimation = null);
    });
  }

  void _showLuckyGiftResult(Map<String, dynamic> data) {
    final multiplier = data['result']?['results']?.first['multiplier'] ?? 0;
    final senderName = data['sender']?['username'] ?? 'Alguien';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎰', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            Text(
              senderName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lucky Gift x$multiplier! 🎉',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _showGlobalBanner(Map<String, dynamic> data) {
    final senderName = data['sender']?['username'] ?? 'Alguien';
    final isLegendary = data['type'] == 'legendary';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLegendary
                  ? [const Color(0xFFFFD700), const Color(0xFFFF4081)]
                  : [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌍', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 12),
              Text(
                isLegendary ? '🏆 BANNER MUNDIAL!' : '⭐ BANNER ESPECIAL!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$senderName ganó un Lucky Gift x100+!',
                style: const TextStyle(color: Colors.white, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _openGiftPanel() {
  final seats = _roomModel?.seats
          .where((s) => s.isOccupied)
          .map((s) => {
                'user_id': s.userId,
                'username': s.username,
                'avatar_url': s.avatarUrl,
              })
          .toList() ??
      [];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => GiftPanel(
      roomId: widget.room['id'],
      seats: seats,
      onGiftSent: (data) {
        if (data['quick_gift'] == true) {
          setState(() {
            _quickGiftData = data;
            _showQuickGift = true;
          });
        } else {
          _showGiftAnimation(data);
        }
      },
    ),
  );
}

  void _openRocketPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RocketWidget(
        roomId: widget.room['id'],
        onRocketLaunched: (data) {
          UIHelpers.showSuccess(context, '🚀 ¡Cohete lanzado!');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
  onPressed: () {
    if (widget.onMinimize != null) {
      widget.onMinimize!(widget.room);
    }
    Navigator.pop(context);
  },
),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.room['name'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
  children: [
    const Icon(Icons.people, color: Colors.grey, size: 12),
    const SizedBox(width: 3),
    Flexible(
      child: Text(
        '${_roomModel?.viewerCount ?? widget.room['viewer_count'] ?? 0} viendo',
        style: const TextStyle(color: Colors.grey, fontSize: 11),
        overflow: TextOverflow.ellipsis,
      ),
    ),
    const SizedBox(width: 8),
    if (_roomModel != null)
      Flexible(
        child: Text(
          _roomModel!.categoryLabel,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
      ),
  ],
),
          ],
        ),
        actions: [
          if (widget.room['is_live'] == true)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'EN VIVO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Botón mute solo si está en asiento
          if (_isInVoice)
            IconButton(
              icon: Icon(
                _isMuted ? Icons.mic_off : Icons.mic,
                color: _isMuted ? Colors.red : Colors.green,
              ),
              onPressed: _toggleMute,
            ),

          // Botón salir de sala
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: () async {
              final confirm = await UIHelpers.showConfirmDialog(
                context,
                title: 'Salir de la sala',
                message: '¿Quieres salir de la sala?',
                confirmText: 'Salir',
                isDanger: true,
              );
              if (confirm && mounted) {
                await _leaveRoomCompletely();
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Stack(
  children: [
    Column(
      children: [
        if (_roomModel != null) _buildSeats(authProvider),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) {
              final msg = _messages[i];
              final isMe =
                  msg['user']?['id'] == authProvider.user?['id'];
              return _MessageBubble(message: msg, isMe: isMe);
            },
          ),
        ),
        _buildActionBar(),
      ],
    ),

    // Overlay de regalo
    if (_activeGiftAnimation != null) _buildGiftOverlay(),

    // Quick gift sender
    if (_showQuickGift && _quickGiftData != null)
      Positioned(
        bottom: 100,
        right: 20,
        child: QuickGiftSender(
          roomId: widget.room['id'],
          giftId: _quickGiftData!['gift_id'],
          giftName: _quickGiftData!['gift_name'],
          giftEmoji: _quickGiftData!['gift_emoji'],
          giftPrice: _quickGiftData!['gift_price'],
          receiverId: _quickGiftData!['receiver_id'],
          receiverName: _quickGiftData!['receiver_name'],
          isLucky: _quickGiftData!['is_lucky'] ?? false,
          firstGiftData: _quickGiftData!['first_gift_data'],
          onGiftSent: (data) => _showGiftAnimation(data),
          onFinished: () {
            setState(() {
              _showQuickGift = false;
              _quickGiftData = null;
            });
            // Abrir panel de regalos de nuevo
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _openGiftPanel();
            });
          },
        ),
      ),
  ],
),
    );
  }

  Widget _buildSeats(AuthProvider authProvider) {
    final seats = _roomModel!.seats;
    final myId = authProvider.user?['id'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      color: AppColors.surface,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: seats.map((seat) {
          final isMe = seat.userId == myId;
          final isEmpty = seat.isEmpty;

          return GestureDetector(
            onTap: () {
              if (isMe && _isInSeat) {
                _leaveSeat();
              } else if (isEmpty && !_isInSeat) {
                _takeSeat(seat.seatNumber);
              } else if (isEmpty && _isInSeat) {
                _changeSeat(seat.seatNumber);
              } else if (seat.userId != null && !isMe) {
                showUserCard(context, seat.userId!);
              }
            },
            child: SizedBox(
              width: AppSizes.seatSize,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isEmpty
                              ? AppColors.cardLight
                              : AppColors.card,
                          border: Border.all(
                            color: isMe
                                ? AppColors.primary
                                : isEmpty
                                    ? Colors.grey.shade700
                                    : AppLevels.getLevelColor(seat.levelSent),
                            width: isMe ? 2.5 : 1.5,
                          ),
                        ),
                        child: isEmpty
                            ? const Icon(Icons.add,
                                color: Colors.grey, size: 20)
                            : ClipOval(
                                child: seat.avatarUrl != null
                                    ? Image.network(seat.avatarUrl!,
                                        fit: BoxFit.cover)
                                    : Center(
                                        child: Text(
                                          seat.username?.isNotEmpty == true
                                              ? seat.username![0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                      ),
                      if (!isEmpty && seat.isMuted)
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mic_off,
                              color: Colors.white, size: 10),
                        ),
                      if (!isEmpty && isMe && _isInVoice)
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                          color: _isMuted ? Colors.red : Colors.green,
                          shape: BoxShape.circle,
                          ),
                         child: Icon(
                          _isMuted ? Icons.mic_off : Icons.mic,
                          color: Colors.white,
                          size: 10,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isEmpty
                        ? 'Asiento\n${seat.seatNumber}'
                        : (seat.username ?? 'Usuario'),
                    style: TextStyle(
                      color: isEmpty ? Colors.grey : Colors.white,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (!isEmpty)
                    LevelBadge(
                      levelSent: seat.levelSent,
                      levelReceived: seat.levelReceived,
                      scale: 0.65,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                isDense: true,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 6),
          _ActionButton(
            emoji: '🎁',
            onTap: _openGiftPanel,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          _ActionButton(
            emoji: '🚀',
            onTap: _openRocketPanel,
            color: AppColors.rocket,
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftOverlay() {
    final data = _activeGiftAnimation!;
    final giftName = data['gift_name'] ?? 'Regalo';
    final senderName = data['sender']?['username'] ??
        data['sender_username'] ?? 'Alguien';
    final receiverName = data['receiver']?['username'] ??
        data['receiver_username'] ?? '';
    final hasAnimation = data['has_animation'] ?? false;

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.2,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _giftAnimController,
        builder: (ctx, child) => Opacity(
          opacity: _giftOpacityAnim.value,
          child: Transform.scale(
            scale: _giftScaleAnim.value,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    data['gift_image_url'] != null
                        ? Image.network(
                            data['gift_image_url'],
                            width: 80,
                            height: 80,
                            errorBuilder: (_, __, ___) => const Text(
                              '🎁',
                              style: TextStyle(fontSize: 60),
                            ),
                          )
                        : const Text('🎁',
                            style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 8),
                    Text(
                      giftName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$senderName → $receiverName',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                    if (hasAnimation) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusRound),
                        ),
                        child: const Text(
                          '✨ Animación especial',
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BURBUJA DE MENSAJE
// ─────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final username = message['user']?['username'] ??
        message['username'] ?? 'Usuario';
    final content = message['content'] ?? '';
    final levelSent = message['user']?['level_sent'] ??
        message['level_sent'] ?? 1;
    final levelReceived = message['user']?['level_received'] ??
        message['level_received'] ?? 1;
    final avatarUrl = message['user']?['avatar_url'] ??
        message['avatar_url'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.cardLight,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primary.withOpacity(0.85)
                    : AppColors.card.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: Border.all(
                  color: isMe
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.cardLight.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        LevelBadge(
                          levelSent: levelSent,
                          levelReceived: levelReceived,
                          scale: 0.65,
                        ),
                      ],
                    ),
                  if (!isMe) const SizedBox(height: 3),
                  Text(
                    content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 6),
            LevelBadge(
              levelSent: levelSent,
              levelReceived: levelReceived,
              scale: 0.65,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOTÓN DE ACCIÓN
// ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.emoji,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}