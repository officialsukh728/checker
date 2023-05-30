part of 'eye_blinking_bloc.dart';

abstract class EyeBlinkingState extends Equatable {
  const EyeBlinkingState();
}

class EyeBlinkingInitial extends EyeBlinkingState {
  @override
  List<Object> get props => [];
}

class EyeBlinkingLoading extends EyeBlinkingState {
  @override
  List<Object> get props => [];
}

class EyeBlinkingLoaded extends EyeBlinkingState {
  final CameraController cameraController;

  const EyeBlinkingLoaded(this.cameraController);
  @override
  List<Object> get props => [cameraController];
}

class EyeBlinkingError extends EyeBlinkingState {
  final String error;

  const EyeBlinkingError(this.error);
  @override
  List<Object> get props => [error];
}
