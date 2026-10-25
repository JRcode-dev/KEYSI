class AppConfig {
  // URL del backend
  static const String baseUrl = 'http://192.168.40.7:3000';
  static const String apiUrl = '$baseUrl/api';
  static const String socketUrl = baseUrl;

  // Configuración de la app
  static const String appName = 'Vivra';
  static const String appVersion = '1.0.0';

  // Configuración de monedas
  static const int coinsPerUsd = 25000;
  static const int diamondsPerUsd = 50000;
  static const int minWithdrawal = 500000;
  static const double diamondToCoinRate = 0.5;

  // Configuración de niveles
  static const int maxLevel = 125;
  static const double levelIncrement = 1.15;
  static const int baseXp = 10000;

  // Configuración de regalos
  static const int customGiftPrice = 150000;
  static const int customGiftLevel = 100;

  // Configuración de momentos
  static const int maxMomentSizeMb = 3;
  static const int maxMomentsPerDay = 1;

  // Colores de niveles
  static const Map<String, dynamic> levelColors = {
    'grey': 0xFF9E9E9E,
    'blue': 0xFF2196F3,
    'purple': 0xFF9C27B0,
    'gold': 0xFFFFD700,
    'red': 0xFFF44336,
  };

  // Colores de títulos
  static const Map<String, dynamic> titleColors = {
    'grey': 0xFF9E9E9E,
    'blue': 0xFF2196F3,
    'purple': 0xFF9C27B0,
    'gold': 0xFFFFD700,
    'orange': 0xFFFF9800,
    'red': 0xFFF44336,
    'bright_blue': 0xFF00BCD4,
    'bright_gold': 0xFFFFD700,
    'bright_red': 0xFFFF1744,
    'rainbow': 0xFFFF4081,
  };
}