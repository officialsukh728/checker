// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:background_fetch/background_fetch.dart';
import 'package:checker/business_logic/blocs/call_log_bloc/call_log_bloc.dart';
import 'package:checker/main.dart';
import 'package:checker/screens/dashboard/swipe_motion_screen.dart';
import 'package:checker/screens/dashboard/typing_speed_tracker_widget.dart';
import 'package:checker/screens/vision_detector_views/eye_tracker_screen.dart';
import 'package:checker/screens/vision_detector_views/face_detector_view.dart';
import 'package:checker/utils/widgets/helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:get/get.dart';
import 'package:is_lock_screen/is_lock_screen.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

RxInt fallingCount = 0.obs;
RxInt eyeBlinkingCount = 0.obs;
RxString unlockCount = "0".obs;

bool get showAllWidgetPermission => false;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();

  static void downloaderCallback(String id, int status, int progress) {
    printLog("progress: $progress");
  }
}

class DashboardState extends State<Dashboard> {
  void get stopRecordingDispose => stopRecording;

  void get startRecordingInitState => startRecording;

  StreamSubscription<Uint8List>? audioSubscription;
  RxDouble audioData = 0.0.obs;
  RxBool isRecording = false.obs;
  late FlutterIsolate flutterIsolate;
  ReceivePort mainToIsolateStream = ReceivePort();
  RxBool isFalling = false.obs;

  @override
  void initState() {
    super.initState();
    _setData();
    startBackgroundFetch();
    initPlatformState();
    startRecordingInitState;
    mainToIsolateStream.listen((message) {
      // getSetUnlockCount();
      isFalling.value = message;
    });
  }

