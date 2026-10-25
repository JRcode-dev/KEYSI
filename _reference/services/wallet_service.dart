import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class WalletService {

  // Obtener balance
  static Future<Map<String, dynamic>> getBalance(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/wallet/balance'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al obtener balance');
    }
  }

  // Recargar monedas
  static Future<Map<String, dynamic>> rechargeCoins(
    String token,
    double amountUsd,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/wallet/recharge'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'amountUsd': amountUsd}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al recargar monedas');
    }
  }

  // Convertir diamantes a monedas
  static Future<Map<String, dynamic>> convertDiamonds(
    String token,
    int diamonds,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/wallet/convert-diamonds'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'diamonds': diamonds}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al convertir diamantes');
    }
  }

  // Solicitar retiro
  static Future<Map<String, dynamic>> requestWithdrawal(
    String token,
    int diamonds,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/withdrawals/request'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'diamonds': diamonds}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al solicitar retiro');
    }
  }

  // Convertir monedas a USD
  static Future<Map<String, dynamic>> coinsToUsd(
    String token,
    int coins,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/wallet/coins-to-usd'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'coins': coins}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al convertir monedas');
    }
  }

  // Convertir diamantes a USD
  static Future<Map<String, dynamic>> diamondsToUsd(
    String token,
    int diamonds,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/wallet/diamonds-to-usd'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'diamonds': diamonds}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Error al convertir diamantes');
    }
  }

}