import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/alarm_screen.dart';
import 'screens/map_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'utils/constants.dart';
import 'services/alarm_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize services
  await AuthService.instance.init();
  await AlarmService.instance.init();
  runApp(const LastStopApp());
}

class LastStopApp extends StatelessWidget {
  const LastStopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = kPrimaryColor;
    return MaterialApp(
      title: 'LastStop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            shape: RoundedRectangleBorder(borderRadius: kRadius),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
      ),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/alarm': (_) => const AlarmScreen(),
        '/map': (_) => const MapScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
      },
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}
