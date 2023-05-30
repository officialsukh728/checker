import 'package:get_it/get_it.dart';
import 'package:checker/business_logic/repos/device_repo.dart';

GeneralRepo get getGeneralRepo => GetIt.I.get<GeneralRepo>();
String get someWentWrong => "Something Went Wrong";