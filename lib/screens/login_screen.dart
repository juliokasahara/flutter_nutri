import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para trabalhar com JSON
import 'home_screen.dart'; // Importar a tela HomeScreen após a requisição bem-sucedida

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    var data = jsonEncode(
        {"nome": emailController.text, "senha": passwordController.text});

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/auth'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'insomnia/2023.5.8'
        },
        body: data,
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(utf8.decode(response.bodyBytes));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              nome: responseData['nome'],
              email: responseData['email'],
              id: responseData['id'],
            ),
          ),
        );
      } else {
        _showErrorDialog('Erro: ${response.body}');
      }
    } catch (error) {
      _showErrorDialog('Erro ao se conectar com o servidor');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Erro de Login'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
