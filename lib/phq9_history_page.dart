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
      
      // 创建查询请求，按日期降序排序
      final request = ModelQueries.list(
        PHQ9Assessment.classType,
        where: PHQ9Assessment.USERID.eq(user.userId),
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors?.isNotEmpty ?? false) {
        throw Exception('加载失败: ${response.errors}');
      }

      final data = response.data?.items;
      if (data != null) {
        // 转换为列表并按日期排序
        _assessments = data.whereType<PHQ9Assessment>().toList()
          ..sort((a, b) => b.date.toString().compareTo(a.date.toString()));
      }

    } catch (e) {
      print('Error loading history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载历史记录失败'),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: '重试',
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
        return '无或轻微';
      case 'mild':
        return '轻度';
      case 'moderate':
        return '中度';
      case 'moderately severe':
        return '中重度';
      case 'severe':
        return '重度';
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
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');
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
                '总分: ${assessment.totalScore}分',
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

    final options = ['完全没有', '有几天', '一半以上时间', '几乎每天'];

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
                  '详细评估结果',
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
                        '回答：${options[answers[index]]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                )),
                Divider(),
                ListTile(
                  title: Text('总分'),
                  trailing: Text(
                    '${assessment.totalScore}分',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: Text('严重程度'),
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
        title: Text('评估历史记录'),
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
                        '暂无评估记录',
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
                        child: Text('开始评估'),
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