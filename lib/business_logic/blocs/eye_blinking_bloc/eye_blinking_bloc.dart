import 'dart:async';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checker/business_logic/services/http_service/response_wrapper.dart';
import 'package:checker/utils/all_getter.dart';
import 'package:checker/utils/widgets/helpers.dart';

part 'eye_blinking_event.dart';
part 'eye_blinking_state.dart';

class EyeBlinkingBloc extends Bloc<EyeBlinkingEvent, EyeBlinkingState> {
  EyeBlinkingBloc() : super(EyeBlinkingInitial()) {
    on<CameraControllerInitialize>(_onCameraControllerInitialize);
    // add(CameraControllerInitialize());
  }

  FutureOr<void> _onCameraControllerInitialize(CameraControllerInitialize event, Emitter<EyeBlinkingState> emit,)async {
    try{
      emit(EyeBlinkingLoading());
      final response=await getGeneralRepo.cameraControllerInitialize();
      if(response.status==RepoResponseStatus.success){
        emit(EyeBlinkingLoaded(response.response));
      }else{
        emit(EyeBlinkingError(response.message??"Some Went Wrong"));
      }
    }catch(e){
      emit(EyeBlinkingError(e.toString()));
      blocLog(msg: e.toString(), bloc: "CameraControllerInitialize");
    }
  }
}
