part of 'face_detector_rebuild_bloc.dart';

abstract class FaceDetectorRebuildEvent extends Equatable {
  const FaceDetectorRebuildEvent();
}
class SetGetFaceDetectorRebuildEvent extends FaceDetectorRebuildEvent{
  @override
  List<Object?> get props => [];
}