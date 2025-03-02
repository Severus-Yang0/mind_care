import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  final String apiKey;
  final String baseUrl;
  final List<Map<String, String>> _messageHistory = [];

  AIService({
    required this.apiKey,
    required this.baseUrl,
  }) {
    // Initialize by adding system role setting
    _messageHistory.add({
      'role': 'system',
      'content': 'You are a professional therapist with extensive experience in psychological counseling. '
          'You always listen to users\' concerns with empathy, providing professional, gentle, and constructive advice. '
          'Please communicate with users in a warm, professional tone to help them explore and resolve psychological issues. '
          'During conversations, be mindful of protecting users\' privacy and suggest they seek offline professional '
          'psychological help when necessary.'
    });
  }

  Future<String> sendMessage(String message) async {
    _messageHistory.add({
      'role': 'user',
      'content': message
    });

    final url = Uri.parse('$baseUrl/services/aigc/text-generation/generation');
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json; charset=utf-8',
    };

    final body = jsonEncode({
      'model': 'qwen-turbo',
      'input': {
        'messages': _messageHistory
      },
      'parameters': {
        'temperature': 0.7,
        'top_p': 0.8,
        'result_format': 'message',
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(decodedResponse);
        final output = jsonResponse['output'];
        if (output != null && output['choices'] != null && output['choices'].isNotEmpty) {
          final assistantMessage = output['choices'][0]['message']['content'];
          _messageHistory.add({
            'role': 'assistant',
            'content': assistantMessage
          });
          return assistantMessage;
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('API request failed');
      }
    } catch (e) {
      throw Exception('Failed to send message');
    }
  }
}