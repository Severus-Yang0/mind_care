import 'package:flutter/material.dart';
import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'models/StimuliTestRecord.dart';

class TestConstants {
  static const int IMAGE_DISPLAY_DURATION = 3500;
  static const int INTERVAL_DURATION = 1500; 
  static const double IMAGE_SIZE = 400.0;
  
  // New constants for image types
  static const String HIGH_VALENCE = "High Valence";
  static const String LOW_VALENCE = "Low Valence";
}

class ImageStimuliPage extends StatefulWidget {
  @override
  _ImageStimuliPageState createState() => _ImageStimuliPageState();
}

class _ImageStimuliPageState extends State<ImageStimuliPage> {
  bool isTestStarted = false;
  int currentImageIndex = -1;
  bool showCross = true;
  Timer? _timer;
  int totalImagesShown = 0;
  DateTime? _startTime; // 记录测试开始时间
  bool _isSubmitting = false; // 添加提交状态标志
  
  // Increase image count to 60, arranged in alternating pattern as filtered
  final List<String> imagePaths = List.generate(60, (index) => 'assets/images/oasis/${index + 1}.jpg');
  
  // Define image type information for recording and display
  final List<String> imageTypes = List.generate(60, (index) => 
    index % 2 == 0 ? TestConstants.HIGH_VALENCE : TestConstants.LOW_VALENCE
  );

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTest() {
    if (!mounted) return;
    
    _startTime = DateTime.now();
    
    setState(() {
      isTestStarted = true;
      currentImageIndex = -1;
      showCross = true;
      totalImagesShown = 0;
    });
    
    _startImageSequence();
  }

  void _startImageSequence() {
    if (!mounted) return;
    
    // Start the first cycle
    _scheduleNextStep();
  }

  void _scheduleNextStep() {
    if (!mounted) return;

    if (showCross) {
      // Currently showing cross, prepare to show next image
      _timer = Timer(Duration(milliseconds: TestConstants.INTERVAL_DURATION), () {
        if (!mounted) return;
        setState(() {
          currentImageIndex++;
          showCross = false;
        });
        
        if (currentImageIndex < imagePaths.length) {
          // Set image display time
          _scheduleNextStep();
        } else {
          // All images have been displayed
          _endTest();
        }
      });
    } else {
      // Currently showing image, prepare to show cross
      _timer = Timer(Duration(milliseconds: TestConstants.IMAGE_DISPLAY_DURATION), () {
        if (!mounted) return;
        setState(() {
          showCross = true;
          totalImagesShown++;
        });
        
        if (currentImageIndex < imagePaths.length - 1) {
          // More images to display
          _scheduleNextStep();
        } else {
          // All images have been displayed
          _endTest();
        }
      });
    }
  }

  void _endTest() {
    if (!mounted) return;
    setState(() {
      isTestStarted = false;
    });
    _timer?.cancel();
    _saveTestRecord();
  }
  
  Future<void> _saveTestRecord() async {
    if (_startTime == null) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final user = await Amplify.Auth.getCurrentUser();
      final endTime = DateTime.now();
      
      final testRecord = StimuliTestRecord(
        userId: user.userId,
        startTime: TemporalDateTime(_startTime!),
        endTime: TemporalDateTime(endTime),
      );
      
      final request = ModelMutations.create(
        testRecord,
        authorizationMode: APIAuthorizationType.userPools,
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors?.isNotEmpty ?? false) {
        throw Exception('Save failed: ${response.errors}');
      }
      _showTestCompleteDialog();
      
    } catch (e) {
      print('Error saving test record: $e');
      _showTestCompleteDialog();
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Method to interrupt the test
  void _stopTest() {
    if (!mounted) return;
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Test Interruption'),
          content: Text('Are you sure you want to interrupt the current test?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                // Continue the test
                _scheduleNextStep();
              },
            ),
            TextButton(
              child: Text('Confirm Interruption'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isTestStarted = false;
                });
                _showTestInterruptedDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTestInterruptedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Test Interrupted'),
          content: Text('The test has been interrupted. Completed showing $totalImagesShown images out of ${imagePaths.length}.'),
          actions: <Widget>[
            TextButton(
              child: Text('Return to Home'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to home page
              },
            ),
          ],
        );
      },
    );
  }

  void _showTestCompleteDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Test Complete'),
          content: Text('60 image stimuli test has been completed.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to home page
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _timer?.cancel();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text('EEG Image Stimuli Test'),
          backgroundColor: Color(0xFF4FC3F7),
        ),
        body: Stack(
          children: [
            Center(
              child: !isTestStarted
                  ? StartTestScreen(onStart: startTest)
                  : TestScreen(
                      showCross: showCross,
                      currentImageIndex: currentImageIndex,
                      imagePaths: imagePaths,
                      totalImages: imagePaths.length,
                      progress: totalImagesShown,
                      onStop: _stopTest, // Pass the stop test callback
                    ),
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
      ),
    );
  }
}

class StartTestScreen extends StatelessWidget {
  final VoidCallback onStart;

  const StartTestScreen({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Test Instructions:\n\n'
            '1. 60 emotional images will be displayed during the test\n'
            '2. If you feel uncomfortable, you can interrupt the test at any time by clicking the pause button\n'
            '3. Please keep your attention focused on the center of the screen\n'
            '4. Please remain quiet during the test and minimize facial muscle movements\n'
            '5. Each image will be displayed for 3.5 seconds\n'
            '6. There will be a 1.5 second fixation point rest time between images\n'
            '7. The entire test will take approximately 5 minutes\n',
            style: TextStyle(fontSize: 18),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4FC3F7),
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          ),
          onPressed: onStart,
          child: Text(
            'Start Test',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
}

class TestScreen extends StatelessWidget {
  final bool showCross;
  final int currentImageIndex;
  final List<String> imagePaths;
  final int totalImages;
  final int progress;
  final VoidCallback onStop; // Add stop callback

  const TestScreen({
    required this.showCross,
    required this.currentImageIndex,
    required this.imagePaths,
    required this.totalImages,
    required this.progress,
    required this.onStop, // Receive stop callback
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: Center(
            child: showCross
                ? Text(
                    '+',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  )
                : currentImageIndex < imagePaths.length 
                    ? Image.asset(
                        imagePaths[currentImageIndex],
                        width: TestConstants.IMAGE_SIZE,
                        height: TestConstants.IMAGE_SIZE,
                        fit: BoxFit.contain,
                      )
                    : Container(),
          ),
        ),
        // Add progress indicator
        Positioned(
          bottom: 20,
          right: 20,
          child: Text(
            'Progress: $progress / $totalImages',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        // Add interrupt button
        Positioned(
          top: 20,
          right: 20,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: onStop,
            child: Text(
              'Interrupt Test',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}