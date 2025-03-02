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
  String _userName = '用户';
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
          // 如果用户有设置姓名，则使用它；否则保持默认值"用户"
          if (userData.name != null && userData.name!.isNotEmpty) {
            _userName = userData.name!;
          }
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // 错误时保持默认欢迎信息
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
            ? Text('加载中...')
            : Text('欢迎, $_userName!'),
        backgroundColor: Color(0xFF4FC3F7),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // 导航到设置页面
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
          crossAxisCount: 2, // 两列的网格布局
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            // 资料填写/心理问卷
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                ).then((_) {
                  // 当用户从个人资料页面返回时，重新加载用户信息
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
                    Text('资料填写/心理问卷', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            // 图片刺激测试
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
                    Text('图片刺激测试', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            // 专属心理医生
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
                    Text('专属心理医生', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            // 用户日记
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
                    Text('用户日记', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            // 查看报告
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
                    Text('查看报告', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            // 帮助与支持
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
                    Text('帮助与支持', style: TextStyle(fontSize: 18)),
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