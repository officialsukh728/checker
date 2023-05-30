import 'package:camera/camera.dart';
import 'package:checker/business_logic/blocs/call_log_bloc/call_log_bloc.dart';
import 'package:checker/screens/dashboard/dashboard.dart';
import 'package:checker/utils/widgets/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:checker/main.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';

// Store the previous eye contour positions
List<Offset>? previousLeftEyeContour;
List<Offset>? previousRightEyeContour;

// SharedPreferences key
const String irisMovementKey = 'irisMovement';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.faces, this.absoluteImageSize, this.rotation);

  final List<Face> faces;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;

    for (final Face face in faces) {
      canvas.drawRect(
        Rect.fromLTRB(
          translateX(face.boundingBox.left, rotation, size, absoluteImageSize),
          translateY(face.boundingBox.top, rotation, size, absoluteImageSize),
          translateX(face.boundingBox.right, rotation, size, absoluteImageSize),
          translateY(
              face.boundingBox.bottom, rotation, size, absoluteImageSize),
        ),
        paint,
      );

      void paintContour(FaceContourType type) {
        final faceContour = face.contours[type];
        if (faceContour?.points != null) {
          for (final Point point in faceContour!.points) {
            canvas.drawCircle(
                Offset(
                  translateX(
                      point.x.toDouble(), rotation, size, absoluteImageSize),
                  translateY(
                      point.y.toDouble(), rotation, size, absoluteImageSize),
                ),
                1,
                paint);
          }
        }
      }

      paintContour(FaceContourType.face);
      paintContour(FaceContourType.leftEyebrowTop);
      paintContour(FaceContourType.leftEyebrowBottom);
      paintContour(FaceContourType.rightEyebrowTop);
      paintContour(FaceContourType.rightEyebrowBottom);
      paintContour(FaceContourType.leftEye);
      paintContour(FaceContourType.rightEye);
      paintContour(FaceContourType.upperLipTop);
      paintContour(FaceContourType.upperLipBottom);
      paintContour(FaceContourType.lowerLipTop);
      paintContour(FaceContourType.lowerLipBottom);
      paintContour(FaceContourType.noseBridge);
      paintContour(FaceContourType.noseBottom);
      paintContour(FaceContourType.leftCheek);
      paintContour(FaceContourType.rightCheek);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}

double translateX(
  double x,
  InputImageRotation rotation,
  Size size,
  Size absoluteImageSize,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          size.width /
          (Platform.isIOS ? absoluteImageSize.width : absoluteImageSize.height);
    case InputImageRotation.rotation270deg:
      return size.width -
          x *
              size.width /
              (Platform.isIOS
                  ? absoluteImageSize.width
                  : absoluteImageSize.height);
    default:
      return x * size.width / absoluteImageSize.width;
  }
}

double translateY(
    double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          size.height /
          (Platform.isIOS ? absoluteImageSize.height : absoluteImageSize.width);
    default:
      return y * size.height / absoluteImageSize.height;
  }
}

class CameraView extends StatefulWidget {
  const CameraView({
    Key? key,
    required this.title,
    required this.customPaint,
    this.text,
    required this.onImage,
    this.initialDirection = CameraLensDirection.front,
  }) : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  int _cameraIndex = -1;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;

  @override
  void initState() {
    super.initState();
    if (cameras.any(
      (element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
            element.lensDirection == widget.initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == widget.initialDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }

    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _liveFeedBody(),
    );
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(_controller!),
            ),
          ),
        ],
      ),
    );
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _processCameraImage(CameraImage image) async {
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

    widget.onImage(inputImage);
  }
}

class FaceDetectorView extends StatefulWidget {
  final bool rebuildScreen;

  const FaceDetectorView({super.key, this.rebuildScreen = false});

  @override
  State<FaceDetectorView> createState() => FaceDetectorViewState();
}

Widget getFaceDetectorView() => SizedBox(
      height: 1,
      width: 1,
      child: (showAllWidgetPermission)
          ? const FaceDetectorView()
          : const SizedBox.shrink(),
    );

class FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  int _conut = 0;

  @override
  void initState() {
    _conut = eyeBlinkingCount.value;
    super.initState();
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Face Detector Count : ${eyeBlinkingCount.value}',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    final faces = await _faceDetector.processImage(inputImage);
    if (mounted) {
      final count = _conut + countEyeBlinks(faces, context);
      await setEyeBlinkingCountCount();
      if (eyeBlinkingCount.value != count) {
        printLog('countEyeBlinks+++==> $count');
      }
      eyeBlinkingCount.value = count;
      if (mounted) {
        setState(() {
          _text = '';
          _conut = count;
        });
      }
    }
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      _customPaint = CustomPaint(
          painter: FaceDetectorPainter(faces, inputImage.inputImageData!.size,
              inputImage.inputImageData!.imageRotation));
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

int countEyeBlinks(List<Face> faces, BuildContext context) {
  int eyeBlinkCount = 0;
  processIrisMovements(faces, context);
  for (Face face in faces) {
    if (face.leftEyeOpenProbability != null &&
        face.rightEyeOpenProbability != null) {
      if ((face.leftEyeOpenProbability ?? 0) < 0.1 &&
          (face.rightEyeOpenProbability ?? 0) < 0.1) {
        eyeBlinkCount++;
      }
    }
  }
  return eyeBlinkCount;
}

Future<void> processImage({ImageSource source = ImageSource.camera}) async {
  final imageFile = await getImageFromCameraGallery(source);
  if (imageFile != null) {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    try {
      final recognisedText = await textRecognizer.processImage(inputImage);
      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            printLog("element.text <<<<<<<==>>>>>>> ${element.text}");
          }
        }
      }
    } catch (e) {
      printLog('Error processing image: $e');
    } finally {
      textRecognizer.close();
    }
  }
}

Future<File?> getImageFromCameraGallery(ImageSource source) async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: source);
  if (pickedImage != null) {
    return File(pickedImage.path);
  } else {
    return null;
  }
}

ProcessIrisMovementModel? processIrisMovements(
    List<Face> faces, BuildContext context) {
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

    /// Perform further processing or display the iris movements
    printLog('Left Iris Movement: $leftIrisMovement');
    printLog('Right Iris Movement: $rightIrisMovement');
    final processIrisMovementModel = ProcessIrisMovementModel(
      leftIrisMovement: leftIrisMovement,
      rightIrisMovement: rightIrisMovement,
    );
    final previous = context.read<ProcessIrisMovementModelBloc>().state;
    if ((previous.leftIrisMovement.dx !=
            processIrisMovementModel.leftIrisMovement.dx ||
        previous.rightIrisMovement.dx !=
            processIrisMovementModel.rightIrisMovement.dx)) {
      context
          .read<ProcessIrisMovementModelBloc>()
          .add(processIrisMovementModel);
    }
  }
  return null;
}

Offset calculateIrisMovement(List<Point<int>> eyeContour) {
  // Calculate the iris movement based on the eye contour points
  // You can implement your logic here based on the specific requirements

  // For example, you can calculate the average movement in the X and Y directions
  double averageX = 0.0;
  double averageY = 0.0;

  for (final point in eyeContour) {
    averageX += point.x;
    averageY += point.y;
  }

  averageX /= eyeContour.length;
  averageY /= eyeContour.length;

  return Offset(averageX, averageY);
}

class ProcessIrisMovementModel {
  final Offset leftIrisMovement;
  final Offset rightIrisMovement;

  ProcessIrisMovementModel({
    required this.leftIrisMovement,
    required this.rightIrisMovement,
  });
}
