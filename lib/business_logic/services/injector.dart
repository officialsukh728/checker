import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:checker/business_logic/repos/device_repo.dart';
import 'package:checker/business_logic/services/http_service/http_service.dart';
import 'package:checker/business_logic/services/local_storage/local_storage.dart';


typedef AppRunner = FutureOr<void> Function();

class AppInjector {
  static Future<void> init({
    required AppRunner appRunner,
  }) async {
    await _initDependencies();
    appRunner();
  }

  static Future<void> _initDependencies() async {
    await GetIt.I.allReady();
    final storage = await HiveStorageImp.init();
    GetIt.I.registerLazySingleton<LocalStorage>(() => storage);
    GetIt.I.registerSingleton<HttpService>(HttpService());
    GetIt.I.registerSingleton<GeneralRepo>(GeneralRepoImp());
    GetIt.I.registerSingleton<GlobalKey<NavigatorState>>(GlobalKey<NavigatorState>());
  }
}

LocalStorage get getLocalStorage => GetIt.I.get<LocalStorage>();
