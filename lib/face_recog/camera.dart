import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mainPage.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final String title;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;
  final Function() turnOffDetect;
  final Function() turnOnDetect;

  final int faceCount;
  TakePictureScreen(
      {Key? key,
        required this.title,
        required this.customPaint,
        required this.onImage,
        required this.turnOffDetect,
        required this.turnOnDetect,
        required this.faceCount,
        this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  CustomPaint? customPaint;
  Timer? _detectTimer;

  @override
  void initState() {
    widget.turnOnDetect();
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      camera.first,
      // Define the resolution to use.
      ResolutionPreset.ultraHigh,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _controller.startImageStream(_processCameraImage);

            if (widget.faceCount >= 1) {
              // 카메라뷰로 돌아오면 안찍히는 버그 있음....
              if (_detectTimer == null) {
                _detectTimer = Timer(
                  const Duration(seconds: 2),
                      () => _autoTakePicture(context),
                );
              }
            }
            // If the Future is complete, display the preview.

            return Container(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CameraPreview(_controller),
                  if (widget.customPaint != null) widget.customPaint!,
                ],
              ),
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            await _controller.stopImageStream();
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            widget.turnOffDetect();
            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();
            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
          widget.turnOnDetect(); // if back to preview Page turn on Detection
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Future _autoTakePicture(context) async {
    if (widget.faceCount >= 1) {
      await _controller.stopImageStream();
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      widget.turnOffDetect();
      // Attempt to take a picture and get the file `image`
      // where it was saved.
      final image = await _controller.takePicture();
      // If the picture was taken, display it on a new screen.
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            // Pass the automatically generated path to
            // the DisplayPictureScreen widget.
            imagePath: image.path,
          ),
        ),
      );
      _detectTimer = null;
      widget.turnOnDetect();
    }
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());

    final maincamera = camera.first;
    final imageRotation =
        InputImageRotationMethods.fromRawValue(maincamera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

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

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);

  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  bool isDetect = false;
  String name = 'unknown';
  final textController = TextEditingController();

  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.file(
            File(widget.imagePath),
            fit: BoxFit.fill,
          ),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'name',
              fillColor: Colors.white,
              filled: true,
            ),
            controller: textController,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          return _postRequest();
        },
        label: Text('check'),
      ),
    );
  }

  _postRequest() async {
    name = textController.text;

    File imageFile = File(widget.imagePath);
    List<int> imageBytes = imageFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    //teprint(base64Image);
    Uri url = Uri.parse('http://cocopam.hopto.org:8081/face/add');
    try {
      http.Response response = await http
          .post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }, // this header is essential to send json data
        body: jsonEncode(
          [
            {
              "image": "$base64Image",
              "username": "$name",
            }
          ],
        ),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('error', 500),
      );

      print(response.statusCode);
    } on TimeoutException catch (e) {
      print('$e');
    } on Error catch (e) {
      print('Error: $e');
    }
    Navigator.of(context).pop();
  }
}