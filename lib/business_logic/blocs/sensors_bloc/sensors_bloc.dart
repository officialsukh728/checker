import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checker/utils/widgets/helpers.dart';
import 'package:sensors_plus/sensors_plus.dart';

part 'sensors_event.dart';

part 'sensors_state.dart';

class SensorsBloc extends Bloc<SensorsEvent, SensorsState> {
  StreamSubscription<AccelerometerEvent>? accelerometerStreamController;
  StreamSubscription<UserAccelerometerEvent>? userAccelerometerStreamController;
  StreamSubscription<GyroscopeEvent>? gyroscopeEventStreamController;
  StreamSubscription<MagnetometerEvent>? magnetometerEventStreamController;

  SensorsBloc() : super(SensorsInitial()) {
    on<GetSensorsData>(_onGetSensorsData);
    on<GetSensorsLoaded>(_onGetSensorsLoaded);
    add(GetSensorsData());
  }

  FutureOr<void> _onGetSensorsData(
    GetSensorsData event,
    Emitter<SensorsState> emit,
  ) async {
    try {
      emit(SensorsLoading());
      accelerometerStreamController =
          accelerometerEvents.listen((AccelerometerEvent accelerometerEvent) {
        printLog("accelerometerEvent()=> $accelerometerEvent");
        userAccelerometerStreamController = userAccelerometerEvents
            .listen((UserAccelerometerEvent userAccelerometerEvent) {
          printLog("userAccelerometerEvent()=> $userAccelerometerEvent");
          gyroscopeEventStreamController =
              gyroscopeEvents.listen((GyroscopeEvent gyroscopeEvent) {
            printLog("gyroscopeEvent()=> $gyroscopeEvent");
            magnetometerEventStreamController = magnetometerEvents
                .listen((MagnetometerEvent magnetometerEvent) {
              printLog("magnetometerEvent()=> $magnetometerEvent");
              add(GetSensorsLoaded(
                accelerometerEvent: accelerometerEvent,
                userAccelerometerEvent: userAccelerometerEvent,
                gyroscopeEvent: gyroscopeEvent,
                magnetometerEvent: magnetometerEvent,
              ));
            });
          });
        });
      });
    } catch (e) {
      emit(SensorsError(e.toString()));
      blocLog(msg: e.toString(), bloc: "GetSensorsData");
    }
  }

  FutureOr<void> _onGetSensorsLoaded(
    GetSensorsLoaded event,
    Emitter<SensorsState> emit,
  ) {
    try {
      emit(SensorsLoaded(
        accelerometerEvent: event.accelerometerEvent,
        userAccelerometerEvent: event.userAccelerometerEvent,
        gyroscopeEvent: event.gyroscopeEvent,
        magnetometerEvent: event.magnetometerEvent,
      ));
    } catch (e) {
      emit(SensorsError(e.toString()));
      blocLog(msg: e.toString(), bloc: "GetSensorsData");
    }
  }

  @override
  Future<void> close() async {
    await accelerometerStreamController?.cancel();
    await userAccelerometerStreamController?.cancel();
    await gyroscopeEventStreamController?.cancel();
    await magnetometerEventStreamController?.cancel();
    return super.close();
  }
}
