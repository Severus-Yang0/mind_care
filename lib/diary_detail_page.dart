import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:intl/intl.dart';
import 'models/DiaryEntry.dart';
import 'diary_edit_page.dart';

class DiaryDetailPage extends StatefulWidget {
  final DiaryEntry entry;

  const DiaryDetailPage({Key? key, required this.entry}) : super(key: key);

  @override
  _DiaryDetailPageState createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  bool _isDeleting = false;

  final _moodIcons = {
    '开心': Icons.sentiment_very_satisfied,
    '平静': Icons.sentiment_satisfied,
    '焦虑': Icons.sentiment_neutral,
    '悲伤': Icons.sentiment_dissatisfied,
  };

  Future<void> _deleteDiary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除这篇日记吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        final request = ModelMutations.delete(
          widget.entry,
          authorizationMode: APIAuthorizationType.userPools,
        );

        final response = await Amplify.API.mutate(request: request).response;

        if (response.errors?.isNotEmpty ?? false) {
          throw Exception('删除失败: ${response.errors}');
        }

        // 返回到列表页面，并传递需要刷新的信号
        Navigator.pop(context, true);
      } catch (e) {
        print('Error deleting diary: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败，请重试')),
        );
      } finally {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _editDiary() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryEditPage(entry: widget.entry),
      ),
    );

    if (result == true) {
      // 编辑成功，返回并刷新列表
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.entry.date.toString());
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('日记详情'),
        backgroundColor: Color(0xFF4FC3F7),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _isDeleting ? null : _editDiary,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _isDeleting ? null : _deleteDiary,
          ),
        ],
      ),
      body: _isDeleting
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormat.format(date),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (widget.entry.mood != null)
                        Icon(
                          _moodIcons[widget.entry.mood] ?? Icons.sentiment_neutral,
                          color: Color(0xFF4FC3F7),
                          size: 28,
                        ),
                    ],
                  ),
                  if (widget.entry.mood != null) ...[
                    SizedBox(height: 8),
                    Text(
                      '心情：${widget.entry.mood}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                  if (widget.entry.title != null &&
                      widget.entry.title!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      widget.entry.title!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  Text(
                    widget.entry.content,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}