import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/socket_service.dart';
import '../room/room_screen.dart';
import '../profile/profile_screen.dart';
import '../moments/moments_screen.dart';
import '../messages/messages_screen.dart';
import '../../widgets/mini_room_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _minimizedRoom;
  bool _showMiniPlayer = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);

      if (authProvider.token != null) {
        SocketService.connect(authProvider.token!);
        await roomProvider.getPublicRooms(authProvider.token!);
        await walletProvider.getBalance(authProvider.token!);
      }
    });
  }

  void _openRoom(Map<String, dynamic> room) {
    setState(() {
      _showMiniPlayer = false;
      _minimizedRoom = null;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomScreen(
          room: room,
          onMinimize: (r) {
            setState(() {
              _minimizedRoom = r;
              _showMiniPlayer = true;
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    SocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              RoomsTab(onRoomTap: _openRoom),
              const MomentsScreen(),
              const MessagesScreen(),
              const ProfileScreen(),
            ],
          ),

          // Mini player flotante
          if (_showMiniPlayer && _minimizedRoom != null)
            MiniRoomPlayer(
              room: _minimizedRoom!,
              onTap: () => _openRoom(_minimizedRoom!),
              onClose: () {
                setState(() {
                  _showMiniPlayer = false;
                  _minimizedRoom = null;
                });
              },
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFF4081),
          unselectedItemColor: Colors.white.withValues(alpha: 0.4),
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.rooms,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.photo_outlined),
              activeIcon: const Icon(Icons.photo),
              label: l10n.moments,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.message_outlined),
              activeIcon: const Icon(Icons.message),
              label: l10n.messages,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB DE SALAS
// ─────────────────────────────────────────────
class RoomsTab extends StatefulWidget {
  final Function(Map<String, dynamic>) onRoomTap;

  const RoomsTab({super.key, required this.onRoomTap});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Row(
          children: [
            Consumer<WalletProvider>(
              builder: (context, wallet, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${wallet.coins}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Consumer<WalletProvider>(
              builder: (context, wallet, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond,
                          color: Color(0xFF00BCD4), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${wallet.diamonds}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => _showCreateRoomDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF4081),
          indicatorWeight: 2,
          labelColor: const Color(0xFFFF4081),
          unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
          tabs: [
            Tab(text: l10n.globalRooms),
            Tab(text: l10n.hotRooms),
            Tab(text: l10n.recentRooms),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoomList(roomProvider.publicRooms, authProvider.token ?? ''),
          _buildRoomList(roomProvider.hotRooms, authProvider.token ?? ''),
          _buildRoomList(roomProvider.recentRooms, authProvider.token ?? ''),
        ],
      ),
    );
  }

  Widget _buildRoomList(List<dynamic> rooms, String token) {
    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.meeting_room_outlined,
              size: 60,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay salas disponibles',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFFF4081),
      backgroundColor: const Color(0xFF1A1A1A),
      onRefresh: () async {
        final authProvider =
            Provider.of<AuthProvider>(context, listen: false);
        final roomProvider =
            Provider.of<RoomProvider>(context, listen: false);
        await roomProvider.getPublicRooms(authProvider.token!);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return _RoomCard(
            room: room,
            token: token,
            onTap: () => widget.onRoomTap(room),
          );
        },
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    int selectedSeats = 10;
    bool isPrivate = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear sala',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre de la sala',
                  labelStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Asientos',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [5, 10, 15, 20].map((seats) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedSeats = seats),
                    child: Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedSeats == seats
                            ? const Color(0xFFFF4081)
                            : const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$seats',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: isPrivate,
                    onChanged: (value) =>
                        setState(() => isPrivate = value),
                    activeThumbColor: const Color(0xFFFF4081),
                  ),
                  const Text('Sala privada',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;
                    final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false);
                    final roomProvider = Provider.of<RoomProvider>(
                        context,
                        listen: false);
                    final success = await roomProvider.createRoom(
                      authProvider.token!,
                      nameController.text,
                      descController.text,
                      isPrivate,
                      selectedSeats,
                      null,
                    );
                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4081),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Crear sala',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CARD DE SALA
// ─────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final String token;
  final VoidCallback onTap;

  const _RoomCard({
    required this.room,
    required this.token,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF4081).withValues(alpha: 0.3),
                    const Color(0xFF0A0A0A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room['name'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (room['description'] != null)
                          Text(
                            room['description'],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.diamond,
                              color: Color(0xFF00BCD4), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${room['total_diamonds_now'] ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFFF4081),
                    child: Text(
                      (room['owner_name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    room['owner_name'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chair_outlined,
                      color: Colors.white.withValues(alpha: 0.5), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${room['seats'] ?? 0}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (room['is_private'] == true)
                    Icon(Icons.lock_outline,
                        color: Colors.white.withValues(alpha: 0.5), size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}