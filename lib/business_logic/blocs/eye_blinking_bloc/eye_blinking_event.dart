part of 'eye_blinking_bloc.dart';

abstract class EyeBlinkingEvent extends Equatable {
  const EyeBlinkingEvent();
}

class CameraControllerInitialize extends EyeBlinkingEvent {
  @override
  List<Object?> get props => [];
}