  @override
  void dispose() {
    flutterIsolate.kill();
    audioSubscription?.cancel();
    super.dispose();
    stopRecordingDispose;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [getFaceDetectorView()],
      ),
      body: BlocProvider(
        create: (context) =>
            SelectedSubscriptionToggleBloc()..add(fallingCount.value),
        child: BlocProvider(
          create: (context) => CallLogBloc(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  yHeight(10),
                  Center(
                    child:
                        Obx(() => Text("Decibel level : ${audioData.value}")),
                  ),
                  yHeight(10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Fall Status: ',
                        style: TextStyle(fontSize: 15),
                      ),
                      Obx(() => Text(
                            isFalling.value ? 'Falling' : 'Not Falling',
                            style: const TextStyle(fontSize: 15),
                          )),
                    ],
                  ),
                  yHeight(10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Unlock Count: ',
                        style: TextStyle(fontSize: 15),
                      ),
                      Obx(() => Text(
                            unlockCount.value,
                            style: const TextStyle(fontSize: 15),
                          )),
                    ],
                  ),
                  yHeight(10),
                  BlocBuilder<SelectedSubscriptionToggleBloc, int>(
                    builder: (context, state) {
                      return Text(
                        "Falling Count: $state",
                        style: const TextStyle(fontSize: 15),
                      );
                    },
                  ),
                  yHeight(10), //
                  Obx(() => Text(
                        "Eye Blinking Count: ${eyeBlinkingCount.value}",
                        style: const TextStyle(fontSize: 15),
                      )),
                  yHeight(10),
                  BlocBuilder<CallLogBloc, CallLogState>(
                    builder: (context, state) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (state is CallLogLoaded)
                            Text(
                              'Drop Calls: ${state.list.length}',
                              style: const TextStyle(fontSize: 15),
                            ),
                        ],
                      );
                    },
                  ),
                  yHeight(10),
                  BlocBuilder<ProcessIrisMovementModelBloc,
                      ProcessIrisMovementModel>(
                    builder: (context, state) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Left Eye Iris Movement Offset: ${state.leftIrisMovement}",
                            style: const TextStyle(fontSize: 15),
                          ),
                          yHeight(5),
                          Text(
                            "Right Eye Iris Movement Offset: ${state.rightIrisMovement}",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      );
                    },
                  ),
                  if (showAllWidgetPermission) ...[
                    StreamBuilder(
                      stream: NoiseMeter().noiseStream,
                      builder: (context, snapshot) => Column(
                        children: [
                          Text("Max Decibel: ${snapshot.data?.maxDecibel}"),
                          Text("Mean Decibel: ${snapshot.data?.meanDecibel}"),
                          yHeight(10),
                        ],
                      ),
                    ),
                    getStreamWidgetByType(
                      stream: magnetometerEvents,
                      name: "magnetometerEvents",
                    ),
                    getStreamWidgetByType(
                      stream: userAccelerometerEvents,
                      name: "userAccelerometerEvents",
                    ),
                    getStreamWidgetByType(
                      stream: accelerometerEvents,
                      name: "accelerometerEvents",
                    ),
                    getStreamWidgetByType(
                      stream: gyroscopeEvents,
                      name: "gyroscopeEvents",
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  pushTo(context, const TypingSpeedWidget());
                },
                child: const Icon(
                  Icons.keyboard_alt_outlined,
                  color: Colors.white,
                ),
              ),
              yHeight(10),
              FloatingActionButton(
                onPressed: () {
                  pushTo(context, const FaceDetectorView());
                },
                child: const Icon(
                  Icons.face,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          xWidth(10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  pushTo(context, const SwipeRecordingWidget());
                },
                child: const Icon(
                  Icons.swipe,
                  color: Colors.white,
                ),
              ),
              yHeight(10),
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EyeTrackerScreen()));
                },
                child: const Icon(
                  Icons.face_2_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _run() async {
    await FlutterIsolate.spawn(isolate1, "isolate").then((isolate) {
      // Timer(const Duration(seconds: 1), () {
      //   printLog("Pausing Isolate 1");
      //   isolate.pause();
      // });
      // Timer(const Duration(seconds: 1), () {
      //   printLog("Resuming Isolate 1");
      //   isolate.resume();
      // });
      // Timer(const Duration(seconds: 20), () {
      //   printLog("Killing Isolate 1");
      //   isolate.kill();
      // });
    });
    await flutterCompute(computeFunction, "computeFunction");
  }

  /// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    try {
      var status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 2,
          startOnBoot: true,
          enableHeadless: true,
          stopOnTerminate: false,
          requiresCharging: false,
          forceAlarmManager: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
          requiresBatteryNotLow: false,
          requiredNetworkType: NetworkType.NONE,
        ),
        _onBackgroundFetch,
        _onBackgroundFetchTimeout,
      );
      printLog('[BackgroundFetch] configure success: $status');

      /// Schedule a "one-shot" custom-task in 100ms.
      /// These are fairly reliable on Android (particularly with forceAlarmManager) but not iOS,
      /// where device must be powered (and delay will be throttled by the OS).
      BackgroundFetch.scheduleTask(TaskConfig(
        delay: 10,
        periodic: false,
        enableHeadless: true,
        stopOnTerminate: false,
        forceAlarmManager: true,
        taskId: "flutter_background_fetch",
      ));
      getSetUnlockCount();
    } on Exception catch (e) {
      printLog("[BackgroundFetch] configure ERROR: $e");
    }

    /// If the widget was removed from the tree while the asynchronous platform
    /// message was in flight, we want to discard the reply rather than calling
    /// setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onBackgroundFetch(String taskId) async {
    getSetUnlockCount();
    printLog('flutterBackgroundFetch >>>>>>>>>> $taskId.');

    /// IMPORTANT:  You must signal completion of your fetch task or
    /// the OS can punish your app for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  /// This event fires shortly before your task is about to timeout.
  /// You must finish any outstanding work and call BackgroundFetch.finish(taskId).
  void _onBackgroundFetchTimeout(String taskId) {
    printLog("[BackgroundFetch] TIMEOUT: $taskId");
    getSetUnlockCount();
    BackgroundFetch.finish(taskId);
  }

  startBackgroundFetch() async {
    flutterIsolate = await FlutterIsolate.spawn(
      isolateEntry,
      mainToIsolateStream.sendPort,
    );
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

  void _setData() async {
    _run();
    final result = await getFallCount();
    printLog("fallingCount==> $result");
    fallingCount.value = result;
    final result1 = await getEyeBlinkingCountCount();
    printLog("eyeBlinkingCount==> $result1");
    eyeBlinkingCount.value = result1;
  }
}

void isolateEntry(SendPort isolateToMainStream) {
  accelerometerEvents.listen((event) => _onAcceleroMeterEvents(
        event: event,
        isolateToMainStream: isolateToMainStream,
      ));
}

_onAcceleroMeterEvents({
  required AccelerometerEvent event,
  required SendPort isolateToMainStream,
}) async {
  final isFalling = await detectFall(event);
  final list = await getFallCountList();
  isolateToMainStream.send(isFalling);
  if (list.isEmpty) {
    await saveFallCount(0);
  } else if (list.isNotEmpty &&
      list.length.isGreaterThan(11) &&
      areLastTenItemsDifferent(list) &&
      isFalling) {
    int previousCount = await getFallCount();
    int currentCount = previousCount + 1;
    printLog("currentCount ==>$currentCount");
    await saveFallCount(currentCount);
    await saveFallCountList("$isFalling");
  } else {
    await saveFallCountList("$isFalling");
  }
}

