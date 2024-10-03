import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatelessWidget {
  final String nome;
  final String email;
  final int id;

  HomeScreen({required this.nome, required this.email, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo $nome'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nome: $nome',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de dieta
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DietScreen(usuarioId: id)),
                );
              },
              child: Text('Ver Dieta'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de cadastro de dieta
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CadastroDietaScreen(usuarioId: id)),
                );
              },
              child: Text('Cadastrar Dieta'),
            ),
          ],
        ),
      ),
    );
  }
}

class DietScreen extends StatefulWidget {
  final int usuarioId;

  DietScreen({required this.usuarioId});

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  List dietas = [];

  @override
  void initState() {
    super.initState();
    fetchDietas();
  }

  Future<void> fetchDietas() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/dieta/usuario/${widget.usuarioId}'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'insomnia/2023.5.8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        dietas = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      // Exibir mensagem de erro caso a requisição falhe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar as dietas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha Dieta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: dietas.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: dietas.length,
                itemBuilder: (context, index) {
                  final dieta = dietas[index];
                  return ListTile(
                    title: Text(dieta['nome']),
                    subtitle: Text(dieta['descricao']),
                    trailing: Text('${dieta['caloria']} cal'),
                  );
                },
              ),
      ),
    );
  }
}

// Classe para tela de cadastro de dieta
class CadastroDietaScreen extends StatefulWidget {
  final int usuarioId;

  CadastroDietaScreen({required this.usuarioId});

  @override
  _CadastroDietaScreenState createState() => _CadastroDietaScreenState();
}

class _CadastroDietaScreenState extends State<CadastroDietaScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController caloriaController = TextEditingController();
  String errorMessage = "";

  Future<void> cadastrarDieta() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/dieta/usuario/${widget.usuarioId}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'nome': nomeController.text,
        'descricao': descricaoController.text,
        'caloria': double.parse(caloriaController.text),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dieta cadastrada com sucesso!')),
      );
      Navigator.pop(context); // Voltar para a tela anterior
    } else if (response.statusCode == 400) {
      // Captura o corpo da resposta com os erros
      var errors = jsonDecode(utf8.decode(response.bodyBytes));

      // Exibir as mensagens de erro (no formato do backend)
      setState(() {
        errorMessage = errors.toString(); // Exibe as mensagens de erro
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro desconhecido ao cadastrar a dieta!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Dieta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome da Refeição'),
            ),
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: caloriaController,
              decoration: InputDecoration(labelText: 'Calorias'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: cadastrarDieta,
              child: Text('Cadastrar'),
            ),
            if (errorMessage
                .isNotEmpty) // Exibe as mensagens de erro, se houver
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
