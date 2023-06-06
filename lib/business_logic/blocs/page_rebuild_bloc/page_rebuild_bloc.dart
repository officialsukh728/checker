import 'dart:async';
import 'dart:convert';

import 'package:call_log/call_log.dart';
import 'package:checker/models/device_data_model.dart';
import 'package:checker/screens/dashboard/dashboard.dart';
import 'package:checker/utils/widgets/helpers.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'page_rebuild_event.dart';

part 'page_rebuild_state.dart';

class PageRebuildBloc extends Bloc<PageRebuildEvent, PageRebuildState> {
  StreamSubscription<DatabaseEvent>? streamSubscription;

  PageRebuildBloc() : super(PageRebuildInitial()) {
    on<SetPageRebuildLoaded>(_onSetPageRebuildLoaded);
    on<GetDataPageRebuildEvent>(_onGetDataPageRebuildEvent);
  }

  Future<FutureOr<void>> _onGetDataPageRebuildEvent(
    GetDataPageRebuildEvent event,
    Emitter<PageRebuildState> emit,
  ) async {
    try {
      final deviceId = await PlatformDeviceId.getDeviceId ?? "";
      database.child(deviceId).once().then((databaseEvent) =>
          add(SetPageRebuildLoaded(databaseEvent: databaseEvent)));
    } catch (e) {
      blocLog(msg: e.toString(), bloc: "_onGetDataPageRebuildEvent");
      emit(PageRebuildError(e.toString()));
    }
  }

  Future<FutureOr<void>> _onSetPageRebuildLoaded(
    SetPageRebuildLoaded event,
    Emitter<PageRebuildState> emit,
  ) async {
    try {
      final response = event.databaseEvent.snapshot.value;
      final model =
          DeviceDataModel.fromJson(jsonDecode(jsonEncode(response)) ?? {});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if(model.swipeRecords!=null) {
        await prefs.setStringList('swipeRecords',model.swipeRecords!);
      }
      if(model.touchRecords!=null) {
        await prefs.setInt('touchRecords',model.touchRecords!);
      }
      if(model.eyeCountRecords!=null) {
        await prefs.setInt('EyeCountRecords',model.eyeCountRecords!);
      }
      if(model.touchSpeed!=null) {
        await prefs.setStringList('touchSpeed',model.touchSpeed!);
      }
        final List<CallLogEntry> result = (await CallLog.get()).toList();
        final list=result.where((entry) => entry.callType == CallType.missed).toList();
        final dropCalls= prefs.getInt('dropCalls')??0;
        if(dropCalls.isGreaterThan(list.length)) {
          await prefs.setInt('dropCalls',list.length);
        }
      emit(PageRebuildLoading());
      emit(PageRebuildLoaded(deviceDataModel: model));
    } catch (e) {
      blocLog(msg: e.toString(), bloc: "_onSetPageRebuildLoaded");
      emit(PageRebuildError(e.toString()));
    }
  }
}
