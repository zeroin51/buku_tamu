import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'form_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String role = 'user'; // default role

  void login() {
    final username = usernameController.text;
    final password = passwordController.text;

    if (role == 'admin' && username == 'admin' && password == 'admin123') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AdminPage()));
    } else if (role == 'user') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const FormPage()));
    } else {
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                title: Text('Login Gagal'),
                content: Text('Username atau password salah.'),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Buku Tamu')),
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: role,
                onChanged: (value) => setState(() => role = value!),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: login, child: const Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}
