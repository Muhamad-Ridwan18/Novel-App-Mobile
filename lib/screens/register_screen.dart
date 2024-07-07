// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/novel_list_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _authService = AuthService('http://10.0.2.2:8000/api'); // Ganti dengan URL Laravel Anda

  void _register() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final passwordConfirmation = _passwordConfirmationController.text;

    final response = await _authService.register(name, email, password, passwordConfirmation);

    if (response.success) {

      // Pindah ke halaman lain setelah registrasi berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NovelScreen()), // Ganti dengan halaman yang diinginkan
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registrasi gagal: ${response.message}'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _passwordConfirmationController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
