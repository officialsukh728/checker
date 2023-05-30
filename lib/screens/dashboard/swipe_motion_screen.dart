import 'package:checker/screens/vision_detector_views/face_detector_view.dart';
import 'package:checker/utils/widgets/helpers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwipeRecordingWidget extends StatefulWidget {
  const SwipeRecordingWidget({super.key});

  @override
  SwipeRecordingWidgetState createState() => SwipeRecordingWidgetState();
}

class SwipeRecordingWidgetState extends State<SwipeRecordingWidget> {
  List<String> swipeRecords = [];

  @override
  void initState() {
    super.initState();
    loadSwipeRecords();
  }

  void loadSwipeRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      swipeRecords = prefs.getStringList('swipeRecords') ?? [];
    });
  }

  void saveSwipeRecord(String swipeDirection) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    swipeRecords.add(swipeDirection);
    await prefs.setStringList('swipeRecords', swipeRecords);
  }

  DateTime? _startTime;
  DateTime? _endTime;
  double? _startX;
  double? _endX;
  double _touchSpeed = 0.0;

  void _handlePanStart(DragStartDetails? details) {
    _startTime = DateTime.now();
    _startX = details?.globalPosition.dx;
  }

  void _handlePanEnd(DragEndDetails? details) {
    _endTime = DateTime.now();
    _endX = details?.velocity.pixelsPerSecond.dx;
    _calculateTouchSpeed();
  }

  void _calculateTouchSpeed() {
    if (_startTime != null && _endTime != null) {
      Duration? duration = _endTime?.difference(_startTime!);
      double? touchDuration = duration?.inMilliseconds.toDouble() ?? 0;
      double distance = ((_endX ?? 0) - (_startX ?? 0)).abs();
      setState(() {
        _touchSpeed = distance / touchDuration;
      });
      printLog('Touch Speed: $_touchSpeed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe Recording'),
        actions: [
          getFaceDetectorView()
        ],
      ),
      body: GestureDetector(
        onPanEnd: _handlePanEnd,
        onPanStart: _handlePanStart,
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            saveSwipeRecord('Swipe Right');
          } else {
            saveSwipeRecord('Swipe Left');
          }
        },
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy > 0) {
            saveSwipeRecord('Swipe Down');
          } else {
            saveSwipeRecord('Swipe Up');
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Swipe in any direction',
                style: TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Swipe Records:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 10.0),
              const SizedBox(height: 20.0),
              const Text(
                'Touch Records:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 10.0),
              Text(
                _touchSpeed.toString(),
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
