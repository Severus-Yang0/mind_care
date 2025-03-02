import 'package:flutter/material.dart';
import 'package:mind_care/profile_page.dart';
import 'package:mind_care/diary_list_page.dart';
import 'package:mind_care/image_stimuli_page.dart';
import 'package:mind_care/chat_page.dart';
import 'package:mind_care/report_page.dart';
import 'package:mind_care/help_support_page.dart';
import 'package:mind_care/settings_page.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:mind_care/models/UserInformation.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = await Amplify.Auth.getCurrentUser();
      
      final request = ModelQueries.get(
        UserInformation.classType,
        UserInformationModelIdentifier(id: user.userId),
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        final userData = response.data as UserInformation;
        
        setState(() {
          // If user has set a name, use it; otherwise keep the default value "User"
          if (userData.name != null && userData.name!.isNotEmpty) {
            _userName = userData.name!;
          }
        });
      }
    } catch (e) {
      // Error handling - keep default welcome message
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading 
            ? Text('Loading...')
            : Text('Welcome, $_userName!'),
        backgroundColor: Color(0xFF4FC3F7),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Two-column grid layout
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            // Profile
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                ).then((_) {
                  // When user returns from profile page, reload user information
                  _loadUserProfile();
                });
              },
              child: Card(
                color: Color(0xFFF1F8E9),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 50, color: Color(0xFF4FC3F7)),
                    SizedBox(height: 10),
                    Text('Profile', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            // Image Stimuli Test
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageStimuliPage()),
                );
              },
              child: Card(
                color: Color(0xFFF1F8E9),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monitor, size: 50, color: Color(0xFF4FC3F7)),
                    SizedBox(height: 10),
                    Text('Image Stimuli Test', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            // Personal Therapist
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              },
              child: Card(
                color: Color(0xFFF1F8E9),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology, size: 50, color: Color(0xFF4FC3F7)),
                    SizedBox(height: 10),
                    Text('Personal Therapist', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            // User Diary
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiaryPage()),
                );
              },
              child: Card(
                color: Color(0xFFF1F8E9),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book, size: 50, color: Color(0xFF4FC3F7)),
                    SizedBox(height: 10),
                    Text('User Diary', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            // View Reports
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportPage()),
                );
              },
              child: Card(
                color: Color(0xFFF1F8E9),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assessment, size: 50, color: Color(0xFF4FC3F7)),
                    SizedBox(height: 10),
                    Text('View Reports', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            // Help & Support
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpSupportPage()),
                );
              },
              child: Card(
                color: Color(0xFFF1F8E9),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline,
                        size: 50, color: Color(0xFF4FC3F7)),
                    SizedBox(height: 10),
                    Text('Help & Support', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}