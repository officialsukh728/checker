import 'package:checker/business_logic/blocs/face_detector_rebuild_bloc/face_detector_rebuild_bloc.dart';
import 'package:checker/business_logic/blocs/page_rebuild_bloc/page_rebuild_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checker/business_logic/blocs/call_log_bloc/call_log_bloc.dart';

class AppBlocProviders extends StatelessWidget {
  final Widget child;
  final bool lazy;

  const AppBlocProviders({
    Key? key,
    required this.child,
    this.lazy = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(lazy: false, create: (_) => CallLogBloc()),
        BlocProvider(lazy: false, create: (_) => PageRebuildBloc()),
        BlocProvider(lazy: false, create: (_) => ProcessImageRebuildBloc()),
        BlocProvider(lazy: false, create: (_) => TouchSpeedToggleBloc()),
        BlocProvider(lazy: false, create: (_) => FaceDetectorRebuildBloc()),
        BlocProvider(lazy: false, create: (_) => SelectedSubscriptionToggleBloc()),
        BlocProvider(lazy: false, create: (_) => ProcessIrisMovementModelBloc()),
        BlocProvider(lazy: false, create: (_) => IsCameraInitializedToggleBloc()),
        // BlocProvider(create: (_) => SensorsBloc()),
        // BlocProvider(create: (_) => NoiseMeterBloc()),
        // BlocProvider(create: (_) => EyeBlinkingBloc()),
      ],
      child: child,
    );
  }
}
