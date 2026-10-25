import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;

  // Inicializar desde SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userStr = prefs.getString('user');
    if (userStr != null) {
      _user = Map<String, dynamic>.from(
        Uri.splitQueryString(userStr),
      );
    }
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(email, password);
      _token = result['token'];
      _user = result['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

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

  // Registro
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(username, email, password);
      _token = result['token'];
      _user = result['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

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

  // Logout
  Future<void> logout() async {
    _token = null;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    notifyListeners();
  }

  // Actualizar usuario
  void updateUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners();
  }

  // Actualizar monedas y diamantes localmente
  void updateWallet({int? coins, int? diamonds}) {
    if (_user == null) return;
    if (coins != null) _user!['coins'] = coins;
    if (diamonds != null) _user!['diamonds'] = diamonds;
    notifyListeners();
  }

  // Recargar usuario desde el backend
  Future<void> refreshUser() async {
    if (_token == null) return;
    try {
      final result = await AuthService.verifyToken(_token!);
      if (result != null) {
        _user = <String, dynamic>{
          ..._user ?? <String, dynamic>{},
          'coins': result['coins'] ?? _user?['coins'] ?? 0,
          'diamonds': result['diamonds'] ?? _user?['diamonds'] ?? 0,
        };
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}