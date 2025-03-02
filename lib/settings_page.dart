import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:mind_care/login_page.dart'; // Import login page

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: ListView(
        children: [
          // Account Security section
          _buildSectionTitle('Account Security'),
          _buildSettingItem(
            title: 'Change Password',
            icon: Icons.lock_outline,
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          
          // Data Management section
          _buildSectionTitle('Data Management'),
          _buildSettingItem(
            title: 'Export Data',
            icon: Icons.download_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('This feature is not available yet')),
              );
            },
          ),
          _buildSettingItem(
            title: 'Clear Local Cache',
            icon: Icons.cleaning_services_outlined,
            onTap: () {
              _showClearCacheConfirmation(context);
            },
          ),
          
          // App Settings section
          _buildSectionTitle('App Settings'),
          _buildSettingItem(
            title: 'Notification Settings',
            icon: Icons.notifications_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('This feature is not available yet')),
              );
            },
          ),
          _buildSettingItem(
            title: 'Theme Settings',
            icon: Icons.color_lens_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('This feature is not available yet')),
              );
            },
          ),
          
          // About section
          _buildSectionTitle('About'),
          _buildSettingItem(
            title: 'App Version',
            icon: Icons.info_outline,
            trailing: Text('1.0.0', style: TextStyle(color: Colors.grey[600])),
          ),
          _buildSettingItem(
            title: 'Feedback',
            icon: Icons.feedback_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('This feature is not available yet')),
              );
            },
          ),
          
          // Logout
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
              child: Text('Logout'),
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
              title: Text('Change Password'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _currentPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        hintText: 'Enter current password',
                        errorText: _errorMessage,
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter new password',
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        hintText: 'Re-enter new password',
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
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          // Validate input
                          if (_currentPasswordController.text.isEmpty ||
                              _newPasswordController.text.isEmpty ||
                              _confirmPasswordController.text.isEmpty) {
                            setState(() {
                              _errorMessage = 'Please fill in all password fields';
                            });
                            return;
                          }

                          if (_newPasswordController.text !=
                              _confirmPasswordController.text) {
                            setState(() {
                              _errorMessage = 'New passwords do not match';
                            });
                            return;
                          }

                          // Validate if new password meets requirements
                          if (_newPasswordController.text.length < 8) {
                            setState(() {
                              _errorMessage = 'New password must be at least 8 characters';
                            });
                            return;
                          }

                          // Set loading state
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });

                          try {
                            // Call Amplify to change password
                            await Amplify.Auth.updatePassword(
                              oldPassword: _currentPasswordController.text,
                              newPassword: _newPasswordController.text,
                            );

                            // Close dialog
                            Navigator.of(context).pop();

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Password changed successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } on AuthException catch (e) {
                            // Handle authentication errors
                            setState(() {
                              _isLoading = false;
                              switch (e.message) {
                                case 'Incorrect username or password.':
                                  _errorMessage = 'Current password is incorrect';
                                  break;
                                default:
                                  _errorMessage = 'Password change failed: ${e.message}';
                              }
                            });
                          } catch (e) {
                            // Handle other errors
                            setState(() {
                              _isLoading = false;
                              _errorMessage = 'An error occurred: $e';
                            });
                          }
                        },
                  child: Text('Confirm Change'),
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
        title: Text('Clear Cache'),
        content: Text('Are you sure you want to clear the app cache? This will not delete your account data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cache cleared')),
              );
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // Correct sign out method, ensuring return to login page
  void _signOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog first
              Navigator.of(dialogContext).pop();
              
              try {
                // Execute sign out
                await Amplify.Auth.signOut();
                
                // After successful logout, navigate to login page and clear all previous routes
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false, // Clear all previous routes
                  );
                }
              } catch (e) {
                // Only show SnackBar if logout fails
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              }
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}