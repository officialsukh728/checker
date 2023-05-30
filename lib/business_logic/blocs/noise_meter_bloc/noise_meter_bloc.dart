import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checker/utils/widgets/helpers.dart';
import 'package:noise_meter/noise_meter.dart';

part 'noise_meter_event.dart';

part 'noise_meter_state.dart';

class NoiseMeterBloc extends Bloc<NoiseMeterEvent, NoiseMeterState> {
  StreamSubscription<NoiseReading>? _noiseSubscription;

  NoiseMeterBloc() : super(NoiseMeterInitial()) {
    on<GetNoiseMeterEvent>(_onGetNoiseMeterEvent);
    on<GetNoiseMeterLoaded>(_onGetNoiseMeterLoaded);
    add(GetNoiseMeterEvent());
  }

  FutureOr<void> _onGetNoiseMeterEvent(
    GetNoiseMeterEvent event,
    Emitter<NoiseMeterState> emit,
  ) async {
    try {
      emit(NoiseMeterLoading());
      _noiseSubscription = NoiseMeter()
          .noiseStream
          .listen((event) {
        add(GetNoiseMeterLoaded(event));
      });
    } catch (e) {
      emit(NoiseMeterError(e.toString()));
      blocLog(msg: e.toString(), bloc: "GetNoiseMeterEvent");
    }
  }

  FutureOr<void> _onGetNoiseMeterLoaded(
    GetNoiseMeterLoaded event,
    Emitter<NoiseMeterState> emit,
  ) async {
    try {
      emit(NoiseMeterLoaded(event.noiseReading));
    } catch (e) {
      emit(NoiseMeterError(e.toString()));
      blocLog(msg: e.toString(), bloc: "GetNoiseMeterLoaded");
    }
  }


  @override
  Future<void> close() async {
    await _noiseSubscription?.cancel();
    return super.close();
  }

}
