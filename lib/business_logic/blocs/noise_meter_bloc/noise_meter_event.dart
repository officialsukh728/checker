part of 'noise_meter_bloc.dart';

abstract class NoiseMeterEvent extends Equatable {
  const NoiseMeterEvent();
}

class GetNoiseMeterEvent extends NoiseMeterEvent {
  @override
  List<Object?> get props => [];
}

class GetNoiseMeterErrorEvent extends NoiseMeterEvent {
  @override
  List<Object?> get props => [];
}

class GetNoiseMeterLoaded extends NoiseMeterEvent {
  final NoiseReading noiseReading;

  const GetNoiseMeterLoaded(this.noiseReading);

  @override
  List<Object> get props => [noiseReading];
}
