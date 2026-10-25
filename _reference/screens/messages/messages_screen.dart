import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _conversations = [];
  List<dynamic> _friendRequests = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadConversations(), _loadFriendRequests()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadConversations() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/private-messages/conversations'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _conversations = data['conversations'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }
  }

  Future<void> _loadFriendRequests() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/follows/requests'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _friendRequests = data['requests'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error loading friend requests: $e');
    }
  }

  List<dynamic> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    return _conversations.where((conv) {
      final name = (conv['username'] ?? '').toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text(
          'Mensajes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE91E8C),
          labelColor: const Color(0xFFE91E8C),
          unselectedLabelColor: Colors.grey,
          tabs: [
            const Tab(text: 'Chats'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Solicitudes'),
                  if (_friendRequests.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E8C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_friendRequests.length}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E8C)),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChatsTab(),
                _buildRequestsTab(),
              ],
            ),
    );
  }

  Widget _buildChatsTab() {
    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar conversación...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E3A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),

        // Lista de conversaciones
        Expanded(
          child: _filteredConversations.isEmpty
              ? _buildEmptyChats()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFFE91E8C),
                  child: ListView.builder(
                    itemCount: _filteredConversations.length,
                    itemBuilder: (ctx, i) =>
                        _buildConversationTile(_filteredConversations[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyChats() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 70, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No se encontraron chats'
                : 'Sin conversaciones aún',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Solo puedes chatear con\nseguidores mutuos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conv) {
    final username = conv['username'] ?? 'Usuario';
    final lastMsg = conv['last_message'] ?? '';
    final unread = conv['unread_count'] ?? 0;
    final avatar = conv['avatar_url'];
    final userId = conv['user_id'];
    final time = conv['last_message_time'];

    String timeStr = '';
    if (time != null) {
      try {
        final dt = DateTime.parse(time).toLocal();
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inMinutes < 60) {
          timeStr = '${diff.inMinutes}m';
        } else if (diff.inHours < 24) {
          timeStr = '${diff.inHours}h';
        } else {
          timeStr = '${diff.inDays}d';
        }
      } catch (_) {}
    }

    return InkWell(
      onTap: () => _openChat(userId, username, avatar),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF1E1E3A), width: 1),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF1E1E3A),
                  backgroundImage:
                      avatar != null ? NetworkImage(avatar) : null,
                  child: avatar == null
                      ? Text(
                          username.isNotEmpty
                              ? username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        )
                      : null,
                ),
                if (unread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE91E8C),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 9),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: unread > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: unread > 0
                              ? const Color(0xFFE91E8C)
                              : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg.isNotEmpty ? lastMsg : 'Sin mensajes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unread > 0 ? Colors.white70 : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    if (_friendRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 70, color: Colors.grey.shade700),
            const SizedBox(height: 16),
            const Text(
              'Sin solicitudes pendientes',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriendRequests,
      color: const Color(0xFFE91E8C),
      child: ListView.builder(
        itemCount: _friendRequests.length,
        itemBuilder: (ctx, i) => _buildRequestTile(_friendRequests[i]),
      ),
    );
  }

  Widget _buildRequestTile(Map<String, dynamic> request) {
    final username = request['username'] ?? 'Usuario';
    final avatar = request['avatar_url'];
    final followId = request['follow_id'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF0A0A0A),
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                const Text('Quiere seguirte',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          // Botones aceptar / rechazar
          Row(
            children: [
              GestureDetector(
                onTap: () => _handleRequest(followId, true),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E8C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Aceptar',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _handleRequest(followId, false),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A4A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Rechazar',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleRequest(dynamic followId, bool accept) async {
    try {
      final token = await _getToken();
      final endpoint = accept ? 'accept' : 'reject';
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/follows/$endpoint/$followId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      await _loadFriendRequests();
      if (accept) await _loadConversations();
    } catch (e) {
      debugPrint('Error handling request: $e');
    }
  }

  void _openChat(dynamic userId, String username, String? avatar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          userId: userId,
          username: username,
          avatarUrl: avatar,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PANTALLA DE CHAT INDIVIDUAL
// ─────────────────────────────────────────────
class ChatDetailScreen extends StatefulWidget {
  final dynamic userId;
  final String username;
  final String? avatarUrl;

  const ChatDetailScreen({
    super.key,
    required this.userId,
    required this.username,
    this.avatarUrl,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/api/private-messages/${widget.userId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages = List.from(data['messages'] ?? []).reversed.toList();
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _msgController.clear();

    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/private-messages/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'receiver_id': widget.userId,
          'content': text,
        }),
      );

      if (response.statusCode == 201) {
        await _loadMessages();
      } else {
        _msgController.text = text;
        _showError('No se pudo enviar el mensaje');
      }
    } catch (e) {
      _msgController.text = text;
      _showError('Error de conexión');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myId = authProvider.user?['id'];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF2A2A4A),
              backgroundImage: widget.avatarUrl != null
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              child: widget.avatarUrl == null
                  ? Text(
                      widget.username.isNotEmpty
                          ? widget.username[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.username,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mensajes
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFE91E8C)),
                  )
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Inicia la conversación 👋',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) {
                          final msg = _messages[i];
                          final isMe = msg['sender_id'] == myId;
                          return _buildMessageBubble(msg, isMe);
                        },
                      ),
          ),

          // Input
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final content = msg['content'] ?? '';
    final time = _formatTime(msg['created_at']);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFE91E8C).withOpacity(0.85)
              : const Color(0xFF1E1E3A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF1A1A2E),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE91E8C),
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}