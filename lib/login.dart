import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:quicktask/register.dart';
import 'package:quicktask/main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => QuickTaskApp()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Colors.indigoAccent,
        centerTitle: true,
        elevation: 8.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Center(
              child: const Text('QuickTask',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.indigoAccent)),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                  'Stay Organized, Achieve More with QuickTask!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.indigoAccent),
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: Colors.indigoAccent),
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _login(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.black, 
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Login', style: TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: const Text(
                'New User? Register here',
                style: TextStyle(color: Colors.indigoAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      final user = ParseUser(username, password, null);
      var response = await user.login();

      if (response.success) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => QuickTaskApp()));
      } else {
        _showError(response.error!.message);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

