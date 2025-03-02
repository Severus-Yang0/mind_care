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
    // 初始化时添加系统角色设定
    _messageHistory.add({
      'role': 'system',
      'content': '你是一位专业的心理医生，拥有丰富的心理咨询经验。你始终以同理心倾听用户的问题，'
          '提供专业、温和且有建设性的建议。请用温暖、专业的语气与用户交流，帮助他们探索和解决心理困扰。'
          '在对话中，要注意保护用户的隐私，并在必要时建议用户寻求线下专业心理医生的帮助。'
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