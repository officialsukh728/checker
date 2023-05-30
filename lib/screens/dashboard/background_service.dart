// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';
//
// import 'package:checker/screens/dashboard/dashboard.dart';
// import 'package:checker/screens/vision_detector_views/face_detector_view.dart';
// import 'package:checker/utils/widgets/helpers.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//
//   /// OPTIONAL, using custom notification channel id
//   AndroidNotificationChannel channel = const AndroidNotificationChannel(
//     'my_foreground', // id
//     'MY FOREGROUND SERVICE', // title
//     description:
//         'This channel is used for important notifications.', // description
//     importance: Importance.low, // importance must be at low or higher level
//   );
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   if (Platform.isIOS) {
//     await flutterLocalNotificationsPlugin.initialize(
//       const InitializationSettings(
//         iOS: DarwinInitializationSettings(),
//       ),
//     );
//   }
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       // this will be executed when app is in foreground or background in separated isolate
//       onStart: onStart,
//       // auto start service
//       autoStart: true,
//       isForegroundMode: true,
//       notificationChannelId: 'my_foreground',
//       initialNotificationTitle: 'AWESOME SERVICE',
//       initialNotificationContent: 'Initializing',
//       foregroundServiceNotificationId: 888,
//     ),
//     iosConfiguration: IosConfiguration(
//       // auto start service
//       autoStart: true,
//
//       // this will be executed when app is in foreground in separated isolate
//       onForeground: onStart,
//
//       // you have to enable background fetch capability on xcode project
//       onBackground: onIosBackground,
//     ),
//   );
//
//   service.startService();
// }
//
// // to ensure this is executed
// // run app from xcode, then from xcode menu, select Simulate Background Fetch
//
// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   await preferences.reload();
//   final log = preferences.getStringList('log') ?? <String>[];
//   log.add(DateTime.now().toIso8601String());
//   await preferences.setStringList('log', log);
//
//   return true;
// }
//
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   // Only available for flutter 3.0.0 and later
//   DartPluginRegistrant.ensureInitialized();
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });
//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//   }
//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });
//
//   // bring to foreground
//   Timer.periodic(const Duration(seconds: 10), (timer) async {
//     // if (service is AndroidServiceInstance &&
//     //     (await service.isForegroundService())) {
//     //   service.setForegroundNotificationInfo(
//     //     title: "My App Service",
//     //     content: "Updated at ${DateTime.now().minute}-${DateTime.now().second}",
//     //   );
//     // }
//
//     /// you can see this log in logcat
//     printLog('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
//     getSetUnlockCount();
//     service.invoke(
//       'update',
//       {
//         "unlockCount": unlockCount.value,
//       },
//     );
//   });
// }
//
// class BackgroundServiceExamole extends StatefulWidget {
//   const BackgroundServiceExamole({Key? key}) : super(key: key);
//
//   @override
//   State<BackgroundServiceExamole> createState() =>
//       _BackgroundServiceStateExamole();
// }
//
// class _BackgroundServiceStateExamole extends State<BackgroundServiceExamole> {
//   String text = "Stop Service";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Service App'),
//         // actions: [getFaceDetectorView()],
//       ),
//       body: Column(
//         children: [
//           StreamBuilder<Map<String, dynamic>?>(
//             stream: FlutterBackgroundService().on('update'),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               }
//               final data = snapshot.data!;
//               String unlockCount = data["unlockCount"] ?? "0";
//               return Column(
//                 children: [
//                   Text(unlockCount),
//                 ],
//               );
//             },
//           ),
//           ElevatedButton(
//             child: const Text("Foreground Mode"),
//             onPressed: () {
//               FlutterBackgroundService().invoke("setAsForeground");
//             },
//           ),
//           ElevatedButton(
//             child: const Text("Background Mode"),
//             onPressed: () {
//               FlutterBackgroundService().invoke("setAsBackground");
//             },
//           ),
//           ElevatedButton(
//             child: Text(text),
//             onPressed: () async {
//               final service = FlutterBackgroundService();
//               var isRunning = await service.isRunning();
//               if (isRunning) {
//                 service.invoke("stopService");
//               } else {
//                 service.startService();
//               }
//               if (!isRunning) {
//                 text = 'Stop Service';
//               } else {
//                 text = 'Start Service';
//               }
//               setState(() {});
//             },
//           ),
//           const Expanded(
//             child: LogView(),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class LogView extends StatefulWidget {
//   const LogView({Key? key}) : super(key: key);
//
//   @override
//   State<LogView> createState() => _LogViewState();
// }
//
// class _LogViewState extends State<LogView> {
//   late final Timer timer;
//   List<String> logs = [];
//
//   @override
//   void initState() {
//     super.initState();
//     timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       final SharedPreferences sp = await SharedPreferences.getInstance();
//       await sp.reload();
//       logs = sp.getStringList('log') ?? [];
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     timer.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: logs.length,
//       itemBuilder: (context, index) {
//         final log = logs.elementAt(index);
//         return Text(log);
//       },
//     );
//   }
// }