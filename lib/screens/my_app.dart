import 'package:checker/utils/widgets/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:checker/screens/dashboard/dashboard.dart';
import 'package:checker/utils/widgets/app_bloc_providers.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyAppContent();
  }
  static void downloaderCallback(
      String id, int status, int progress) {
    printLog("progress: $progress");
  }

}

class MyAppContent extends StatefulWidget {
  const MyAppContent({super.key});

  @override
  State<MyAppContent> createState() => _MyAppContentState();
}

class _MyAppContentState extends State<MyAppContent> {
  @override
  Widget build(BuildContext context) {
    return AppBlocProviders(
      child: GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const Dashboard(),
      ),
    );
  }
}
