import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'painters/face_detector_painter.dart';

import 'package:cspc_recog_manage/face_recog/camera_recog.dart';

class FaceRecogView extends StatefulWidget {
  @override
  _FaceRecogViewState createState() => _FaceRecogViewState();
}

class _FaceRecogViewState extends State<FaceRecogView> {
  FaceDetector faceDetector =
  GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
    mode: FaceDetectorMode.fast, // default
  ));
  bool isBusy = false;
  CustomPaint? customPaint;
  bool _isPreview = false;
  int _faceCount = 0;

  int get getFaceCount => _faceCount;

  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TakeDetectScreen(
      title: 'Face Detector',
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      faceCount: getFaceCount,
      initialDirection: CameraLensDirection.back,
      turnOffDetect: turnOffDetection,
      turnOnDetect: turnOnDetection,
    );
  }

  turnOffDetection() {
    _isPreview = false;
  }

  turnOnDetection() {
    _isPreview = true;
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    if (!_isPreview) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    print('Found ${faces.length} faces');
    _faceCount = faces.length;
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.inputImageData!.size,
        inputImage.inputImageData!.imageRotation,
      );
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}