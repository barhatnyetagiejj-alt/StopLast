import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  void _register() async {
    setState(() => _loading = true);
    final ok = await AuthService.instance.register(_loginCtrl.text.trim(), _passCtrl.text);
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Логин уже существует')));
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
                const Text('Register', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                TextField(controller: _loginCtrl, decoration: const InputDecoration(labelText: 'Логин')),
                const SizedBox(height: 12),
                TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Пароль'), obscureText: true),
                const SizedBox(height: 20),
                AppButton.primary(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Зарегистрироваться')),
                const SizedBox(height: 12),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Уже есть аккаунт?')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
