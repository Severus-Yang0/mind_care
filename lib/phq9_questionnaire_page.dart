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
    'Little interest or pleasure in doing things',
    'Feeling down, depressed, or hopeless',
    'Trouble falling or staying asleep, or sleeping too much',
    'Feeling tired or having little energy',
    'Poor appetite or overeating',
    'Feeling bad about yourself or that you are a failure or have let yourself or your family down',
    'Trouble concentrating on things, such as reading the newspaper or watching television',
    'Moving or speaking so slowly that other people could have noticed, or being fidgety or restless',
    'Thoughts that you would be better off dead, or of hurting yourself'
  ];

  final List<String> _options = [
    'Not at all',
    'Several days',
    'More than half the days',
    'Nearly every day'
  ];

  String _getSeverity(int totalScore) {
    if (totalScore >= 20) return 'severe';
    if (totalScore >= 15) return 'moderately severe';
    if (totalScore >= 10) return 'moderate';
    if (totalScore >= 5) return 'mild';
    return 'minimal';
  }

  Future<void> _submitAssessment() async {
    // Check if all questions have been answered
    if (_answers.contains(-1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please answer all questions')),
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
        throw Exception('Save failed: ${response.errors}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Questionnaire submitted successfully')),
      );

      // Return to previous page
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed, please try again')),
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
        title: Text('PHQ-9 Depression Screening Scale'),
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
                  'Over the last 2 weeks, how often have you been bothered by the following problems?',
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
                    _isSubmitting ? 'Submitting...' : 'Submit Questionnaire',
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