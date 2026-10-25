import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  Map<String, dynamic>? _balance;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get balance => _balance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get coins => _balance?['coins'] ?? 0;
  int get diamonds => _balance?['diamonds'] ?? 0;
  double get totalSpentUsd => _balance?['totalSpentUsd'] ?? 0.0;
  double get totalEarnedUsd => _balance?['totalEarnedUsd'] ?? 0.0;
  double get totalWithdrawnUsd => _balance?['totalWithdrawnUsd'] ?? 0.0;

  // Obtener balance
  Future<void> getBalance(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _balance = await WalletService.getBalance(token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Recargar monedas
  Future<bool> rechargeCoins(String token, double amountUsd) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await WalletService.rechargeCoins(token, amountUsd);
      _balance?['coins'] = result['user']['coins'];
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

  // Convertir diamantes a monedas
  Future<bool> convertDiamonds(String token, int diamonds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await WalletService.convertDiamonds(token, diamonds);
      _balance?['diamonds'] = (_balance?['diamonds'] ?? 0) - diamonds;
      _balance?['coins'] = (_balance?['coins'] ?? 0) + result['coinsReceived'];
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

  // Solicitar retiro
  Future<bool> requestWithdrawal(String token, int diamonds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await WalletService.requestWithdrawal(token, diamonds);
      _balance?['diamonds'] = (_balance?['diamonds'] ?? 0) - diamonds;
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

  // Actualizar monedas localmente
  void updateCoins(int amount) {
    if (_balance != null) {
      _balance!['coins'] = (_balance!['coins'] ?? 0) + amount;
      notifyListeners();
    }
  }

  // Actualizar diamantes localmente
  void updateDiamonds(int amount) {
    if (_balance != null) {
      _balance!['diamonds'] = (_balance!['diamonds'] ?? 0) + amount;
      notifyListeners();
    }
  }

  // Recargar balance desde el backend
Future<void> refreshBalance(String token) async {
  try {
    _balance = await WalletService.getBalance(token);
    notifyListeners();
  } catch (e) {
    debugPrint('Error refreshing balance: $e');
  }
}

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}