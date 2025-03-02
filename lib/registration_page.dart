import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _confirmationCodeController =
      TextEditingController(); // 验证码控制器

  bool _isConfirmationStep = false; // 控制是否显示验证码输入
  String _currentUsername = ''; // 存储注册时的用户名

  Future<void> _registerUser(BuildContext context) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError(context, '两次输入的密码不一致');
      return;
    }

    try {
      // 尝试注册用户
      SignUpResult result = await Amplify.Auth.signUp(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        options: SignUpOptions(userAttributes: {
          CognitoUserAttributeKey.email: _emailController.text.trim(),
        }),
      );
      if (result.isSignUpComplete) {
        // 注册完成，跳转到登录页面或主页
        Navigator.pop(context);
      } else {
        setState(() {
          _isConfirmationStep = true; // 进入验证码输入步骤
          _currentUsername = _usernameController.text.trim();
        });
      }
    } on AuthException catch (e) {
      // 如果用户已存在但未确认
      if (e.message.contains('User already exists')) {
        // 通过 resendSignUp 重发验证码
        try {
          await Amplify.Auth.resendSignUpCode(
            username: _usernameController.text.trim(),
          );
          setState(() {
            _isConfirmationStep = true; // 切换到验证码输入模式
            _currentUsername = _usernameController.text.trim();
          });
          _showError(context, '用户已存在，但未验证(将使用第一次注册时的密码)。已重新发送验证码');
        } catch (resendError) {
          _showError(context, '无法重新发送验证码: ${resendError.toString()}');
        }
      } else {
        _showError(context, '注册失败: ${e.message}');
      }
    }
  }

  Future<void> _confirmSignUp(BuildContext context) async {
    try {
      SignUpResult result = await Amplify.Auth.confirmSignUp(
        username: _currentUsername,
        confirmationCode: _confirmationCodeController.text.trim(),
      );
      if (result.isSignUpComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('注册成功')),
        );
        Navigator.pop(context); // 验证完成后返回登录页面
      } else {
        _showError(context, '验证码验证失败');
      }
    } catch (e) {
      _showError(context, '验证码验证失败: ${e.toString()}');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text('注册'),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isConfirmationStep ? '输入验证码' : '创建新账户',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            if (!_isConfirmationStep) ...[
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
              // 邮箱输入框
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '邮箱',
                  prefixIcon: Icon(Icons.email, color: Color(0xFF4FC3F7)),
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
              SizedBox(height: 20),
              // 确认密码输入框
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '确认密码',
                  prefixIcon:
                      Icon(Icons.lock_outline, color: Color(0xFF4FC3F7)),
                  filled: true,
                  fillColor: Color(0xFFF1F8E9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // 注册按钮
              ElevatedButton(
                onPressed: () => _registerUser(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4FC3F7),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '注册',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ] else ...[
              // 验证码输入框
              TextField(
                controller: _confirmationCodeController,
                decoration: InputDecoration(
                  labelText: '验证码',
                  prefixIcon:
                      Icon(Icons.confirmation_num, color: Color(0xFF4FC3F7)),
                  filled: true,
                  fillColor: Color(0xFFF1F8E9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 验证按钮
              ElevatedButton(
                onPressed: () => _confirmSignUp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4FC3F7),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '验证',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              // 重新发送验证码按钮
              TextButton(
                onPressed: () async {
                  try {
                    await Amplify.Auth.resendSignUpCode(
                      username: _currentUsername,
                    );
                    _showError(context, '验证码已重新发送');
                  } catch (e) {
                    _showError(context, '重新发送验证码失败: ${e.toString()}');
                  }
                },
                child: Text(
                  '重新发送验证码',
                  style: TextStyle(color: Color(0xFFFFA726), fontSize: 16),
                ),
              ),
            ],
            SizedBox(height: 20),
            // 返回登录按钮
            if (!_isConfirmationStep)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '已经有账户？前往登录',
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
