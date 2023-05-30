// ignore_for_file: library_private_types_in_public_api

import 'package:call_log/call_log.dart';
import 'package:checker/screens/vision_detector_views/face_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checker/business_logic/blocs/call_log_bloc/call_log_bloc.dart';
import 'package:checker/utils/widgets/helpers.dart';
import 'package:workmanager/workmanager.dart';

/// example widget for call log plugin
class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  _CallLogScreenState createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Logs'),
        actions: [
            getFaceDetectorView(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: _onPressed,
              child: const Icon(Icons.sync),
            ),
          ),
          xWidth(10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Workmanager().registerOneOffTask(
                  DateTime.now().millisecondsSinceEpoch.toString(),
                  'simpleTask',
                  existingWorkPolicy: ExistingWorkPolicy.replace,
                );
              },
              child: const Icon(Icons.work_history),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<CallLogBloc, CallLogState>(
          builder: (context, state) {
            if (state is CallLogLoaded) {
              printLog("CallLogLoaded ()=> ${state.list.length}");
            }
            return Column(
              children: <Widget>[
                if (state is CallLogLoading)
                  Center(
                    child: customLoader(),
                  ),
                if (state is CallLogLoaded)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      for (CallLogEntry entry in state.list)
                        if (entry.callType == CallType.missed)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Divider(),
                              Text('NUMBER     : ${entry.number}'),
                              Text('NAME       : ${entry.name}'),
                              Text('TYPE       : ${entry.callType}'),
                              Text('DATE       : ${DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0)}'),
                              Text('DURATION   : ${entry.duration}'),
                              Text('ACCOUNT ID : ${entry.phoneAccountId}'),
                              Text('SIM NAME   : ${entry.simDisplayName}'),
                            ],
                          ),
                    ]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onPressed() {
    context.read<CallLogBloc>().add(GetCallLogEvent());
  }
}
