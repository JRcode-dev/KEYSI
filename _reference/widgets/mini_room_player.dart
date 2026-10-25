import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MiniRoomPlayer extends StatefulWidget {
  final Map<String, dynamic> room;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const MiniRoomPlayer({
    super.key,
    required this.room,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<MiniRoomPlayer> createState() => _MiniRoomPlayerState();
}

class _MiniRoomPlayerState extends State<MiniRoomPlayer> {
  double _x = 20;
  double _y = 100;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: _x,
      top: _y,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _x = (_x + details.delta.dx)
                .clamp(0, screenWidth - 80);
            _y = (_y + details.delta.dy)
                .clamp(0, screenHeight - 80);
          });
        },
        onTap: widget.onTap,
        child: Stack(
          children: [
            // Círculo principal
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic, color: Colors.white, size: 20),
                  const SizedBox(height: 2),
                  Text(
                    widget.room['name'] ?? 'Sala',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Botón cerrar
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}