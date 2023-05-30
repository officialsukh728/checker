import 'package:checker/screens/vision_detector_views/face_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TypingSpeedWidget extends StatefulWidget {
  const TypingSpeedWidget({super.key});

  @override
  TypingSpeedWidgetState createState() => TypingSpeedWidgetState();
}

class TypingSpeedWidgetState extends State<TypingSpeedWidget> {
  Rx<TextEditingController> controller = TextEditingController().obs;
  Rx<DateTime> startTime = DateTime.now().obs;
  Rx<DateTime> endTime = DateTime.now().obs;
  RxBool isRunning = false.obs;
  RxString text = ''.obs;

  @override
  void initState() {
    resetTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Speed Checker'),
        actions: [getFaceDetectorView()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),
              TextField(
                maxLines: 5,
                controller: controller.value,
                onChanged: handleTextChange,
                decoration: const InputDecoration(
                  labelText: 'Type here',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Obx(
                () => Text(
                  isRunning.value ? 'Typing...' : 'Finished!',
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 8.0),
              Obx(
                () => Text(
                  'Typing speed: ${calculateTypingSpeedNew()} words per minute',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: resetTimer,
                child: const Text('Reset'),
              ),  const SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }

  void resetTimer() {
    controller.value.clear();
    isRunning.value = false;
    startTime.value = DateTime.now();
    endTime.value = DateTime.now();
    text.value = '';
  }

  void handleTextChange(String value) {
    if (!isRunning.value) {
      isRunning.value = true;
      startTime.value = DateTime.now();
    }
    text.value = value;
  }

  String calculateTypingSpeedNew() {
    final duration = endTime.value.difference(startTime.value);
    final seconds = duration.inSeconds;
    final charactersTyped = text.value.length;
    return (charactersTyped / seconds).toStringAsFixed(2);
  }

}
