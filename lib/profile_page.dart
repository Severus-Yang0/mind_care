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
      print('Current user ID: ${user.userId}');

      // 使用 ModelQueries 获取用户信息，并明确指定认证类型
      final request = ModelQueries.get(
        UserInformation.classType,
        UserInformationModelIdentifier(id: user.userId),
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.query(request: request).response;

      // 打印响应以便调试
      print('Query response: ${response.data}');
      print('Query errors: ${response.errors}');

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
      print('Error loading profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载个人信息失败: ${e.toString()}'),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: '重试',
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
        print('Current user ID: ${user.userId}');

        // 检查认证状态
        final session = await Amplify.Auth.fetchAuthSession();
        print('Is user signed in: ${session.isSignedIn}');

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

        // 使用 ModelMutations 保存数据，并明确指定认证类型
        final request = _existingProfile != null
            ? ModelMutations.update(profile,
                authorizationMode: APIAuthorizationType.userPools)
            : ModelMutations.create(profile,
                authorizationMode: APIAuthorizationType.userPools);

        final response = await Amplify.API.mutate(request: request).response;

        // 检查是否有错误
        if (response.errors?.isNotEmpty ?? false) {
          print('Mutation errors: ${response.errors}');
          throw Exception('保存失败: ${response.errors}');
        }

        // 检查返回的数据
        if (response.data == null) {
          throw Exception('No data returned from mutation');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('个人信息已更新')),
        );

        setState(() {
          _isEditing = false;
          _existingProfile = profile;
        });

        // 刷新数据
        await _loadUserProfile();
      } catch (e, stackTrace) {
        print('Error saving profile: $e');
        print('Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败，请重试: ${e.toString()}'),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: '重试',
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
            child: Text(value?.isNotEmpty == true ? value! : '暂未填写'),
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
              labelText: '姓名',
              hintText: '暂未填写',
              filled: true,
              fillColor: Color(0xFFF1F8E9),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入姓名';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            decoration: InputDecoration(
              labelText: '年龄',
              hintText: '暂未填写',
              filled: true,
              fillColor: Color(0xFFF1F8E9),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final age = int.tryParse(value);
                if (age == null || age < 0 || age > 120) {
                  return '请输入有效年龄';
                }
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              labelText: '性别',
              hintText: '暂未填写',
              filled: true,
              fillColor: Color(0xFFF1F8E9),
            ),
            items: ['男', '女', '其他'].map((String value) {
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
              labelText: '职业',
              hintText: '暂未填写',
              filled: true,
              fillColor: Color(0xFFF1F8E9),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _educationController,
            decoration: InputDecoration(
              labelText: '教育程度',
              hintText: '暂未填写',
              filled: true,
              fillColor: Color(0xFFF1F8E9),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _medicalHistoryController,
            decoration: InputDecoration(
              labelText: '既往病史',
              hintText: '暂未填写',
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
            child: Text('保存信息', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人信息'),
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
                    _buildInfoRow('姓名', _nameController.text),
                    _buildInfoRow('年龄', _ageController.text),
                    _buildInfoRow('性别', _selectedGender),
                    _buildInfoRow('职业', _occupationController.text),
                    _buildInfoRow('教育程度', _educationController.text),
                    _buildInfoRow('既往病史', _medicalHistoryController.text),
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
                        backgroundColor: Color(0xFFFFA726),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('填写心理问卷', style: TextStyle(fontSize: 18)),
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
                      child: Text('查看历史问卷', style: TextStyle(fontSize: 18)),
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
