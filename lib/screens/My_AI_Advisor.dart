import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:health_companion/config/app_settings.dart';

class MyAIAdvisorScreen extends StatefulWidget {
  @override
  _MyAIAdvisorScreenState createState() => _MyAIAdvisorScreenState();
}

class _MyAIAdvisorScreenState extends State<MyAIAdvisorScreen> {
  final TextEditingController _questionController = TextEditingController();
  List<Map<String, String>> _conversationHistory = [];
  bool _isHealth = true;
  bool _isLoading = false;
  FlutterTts flutterTts = FlutterTts();

  final String _apiKey = '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'; // Update this line with your correct API key
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  double globalFontSize = 16.0;  // Define a default font size

  // ... (previous methods remain the same)

  Future<void> _askQuestion() async {
    if (_questionController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final topic = _isHealth ? "health" : "diet and nutrition";
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant specializing in $topic advice. Provide concise answers.'},
            {'role': 'user', 'content': _questionController.text},
          ],
          'max_tokens': 150,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final aiResponse = data['choices'][0]['message']['content'];
          setState(() {
            _conversationHistory.add({
              'question': _questionController.text,
              'answer': aiResponse,
            });
            _questionController.clear();
          });
          await _saveConversationHistory();
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception('API request failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error in _askQuestion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _speakText(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  Future<void> _saveConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = _conversationHistory.map((item) => json.encode(item)).toList();
    await prefs.setStringList('conversation_history', history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My AI Advisor (English)'),
        actions: [
          Switch(
            value: _isHealth,
            onChanged: (value) {
              setState(() {
                _isHealth = value;
              });
            },
          ),
          Text(_isHealth ? 'Health' : 'Diet'),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _conversationHistory.length,
              itemBuilder: (context, index) {
                final item = _conversationHistory[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Q: ${item['question']}', style: TextStyle(fontSize:globalFontSize, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('A: ${item['answer']}'),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.volume_up),
                              onPressed: () => _speakText(item['answer'] ?? ''),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0).copyWith(bottom: 28.0), // Increase bottom padding to move up
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Ask a question in English...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isLoading ? null : _askQuestion,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
