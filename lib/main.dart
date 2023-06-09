import 'package:background_fetch/background_fetch.dart';
import 'package:camera/camera.dart';
import 'package:checker/firebase_options.dart';
import 'package:checker/screens/my_app.dart';
import 'package:checker/utils/widgets/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:checker/business_logic/services/injector.dart';
import 'package:checker/screens/dashboard/dashboard.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart' as w;
import 'dart:async';

List<CameraDescription> cameras = [];

/// This "Headless Task" is run when app is terminated.
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  var timeout = task.timeout;
  printLog("[BackgroundFetch] Headless event received: $taskId");
  if (timeout) {
    blocLog(msg: "timeout", bloc: "backgroundFetchHeadlessTask");
    BackgroundFetch.finish(taskId);
    return;
  }
  DashboardState().getSetUnlockCount();
  if (taskId == 'flutter_background_fetch') {
    BackgroundFetch.scheduleTask(
      TaskConfig(
        delay: 100,
        periodic: false,
        enableHeadless: true,
        stopOnTerminate: false,
        forceAlarmManager: false,
        taskId: "flutter_background_fetch",
      ),
    );
  }
}

@pragma('vm:entry-point')
void isolate1(String arg) async {
  Timer.periodic(
    const Duration(seconds: 1),
    (timer) => DashboardState().getSetUnlockCount(arg: "isolate"),
  );
}

@pragma('vm:entry-point')
void computeFunction(String arg) async {
  Timer.periodic(
    const Duration(seconds: 1),
    (timer) => DashboardState().getSetUnlockCount(arg: "computeFunction"),
  );
}

///TOP-LEVEL FUNCTION PROVIDED FOR WORK MANAGER AS CALLBACK
void callbackDispatcher() => w.Workmanager()
    .executeTask((taskName, inputData) async => await _onExecuteTask(
          taskName: taskName,
          inputData: inputData,
        ));

Future<bool> _onExecuteTask({
  required String taskName,
  Map<String, dynamic>? inputData,
}) async {
  printLog('Background Services are Working!');
  try {
    DashboardState().getSetUnlockCount();
    return true;
  } on PlatformException catch (e, s) {
    printLog(e);
    printLog(s);
    return true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  cameras = await availableCameras();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await w.Workmanager().initialize(callbackDispatcher);
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  )
      .then((value) => FirebaseAuth.instanceFor(app: value))
      .then((value) => printLog("FirebaseAuth ${value.currentUser} "));
  await AppInjector.init(appRunner: () => runApp(const MyApp()));
}
