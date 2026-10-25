import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/constants.dart';

class QuickGiftSender extends StatefulWidget {
  final int roomId;
  final int giftId;
  final String giftName;
  final String giftEmoji;
  final int giftPrice;
  final int receiverId;
  final String receiverName;
  final bool isLucky;
  final Map<String, dynamic>? firstGiftData;
  final Function(Map<String, dynamic>) onGiftSent;
  final VoidCallback onFinished;

  const QuickGiftSender({
    super.key,
    required this.roomId,
    required this.giftId,
    required this.giftName,
    required this.giftEmoji,
    required this.giftPrice,
    required this.receiverId,
    required this.receiverName,
    required this.isLucky,
    this.firstGiftData,
    required this.onGiftSent,
    required this.onFinished,
  });

  @override
  State<QuickGiftSender> createState() => _QuickGiftSenderState();
}

class _QuickGiftSenderState extends State<QuickGiftSender>
    with SingleTickerProviderStateMixin {
  int _secondsLeft = 5;
  int _totalSent = 1; // Ya se envió 1 desde el panel
  bool _isSending = false;
  bool _finished = false;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int? _lastMultiplier;
  bool _showLuckyResult = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Notificar el primer regalo que ya se envió
if (widget.firstGiftData != null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      widget.onGiftSent(widget.firstGiftData!);
      _checkLuckyResult(widget.firstGiftData!);
    }
  });
}

    // Iniciar timer inmediatamente
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _checkLuckyResult(Map<String, dynamic> data) {
    if (widget.isLucky && data['multiplier'] != null) {
      final multiplier = data['multiplier'] as int;
      if (multiplier > 0 && mounted) {
        setState(() {
          _lastMultiplier = multiplier;
          _showLuckyResult = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showLuckyResult = false);
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (mounted) setState(() => _secondsLeft = 5);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _finished) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        _finished = true;
        widget.onFinished();
      }
    });
  }

  Future<void> _sendGift() async {
    if (_isSending || !mounted || _finished) return;
    setState(() => _isSending = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/gifts/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'gift_id': widget.giftId,
          'receiver_id': widget.receiverId,
          'room_id': widget.roomId,
          'quantity': 1,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        widget.onGiftSent(data);
        _checkLuckyResult(data);

        // Actualizar balance
        final authProvider =
            Provider.of<AuthProvider>(context, listen: false);
        final walletProvider =
            Provider.of<WalletProvider>(context, listen: false);
        authProvider.updateWallet(
          coins: (authProvider.user?['coins'] ?? 0) - widget.giftPrice,
        );
        await walletProvider.refreshBalance(authProvider.token ?? '');

        if (mounted) setState(() => _totalSent++);
      }
    } catch (e) {
      debugPrint('Error sending quick gift: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _onTap() {
    if (_finished || _isSending) return;
    _startTimer(); // Reiniciar timer
    _sendGift();   // Enviar regalo
  }

  @override
  Widget build(BuildContext context) {
    final progress = _secondsLeft / 5.0;
    final color = widget.isLucky ? AppColors.secondary : AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Resultado lucky gift
        if (_showLuckyResult && _lastMultiplier != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _lastMultiplier! >= 100
                  ? Colors.amber
                  : AppColors.secondary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (_lastMultiplier! >= 100
                          ? Colors.amber
                          : AppColors.secondary)
                      .withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              _lastMultiplier! >= 100
                  ? '🌍 x$_lastMultiplier MUNDIAL!'
                  : '🎰 x$_lastMultiplier',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Círculo principal
        GestureDetector(
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (ctx, child) => Transform.scale(
              scale: _isSending ? 0.95 : _pulseAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: color, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.giftEmoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                        Text(
                          'x$_totalSent',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_secondsLeft}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.receiverName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}