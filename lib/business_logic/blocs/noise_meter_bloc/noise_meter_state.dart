part of 'noise_meter_bloc.dart';

abstract class NoiseMeterState extends Equatable {
  const NoiseMeterState();
}

class NoiseMeterInitial extends NoiseMeterState {
  @override
  List<Object> get props => [];
}

class NoiseMeterLoading extends NoiseMeterState {
  @override
  List<Object> get props => [];
}

class NoiseMeterLoaded extends NoiseMeterState {
  final NoiseReading noiseReading;

  const NoiseMeterLoaded(this.noiseReading);
  @override
  List<Object> get props => [noiseReading];
}

class NoiseMeterError extends NoiseMeterState {
  final String error;

  const NoiseMeterError(this.error);
  @override
  List<Object> get props => [error];
}
