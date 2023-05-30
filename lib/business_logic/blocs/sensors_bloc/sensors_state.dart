part of 'sensors_bloc.dart';

abstract class SensorsState extends Equatable {
  const SensorsState();
}

class SensorsInitial extends SensorsState {
  @override
  List<Object> get props => [];
}

class SensorsLoading extends SensorsState {
  @override
  List<Object> get props => [];
}

class SensorsLoaded extends SensorsState {
  final AccelerometerEvent accelerometerEvent;
  final UserAccelerometerEvent userAccelerometerEvent;
  final GyroscopeEvent gyroscopeEvent;
  final MagnetometerEvent magnetometerEvent;

  const SensorsLoaded({
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

class SensorsError extends SensorsState {
  final String error;

  const SensorsError(this.error);
  @override
  List<Object> get props => [error];
}
