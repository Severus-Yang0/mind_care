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

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  UserInformation? _userProfile;
  List<PHQ9Assessment> _assessments = [];
  // Chart data
  List<FlSpot> _scoreSpots = [];
  double _minScore = 0;
  double _maxScore = 27; // PHQ-9 maximum score is 27
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
    // Load data in parallel
    await Future.wait([
      _loadUserProfile(),
      _loadAssessments(),
    ]);
    // Process chart data
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
      // Handle error
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
        throw Exception('Loading failed: ${response.errors}');
      }
      final data = response.data?.items;
      if (data != null) {
        setState(() {
          _assessments = data.whereType<PHQ9Assessment>().toList()
            ..sort((a, b) => DateTime.parse(a.date.toString())
                .compareTo(DateTime.parse(b.date.toString())));
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _processChartData() {
    if (_assessments.isEmpty) return;
    _scoreSpots = [];
    // Get first and last assessment dates
    _firstAssessmentDate = DateTime.parse(_assessments.first.date.toString());
    _lastAssessmentDate = DateTime.parse(_assessments.last.date.toString());
    for (int i = 0; i < _assessments.length; i++) {
      final assessment = _assessments[i];
      final date = DateTime.parse(assessment.date.toString());
      final double x = date.difference(_firstAssessmentDate!).inDays.toDouble();
      final double y = assessment.totalScore.toDouble();
      _scoreSpots.add(FlSpot(x, y));
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

  Widget _buildSummaryTab() {
    if (_assessments.isEmpty) {
      return Center(
        child: Text(
            'No assessment data yet, please complete a PHQ-9 questionnaire first'),
      );
    }
    final mostRecent = _assessments.last;
    final mostRecentDate = DateTime.parse(mostRecent.date.toString());
    // Calculate average score
    final avgScore = _assessments.isNotEmpty
        ? _assessments.map((e) => e.totalScore).reduce((a, b) => a + b) /
            _assessments.length
        : 0;
    // Calculate highest and lowest scores
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
                    'Latest Assessment Results',
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
                        'Completion Date: ${DateFormat('MMM dd, yyyy').format(mostRecentDate)}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(mostRecent.severity)
                              .withOpacity(0.2),
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
                    'Total Score: ${mostRecent.totalScore} points',
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
                      'Assessment Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
                      spacing: 8.0,
                      runSpacing: 16.0,
                      children: [
                        _buildStatItem('Assessments',
                            '${_assessments.length} times', Icons.assessment),
                        _buildStatItem(
                            'Average Score',
                            '${avgScore.toStringAsFixed(1)} points',
                            Icons.analytics),
                        _buildStatItem('Highest Score', '$highestScore points',
                            Icons.arrow_upward),
                      ],
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
                      spacing: 8.0,
                      runSpacing: 16.0,
                      children: [
                        _buildStatItem('Lowest Score', '$lowestScore points',
                            Icons.arrow_downward),
                        _buildStatItem(
                          'Trend',
                          _assessments.length >= 3
                              ? _calculateTrend()
                              : 'Insufficient data',
                          _getTrendIcon(),
                        ),
                        _buildStatItem(
                          'First Assessment',
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
    return Container(
      width: 100, // Fixed width to ensure consistent sizing
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Color(0xFF4FC3F7), size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16, // Slightly smaller text
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center, // Center align text
            overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center, // Center align text
            overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
          ),
        ],
      ),
    );
  }

  String _calculateTrend() {
    if (_assessments.length < 3) return 'Insufficient data';
    // Get the latest three assessments
    final last3 = _assessments.length >= 3
        ? _assessments.sublist(_assessments.length - 3)
        : _assessments;
    // Simple linear regression to calculate trend
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
    if (slope < -0.5) return 'Improvement';
    if (slope < 0) return 'Slight Improvement';
    if (slope > 0.5) return 'Worsening';
    if (slope > 0) return 'Slight Worsening';
    return 'Stable';
  }

  IconData _getTrendIcon() {
    String trend = _calculateTrend();
    switch (trend) {
      case 'Improvement':
        return Icons.trending_down;
      case 'Slight Improvement':
        return Icons.trending_down;
      case 'Worsening':
        return Icons.trending_up;
      case 'Slight Worsening':
        return Icons.trending_up;
      case 'Stable':
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
        recommendation =
            'Your depression symptoms are very mild or non-existent. It\'s recommended to maintain good lifestyle habits and mindset, and perform self-assessments regularly.';
        recommendationColor = Colors.green;
        break;
      case 'mild':
        recommendation =
            'You have mild depression symptoms. It\'s recommended to participate in more outdoor activities, maintain a regular routine, and share your feelings with friends and family when needed.';
        recommendationColor = Colors.lightGreen;
        break;
      case 'moderate':
        recommendation =
            'You have moderate depression symptoms. It\'s recommended to seek professional counseling, learn stress management techniques, and maintain social activities.';
        recommendationColor = Colors.orange;
        break;
      case 'moderately severe':
        recommendation =
            'You have moderately severe depression symptoms. It\'s strongly recommended to consult a professional psychologist, consider seeking formal treatment, and don\'t ignore your symptoms.';
        recommendationColor = Colors.deepOrange;
        break;
      case 'severe':
        recommendation =
            'You have severe depression symptoms. Please seek professional medical help immediately, as you may need a combination of medication and psychological therapy.';
        recommendationColor = Colors.red;
        break;
      default:
        recommendation =
            'Unable to provide recommendations, please consult a professional doctor.';
        recommendationColor = Colors.grey;
    }
    return Card(
      elevation: 4,
      color: Color.fromRGBO(255, 255, 255, 0.9),
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
                  'Suggestions & Recommendations',
                  style: TextStyle(
                    fontSize: 16, // Reduced from 18
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
              'Disclaimer: This suggestion is for reference only and does not constitute medical advice. If you have severe symptoms, please consult a professional doctor.',
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

// Add this helper method to your _ReportPageState class
  Widget _buildTrendsTab() {
    if (_assessments.isEmpty) {
      return Center(
        child: Text(
            'No assessment data yet, please complete a PHQ-9 questionnaire first'),
      );
    }
    if (_assessments.length < 2) {
      return Center(
        child: Text(
            'At least three assessments are needed to display a trend chart, please continue completing PHQ-9 questionnaires'),
      );
    }

    // Ensure assessments are sorted by date (from early to late)
    final sortedAssessments = List<PHQ9Assessment>.from(_assessments)
      ..sort((a, b) => DateTime.parse(a.date.toString())
          .compareTo(DateTime.parse(b.date.toString())));

    // Prepare chart data points
    final spots = <FlSpot>[];
    final dates = <DateTime>[];

    for (int i = 0; i < sortedAssessments.length; i++) {
      final assessment = sortedAssessments[i];
      final date = DateTime.parse(assessment.date.toString());
      dates.add(date);
      // Use index as X coordinate, so points will be evenly spaced
      final double x = i.toDouble();
      final double y = assessment.totalScore.toDouble();
      spots.add(FlSpot(x, y));
    }

    // Calculate appropriate date format and label interval based on data span
    final daysBetween =
        dates.isEmpty ? 0 : dates.last.difference(dates.first).inDays;
    final DateFormat dateFormat;

    if (daysBetween > 365) {
      dateFormat = DateFormat('MMM yy'); // Feb 22
    } else if (daysBetween > 60) {
      dateFormat = DateFormat('d MMM'); // 15 Feb
    } else {
      dateFormat = DateFormat('MM/dd'); // 02/15
    }

    // Full date format for detailed view
    final fullDateFormat = DateFormat('MMM dd, yyyy');

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PHQ-9 Score Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'From ${fullDateFormat.format(dates.first)} to ${fullDateFormat.format(dates.last)}',
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
                      reservedSize: 35, // Increased for rotated text
                      getTitlesWidget: (value, meta) {
                        // Calculate how many labels to show based on data points
                        final interval = _calculateLabelInterval(dates.length);
                        final index = value.toInt();

                        if (index >= 0 &&
                            index < dates.length &&
                            (index % interval == 0 ||
                                index == dates.length - 1)) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -45 *
                                  (3.1415926 / 180), // 45 degrees in radians
                              alignment: Alignment.center,
                              child: Text(
                                dateFormat.format(dates[index]),
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10, // Smaller text for better fit
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox
                            .shrink(); // Empty widget, better than Text('')
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
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Color(0xff37434d), width: 1),
                ),
                minX: -0.5, // Leave some space on the left
                maxX: spots.length - 0.5, // Leave some space on the right
                minY: 0,
                maxY: 27, // PHQ-9 maximum score
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
                        // Use larger, more visible dots
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
                              text: 'Score: ${barSpot.y.toInt()}',
                              style: TextStyle(
                                color: Color(0xFF4FC3F7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '\n${_getSeverityText(assessment.severity)}',
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
            'Note: PHQ-9 scores reflect the severity of depression symptoms, with lower scores indicating milder symptoms. The chart above shows data points in chronological order by assessment date.',
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

// Helper method to determine optimal label interval based on data size
  int _calculateLabelInterval(int dataSize) {
    if (dataSize <= 5) return 1;
    if (dataSize <= 10) return 2;
    if (dataSize <= 20) return 3;
    if (dataSize <= 30) return 5;
    if (dataSize <= 50) return 8;
    return dataSize ~/ 6; // Show approximately 6 labels regardless of size
  }

  Widget _buildSeverityLegend() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center, // Center the items
      children: [
        _buildLegendItem('Minimal (0-4)', Colors.green),
        _buildLegendItem('Mild (5-9)', Colors.lightGreen),
        _buildLegendItem('Moderate (10-14)', Colors.orange),
        _buildLegendItem(
            'Mod. Severe (15-19)', Colors.deepOrange), // Shortened "Moderately"
        _buildLegendItem('Severe (20-27)', Colors.red),
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
            child: Text(
                'Unable to load user profile, please complete your personal information first'),
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
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            _buildProfileItem('Name', _userProfile?.name ?? 'Not filled'),
            _buildProfileItem(
                'Age',
                _userProfile?.age != null
                    ? '${_userProfile!.age} years'
                    : 'Not filled'),
            _buildProfileItem('Gender', _userProfile?.gender ?? 'Not filled'),
            _buildProfileItem(
                'Occupation', _userProfile?.occupation ?? 'Not filled'),
            _buildProfileItem(
                'Education', _userProfile?.education ?? 'Not filled'),
            _buildProfileItem('Medical History',
                _userProfile?.medicalHistory ?? 'Not filled'),
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
          child: Text('No assessment records yet'),
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
              'Assessment History',
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
            final assessment = _assessments[
                _assessments.length - 1 - index]; // Display in reverse order
            final date = DateTime.parse(assessment.date.toString());
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(date),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Score: ${assessment.totalScore} points'),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getSeverityColor(assessment.severity).withOpacity(0.2),
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
    final options = [
      'Not at all',
      'Several days',
      'More than half the days',
      'Nearly every day'
    ];
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
                ...List.generate(
                    9,
                    (index) => Column(
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
                              padding:
                                  EdgeInsets.only(left: 16, top: 8, bottom: 16),
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
                      color: _getSeverityColor(assessment.severity)
                          .withOpacity(0.2),
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
        title: Text('Personal Report'),
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
                      text: 'Overview',
                    ),
                    Tab(
                      icon: Icon(Icons.trending_up),
                      text: 'Trends',
                    ),
                    Tab(
                      icon: Icon(Icons.person),
                      text: 'Details',
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
        tooltip: 'Refresh Data',
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
