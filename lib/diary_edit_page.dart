import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:mind_care/models/DiaryEntry.dart';

class DiaryEditPage extends StatefulWidget {
  final DiaryEntry? entry; // Pass in if editing an existing diary entry

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

  final List<String> _moods = ['Happy', 'Calm', 'Anxious', 'Sad'];

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
          // Edit existing diary entry
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
            throw Exception('Save failed: ${response.errors}');
          }
        } else {
          // Create new diary entry
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
            throw Exception('Save failed: ${response.errors}');
          }
        }

        Navigator.pop(context, true); // Return and refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed, please try again'),
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
        title: Text(widget.entry == null ? 'Write Diary' : 'Edit Diary'),
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
                        labelText: 'Title',
                        hintText: 'Give today\'s diary a title (optional)',
                        filled: true,
                        fillColor: Color(0xFFF1F8E9),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedMood,
                      decoration: InputDecoration(
                        labelText: 'Today\'s Mood',
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
                        labelText: 'Content',
                        hintText: 'Write down your thoughts...',
                        filled: true,
                        fillColor: Color(0xFFF1F8E9),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter diary content';
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