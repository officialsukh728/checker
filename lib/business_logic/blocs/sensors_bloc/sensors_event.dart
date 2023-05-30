part of 'sensors_bloc.dart';

abstract class SensorsEvent extends Equatable {
  const SensorsEvent();
}

class GetSensorsData extends SensorsEvent {
  @override
  List<Object?> get props => [];
}

class GetSensorsLoaded extends SensorsEvent {
  final AccelerometerEvent accelerometerEvent;
  final UserAccelerometerEvent userAccelerometerEvent;
  final GyroscopeEvent gyroscopeEvent;
  final MagnetometerEvent magnetometerEvent;

  const GetSensorsLoaded({
   required this.accelerometerEvent,
   required this.userAccelerometerEvent,
   required this.gyroscopeEvent,
   required this.magnetometerEvent,
  });

  @override
  List<Object?> get props => [
        accelerometerEvent,
        userAccelerometerEvent,
        gyroscopeEvent,
        magnetometerEvent,
      ];
}
