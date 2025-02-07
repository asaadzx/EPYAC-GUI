import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const OllamaChatApp());
}

class OllamaChatApp extends StatelessWidget {
  const OllamaChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:11434/api/generate'));
  bool _isLoading = false;

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': message});
      _isLoading = true;
    });

    try {
      final response = await _dio.post(
        '',
        data: {'model': 'gemma', 'prompt': message},
      );
      setState(() {
        _messages.add({'sender': 'bot', 'text': response.data['response']});
      });
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'Error: Unable to fetch response'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ollama Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['text']!, style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
