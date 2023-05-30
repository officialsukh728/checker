import 'dart:io';
import 'dart:ui';

import 'package:call_log/call_log.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:checker/business_logic/services/http_service/response_wrapper.dart';
import 'package:checker/utils/widgets/helpers.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

Rx<int> blinkCount = 0.obs;

abstract class GeneralRepo {
  Future<ResponseWrapper> cameraControllerInitialize();
  Future<ResponseWrapper> getCallLogs();
  Future<ResponseWrapper> startImageStream(
      CameraController controller);
}

class GeneralRepoImp extends GeneralRepo {
  final Vision mlKit = GoogleMlKit.vision;
  final FaceDetector faceDetector =
      GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
    // enableClassification: true,
    enableTracking: true,
  ));

  @override
  Future<ResponseWrapper> getCallLogs() async {
    try {
      final List<CallLogEntry> result = (await CallLog.get()).toList();
      final list=result.where((entry) => entry.callType == CallType.missed).toList();
      return getSuccessResponseWrapper(list);
    } catch (e) {
      functionLog(msg: e.toString(), fun: "cameraControllerInitialize");
      return getFailedResponseWrapper(e);
    }
  }

  @override
  Future<ResponseWrapper> cameraControllerInitialize() async {
    try {
      CameraController? controller;
      final listAvailableCameras = await availableCameras();
      controller = CameraController(
        listAvailableCameras.first,
        ResolutionPreset.max,
      );
      await controller.initialize();
      await startImageStream(controller);
      return getSuccessResponseWrapper(controller);
    } catch (e) {
      functionLog(msg: e.toString(), fun: "cameraControllerInitialize");
      return getFailedResponseWrapper(e);
    }
  }

  @override
  Future<ResponseWrapper> startImageStream(
      CameraController controller) async {
    try {
      await controller.resumePreview();
      await controller.startImageStream((cameraImage) async {
        processCameraFrame(cameraImage);
      });
      return getSuccessResponseWrapper(controller);
    } catch (e) {
      functionLog(msg: e.toString(), fun: "cameraControllerInitialize");
      return getFailedResponseWrapper(e);
    }
  }

  Future<void> processCameraFrame(CameraImage cameraImage) async {
    final inputImage = _convertCameraImageToInputImage(cameraImage);
    printLog("cameraImage==>${cameraImage.toString()}");
    // final faces = await faceDetector.processImage(inputImage);
    // for (Face face in faces) {
    //   if ((face.leftEyeOpenProbability != null &&
    //           face.rightEyeOpenProbability != null) &&
    //       ((face.leftEyeOpenProbability ?? 0) < 0.1 &&
    //           (face.rightEyeOpenProbability ?? 0) < 0.1)) {
    //     blinkCount.value++;
    //   }
    // }
  }

  InputImage _convertCameraImageToInputImage(CameraImage cameraImage) {
    InputImageFormat? inputImageFormat;
    switch (cameraImage.format.group) {
      case ImageFormatGroup.yuv420:
        if (Platform.isAndroid) {
          inputImageFormat = InputImageFormat.yuv_420_888;
        }
        if (Platform.isIOS) {
          inputImageFormat = InputImageFormat.yuv420;
        }
        break;
      case ImageFormatGroup.bgra8888:
        inputImageFormat = InputImageFormat.bgra8888;
        break;
    }

    if (inputImageFormat == null) {
      throw Exception("InputImageFormat is null");
    }

    InputImagePlaneMetadata inputImagePlaneMetadata = InputImagePlaneMetadata(
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
        height: cameraImage.planes[0].height,
        width: cameraImage.planes[0].width);
    InputImageData inputImageData = InputImageData(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        imageRotation: InputImageRotation.rotation0deg,
        inputImageFormat: inputImageFormat,
        planeData: [inputImagePlaneMetadata]);
    return InputImage.fromBytes(
        bytes: cameraImage.planes[0].bytes, inputImageData: inputImageData);
  }
}
