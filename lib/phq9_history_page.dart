import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:intl/intl.dart';
import 'package:mind_care/phq9_questionnaire_page.dart';
import 'models/PHQ9Assessment.dart';

class PHQ9HistoryPage extends StatefulWidget {
  @override
  _PHQ9HistoryPageState createState() => _PHQ9HistoryPageState();
}

class _PHQ9HistoryPageState extends State<PHQ9HistoryPage> {
  bool _isLoading = true;
  List<PHQ9Assessment> _assessments = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = await Amplify.Auth.getCurrentUser();
      
      // Create query request, sorted by date in descending order
      final request = ModelQueries.list(
        PHQ9Assessment.classType,
        where: PHQ9Assessment.USERID.eq(user.userId),
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors?.isNotEmpty ?? false) {
        throw Exception('Loading failed: ${response.errors}');
      }

      final data = response.data?.items;
      if (data != null) {
        // Convert to list and sort by date
        _assessments = data.whereType<PHQ9Assessment>().toList()
          ..sort((a, b) => b.date.toString().compareTo(a.date.toString()));
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load history records'),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadHistory,
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getSeverityText(String severity) {
    switch (severity) {
      case 'minimal':
        return 'Minimal';
      case 'mild':
        return 'Mild';
      case 'moderate':
        return 'Moderate';
      case 'moderately severe':
        return 'Moderately Severe';
      case 'severe':
        return 'Severe';
      default:
        return severity;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'minimal':
        return Colors.green;
      case 'mild':
        return Colors.lightGreen;
      case 'moderate':
        return Colors.orange;
      case 'moderately severe':
        return Colors.deepOrange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAssessmentCard(PHQ9Assessment assessment) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final date = DateTime.parse(assessment.date.toString());
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          _showAssessmentDetails(assessment);
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(assessment.severity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getSeverityText(assessment.severity),
                      style: TextStyle(
                        color: _getSeverityColor(assessment.severity),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Total score: ${assessment.totalScore} points',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssessmentDetails(PHQ9Assessment assessment) {
    final questions = [
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

    final answers = [
      assessment.q1,
      assessment.q2,
      assessment.q3,
      assessment.q4,
      assessment.q5,
      assessment.q6,
      assessment.q7,
      assessment.q8,
      assessment.q9,
    ];

    final options = ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Detailed Assessment Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ...List.generate(9, (index) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${questions[index]}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
                      child: Text(
                        'Answer: ${options[answers[index]]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                )),
                Divider(),
                ListTile(
                  title: Text('Total Score'),
                  trailing: Text(
                    '${assessment.totalScore} points',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Severity'),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(assessment.severity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getSeverityText(assessment.severity),
                      style: TextStyle(
                        color: _getSeverityColor(assessment.severity),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment History'),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _assessments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No assessment records yet',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PHQ9QuestionnairePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4FC3F7),
                        ),
                        child: Text('Start Assessment'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: _assessments.length,
                    itemBuilder: (context, index) {
                      return _buildAssessmentCard(_assessments[index]);
                    },
                  ),
                ),
    );
  }
}