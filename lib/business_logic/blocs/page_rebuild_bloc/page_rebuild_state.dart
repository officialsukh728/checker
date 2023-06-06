part of 'page_rebuild_bloc.dart';

abstract class PageRebuildState extends Equatable {
  const PageRebuildState();
}

class PageRebuildInitial extends PageRebuildState {
  @override
  List<Object> get props => [];
}

class PageRebuildLoading extends PageRebuildState {
  @override
  List<Object> get props => [];
}

class PageRebuildLoaded extends PageRebuildState {
  final DeviceDataModel deviceDataModel;

  const PageRebuildLoaded({
    required this.deviceDataModel,
  });

  @override
  List<Object> get props => [
        deviceDataModel,
      ];
}

class PageRebuildError extends PageRebuildState {
  final String error;

  const PageRebuildError(this.error);

  @override
  List<Object> get props => [error];
}
