import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ai_service.dart';
import 'config.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // 创建 AIService 实例
  final AIService _aiService = AIService(
    apiKey: Config.qwenApiKey,
    baseUrl: Config.qwenBaseUrl,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('专属心理医生'),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUserMessage = message.isUser;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage)
            CircleAvatar(
              backgroundColor: Color(0xFF4FC3F7),
              child: Icon(Icons.psychology, color: Colors.white),
            ),
          SizedBox(width: 8.0),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isUserMessage ? Color(0xFF4FC3F7) : Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: 
              MarkdownBody(
  data: message.text,
  styleSheet: MarkdownStyleSheet(
    p: TextStyle(
      color: isUserMessage ? Colors.white : Colors.black87,
    ),
    strong: TextStyle(
      color: isUserMessage ? Colors.white : Colors.black87,
      fontWeight: FontWeight.bold,
    ),
  ),
)
            ),
          ),
          SizedBox(width: 8.0),
          if (isUserMessage)
            CircleAvatar(
              backgroundColor: Color(0xFF4FC3F7),
              child: Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 4,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onSubmitted: _isLoading ? null : _handleSubmitted,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      final response = await _sendMessageToAI(text);
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });

      // 再次滚动到底部以显示AI的回复
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送消息失败，请重试')),
      );
    }
  }

  Future<String> _sendMessageToAI(String message) async {
    try {
      // 使用 AIService 发送消息到 Qwen API
      final response = await _aiService.sendMessage(message);
      return response;
    } catch (e) {
      throw Exception('与AI助手通信失败，请稍后再试');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}