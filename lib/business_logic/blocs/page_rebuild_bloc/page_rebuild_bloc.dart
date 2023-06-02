import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'page_rebuild_event.dart';
part 'page_rebuild_state.dart';

class PageRebuildBloc extends Bloc<PageRebuildEvent, PageRebuildState> {
  PageRebuildBloc() : super(PageRebuildInitial()) {
    on<PageRebuildEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
