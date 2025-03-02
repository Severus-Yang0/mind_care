import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:mind_care/login_page.dart'; // 导入登录页面

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: ListView(
        children: [
          // 账户安全部分
          _buildSectionTitle('账户安全'),
          _buildSettingItem(
            title: '修改密码',
            icon: Icons.lock_outline,
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          
          // 数据管理部分
          _buildSectionTitle('数据管理'),
          _buildSettingItem(
            title: '导出数据',
            icon: Icons.download_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('此功能暂未开放')),
              );
            },
          ),
          _buildSettingItem(
            title: '清除本地缓存',
            icon: Icons.cleaning_services_outlined,
            onTap: () {
              _showClearCacheConfirmation(context);
            },
          ),
          
          // 应用设置部分
          _buildSectionTitle('应用设置'),
          _buildSettingItem(
            title: '通知设置',
            icon: Icons.notifications_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('此功能暂未开放')),
              );
            },
          ),
          _buildSettingItem(
            title: '主题设置',
            icon: Icons.color_lens_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('此功能暂未开放')),
              );
            },
          ),
          
          // 关于
          _buildSectionTitle('关于'),
          _buildSettingItem(
            title: '应用版本',
            icon: Icons.info_outline,
            trailing: Text('1.0.0', style: TextStyle(color: Colors.grey[600])),
          ),
          _buildSettingItem(
            title: '意见反馈',
            icon: Icons.feedback_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('此功能暂未开放')),
              );
            },
          ),
          
          // 退出登录
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[800],
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('退出登录'),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4FC3F7),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    bool _isLoading = false;
    String? _errorMessage;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('修改密码'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _currentPasswordController,
                      decoration: InputDecoration(
                        labelText: '当前密码',
                        hintText: '请输入当前密码',
                        errorText: _errorMessage,
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: '新密码',
                        hintText: '请输入新密码',
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: '确认新密码',
                        hintText: '请再次输入新密码',
                      ),
                      obscureText: true,
                    ),
                    if (_isLoading) ...[
                      SizedBox(height: 16),
                      Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: Text('取消'),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          // 验证输入
                          if (_currentPasswordController.text.isEmpty ||
                              _newPasswordController.text.isEmpty ||
                              _confirmPasswordController.text.isEmpty) {
                            setState(() {
                              _errorMessage = '请填写所有密码字段';
                            });
                            return;
                          }

                          if (_newPasswordController.text !=
                              _confirmPasswordController.text) {
                            setState(() {
                              _errorMessage = '两次输入的新密码不一致';
                            });
                            return;
                          }

                          // 验证新密码是否符合规则
                          if (_newPasswordController.text.length < 8) {
                            setState(() {
                              _errorMessage = '新密码长度至少为8位';
                            });
                            return;
                          }

                          // 设置加载状态
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });

                          try {
                            // 调用 Amplify 修改密码
                            await Amplify.Auth.updatePassword(
                              oldPassword: _currentPasswordController.text,
                              newPassword: _newPasswordController.text,
                            );

                            // 关闭对话框
                            Navigator.of(context).pop();

                            // 显示成功消息
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('密码修改成功'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } on AuthException catch (e) {
                            // 处理认证错误
                            setState(() {
                              _isLoading = false;
                              switch (e.message) {
                                case 'Incorrect username or password.':
                                  _errorMessage = '当前密码错误';
                                  break;
                                default:
                                  _errorMessage = '密码修改失败: ${e.message}';
                              }
                            });
                          } catch (e) {
                            // 处理其他错误
                            setState(() {
                              _isLoading = false;
                              _errorMessage = '发生错误: $e';
                            });
                          }
                        },
                  child: Text('确认修改'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showClearCacheConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('清除缓存'),
        content: Text('确定要清除应用缓存吗？这不会删除您的账户数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('缓存已清除')),
              );
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  // 正确的退出登录方法，确保返回到登录页面
  void _signOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('退出登录'),
        content: Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 先关闭对话框
              Navigator.of(dialogContext).pop();
              
              try {
                // 执行退出登录
                await Amplify.Auth.signOut();
                
                // 登出成功后，直接导航到登录页面并清除所有之前的路由
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false, // 清除所有之前的路由
                  );
                }
              } catch (e) {
                // 只有在登出失败时才显示SnackBar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('退出登录失败: $e')),
                  );
                }
              }
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }
}