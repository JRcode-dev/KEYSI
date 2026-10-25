import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_localizations.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/room_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/moments/moments_screen.dart';
import 'screens/messages/messages_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación solo vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Verificar si hay token guardado
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(VivraApp(isLoggedIn: token != null));
}

class VivraApp extends StatelessWidget {
  final bool isLoggedIn;

  const VivraApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,

            // Tema de la app
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFFF4081),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF0A0A0A),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0A0A0A),
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),
            ),

            // Idiomas soportados
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,

            // Soporte RTL para árabe
            builder: (context, child) {
              return Directionality(
                textDirection: Localizations.localeOf(context).languageCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },

            // Pantalla inicial
            home: isLoggedIn ? const HomeScreen() : const LoginScreen(),

            // Rutas
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/register': (context) => const RegisterScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/wallet': (context) => const WalletScreen(),
              '/moments': (context) => const MomentsScreen(),
              '/messages': (context) => const MessagesScreen(),
            },
          );
        },
      ),
    );
  }
}