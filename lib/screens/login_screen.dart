import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    final ok = await AuthService.instance.login(_loginCtrl.text.trim(), _passCtrl.text);
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Неверный логин или пароль')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kBgGradientStart, kBgGradientEnd],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('LastStop', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                TextField(controller: _loginCtrl, decoration: const InputDecoration(labelText: 'Логин')),
                const SizedBox(height: 12),
                TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Пароль'), obscureText: true),
                const SizedBox(height: 20),
                AppButton.primary(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator() : const Text('Войти')),
                const SizedBox(height: 12),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Зарегистрироваться')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
