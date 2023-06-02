import 'dart:convert';

DeviceDataModel deviceDataModelFromStringJson(String str) =>
    DeviceDataModel.fromJson(json.decode(str));

String deviceDataModelToJsonString(DeviceDataModel data) => json.encode(data.toJson());

class DeviceDataModel {
  String? deviceId;
  String? unlockCount;
  int? fallingCount;
  int? eyeBlinkingCount;

  DeviceDataModel({
    this.deviceId,
    this.unlockCount,
    this.fallingCount,
    this.eyeBlinkingCount,
  });

  factory DeviceDataModel.fromJson(Map<String, dynamic> json) =>
      DeviceDataModel(
        deviceId: json["deviceId"],
        unlockCount: json["unlockCount"],
        fallingCount: json["fallingCount"],
        eyeBlinkingCount: json["eyeBlinkingCount"],
      );

  Map<String, dynamic> toJson() => {
        "deviceId": deviceId,
        "unlockCount": unlockCount,
        "fallingCount": fallingCount,
        "eyeBlinkingCount": eyeBlinkingCount,
      };
}
