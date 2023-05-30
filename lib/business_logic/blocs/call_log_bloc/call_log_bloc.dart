import 'dart:async';
import 'dart:ui';

import 'package:call_log/call_log.dart';
import 'package:checker/screens/vision_detector_views/face_detector_view.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checker/business_logic/services/http_service/response_wrapper.dart';
import 'package:checker/utils/all_getter.dart';
import 'package:checker/utils/widgets/helpers.dart';

part 'call_log_event.dart';

part 'call_log_state.dart';

class CallLogBloc extends Bloc<CallLogEvent, CallLogState> {
  CallLogBloc() : super(CallLogInitial()) {
    on<GetCallLogEvent>(_onGetCallLogEvent);
    add(GetCallLogEvent());
  }

  FutureOr<void> _onGetCallLogEvent(
    GetCallLogEvent event,
    Emitter<CallLogState> emit,
  ) async {
    try {
      emit(CallLogLoading());
      final response = await getGeneralRepo.getCallLogs();
      if (response.status == RepoResponseStatus.success) {
        emit(CallLogLoaded(response.response));
      } else {
        emit(CallLogError(response.message ?? someWentWrong));
      }
    } catch (e) {
      emit(CallLogError(e.toString()));
      blocLog(msg: e.toString(), bloc: "GetCallLogEvent");
    }
  }
}

class SelectedSubscriptionToggleBloc extends Bloc<int, int> {
  SelectedSubscriptionToggleBloc() : super(0) {
    on<int>((event, emit) {
      emit(event);
    });
  }
}

class ProcessIrisMovementModelBloc
    extends Bloc<ProcessIrisMovementModel, ProcessIrisMovementModel> {
  ProcessIrisMovementModelBloc()
      : super(ProcessIrisMovementModel(
            leftIrisMovement: const Offset(0, 0),
            rightIrisMovement: const Offset(0, 0))) {
    on<ProcessIrisMovementModel>((event, emit) {
      emit(event);
    });
  }
}
