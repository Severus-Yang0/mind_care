import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ai_service.dart';
import 'config.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'models/DiaryEntry.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<DiaryEntry> _diaryEntries = [];
  bool _isLoadingDiaries = false;

  // Create AIService instance
  final AIService _aiService = AIService(
    apiKey: Config.qwenApiKey,
    baseUrl: Config.qwenBaseUrl,
  );

  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();
  }

  Future<void> _loadDiaryEntries() async {
    try {
      setState(() {
        _isLoadingDiaries = true;
      });
      
      final user = await Amplify.Auth.getCurrentUser();
      final request = ModelQueries.list(
        DiaryEntry.classType,
        where: DiaryEntry.USERID.eq(user.userId),
        authorizationMode: APIAuthorizationType.userPools,
      );
      
      final response = await Amplify.API.query(request: request).response;
      final entries = response.data?.items;
      
      if (entries != null) {
        setState(() {
          _diaryEntries = entries
            .whereType<DiaryEntry>()
            .toList()
            ..sort((a, b) => b.date.toString().compareTo(a.date.toString()));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load diary entries')),
      );
    } finally {
      setState(() {
        _isLoadingDiaries = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Therapist'),
        backgroundColor: Color(0xFF4FC3F7),
        actions: [
          IconButton(
            icon: Icon(Icons.book),
            tooltip: 'Share diary entry',
            onPressed: _showDiarySelectionDialog,
          ),
        ],
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

  void _showDiarySelectionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a diary entry to share',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: _isLoadingDiaries
                    ? Center(child: CircularProgressIndicator())
                    : _diaryEntries.isEmpty
                        ? Center(
                            child: Text(
                              'No diary entries yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _diaryEntries.length,
                            itemBuilder: (context, index) {
                              return _buildDiarySelectItem(_diaryEntries[index]);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiarySelectItem(DiaryEntry entry) {
    final date = DateTime.parse(entry.date.toString());
    final dateFormat = DateFormat('MMM dd, yyyy');
    final preview = entry.content.length > 50
        ? '${entry.content.substring(0, 50)}...'
        : entry.content;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          entry.title ?? dateFormat.format(date),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(preview),
        onTap: () {
          Navigator.pop(context);
          _shareDiaryWithAI(entry);
        },
      ),
    );
  }

  void _shareDiaryWithAI(DiaryEntry entry) async {
    final date = DateTime.parse(entry.date.toString());
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    final diaryText = '''
I'd like to share a diary entry from ${dateFormat.format(date)}:

${entry.title != null && entry.title!.isNotEmpty ? "Title: ${entry.title}\n" : ""}
${entry.mood != null ? "Mood: ${entry.mood}\n" : ""}
${entry.content}

Please provide your thoughts and insights based on this entry.
''';

    setState(() {
      _messages.add(ChatMessage(
        text: "I've shared a diary entry from ${dateFormat.format(date)}",
        isUser: true,
        isDiaryShare: true,
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _aiService.sendMessage(diaryText);
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share diary with AI, please try again')),
      );
    }
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
                color: isUserMessage 
                    ? (message.isDiaryShare ? Color(0xFF81C784) : Color(0xFF4FC3F7)) 
                    : Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: MarkdownBody(
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
              ),
            ),
          ),
          SizedBox(width: 8.0),
          if (isUserMessage)
            CircleAvatar(
              backgroundColor: message.isDiaryShare ? Color(0xFF81C784) : Color(0xFF4FC3F7),
              child: Icon(
                message.isDiaryShare ? Icons.book : Icons.person,
                color: Colors.white,
              ),
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
                hintText: 'Type a message...',
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

    _scrollToBottom();

    try {
      final response = await _sendMessageToAI(text);
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message, please try again')),
      );
    }
  }

  void _scrollToBottom() {
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<String> _sendMessageToAI(String message) async {
    try {
      // Use AIService to send message to Qwen API
      final response = await _aiService.sendMessage(message);
      return response;
    } catch (e) {
      throw Exception('Failed to communicate with AI assistant, please try again later');
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
  final bool isDiaryShare;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isDiaryShare = false,
  });
}