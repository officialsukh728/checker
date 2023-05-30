import 'package:get/get.dart';
import 'package:checker/utils/widgets/helpers.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class HiveConst {
  static const String opertionCount = 'opertionCount';
  static const String fallCountList = 'fallCountList';
  static const String fallCountPoint = 'fallCountPoint';
}

abstract class LocalStorage {
  Future<void> clearAllBox();
  Future<void> saveFallCount(int count);
  Future<int> getFallCount();
  Future<void> setOpertionCount(int count);
  Future<int> getOpertionCount();
  Future<void> saveFallCountList(String value);
  Future<List<String>> getFallCountList();
}

class HiveStorageImp extends LocalStorage {
  final Box opertionCount;
  final Box fallCountList;
  final Box fallCountPoint;

  HiveStorageImp({
    required this.opertionCount,
    required this.fallCountList,
    required this.fallCountPoint,
  });

  static Future<LocalStorage> init() async => HiveStorageImp(
    fallCountPoint: await Hive.openBox(HiveConst.fallCountPoint),
    opertionCount: await Hive.openBox(HiveConst.opertionCount),
    fallCountList: await Hive.openBox(HiveConst.fallCountList),
      );

  @override
  Future<void> saveFallCount(int count) async {
    int opCount = await getOpertionCount();
    if (count.isGreaterThan(10) && opCount.isEqual(10)) {
      count = count - 9;
      await setOpertionCount(1);
    } else {
      await setOpertionCount(opCount++);
    }
    printLog("SaveCount==>$count");
    await fallCountPoint.put(HiveConst.fallCountPoint, count);
  }

  @override
  Future<int> getFallCount() async {
    return fallCountPoint.get(HiveConst.fallCountPoint) ?? 0;
  }

  @override
  Future<void> setOpertionCount(int count) async {
    await opertionCount.put(HiveConst.opertionCount, count);
  }

  @override
  Future<int> getOpertionCount() async {
    return opertionCount.get(HiveConst.opertionCount,) ?? 0;
  }

  @override
  Future<void> saveFallCountList(String value) async {
     await fallCountList.put(HiveConst.fallCountList, value);
  }

  @override
  Future<List<String>> getFallCountList() async {
    return (fallCountList.get(HiveConst.fallCountList)) ?? <String>[];
  }

  @override
  Future<void> clearAllBox() async {
    await opertionCount.clear();
    await fallCountList.clear();
    await fallCountPoint.clear();
  }
}
