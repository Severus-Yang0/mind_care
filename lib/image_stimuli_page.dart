import 'package:flutter/material.dart';
import 'dart:async';

class TestConstants {
  static const int IMAGE_DISPLAY_DURATION = 3500; // 图片显示时间(毫秒)，调整为3.5秒
  static const int INTERVAL_DURATION = 1500; // 间隔时间(毫秒)，保持1.5秒的注视点
  static const double IMAGE_SIZE = 400.0; // 图片显示尺寸
  
  // 新增常量说明图片类型
  static const String HIGH_VALENCE = "高效价";
  static const String LOW_VALENCE = "低效价";
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
  
  // 增加图片数量至60张，按我们筛选的交替模式排列
  final List<String> imagePaths = List.generate(60, (index) => 'assets/images/oasis/${index + 1}.jpg');
  
  // 定义图片类型信息，用于记录和显示
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
    
    // 开始第一个周期
    _scheduleNextStep();
  }

  void _scheduleNextStep() {
    if (!mounted) return;

    if (showCross) {
      // 当前显示十字，准备显示下一张图片
      _timer = Timer(Duration(milliseconds: TestConstants.INTERVAL_DURATION), () {
        if (!mounted) return;
        setState(() {
          currentImageIndex++;
          showCross = false;
          // 调试信息更详细，显示图片类型
          print('显示图片 ${currentImageIndex+1}/60: ${imageTypes[currentImageIndex]} 图片');
        });
        
        if (currentImageIndex < imagePaths.length) {
          // 设置图片显示时间
          _scheduleNextStep();
        } else {
          // 所有图片都显示完毕
          _endTest();
        }
      });
    } else {
      // 当前显示图片，准备显示十字
      _timer = Timer(Duration(milliseconds: TestConstants.IMAGE_DISPLAY_DURATION), () {
        if (!mounted) return;
        setState(() {
          showCross = true;
          totalImagesShown++;
          print('显示注视点 (已完成: $totalImagesShown/60)');
        });
        
        if (currentImageIndex < imagePaths.length - 1) {
          // 还有更多图片要显示
          _scheduleNextStep();
        } else {
          // 所有图片都显示完毕
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
    _showTestCompleteDialog();
  }

  // 添加中断测试的方法
  void _stopTest() {
    if (!mounted) return;
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认中断测试'),
          content: Text('您确定要中断当前测试吗？'),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
                // 继续测试
                _scheduleNextStep();
              },
            ),
            TextButton(
              child: Text('确认中断'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isTestStarted = false;
                });
                // 显示中断测试的信息
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
          title: Text('测试已中断'),
          content: Text('测试已被中断。已完成显示 $totalImagesShown 张图片，共 ${imagePaths.length} 张。'),
          actions: <Widget>[
            TextButton(
              child: Text('返回主页'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // 返回主页
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
          title: Text('测试完成'),
          content: Text('60张图片刺激测试已完成。'),
          actions: <Widget>[
            TextButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // 返回主页
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
          title: Text('EEG图片刺激测试'),
          backgroundColor: Color(0xFF4FC3F7),
        ),
        body: Center(
          child: !isTestStarted
              ? StartTestScreen(onStart: startTest)
              : TestScreen(
                  showCross: showCross,
                  currentImageIndex: currentImageIndex,
                  imagePaths: imagePaths,
                  totalImages: imagePaths.length,
                  progress: totalImagesShown,
                  onStop: _stopTest, // 传递停止测试的回调
                ),
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
            '测试说明：\n\n'
            '1. 测试过程中将显示60张情绪图片\n'
            '2. 如果感到不适，可以随时点击暂停按钮中断测试\n'
            '3. 请保持注意力集中在屏幕中央\n'
            '4. 测试期间请保持安静，尽量减少面部肌肉活动\n'
            '5. 每张图片显示3.5秒钟\n'
            '6. 图片之间会有1.5秒的注视点休息时间\n'
            '7. 整个测试大约持续5分钟\n',
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
            '开始测试',
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
  final VoidCallback onStop; // 添加停止回调

  const TestScreen({
    required this.showCross,
    required this.currentImageIndex,
    required this.imagePaths,
    required this.totalImages,
    required this.progress,
    required this.onStop, // 接收停止回调
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
        // 添加进度指示器
        Positioned(
          bottom: 20,
          right: 20,
          child: Text(
            '进度: $progress / $totalImages',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        // 添加中断按钮
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
              '中断测试',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}