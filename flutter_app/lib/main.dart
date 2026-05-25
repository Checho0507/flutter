import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/events/events_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.instance.loadToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventos Académicos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      initialRoute: ApiService.instance.isLoggedIn ? '/events' : '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/events': (_) => const EventsListScreen(),
      },
    );
  }
}
