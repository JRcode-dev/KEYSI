import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';

class SocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;

  static IO.Socket? get socket => _socket;
  static bool get isConnected => _isConnected;

  // Conectar al servidor
  static void connect(String token) {
    _socket = IO.io(
      AppConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      print('✅ Socket conectado');

      // Autenticar con token
      _socket!.emit('authenticate', token);
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('❌ Socket desconectado');
    });

    _socket!.onError((error) {
      print('❌ Socket error: $error');
    });

    _socket!.onReconnect((_) {
      _isConnected = true;
      print('✅ Socket reconectado');
      _socket!.emit('authenticate', token);
    });
  }

  // Desconectar
  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }

  // Unirse a sala
  static void joinRoom(int roomId) {
    _socket?.emit('join_room', roomId);
  }

  // Salir de sala
  static void leaveRoom() {
    _socket?.emit('leave_room');
  }

  // Enviar mensaje
  static void sendMessage(String content, {int? mentionedUserId}) {
    _socket?.emit('send_message', {
      'content': content,
      'mentionedUserId': mentionedUserId,
    });
  }

  // Enviar gift normal
  static void sendGift(int receiverId, int roomId, int amount) {
    _socket?.emit('send_gift', {
      'receiverId': receiverId,
      'roomId': roomId,
      'amount': amount,
    });
  }

  // Enviar Lucky Gift
  static void sendLuckyGift(
    int receiverId,
    int roomId,
    int coinsSent,
    int quantity,
  ) {
    _socket?.emit('send_lucky_gift', {
      'receiverId': receiverId,
      'roomId': roomId,
      'coinsSent': coinsSent,
      'quantity': quantity,
    });
  }

  // Voice chat
  static void joinVoice(int roomId) {
    _socket?.emit('join_voice', {'roomId': roomId});
  }

  static void leaveVoice(int roomId) {
    _socket?.emit('leave_voice', {'roomId': roomId});
  }

  static void toggleMute(int roomId, bool isMuted) {
    _socket?.emit('toggle_mute', {
      'roomId': roomId,
      'isMuted': isMuted,
    });
  }

  static void sendSpeaking(int roomId, bool isSpeaking) {
    _socket?.emit('speaking', {
      'roomId': roomId,
      'isSpeaking': isSpeaking,
    });
  }

  // WebRTC
  static void sendOffer(int roomId, int targetUserId, dynamic offer) {
    _socket?.emit('webrtc_offer', {
      'roomId': roomId,
      'targetUserId': targetUserId,
      'offer': offer,
    });
  }

  static void sendAnswer(int roomId, int targetUserId, dynamic answer) {
    _socket?.emit('webrtc_answer', {
      'roomId': roomId,
      'targetUserId': targetUserId,
      'answer': answer,
    });
  }

  static void sendIceCandidate(int roomId, int targetUserId, dynamic candidate) {
    _socket?.emit('webrtc_ice_candidate', {
      'roomId': roomId,
      'targetUserId': targetUserId,
      'candidate': candidate,
    });
  }

  // Cohete
  static void addDiamondsToRocket(int roomId, int diamonds) {
    _socket?.emit('add_diamonds_to_rocket', {
      'roomId': roomId,
      'diamonds': diamonds,
    });
  }

  // Escuchar eventos
  static void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  // Dejar de escuchar eventos
  static void off(String event) {
    _socket?.off(event);
  }
}