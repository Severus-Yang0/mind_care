import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:mind_care/models/DiaryEntry.dart';

class DiaryEditPage extends StatefulWidget {
  final DiaryEntry? entry; // 如果是编辑现有日记，则传入

  const DiaryEditPage({Key? key, this.entry}) : super(key: key);

  @override
  _DiaryEditPageState createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends State<DiaryEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedMood;
  bool _isSaving = false;

  final List<String> _moods = ['开心', '平静', '焦虑', '悲伤'];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title ?? '';
      _contentController.text = widget.entry!.content;
      _selectedMood = widget.entry!.mood;
    }
  }

Future<void> _saveDiary() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final user = await Amplify.Auth.getCurrentUser();
        final now = DateTime.now();
        
        if (widget.entry != null) {
          // 编辑现有日记
          final updatedEntry = widget.entry!.copyWith(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            mood: _selectedMood,
            updatedAt: TemporalDateTime(now),
          );

          final request = ModelMutations.update(
            updatedEntry,
            authorizationMode: APIAuthorizationType.userPools,
          );

          final response = await Amplify.API.mutate(request: request).response;

          if (response.errors?.isNotEmpty ?? false) {
            throw Exception('保存失败: ${response.errors}');
          }
        } else {
          // 创建新日记
          final newEntry = DiaryEntry(
            userId: user.userId,
            date: TemporalDateTime(now),
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            mood: _selectedMood,
            tags: [],
            createdAt: TemporalDateTime(now),
            updatedAt: TemporalDateTime(now),
          );

          final request = ModelMutations.create(
            newEntry,
            authorizationMode: APIAuthorizationType.userPools,
          );

          final response = await Amplify.API.mutate(request: request).response;

          if (response.errors?.isNotEmpty ?? false) {
            throw Exception('保存失败: ${response.errors}');
          }
        }

        Navigator.pop(context, true); // 返回并刷新列表
      } catch (e) {
        print('Error saving diary: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败，请重试\n${e.toString()}'),
            duration: Duration(seconds: 5),
          ),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? '写日记' : '编辑日记'),
        backgroundColor: Color(0xFF4FC3F7),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isSaving ? null : _saveDiary,
          ),
        ],
      ),
      body: _isSaving
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: '标题',
                        hintText: '给今天的日记起个标题吧（选填）',
                        filled: true,
                        fillColor: Color(0xFFF1F8E9),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedMood,
                      decoration: InputDecoration(
                        labelText: '今天的心情',
                        filled: true,
                        fillColor: Color(0xFFF1F8E9),
                      ),
                      items: _moods.map((String mood) {
                        return DropdownMenuItem<String>(
                          value: mood,
                          child: Text(mood),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMood = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: '内容',
                        hintText: '记录下此刻的想法...',
                        filled: true,
                        fillColor: Color(0xFFF1F8E9),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入日记内容';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}