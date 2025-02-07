import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const OllamaApp());
}

class OllamaApp extends StatefulWidget {
  const OllamaApp({super.key});

  @override
  State<OllamaApp> createState() => _OllamaAppState();
}

class _OllamaAppState extends State<OllamaApp> {
  final TextEditingController _promptController = TextEditingController();
  String _response = '';

  Future<void> _sendPrompt() async {
    final prompt = _promptController.text;
    final response = await http.post(
      Uri.parse('http://localhost:11434/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: '{"model": "asaad/epyac.1", "prompt": "$prompt"}',
    );

    if (response.statusCode == 200) {
      setState(() {
        _response = response.body;
      });
    } else {
      setState(() {
        _response = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Epyac wings',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ollama App'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _promptController,
                decoration: const InputDecoration(
                  hintText: 'Enter your prompt',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _sendPrompt,
                child: const Text('Send'),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_response),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}