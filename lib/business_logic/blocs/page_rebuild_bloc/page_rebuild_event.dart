part of 'page_rebuild_bloc.dart';

abstract class PageRebuildEvent extends Equatable {
  const PageRebuildEvent();
}
class SetPageRebuildLoaded extends PageRebuildEvent {
  final DatabaseEvent databaseEvent ;

  const SetPageRebuildLoaded({
    required this.databaseEvent,
  });

  @override
  List<Object> get props => [databaseEvent];
}

class GetDataPageRebuildEvent extends PageRebuildEvent{
  @override
  List<Object?> get props => [];
}