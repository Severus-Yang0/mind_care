import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mind_care/models/PHQ9Assessment.dart';
import 'package:mind_care/models/UserInformation.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  UserInformation? _userProfile;
  List<PHQ9Assessment> _assessments = [];
  
  // 图表数据
  List<FlSpot> _scoreSpots = [];
  double _minScore = 0;
  double _maxScore = 27; // PHQ-9最高分为27分
  DateTime? _firstAssessmentDate;
  DateTime? _lastAssessmentDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });
    
    // 并行加载数据
    await Future.wait([
      _loadUserProfile(),
      _loadAssessments(),
    ]);
    
    // 处理图表数据
    _processChartData();
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      
      final request = ModelQueries.get(
        UserInformation.classType,
        UserInformationModelIdentifier(id: user.userId),
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        setState(() {
          _userProfile = response.data;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      // 处理错误
    }
  }

  Future<void> _loadAssessments() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      
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
        setState(() {
          _assessments = data.whereType<PHQ9Assessment>().toList()
            ..sort((a, b) => DateTime.parse(a.date.toString()).compareTo(DateTime.parse(b.date.toString())));
        });
      }
    } catch (e) {
      print('Error loading assessments: $e');
      // 处理错误
    }
  }

  void _processChartData() {
    if (_assessments.isEmpty) return;
    
    _scoreSpots = [];
    
    // 获取第一个和最后一个评估日期
    _firstAssessmentDate = DateTime.parse(_assessments.first.date.toString());
    _lastAssessmentDate = DateTime.parse(_assessments.last.date.toString());
    
    for (int i = 0; i < _assessments.length; i++) {
      final assessment = _assessments[i];
      final date = DateTime.parse(assessment.date.toString());
      
      // 将日期转换为x轴上的位置（以天为单位的相对位置）
      final double x = date.difference(_firstAssessmentDate!).inDays.toDouble();
      final double y = assessment.totalScore.toDouble();
      
      _scoreSpots.add(FlSpot(x, y));
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

  Widget _buildSummaryTab() {
    if (_assessments.isEmpty) {
      return Center(
        child: Text('暂无评估数据，请先完成PHQ-9问卷评估'),
      );
    }

    final mostRecent = _assessments.last;
    final mostRecentDate = DateTime.parse(mostRecent.date.toString());
    
    // 计算平均分
    final avgScore = _assessments.isNotEmpty
        ? _assessments.map((e) => e.totalScore).reduce((a, b) => a + b) / _assessments.length
        : 0;
    
    // 计算最高分和最低分
    final highestScore = _assessments.isNotEmpty
        ? _assessments.map((e) => e.totalScore).reduce((a, b) => a > b ? a : b)
        : 0;
    final lowestScore = _assessments.isNotEmpty
        ? _assessments.map((e) => e.totalScore).reduce((a, b) => a < b ? a : b)
        : 0;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最新评估结果',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '完成日期：${DateFormat('yyyy年MM月dd日').format(mostRecentDate)}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(mostRecent.severity).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getSeverityText(mostRecent.severity),
                          style: TextStyle(
                            color: _getSeverityColor(mostRecent.severity),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '总分：${mostRecent.totalScore}分',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _getSeverityColor(mostRecent.severity),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_assessments.length > 1)
            Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '评估概况',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('评估次数', '${_assessments.length}次', Icons.assessment),
                        _buildStatItem('平均分数', '${avgScore.toStringAsFixed(1)}分', Icons.analytics),
                        _buildStatItem('最高分数', '$highestScore分', Icons.arrow_upward),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('最低分数', '$lowestScore分', Icons.arrow_downward),
                        _buildStatItem(
                          '趋势',
                          _assessments.length >= 3
                              ? _calculateTrend()
                              : '数据不足',
                          _getTrendIcon(),
                        ),
                        _buildStatItem(
                          '首次评估',
                          '${DateFormat('MM/dd').format(_firstAssessmentDate!)}',
                          Icons.calendar_today,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          _buildRecommendationCard(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF4FC3F7), size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _calculateTrend() {
    if (_assessments.length < 3) return '数据不足';
    
    // 获取最近三次评估
    final last3 = _assessments.length >= 3
        ? _assessments.sublist(_assessments.length - 3)
        : _assessments;
    
    // 简单线性回归计算趋势
    int n = last3.length;
    List<int> x = List.generate(n, (i) => i);
    List<int> y = last3.map((e) => e.totalScore).toList();
    
    double sumX = x.reduce((a, b) => a + b).toDouble();
    double sumY = y.reduce((a, b) => a + b).toDouble();
    double sumXY = 0;
    double sumX2 = 0;
    
    for (int i = 0; i < n; i++) {
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
    }
    
    double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    if (slope < -0.5) return '明显改善';
    if (slope < 0) return '轻微改善';
    if (slope > 0.5) return '明显恶化';
    if (slope > 0) return '轻微恶化';
    return '稳定';
  }

  IconData _getTrendIcon() {
    String trend = _calculateTrend();
    switch (trend) {
      case '明显改善':
        return Icons.trending_down;
      case '轻微改善':
        return Icons.trending_down;
      case '明显恶化':
        return Icons.trending_up;
      case '轻微恶化':
        return Icons.trending_up;
      case '稳定':
        return Icons.trending_flat;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildRecommendationCard() {
    if (_assessments.isEmpty) return SizedBox();
    
    final mostRecent = _assessments.last;
    String recommendation;
    Color recommendationColor;
    
    switch (mostRecent.severity) {
      case 'minimal':
        recommendation = '您的抑郁症状非常轻微或没有。建议保持良好的生活习惯和心态，定期进行自我评估。';
        recommendationColor = Colors.green;
        break;
      case 'mild':
        recommendation = '您有轻度抑郁症状。建议多参与户外活动，保持规律作息，需要时与亲友交流感受。';
        recommendationColor = Colors.lightGreen;
        break;
      case 'moderate':
        recommendation = '您有中度抑郁症状。建议寻求专业心理咨询，学习应对压力的技巧，保持社交活动。';
        recommendationColor = Colors.orange;
        break;
      case 'moderately severe':
        recommendation = '您有中重度抑郁症状。强烈建议咨询专业心理医生，考虑接受正规治疗，请勿忽视症状。';
        recommendationColor = Colors.deepOrange;
        break;
      case 'severe':
        recommendation = '您有重度抑郁症状。请立即寻求专业医疗帮助，可能需要药物治疗和心理治疗相结合的方式。';
        recommendationColor = Colors.red;
        break;
      default:
        recommendation = '无法提供推荐，请咨询专业医生。';
        recommendationColor = Colors.grey;
    }
    
    return Card(
      elevation: 4,
      color: recommendationColor.withOpacity(0.1),
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: recommendationColor.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: recommendationColor),
                SizedBox(width: 8),
                Text(
                  '建议与推荐',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: recommendationColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              recommendation,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              '免责声明：此建议仅供参考，不构成医疗建议。如有严重症状，请咨询专业医生。',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildTrendsTab() {
  if (_assessments.isEmpty) {
    return Center(
      child: Text('暂无评估数据，请先完成PHQ-9问卷评估'),
    );
  }

  if (_assessments.length < 2) {
    return Center(
      child: Text('需要至少两次评估才能显示趋势图，请继续完成PHQ-9问卷评估'),
    );
  }

  // 确保评估按日期排序（从早到晚）
  final sortedAssessments = List<PHQ9Assessment>.from(_assessments)
    ..sort((a, b) => DateTime.parse(a.date.toString())
        .compareTo(DateTime.parse(b.date.toString())));

  // 准备图表数据点
  final spots = <FlSpot>[];
  final dates = <DateTime>[];
  
  for (int i = 0; i < sortedAssessments.length; i++) {
    final assessment = sortedAssessments[i];
    final date = DateTime.parse(assessment.date.toString());
    dates.add(date);
    
    // 使用索引作为X坐标，这样点之间的距离会均匀
    final double x = i.toDouble();
    final double y = assessment.totalScore.toDouble();
    
    spots.add(FlSpot(x, y));
  }

  // 日期格式化器
  final shortDateFormat = DateFormat('MM/dd');
  final fullDateFormat = DateFormat('yyyy年MM月dd日');

  return Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHQ-9分数趋势',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '从 ${fullDateFormat.format(dates.first)} 到 ${fullDateFormat.format(dates.last)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 5,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      // 确保只显示与数据点对应的日期
                      final index = value.toInt();
                      if (index >= 0 && index < dates.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            shortDateFormat.format(dates[index]),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value % 5 == 0 && value >= 0 && value <= 27) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Color(0xff37434d), width: 1),
              ),
              minX: -0.5, // 给左边留一些空间
              maxX: spots.length - 0.5, // 给右边留一些空间
              minY: 0,
              maxY: 27, // PHQ-9的最高分
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Color(0xFF4FC3F7),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      // 使用更大、更明显的点
                      return FlDotCirclePainter(
                        radius: 6,
                        color: Color(0xFF4FC3F7),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Color(0xFF4FC3F7).withOpacity(0.2),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (LineBarSpot touchedSpot) => Colors.white,
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final index = barSpot.spotIndex;
                      final assessment = sortedAssessments[index];
                      final date = dates[index];
                      return LineTooltipItem(
                        '${DateFormat('yyyy-MM-dd HH:mm').format(date)}\n',
                        TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '分数: ${barSpot.y.toInt()}',
                            style: TextStyle(
                              color: Color(0xFF4FC3F7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '\n${_getSeverityText(assessment.severity)}',
                            style: TextStyle(
                              color: _getSeverityColor(assessment.severity),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildSeverityLegend(),
        SizedBox(height: 16),
        Text(
          '说明：PHQ-9分数反映抑郁症状的严重程度，分数越低表示症状越轻微。以上图表按评估日期顺序展示数据点。',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSeverityLegend() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildLegendItem('无或轻微 (0-4)', Colors.green),
        _buildLegendItem('轻度 (5-9)', Colors.lightGreen),
        _buildLegendItem('中度 (10-14)', Colors.orange),
        _buildLegendItem('中重度 (15-19)', Colors.deepOrange),
        _buildLegendItem('重度 (20-27)', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDetailTab() {
    return _userProfile == null
        ? Center(
            child: Text('无法加载用户资料，请先完善个人信息'),
          )
        : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(),
                SizedBox(height: 24),
                _buildAssessmentHistorySection(),
              ],
            ),
          );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Color(0xFF4FC3F7)),
                SizedBox(width: 8),
                Text(
                  '个人基本资料',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            _buildProfileItem('姓名', _userProfile?.name ?? '暂未填写'),
            _buildProfileItem('年龄', _userProfile?.age != null ? '${_userProfile!.age}岁' : '暂未填写'),
            _buildProfileItem('性别', _userProfile?.gender ?? '暂未填写'),
            _buildProfileItem('职业', _userProfile?.occupation ?? '暂未填写'),
            _buildProfileItem('教育程度', _userProfile?.education ?? '暂未填写'),
            _buildProfileItem('既往病史', _userProfile?.medicalHistory ?? '暂未填写'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentHistorySection() {
    if (_assessments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 32),
          child: Text('暂无评估记录'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: Color(0xFF4FC3F7)),
            SizedBox(width: 8),
            Text(
              '评估历史记录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _assessments.length,
          itemBuilder: (context, index) {
            final assessment = _assessments[_assessments.length - 1 - index]; // 倒序显示
            final date = DateTime.parse(assessment.date.toString());
            
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  DateFormat('yyyy年MM月dd日 HH:mm').format(date),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('得分: ${assessment.totalScore}分'),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(assessment.severity).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getSeverityText(assessment.severity),
                    style: TextStyle(
                      color: _getSeverityColor(assessment.severity),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () => _showAssessmentDetails(assessment),
              ),
            );
          },
        ),
      ],
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
        title: Text('个人报告'),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Color(0xFF4FC3F7),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF4FC3F7),
                  tabs: [
                    Tab(
                      icon: Icon(Icons.dashboard),
                      text: '概览',
                    ),
                    Tab(
                      icon: Icon(Icons.trending_up),
                      text: '趋势',
                    ),
                    Tab(
                      icon: Icon(Icons.person),
                      text: '详情',
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSummaryTab(),
                      _buildTrendsTab(),
                      _buildDetailTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAllData,
        backgroundColor: Color(0xFF4FC3F7),
        child: Icon(Icons.refresh),
        tooltip: '刷新数据',
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}