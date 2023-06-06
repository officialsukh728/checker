import 'dart:convert';

DeviceDataModel deviceDataModelFromStringJson(String str) =>
    DeviceDataModel.fromJson(json.decode(str));

String deviceDataModelToJsonString(DeviceDataModel data) => json.encode(data.toJson());

class DeviceDataModel {
  String? deviceId;
  String? unlockCount;
  int? fallingCount;
  int? eyeBlinkingCount;
  int? audioData;
  bool? isRecording;
  bool? isFalling;
  List<String>? touchSpeed;
  List<String>? swipeRecords;
  int? touchRecords;
  int? eyeCountRecords;
  int? dropCalls;

  DeviceDataModel({
    this.deviceId,
    this.dropCalls,
    this.isRecording,
    this.audioData,
    this.unlockCount,
    this.fallingCount,
    this.isFalling,
    this.eyeBlinkingCount,
    this.touchSpeed,
    this.swipeRecords,
    this.touchRecords,
    this.eyeCountRecords,
      });

  factory DeviceDataModel.fromJson(Map<dynamic, dynamic> json) =>
      DeviceDataModel(
        deviceId: json["deviceId"],
        dropCalls: json["dropCalls"],
        audioData: json["audioData"],
        unlockCount: json["unlockCount"],
        fallingCount: json["fallingCount"],
        isRecording: json["isRecording"],
        isFalling: json["isFalling"],
        eyeBlinkingCount: json["eyeBlinkingCount"],
        touchSpeed: json["touchSpeed"],
        swipeRecords: json["swipeRecords"],
        touchRecords: json["touchRecords"],
        eyeCountRecords: json["eyeCountRecords"],
      );

  Map<String, dynamic> toJson() => {
        "deviceId": deviceId,
        "dropCalls": dropCalls,
        "audioData": audioData,
        "unlockCount": unlockCount,
        "fallingCount": fallingCount,
        "isRecording": isRecording,
        "isFalling": isFalling,
        "eyeBlinkingCount": eyeBlinkingCount,
        "touchSpeed": touchSpeed,
        "swipeRecords": swipeRecords,
        "touchRecords": touchRecords,
        "eyeCountRecords": eyeCountRecords,
      };
}
