part of 'call_log_bloc.dart';

abstract class CallLogEvent extends Equatable {
  const CallLogEvent();
}

class GetCallLogEvent extends CallLogEvent {
  @override
  List<Object?> get props => [];
}
