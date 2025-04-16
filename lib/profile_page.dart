import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart';
import 'models/UserInformation.dart';
import 'models/ModelProvider.dart';
import 'package:mind_care/phq9_questionnaire_page.dart';
import 'package:mind_care/phq9_history_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  UserInformation? _existingProfile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _medicalHistoryController =
      TextEditingController();

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

      // Use ModelQueries to get user information with explicit authentication type
      final request = ModelQueries.get(
        UserInformation.classType,
        UserInformationModelIdentifier(id: user.userId),
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.query(request: request).response;

      final userData = response.data;
      setState(() {
        if (userData != null) {
          _existingProfile = userData;
          _nameController.text = userData.name ?? '';
          _ageController.text = userData.age?.toString() ?? '';
          _selectedGender = userData.gender;
          _occupationController.text = userData.occupation ?? '';
          _educationController.text = userData.education ?? '';
          _medicalHistoryController.text = userData.medicalHistory ?? '';
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile information'),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadUserProfile,
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = await Amplify.Auth.getCurrentUser();

        final profile = UserInformation(
          id: user.userId,
          name: _nameController.text.trim(),
          age: _ageController.text.isNotEmpty
              ? int.tryParse(_ageController.text)
              : null,
          gender: _selectedGender,
          occupation: _occupationController.text.trim(),
          education: _educationController.text.trim(),
          medicalHistory: _medicalHistoryController.text.trim(),
          updatedAt: TemporalDateTime(DateTime.now()),
          createdAt:
              _existingProfile?.createdAt ?? TemporalDateTime(DateTime.now()),
        );

        // Use ModelMutations to save data with explicit authentication type
        final request = _existingProfile != null
            ? ModelMutations.update(profile,
                authorizationMode: APIAuthorizationType.userPools)
            : ModelMutations.create(profile,
                authorizationMode: APIAuthorizationType.userPools);

        final response = await Amplify.API.mutate(request: request).response;

        // Check for errors
        if (response.errors?.isNotEmpty ?? false) {
          throw Exception('Save failed: ${response.errors}');
        }

        // Check returned data
        if (response.data == null) {
          throw Exception('No data returned from mutation');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile information updated')),
        );

        setState(() {
          _isEditing = false;
          _existingProfile = profile;
        });

        // Refresh data
        await _loadUserProfile();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed, please try again'),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _saveProfile,
            ),
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4FC3F7),
              ),
            ),
          ),
          Expanded(
            child: Text(value?.isNotEmpty == true ? value! : 'Not filled yet'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'Not filled yet',
              filled: true,
              fillColor: Color(0xFFF1F8E9),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            decoration: InputDecoration(
              labelText: 'Age',
              hintText: 'Not filled yet',
              filled: true,
              fillColor: Color(0xFFF1F8E9),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final age = int.tryParse(value);
                if (age == null || age < 0 || age > 120) {
                  return 'Please enter a valid age';
                }
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              labelText: 'Gender',
              hintText: 'Not filled yet',
              filled: true,
              fillColor: Color(0xFFF1F8E9),
            ),
            items: ['Male', 'Female', 'Other'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _occupationController,
            decoration: InputDecoration(
              labelText: 'Occupation',
              hintText: 'Not filled yet',
              filled: true,
              fillColor: Color(0xFFF1F8E9),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _educationController,
            decoration: InputDecoration(
              labelText: 'Education Level',
              hintText: 'Not filled yet',
              filled: true,
              fillColor: Color(0xFFF1F8E9),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _medicalHistoryController,
            decoration: InputDecoration(
              labelText: 'Medical History',
              hintText: 'Not filled yet',
              filled: true,
              fillColor: Color(0xFFF1F8E9),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4FC3F7),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Save Information', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
        backgroundColor: Color(0xFF4FC3F7),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isEditing) ...[
                    _buildInfoRow('Name', _nameController.text),
                    _buildInfoRow('Age', _ageController.text),
                    _buildInfoRow('Gender', _selectedGender),
                    _buildInfoRow('Occupation', _occupationController.text),
                    _buildInfoRow('Education', _educationController.text),
                    _buildInfoRow(
                        'Medical History', _medicalHistoryController.text),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PHQ9QuestionnairePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 217, 92),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Complete Questionnaire',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 19, 54, 115))),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PHQ9HistoryPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF90CAF9),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('View History',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 19, 54, 115))),
                    ),
                  ] else ...[
                    _buildEditForm(),
                  ],
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }
}
