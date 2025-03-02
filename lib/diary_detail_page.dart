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
    'Happy': Icons.sentiment_very_satisfied,
    'Calm': Icons.sentiment_satisfied,
    'Anxious': Icons.sentiment_neutral,
    'Sad': Icons.sentiment_dissatisfied,
  };

  Future<void> _deleteDiary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this diary entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
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
          throw Exception('Delete failed: ${response.errors}');
        }

        // Return to the list page with a signal to refresh
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed, please try again')),
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
      // Edit successful, return and refresh the list
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.entry.date.toString());
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Diary Details'),
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
                      'Mood: ${widget.entry.mood}',
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