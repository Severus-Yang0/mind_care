import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:intl/intl.dart';
import 'models/DiaryEntry.dart';
import 'diary_edit_page.dart';
import 'diary_detail_page.dart';

class DiaryPage extends StatefulWidget {
  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  List<DiaryEntry> _entries = [];
  bool _isLoading = true;
  
  final _moodIcons = {
    'Happy': Icons.sentiment_very_satisfied,
    'Calm': Icons.sentiment_satisfied,
    'Anxious': Icons.sentiment_neutral,
    'Sad': Icons.sentiment_dissatisfied,
  };
  
  @override
  void initState() {
    super.initState();
    _loadEntries();
  }
  
  Future<void> _loadEntries() async {
    try {
      setState(() {
        _isLoading = true;
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
          _entries = entries
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
        _isLoading = false;
      });
    }
  }
  
  Widget _buildEntryCard(DiaryEntry entry) {
    final date = DateTime.parse(entry.date.toString());
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryDetailPage(entry: entry),
            ),
          );
          // If returning true, it means the entry was edited or deleted and the list needs to be refreshed
          if (result == true) {
            _loadEntries();
          }
        },
        child: Padding(
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
                  if (entry.mood != null)
                    Icon(
                      _moodIcons[entry.mood] ?? Icons.sentiment_neutral,
                      color: Color(0xFF4FC3F7),
                    ),
                ],
              ),
              SizedBox(height: 8),
              if (entry.title != null && entry.title!.isNotEmpty) ...[
                Text(
                  entry.title!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
              ],
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _navigateToCreateDiary() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryEditPage(),
      ),
    );
    // If returning true, it means creation/editing was successful and the list needs to be refreshed
    if (result == true) {
      _loadEntries();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Diary'),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadEntries,
            child: _entries.isEmpty
              ? Center(
                  child: Text(
                    'No diary entries yet\nClick the button below to start writing',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    return _buildEntryCard(_entries[index]);
                  },
                ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateDiary,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF4FC3F7),
      ),
    );
  }
}