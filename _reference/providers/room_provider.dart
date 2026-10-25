import 'package:flutter/material.dart';
import '../services/room_service.dart';

class RoomProvider extends ChangeNotifier {
  List<dynamic> _publicRooms = [];
  List<dynamic> _hotRooms = [];
  List<dynamic> _recentRooms = [];
  Map<String, dynamic>? _currentRoom;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get publicRooms => _publicRooms;
  List<dynamic> get hotRooms => _hotRooms;
  List<dynamic> get recentRooms => _recentRooms;
  Map<String, dynamic>? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Obtener salas públicas
  Future<void> getPublicRooms(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _publicRooms = await RoomService.getPublicRooms(token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener salas hot
  Future<void> getHotRooms(String token) async {
    try {
      _hotRooms = await RoomService.getHotRooms(token);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Obtener salas recientes
  Future<void> getRecentRooms(String token) async {
    try {
      _recentRooms = await RoomService.getRecentRooms(token);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Crear sala
  Future<bool> createRoom(
    String token,
    String name,
    String description,
    bool isPrivate,
    int seats,
    String? password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final room = await RoomService.createRoom(
        token, name, description, isPrivate, seats, password,
      );
      _publicRooms.insert(0, room);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Establecer sala actual
  void setCurrentRoom(Map<String, dynamic> room) {
    _currentRoom = room;
    notifyListeners();
  }

  // Limpiar sala actual
  void clearCurrentRoom() {
    _currentRoom = null;
    notifyListeners();
  }

  // Actualizar diamantes en tiempo real
  void updateRoomDiamonds(int roomId, int diamonds) {
    final index = _publicRooms.indexWhere((r) => r['id'] == roomId);
    if (index != -1) {
      _publicRooms[index]['total_diamonds_now'] = diamonds;
      notifyListeners();
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}