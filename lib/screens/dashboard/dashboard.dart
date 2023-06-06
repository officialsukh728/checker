// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:background_fetch/background_fetch.dart';
import 'package:checker/business_logic/blocs/call_log_bloc/call_log_bloc.dart';
import 'package:checker/business_logic/blocs/page_rebuild_bloc/page_rebuild_bloc.dart';
import 'package:checker/firebase_options.dart';
import 'package:checker/main.dart';
import 'package:checker/models/device_data_model.dart';
import 'package:checker/screens/dashboard/typing_speed_tracker_widget.dart';
import 'package:checker/screens/vision_detector_views/eye_tracker_screen.dart';
import 'package:checker/screens/vision_detector_views/face_detector_view.dart';
import 'package:checker/utils/widgets/helpers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:get/get.dart';
import 'package:is_lock_screen/is_lock_screen.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

final database = FirebaseDatabase.instance.ref("devicesData");

bool get showAllWidgetPermission => true;

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
  DateTime? _startTime;
  DateTime? _endTime;
  double? _startX;
  double? _endX;

  int fallingCount = 0;
  int eyeBlinkingCount = 0;
  String unlockCount = "0";
  int audioData = 0;
  bool isRecording = false;
  bool isFalling = false;

  StreamSubscription<Uint8List>? audioSubscription;
  DeviceDataModel? deviceDataModel;
  late FlutterIsolate flutterIsolate;
  ReceivePort mainToIsolateStream = ReceivePort();

  @override
  void initState() {
    super.initState();
    _setData();
    startBackgroundFetch();
    initPlatformState();
    startRecordingInitState;
    mainToIsolateStream.listen((message) {
      isFalling = message;
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
        create: (context) => CallLogBloc(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocConsumer<PageRebuildBloc, PageRebuildState>(
              listener: (context, state) {
                if (state is PageRebuildLoaded) {
                  fallingCount = state.deviceDataModel.fallingCount ?? 0;
                  eyeBlinkingCount = state.deviceDataModel.eyeBlinkingCount ?? 0;
                  unlockCount = state.deviceDataModel.unlockCount ?? "0";
                  audioData = state.deviceDataModel.audioData ?? 0;
                  isRecording = state.deviceDataModel.isRecording ?? false;
                  isFalling = state.deviceDataModel.isFalling ?? false;
                }
              },
              builder: (context, state) {
                if (state is PageRebuildLoaded) {
                  return GestureDetector(
                    onPanEnd: _handlePanEnd,
                    onPanStart: _handlePanStart,
                    onTap: ()=>saveTouchRecords(),
                    // onHorizontalDragEnd: (details) {
                    //   if (details.velocity.pixelsPerSecond.dx > 0) {
                    //     saveSwipeRecord('Swipe Right');
                    //   } else {
                    //     saveSwipeRecord('Swipe Left');
                    //   }
                    // },
                    // onVerticalDragEnd: (details) {
                    //   if (details.velocity.pixelsPerSecond.dy > 0) {
                    //     saveSwipeRecord('Swipe Down');
                    //   } else {
                    //     saveSwipeRecord('Swipe Up');
                    //   }
                    // },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        yHeight(10),
                        Text(
                            "Decibel level : ${state.deviceDataModel.audioData ?? audioData}"),
                        yHeight(10),
                        Text(
                          "Fall Status: ${isFalling ? 'Falling' : 'Not Falling'}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        yHeight(10),
                        Text(
                          'Unlock Count: ${state.deviceDataModel.unlockCount ?? unlockCount}',
                          style: const TextStyle(fontSize: 15),
                        ),
                        yHeight(10),
                        Text(
                          "Falling Count: ${state.deviceDataModel.fallingCount ?? fallingCount}",
                          style: const TextStyle(fontSize: 15),
                        ),

                        yHeight(10), //
                        Text(
                          "Eye Blinking Count: ${state.deviceDataModel.eyeBlinkingCount ?? eyeBlinkingCount}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        yHeight(10),
                         Text(
                          'Touch Speed: ${state.deviceDataModel.touchSpeed ?? 0}"',
                          style: const TextStyle(fontSize: 15),
                        ),
                        yHeight(10),
                         Text(
                          'Touch Records: ${state.deviceDataModel.touchRecords ?? 0}"',
                          style: const TextStyle(fontSize: 15),
                        ),
                        yHeight(10),
                         Text(
                          'Eye Count Records: ${state.deviceDataModel.eyeCountRecords ?? 0}"',
                          style: const TextStyle(fontSize: 15),
                        ),
                        yHeight(10),
                         Text(
                          'Swipe Records: ${state.deviceDataModel.swipeRecords ?? 0}"',
                          style: const TextStyle(fontSize: 15),
                        ),
                        yHeight(10),
                         Text(
                          'Drop Calls: ${state.deviceDataModel.dropCalls ?? 0}"',
                          style: const TextStyle(fontSize: 15),
                        ),
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
                                Text(
                                    "Mean Decibel: ${snapshot.data?.meanDecibel}"),
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
                  );
                } else {
                  return Center(
                    child: customLoader(),
                  );
                }
              },
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
  void saveSwipeRecord(String swipeDirection) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> swipeRecords = prefs.getStringList('swipeRecords') ?? [];
    swipeRecords.add(swipeDirection);
    await prefs.setStringList('swipeRecords', swipeRecords);
  }

  void saveTouchRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int swipeRecords = prefs.getInt('touchRecords') ??0;
    swipeRecords++;
    await prefs.setInt('touchRecords', swipeRecords);
  }

  void saveTouchSpeed(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> touchSpeed = prefs.getStringList('touchSpeed') ?? [];
    touchSpeed.add("value");
    await prefs.setStringList('touchSpeed', touchSpeed);
  }

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
      final value=(distance / touchDuration);
      saveTouchSpeed(value);
    }
  }

  Future<void> _run() async {
    await FlutterIsolate.spawn(isolate1, "isolate");
    await flutterCompute(computeFunction, "computeFunction");
  }

  Future<void> initPlatformState() async {
    try {
      await BackgroundFetch.configure(
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
    if (!mounted) return;
  }

  void _onBackgroundFetch(String taskId) async {
    getSetUnlockCount();
    BackgroundFetch.finish(taskId);
  }

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
    isRecording = true;
    audioSubscription = (await MicStream.microphone())
        ?.listen((audioData) => calculateDecibelLevel(audioData));
  }

  Future<void> stopRecording() async {
    isRecording = false;
    audioSubscription?.cancel();
    audioSubscription = null;
    audioData = 0;
    // saveDeviceData(audioDataNew: audioData, isFallingNew: isRecording);
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
    audioData = decibel.toInt();
  }

  void _setData() async {
    await _run();
    final result = await getFallCount();
    printLog("fallingCount==> $result");
    fallingCount = result;
    final result1 = await getEyeBlinkingCountCount();
    printLog("eyeBlinkingCount==> $result1");
    eyeBlinkingCount = result1;
    // saveDeviceData(eyeBlinkingCountNew: eyeBlinkingCount);
    Timer.periodic(
      const Duration(seconds: 2),
      (Timer timer) async {
        saveDeviceData();
        getDeviceData();
      },
    );
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
    fallingCount = count;
    // saveDeviceData(fallingCountNew: fallingCount);
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
      unlockCount = unlockCountLocal.toString();
      blocLog(
          bloc: "MainToIsolateStreamUpdate",
          msg: '$currentStatus ${unlockCount.toString()}');
      // saveDeviceData(unlockCountNew: unlockCount.toString());
    }
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

  Future<void> saveDeviceData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final deviceId = await PlatformDeviceId.getDeviceId ?? "";
      final swipeRecords = prefs.getStringList('swipeRecords') ?? [];
      final touchRecords = prefs.getInt('touchRecords') ??0;
      final eyeCountRecords = prefs.getInt('EyeCountRecords') ??0;
      final dropCalls = prefs.getInt('dropCalls') ??0;
      final touchSpeed = prefs.getStringList('touchSpeed') ?? [];
      Map<String, dynamic> data = {
        "deviceId": deviceId,
        "fallingCount": fallingCount,
        "unlockCount": unlockCount,
        "audioData": audioData.toInt(),
        "isRecording": isRecording,
        "isFalling": isFalling,
        "eyeBlinkingCount": eyeBlinkingCount,
        "dropCalls": dropCalls,
        "touchSpeed": touchSpeed,
        "swipeRecords": swipeRecords,
        "touchRecords": touchRecords,
        "eyeCountRecords": eyeCountRecords,
      };
      printLog("saveDeviceData()=> $data");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await database.child(deviceId).set(data);
    } catch (e) {
      blocLog(msg: e.toString(), bloc: "saveDeviceDataLocal");
    }
  }

  void getDeviceData() {
    context.read<PageRebuildBloc>().add(GetDataPageRebuildEvent());
  }
}
