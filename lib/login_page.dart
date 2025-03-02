import 'package:flutter/material.dart';
import 'package:mind_care/registration_page.dart';
import 'package:mind_care/home_page.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser(BuildContext context) async {
    try {
      await Amplify.Auth.signOut();
    } on AuthException catch (e) {}
    try {
      SignInResult result = await Amplify.Auth.signIn(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (result.isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        _showError(context, '');
      }
    } catch (e) {
      _showError(context, '${e.toString()}');
    }
  }

  void _showError(BuildContext context, String message) {
    print('$message');
    String errorMessage = '登录失败';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '欢迎来到 MindCare',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            // 用户名输入框
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: '用户名',
                prefixIcon: Icon(Icons.person, color: Color(0xFF4FC3F7)),
                filled: true,
                fillColor: Color(0xFFF1F8E9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            // 密码输入框
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '密码',
                prefixIcon: Icon(Icons.lock, color: Color(0xFF4FC3F7)),
                filled: true,
                fillColor: Color(0xFFF1F8E9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 40),
            // 登录按钮
            ElevatedButton(
              onPressed: () => _loginUser(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4FC3F7),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '登录',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            // 前往注册页面按钮
            TextButton(
              onPressed: () {
                // 导航到注册页面
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: Text(
                '没有账户？前往注册',
                style: TextStyle(
                  color: Color(0xFFFFA726),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
