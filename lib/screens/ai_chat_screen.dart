// screens/ai_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIChatScreen extends StatefulWidget {
  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> _messages = [];
  String _selectedCategory = 'Health';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages.add({'sender': 'ai', 'message': 'Welcome! How can I assist you today?'});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Chat', style: TextStyle(fontSize: 18, color: Colors.black)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return ['Health', 'Diet'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && !_isLoading
                ? Center(child: Text('Start a conversation with AI!'))
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_messages[index]['sender'] == 'user' ? 'You' : 'AI',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(_messages[index]['message'] ?? ''),
                      );
                    },
                  ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': _messageController.text});
      _isLoading = true;
    });

    _getAIResponse(_messageController.text);
    _messageController.clear();
  }

  Future<void> _getAIResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer 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'
        },
        body: json.encode({
          'model': 'text-davinci-003',
          'prompt': _buildPrompt(userMessage),
          'max_tokens': 100,
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String aiResponse = data['choices'][0]['text'].trim();

        setState(() {
          _messages.add({'sender': 'ai', 'message': aiResponse});
        });
      } else {
        setState(() {
          _messages.add({'sender': 'ai', 'message': 'Error: Unable to fetch response from AI.'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'ai', 'message': 'Error: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildPrompt(String userMessage) {
    if (_selectedCategory == 'Health') {
      return "You are a health assistant specialized in providing advice for men and women above 50. Provide accurate and empathetic responses: \nUser: $userMessage";
    } else if (_selectedCategory == 'Diet') {
      return "You are a dietary assistant. Provide advice on healthy eating, meal planning, and nutritional advice for people above 50: \nUser: $userMessage";
    }
    return userMessage;
  }
}
