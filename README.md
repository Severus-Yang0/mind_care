# MindCare

MindCare is a Flutter-based mobile application designed to provide mental health support and tracking. It offers users tools to monitor their mental wellbeing, complete psychological assessments, and access support resources.

## Features

### User Account Management
- User registration with email verification
- Secure login system
- Profile management

### Mental Health Assessment
- PHQ-9 depression screening questionnaire
- Assessment history tracking
- Detailed analysis of mental health trends

### Personal Diary
- Journal entry creation and management
- Mood tracking with each entry
- Secure and private record keeping

### Visualization & Reports
- Mental health trend analysis
- Score visualization with charts
- Personalized recommendations based on assessment results

### Image Stimuli Test
- EEG image stimuli test for research purposes
- Structured test with alternating image types
- Progress tracking during test sessions

### Personal Therapist
- AI-powered chat assistant for mental support
- Professional guidance and recommendations
- 24/7 availability for emotional support

### Help & Support
- Emergency contact information
- Frequently asked questions
- Direct support channels

## Technical Details

### Dependencies
- Flutter framework
- AWS Amplify for backend services
- Authentication with Amazon Cognito
- API connections for data management
- Chart visualization with fl_chart
- Markdown rendering for chat responses

### Architecture
- Clean architecture with separation of concerns
- Model-View-Controller pattern
- Secure data handling for sensitive information
- Responsive UI design for multiple device types

## Setup & Installation
1. Ensure Flutter is installed on your development machine
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Create a `config.dart` file in the appropriate directory with the following format:
   ```dart
   class Config {
     static const String qwenApiKey = '';
     static const String qwenBaseUrl = '';
     static const bool isProduction = false;
     static const Duration apiTimeout = Duration(seconds: 30);
   }
   ```
5. Fill in the API key and URL in the config file
6. Configure AWS Amplify following the provided configuration guide
7. Run the app using `flutter run`

## Usage Guidelines
MindCare is intended to provide supportive tools for mental health monitoring and should not be used as a replacement for professional medical advice or treatment. Always consult healthcare professionals for diagnosis and treatment of mental health conditions.

## Contact
For any issues or questions, please contact the developer at by75@duke.edu.

---
*Disclaimer: MindCare app assessments are for reference only and do not constitute medical diagnosis. If you experience severe symptoms, please seek professional medical help immediately.*