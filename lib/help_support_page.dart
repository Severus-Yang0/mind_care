import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  // FAQ数据
  final List<Map<String, String>> _faqList = [
    {
      'question': '如何使用心理问卷功能？',
      'answer': '在首页选择"资料填写/心理问卷"选项，然后点击"填写心理问卷"按钮开始测评。完成所有问题后点击提交，系统会自动计算结果并提供分析。'
    },
    {
      'question': '如何查看我之前的评估记录？',
      'answer': '在首页选择"资料填写/心理问卷"，然后点击"查看历史问卷"按钮，或者在首页直接点击"查看报告"可以查看所有历史评估的详细信息和趋势分析。'
    },
    {
      'question': '评估结果表明我有中度或重度抑郁症状，我该怎么办？',
      'answer': '请记住，应用提供的评估仅供参考，不能替代专业诊断。如果评估显示您有中度或重度症状，我们强烈建议您咨询专业的心理医生或精神科医生获取正式诊断和治疗建议。'
    },
  ];

  // 联系方式
  final Map<String, Map<String, dynamic>> _contactInfo = {
    '客服邮箱': {
      'value': 'by75@duke.edu',
      'icon': Icons.email,
      'action': 'email',
      'color': Colors.orange,
    },
  };

  // 紧急联系方式
  final Map<String, Map<String, dynamic>> _emergencyContacts = {
    '心理危机干预热线': {
      'value': '400-161-9995',
      'icon': Icons.local_hospital,
      'action': 'call',
      'color': Colors.red,
    },
    '全国公共卫生热线': {
      'value': '12320',
      'icon': Icons.medical_services,
      'action': 'call',
      'color': Colors.redAccent,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('帮助与支持'),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: ListView(
        children: [
          // 顶部紧急求助卡片
          _buildEmergencyCard(),
          
          // 联系方式
          _buildSectionTitle('联系我们'),
          ..._contactInfo.entries.map((entry) => _buildContactItem(
            entry.key,
            entry.value['value'],
            entry.value['icon'],
            entry.value['action'],
            entry.value['color'],
          )).toList(),
          
          // 常见问题
          _buildSectionTitle('常见问题'),
          ..._faqList.map((faq) => _buildFaqItem(faq['question']!, faq['answer']!)).toList(),
          
          // 应用信息
          _buildSectionTitle('应用信息'),
          _buildInfoItem('应用版本', '1.0.0'),
          // _buildInfoItem('用户协议', '点击查看', onTap: () {
          //   // 显示用户协议
          //   _showPolicyDialog('用户协议', '这里是用户协议内容...');
          // }),
          // _buildInfoItem('隐私政策', '点击查看', onTap: () {
          //   // 显示隐私政策
          //   _showPolicyDialog('隐私政策', '这里是隐私政策内容...');
          // }),
          
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Card(
      margin: EdgeInsets.all(16),
      color: Color(0xFFFFF8E1),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade300, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Text(
                  '紧急求助',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '如果您正在经历严重的心理危机或有自伤、自杀想法，请立即联系以下紧急求助热线或前往最近的医院就诊。',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            ..._emergencyContacts.entries.map((entry) => _buildEmergencyContactItem(
              entry.key,
              entry.value['value'],
              entry.value['icon'],
              entry.value['color'],
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactItem(String title, String value, IconData icon, Color color) {
    return GestureDetector(
      onTap: () async {
        final Uri phoneUri = Uri(scheme: 'tel', path: value);
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.phone_in_talk, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4FC3F7),
        ),
      ),
    );
  }

  Widget _buildContactItem(String title, String value, IconData icon, String action, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(value),
      trailing: IconButton(
        icon: Icon(
          action == 'copy' ? Icons.content_copy :
          action == 'email' ? Icons.open_in_new :
          action == 'web' ? Icons.open_in_new :
          action == 'call' ? Icons.call : Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 20,
        ),
        onPressed: () async {
          if (action == 'copy') {
            await Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已复制到剪贴板')),
            );
          } else if (action == 'email') {
            final Uri emailUri = Uri(scheme: 'mailto', path: value);
            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
            }
          } else if (action == 'web') {
            final Uri webUri = Uri.parse(value);
            if (await canLaunchUrl(webUri)) {
              await launchUrl(webUri, mode: LaunchMode.externalApplication);
            }
          } else if (action == 'call') {
            final Uri phoneUri = Uri(scheme: 'tel', path: value);
            if (await canLaunchUrl(phoneUri)) {
              await launchUrl(phoneUri);
            }
          }
        },
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(label),
      trailing: onTap != null 
          ? TextButton(
              onPressed: onTap,
              child: Text(
                value,
                style: TextStyle(color: Color(0xFF4FC3F7)),
              ),
            )
          : Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
    );
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }
}