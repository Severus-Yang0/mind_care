import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  // FAQ data
  final List<Map<String, String>> _faqList = [
    {
      'question': 'How do I use the psychological questionnaire?',
      'answer':
          'On the home page, select "Profile/Questionnaire" option, then click the "Complete Questionnaire" button to start the assessment. After answering all questions, click submit, and the system will automatically calculate the results and provide analysis.'
    },
    {
      'question': 'How can I view my previous assessment records?',
      'answer':
          'On the home page, select "Profile/Questionnaire", then click the "View History" button, or directly click "View Reports" on the home page to see detailed information and trend analysis of all historical assessments.'
    },
    {
      'question':
          'The assessment indicates I have moderate or severe depression symptoms, what should I do?',
      'answer':
          'Please remember that the assessments provided by the app are for reference only and cannot replace professional diagnosis. If the assessment shows you have moderate or severe symptoms, we strongly recommend consulting a professional psychologist or psychiatrist for formal diagnosis and treatment advice.'
    },
  ];

  // Contact information
  final Map<String, Map<String, dynamic>> _contactInfo = {
    'Customer Service Email': {
      'value': 'by75@duke.edu',
      'icon': Icons.email,
      'action': 'email',
      'color': Colors.orange,
    },
  };

  // Emergency contacts
  final Map<String, Map<String, dynamic>> _emergencyContacts = {
    'Mental Health Hotline': {
      'value': '400-161-9995',
      'icon': Icons.local_hospital,
      'action': 'call',
      'color': Colors.red,
    },
    'Public Health Hotline': {
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
        title: Text('Help & Support'),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: ListView(
        children: [
          // Top emergency help card
          _buildEmergencyCard(),

          // Contact information
          _buildSectionTitle('Contact Us'),
          ..._contactInfo.entries
              .map((entry) => _buildContactItem(
                    entry.key,
                    entry.value['value'],
                    entry.value['icon'],
                    entry.value['action'],
                    entry.value['color'],
                  ))
              .toList(),

          // Frequently asked questions
          _buildSectionTitle('Frequently Asked Questions'),
          ..._faqList
              .map((faq) => _buildFaqItem(faq['question']!, faq['answer']!))
              .toList(),

          // App information
          _buildSectionTitle('App Information'),
          _buildInfoItem('App Version', '1.0.0'),
          // _buildInfoItem('Terms of Service', 'View', onTap: () {
          //   // Show terms of service
          //   _showPolicyDialog('Terms of Service', 'Terms of service content here...');
          // }),
          // _buildInfoItem('Privacy Policy', 'View', onTap: () {
          //   // Show privacy policy
          //   _showPolicyDialog('Privacy Policy', 'Privacy policy content here...');
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
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Text(
                  'Emergency Help',
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
              'If you are experiencing a serious mental health crisis or having thoughts of self-harm or suicide, please immediately contact the emergency hotlines below or go to the nearest hospital.',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            ..._emergencyContacts.entries
                .map((entry) => _buildEmergencyContactItem(
                      entry.key,
                      entry.value['value'],
                      entry.value['icon'],
                      entry.value['color'],
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactItem(
      String title, String value, IconData icon, Color color) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
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
            ),
            SizedBox(width: 4),
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

  Widget _buildContactItem(
      String title, String value, IconData icon, String action, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(value),
      trailing: IconButton(
        icon: Icon(
          action == 'copy'
              ? Icons.content_copy
              : action == 'email'
                  ? Icons.open_in_new
                  : action == 'web'
                      ? Icons.open_in_new
                      : action == 'call'
                          ? Icons.call
                          : Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 20,
        ),
        onPressed: () async {
          if (action == 'copy') {
            await Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied to clipboard')),
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
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
