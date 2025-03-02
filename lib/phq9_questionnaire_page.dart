import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'models/PHQ9Assessment.dart';

class PHQ9QuestionnairePage extends StatefulWidget {
  @override
  _PHQ9QuestionnairePageState createState() => _PHQ9QuestionnairePageState();
}

class _PHQ9QuestionnairePageState extends State<PHQ9QuestionnairePage> {
  final List<int> _answers = List.filled(9, -1);
  bool _isSubmitting = false;

  final List<String> _questions = [
    '做事时提不起劲或没有兴趣',
    '感到心情低落、沮丧或绝望',
    '难以入睡、睡不安稳或睡眠过多',
    '感觉疲倦或没有活力',
    '胃口不好或吃太多',
    '觉得自己很差劲，或觉得自己很失败，或让自己或家人失望',
    '难以集中注意力做事，例如看报纸或看电视',
    '行动或说话速度变得缓慢，或变得坐立不安，动来动去',
    '想到自己最好死掉或者伤害自己'
  ];

  final List<String> _options = [
    '完全没有',
    '有几天',
    '一半以上时间',
    '几乎每天'
  ];

  String _getSeverity(int totalScore) {
    if (totalScore >= 20) return 'severe';
    if (totalScore >= 15) return 'moderately severe';
    if (totalScore >= 10) return 'moderate';
    if (totalScore >= 5) return 'mild';
    return 'minimal';
  }

  Future<void> _submitAssessment() async {
    // 检查是否所有问题都已回答
    if (_answers.contains(-1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请回答所有问题')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = await Amplify.Auth.getCurrentUser();
      final totalScore = _answers.reduce((a, b) => a + b);
      
      final assessment = PHQ9Assessment(
        userId: user.userId,
        date: TemporalDateTime(DateTime.now()),
        q1: _answers[0],
        q2: _answers[1],
        q3: _answers[2],
        q4: _answers[3],
        q5: _answers[4],
        q6: _answers[5],
        q7: _answers[6],
        q8: _answers[7],
        q9: _answers[8],
        totalScore: totalScore,
        severity: _getSeverity(totalScore),
        createdAt: TemporalDateTime(DateTime.now()),
        updatedAt: TemporalDateTime(DateTime.now()),
      );

      final request = ModelMutations.create(
        assessment,
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.errors?.isNotEmpty ?? false) {
        throw Exception('保存失败: ${response.errors}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('问卷提交成功')),
      );

      // 返回上一页
      Navigator.pop(context);

    } catch (e) {
      print('Error submitting assessment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败，请重试')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildQuestionItem(int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${_questions[index]}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ...List.generate(4, (optionIndex) {
              return RadioListTile<int>(
                title: Text(_options[optionIndex]),
                value: optionIndex,
                groupValue: _answers[index],
                onChanged: (int? value) {
                  setState(() {
                    _answers[index] = value!;
                  });
                },
                activeColor: Color(0xFF4FC3F7),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PHQ-9 抑郁症筛查量表'),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '在过去的两周内，您经历以下情况的频率是？',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              ...List.generate(9, (index) => _buildQuestionItem(index)),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAssessment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4FC3F7),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isSubmitting ? '提交中...' : '提交问卷',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}