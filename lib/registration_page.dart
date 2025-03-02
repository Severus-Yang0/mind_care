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
      TextEditingController(); // Confirmation code controller

  bool _isConfirmationStep = false; // Controls whether to show confirmation code input
  String _currentUsername = ''; // Stores the username used during registration

  Future<void> _registerUser(BuildContext context) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError(context, 'Passwords do not match');
      return;
    }

    try {
      // Attempt to register user
      SignUpResult result = await Amplify.Auth.signUp(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        options: SignUpOptions(userAttributes: {
          CognitoUserAttributeKey.email: _emailController.text.trim(),
        }),
      );
      if (result.isSignUpComplete) {
        // Registration complete, navigate to login page or home page
        Navigator.pop(context);
      } else {
        setState(() {
          _isConfirmationStep = true; // Enter confirmation code step
          _currentUsername = _usernameController.text.trim();
        });
      }
    } on AuthException catch (e) {
      // If user already exists but is not confirmed
      if (e.message.contains('User already exists')) {
        // Resend verification code via resendSignUp
        try {
          await Amplify.Auth.resendSignUpCode(
            username: _usernameController.text.trim(),
          );
          setState(() {
            _isConfirmationStep = true; // Switch to confirmation code mode
            _currentUsername = _usernameController.text.trim();
          });
          _showError(context, 'User already exists but not verified (will use password from first registration). Verification code resent');
        } catch (resendError) {
          _showError(context, 'Unable to resend verification code: ${resendError.toString()}');
        }
      } else {
        _showError(context, 'Registration failed: ${e.message}');
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
          SnackBar(content: Text('Registration successful')),
        );
        Navigator.pop(context); // Return to login page after verification
      } else {
        _showError(context, 'Verification code validation failed');
      }
    } catch (e) {
      _showError(context, 'Verification code validation failed: ${e.toString()}');
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
        title: Text('Register'),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isConfirmationStep ? 'Enter Verification Code' : 'Create New Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            if (!_isConfirmationStep) ...[
              // Username input field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person, color: Color(0xFF4FC3F7)),
                  filled: true,
                  fillColor: Color(0xFFF1F8E9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Email input field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Color(0xFF4FC3F7)),
                  filled: true,
                  fillColor: Color(0xFFF1F8E9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Password input field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF4FC3F7)),
                  filled: true,
                  fillColor: Color(0xFFF1F8E9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Confirm password input field
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
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
              // Register button
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
                  'Register',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ] else ...[
              // Verification code input field
              TextField(
                controller: _confirmationCodeController,
                decoration: InputDecoration(
                  labelText: 'Verification Code',
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
              // Verify button
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
                  'Verify',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              // Resend verification code button
              TextButton(
                onPressed: () async {
                  try {
                    await Amplify.Auth.resendSignUpCode(
                      username: _currentUsername,
                    );
                    _showError(context, 'Verification code resent');
                  } catch (e) {
                    _showError(context, 'Failed to resend verification code: ${e.toString()}');
                  }
                },
                child: Text(
                  'Resend verification code',
                  style: TextStyle(color: Color(0xFFFFA726), fontSize: 16),
                ),
              ),
            ],
            SizedBox(height: 20),
            // Return to login button
            if (!_isConfirmationStep)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Already have an account? Login here',
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