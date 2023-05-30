part of 'call_log_bloc.dart';

abstract class CallLogState extends Equatable {
  const CallLogState();
}

class CallLogInitial extends CallLogState {
  @override
  List<Object> get props => [];
}

class CallLogLoading extends CallLogState {
  @override
  List<Object> get props => [];
}

class CallLogLoaded extends CallLogState {
  final List<CallLogEntry> list;

  const CallLogLoaded(this.list);
  @override
  List<Object> get props => [list];
}

class CallLogError extends CallLogState {
  final String error;

  const CallLogError(this.error);
  @override
  List<Object> get props => [error];
}
