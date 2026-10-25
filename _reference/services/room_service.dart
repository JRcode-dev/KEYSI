import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class RoomService {

  // Obtener salas públicas
  static Future<List<dynamic>> getPublicRooms(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/rooms'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al obtener salas');
    }
  }

  // Obtener salas hot (más activas)
  static Future<List<dynamic>> getHotRooms(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/rooms/hot'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al obtener salas hot');
    }
  }

  // Obtener salas recientes
  static Future<List<dynamic>> getRecentRooms(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/rooms/recent'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al obtener salas recientes');
    }
  }

  // Crear sala
  static Future<Map<String, dynamic>> createRoom(
    String token,
    String name,
    String description,
    bool isPrivate,
    int seats,
    String? password,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/rooms'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'isPrivate': isPrivate,
        'seats': seats,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al crear sala');
    }
  }

  // Obtener sala por id
  static Future<Map<String, dynamic>> getRoomById(
    String token,
    int roomId,
  ) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/rooms/$roomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al obtener sala');
    }
  }

  // Eliminar sala
  static Future<bool> deleteRoom(String token, int roomId) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.apiUrl}/rooms/$roomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Error al eliminar sala');
    }
  }

  // Obtener mensajes de una sala
  static Future<List<dynamic>> getRoomMessages(
    String token,
    int roomId,
  ) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/rooms/$roomId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al obtener mensajes');
    }
  }

}