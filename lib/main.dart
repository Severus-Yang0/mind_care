import 'package:flutter/material.dart';
import 'package:mind_care/login_page.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await configureAmplify();
  runApp(MyApp());
}
Future<void> configureAmplify() async {
  final authPlugin = AmplifyAuthCognito();
  final apiPlugin = AmplifyAPI(options: APIPluginOptions(modelProvider: ModelProvider.instance));

  try {
    await Amplify.addPlugin(authPlugin);
    await Amplify.addPlugin(apiPlugin);
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print('Amplify configuration failed: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindCare App',
      theme: ThemeData(
        primaryColor: Color(0xFF4FC3F7), 
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Color(0xFFFFA726)),
      ),
      home: LoginPage(),
    );
  }
}
