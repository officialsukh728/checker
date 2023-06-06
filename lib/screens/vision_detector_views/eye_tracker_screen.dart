import 'package:camera/camera.dart';
import 'package:checker/business_logic/blocs/call_log_bloc/call_log_bloc.dart';
import 'package:checker/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:checker/screens/vision_detector_views/face_detector_view.dart';

class EyeTrackerScreen extends StatefulWidget {
  const EyeTrackerScreen({super.key});

  @override
  EyeTrackerScreenState createState() => EyeTrackerScreenState();
}

class EyeTrackerScreenState extends State<EyeTrackerScreen> {
  CameraController? _cameraController;
  int _cameraIndex = -1;

  @override
  void initState() {
    super.initState();
    if (cameras.any(
      (element) =>
          element.lensDirection == CameraLensDirection.front &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
            element.lensDirection == CameraLensDirection.front &&
            element.sensorOrientation == 90),
      );
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == CameraLensDirection.front) {
          _cameraIndex = i;
          break;
        }
      }
    }
    if (_cameraIndex != -1) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final camera = cameras[_cameraIndex];
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    if (mounted) {
      context.read<IsCameraInitializedToggleBloc>().add(true);
      _startFaceDetection();
    }
  }

  Future<void> _startFaceDetection() async {
    _cameraController!.startImageStream((CameraImage image) async {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());

      final camera = cameras[_cameraIndex];
      final imageRotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      if (imageRotation == null) return;

      final inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw);
      if (inputImageFormat == null) return;

      final planeData = image.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      final inputImage =
          InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
      await FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableClassification: true,
        ),
      )
          .processImage(inputImage)
          .then((value) => context.read<ProcessImageRebuildBloc>().add(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _cameraController!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eye Movement Tracking'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          BlocBuilder<IsCameraInitializedToggleBloc, bool>(
            builder: (context, state) {
              return Visibility(
                visible: state,
                child: Transform.scale(
                  scale: scale,
                  child: Center(
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              );
            },
          ),
          // AspectRatio(
          //   aspectRatio: _cameraController!.value.aspectRatio,
          //   child: CameraPreview(_cameraController!),
          // ),
          BlocBuilder<ProcessImageRebuildBloc, List<Face>>(
            builder: (context, state) {
              return CustomPaint(
                painter: EyeTrackingPainter(state),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

class EyeTrackingPainter extends CustomPainter {
  final List<Face> faces;

  EyeTrackingPainter(this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final face in faces) {
      final leftEyeContour = face.contours[FaceContourType.leftEye]?.points;
      final rightEyeContour = face.contours[FaceContourType.rightEye]?.points;

      /// Process iris movements based on the eye contours
      final leftIrisMovement = leftEyeContour != null
          ? calculateIrisMovement(leftEyeContour)
          : const Offset(0, 0);
      final rightIrisMovement = rightEyeContour != null
          ? calculateIrisMovement(rightEyeContour)
          : const Offset(0, 0);

      if (leftEyeContour != null && rightEyeContour != null) {
        canvas.drawLine(leftIrisMovement, rightIrisMovement, paint);
      }
    }
  }

  @override
  bool shouldRepaint(EyeTrackingPainter oldDelegate) => true;
}
