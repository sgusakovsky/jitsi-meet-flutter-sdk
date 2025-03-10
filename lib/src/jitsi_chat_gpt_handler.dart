import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JitsiChatGPTHandler {
  final String bearer;
  final String model;
  final int maxTokens;

  JitsiChatGPTHandler({
    required this.bearer,
    this.model = 'gpt-4-turbo',
    this.maxTokens = 4096
  });

  Future<String?>makeChatGPTRequest(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Authorization': 'Bearer $bearer',
      'Content-Type': 'application/json',
    };

    final body = {
      'model': model,
      'messages': [
        {"role": "system", "content": "You must respond in plain text only. You must not use Markdown, special symbols, or any formatting. Provide responses as a simple string with no extra characters."},
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': maxTokens,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['choices'][0]['message']['content'];
      debugPrint('ChatGPT response: $text');
      return text;
    } else {
      debugPrint('ChatGPT Error: ${response.body}');
      return null;
    }

  }

}