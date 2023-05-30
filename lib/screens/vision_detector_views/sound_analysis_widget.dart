import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';

class MicrophoneExampleApp extends StatefulWidget {
  /// Constructs [MicrophoneExampleApp].
  const MicrophoneExampleApp({Key? key}) : super(key: key);

  @override
  MicrophoneExampleAppState createState() => MicrophoneExampleAppState();
}

class MicrophoneExampleAppState extends State<MicrophoneExampleApp> {
  StreamSubscription<Uint8List>? audioSubscription;
  RxDouble audioData = 0.0.obs;
  RxBool isRecording = false.obs;
  @override
  void dispose() {
    audioSubscription?.cancel();
    super.dispose();
  }

  Future<void> startRecording() async {
    isRecording.value = true;
    audioSubscription = (await MicStream.microphone())
        ?.listen((audioData) => calculateDecibelLevel(audioData));
  }

  Future<void> stopRecording() async {
    isRecording.value = false;
    audioSubscription?.cancel();
    audioSubscription = null;
    audioData.value = 0.0;
  }

  void calculateDecibelLevel(Uint8List data) {
    double sum = 0;
    int len = data.length;
    for (int i = 0; i < len; i++) {
      double value = data[i].toDouble();
      sum += value * value;
    }
    double rms = sqrt(sum / len);
    double referenceAmplitude = 1.0;
    num decibel = 20 * log(rms / referenceAmplitude);
    audioData.value = decibel.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Decibel"),
      ),
      body: Center(
        child: Obx(() => Text("Decibel level : ${audioData.value}")),
      ),
      floatingActionButton: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isRecording.value)
              FloatingActionButton(
                onPressed: () {
                  startRecording();
                },
                child: const Icon(Icons.play_circle),
              ),
            if (isRecording.value)
              FloatingActionButton(
                onPressed: () {
                  stopRecording();
                },
                child: const Icon(Icons.pause_circle),
              )
          ],
        ),
      ),
    );
  }
}
