import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'face_detector_rebuild_event.dart';
part 'face_detector_rebuild_state.dart';

class FaceDetectorRebuildBloc extends Bloc<FaceDetectorRebuildEvent, FaceDetectorRebuildState> {
  FaceDetectorRebuildBloc() : super(FaceDetectorRebuildInitial()) {
    on<FaceDetectorRebuildEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
