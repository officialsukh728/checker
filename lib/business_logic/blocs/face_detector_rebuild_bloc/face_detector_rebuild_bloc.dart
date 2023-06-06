import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'face_detector_rebuild_event.dart';

part 'face_detector_rebuild_state.dart';

class FaceDetectorRebuildBloc
    extends Bloc<FaceDetectorRebuildEvent, FaceDetectorRebuildState> {
  FaceDetectorRebuildBloc() : super(FaceDetectorRebuildInitial()) {
    on<SetGetFaceDetectorRebuildEvent>(_onSetGetFaceDetectorRebuildEvent);
  }

  FutureOr<void> _onSetGetFaceDetectorRebuildEvent(
    SetGetFaceDetectorRebuildEvent event,
    Emitter<FaceDetectorRebuildState> emit,
  ) {
    emit(FaceDetectorRebuildLoading());
    emit(FaceDetectorRebuildLoaded());
  }
}