bool areLastTenItemsDifferent(List<dynamic> list) {
  if (list.length < 10) {
    return true;
  }
  List<dynamic> lastTenItems = list.sublist(list.length - 10);
  dynamic firstItem = lastTenItems.first;
  for (dynamic item in lastTenItems) {
    if (item != firstItem) {
      return true;
    }
  }
  return false;
}

Future<bool> detectFall(AccelerometerEvent event) async {
  double fallThreshold = 10.0;
  double impactThreshold = 13.0;
  double totalAcceleration =
      (event.x.abs() + event.y.abs() + event.z.abs()).floorToDouble();
  if (totalAcceleration < fallThreshold) {
    return false;
  } else if (totalAcceleration > impactThreshold) {
    return false;
  } else {
    return true;
  }
}

StreamBuilder getStreamWidgetByType({
  required Stream stream,
  required String name,
}) {
  return StreamBuilder(
    stream: stream,
    builder: (context, snapshot) => snapshot.data == null
        ? const SizedBox.shrink()
        : Column(
            children: [
              Text("$name x : ${snapshot.data?.x}"),
              Text("$name y : ${snapshot.data?.y}"),
              Text("$name z : ${snapshot.data?.z}"),
              yHeight(10),
            ],
          ),
  );
}

Future<void> saveFallCount(int count) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int opCount = await getOpertionCount();
  if (count.isGreaterThan(10) && opCount.isEqual(10)) {
    count = count - 9;
    await setOpertionCount(1);
  } else {
    await setOpertionCount(opCount++);
  }
  fallingCount.value = count;
  Get.context?.read<SelectedSubscriptionToggleBloc>().add(count);
  await prefs.setInt('fallCountPoint', count);
}

void getSetUnlockCount({String arg = ""}) async {
  int unlockCountLocal = await getUnlockCount();
  final currentStatus = await isLockScreen() ?? false;
  final previousStatus = await getUnlockCountStatus();
  await setUnlockCountStatus(currentStatus);
  if (currentStatus != previousStatus && currentStatus) {
    unlockCountLocal = unlockCountLocal + 1;
    await setUnlockCount(unlockCountLocal);
    blocLog(bloc: "MainToIsolateStream", msg: '$currentStatus');
  }
  unlockCount.value = unlockCountLocal.toString();
}

Future<int> getUnlockCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  return prefs.getInt('UnlockCount') ?? 0;
}

Future<void> setUnlockCount(int count) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('UnlockCount', count);
}

Future<bool> getUnlockCountStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  return prefs.getBool('UnlockCountStatus') ?? false;
}

Future<void> setUnlockCountStatus(bool count) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('UnlockCountStatus', count);
}

Future<int> getFallCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  return prefs.getInt('fallCountPoint') ?? 0;
}

Future<void> setOpertionCount(int count) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('opertionCount', count);
}

Future<int> getEyeBlinkingCountCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('eyeBlinkingCount') ?? 0;
}

Future<void> setEyeBlinkingCountCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final count = await (getEyeBlinkingCountCount()) + 1;
  await prefs.setInt('eyeBlinkingCount', count);
}

Future<int> getOpertionCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('opertionCount') ?? 0;
}

Future<void> saveFallCountList(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList('fallCountList') ?? <String>[];
  list.add(value);
  await prefs.setStringList('fallCountList', list);
}

Future<List<String>> getFallCountList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('fallCountList') ?? <String>[];
}

class HolidayPlanner {
  List<DateTime> manuallySpecifiedHolidays = [
    DateTime(2023, 5, 29),
    DateTime(2023, 5, 30),
    DateTime(2023, 6, 01),
    DateTime(2023, 6, 02),
    DateTime(2023, 6, 04),
    DateTime(2023, 6, 05),
  ];

  bool isHoliday(DateTime date) {
    if (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday ||
        manuallySpecifiedHolidays.contains(date)) {
      return true;
    }
    return false;
  }

  DateTime? findBestHolidayPlan(DateTime startDate, DateTime endDate) {
    DateTime? bestDate;
    int bestCount = 0;
    for (DateTime date = startDate;
        date.isBefore(endDate);
        date = date.add(const Duration(days: 1))) {
      if (!isHoliday(date)) {
        int count = 0;
        for (DateTime nextDate = date.add(const Duration(days: 1));
            nextDate.isBefore(endDate);
            nextDate = nextDate.add(const Duration(days: 1))) {
          if (!isHoliday(nextDate)) {
            count++;
          } else {
            break;
          }
        }
        if (count > bestCount) {
          bestCount = count;
          bestDate = date;
        }
      }
    }
    return bestDate;
  }
}
