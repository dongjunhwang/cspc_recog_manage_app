import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mainPage.dart';
import 'package:cspc_recog_manage/style.dart';
import 'package:cspc_recog_manage/urls.dart';

late Map<String, dynamic> recogJson;


// A screen that allows users to take a picture using a given camera.
class TakeDetectScreen extends StatefulWidget {
  final String title;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;
  final Function() turnOffDetect;
  final Function() turnOnDetect;

  final int faceCount;
  TakeDetectScreen(
      {Key? key,
      required this.title,
      required this.customPaint,
      required this.onImage,
      required this.turnOffDetect,
      required this.turnOnDetect,
      required this.faceCount,
      this.initialDirection = CameraLensDirection.front})
      : super(key: key);

  @override
  TakeDetectScreenState createState() => TakeDetectScreenState();
}

class TakeDetectScreenState extends State<TakeDetectScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  CustomPaint? customPaint;
  Timer? _detectTimer;
  late Timer _everySecond;

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
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    _everySecond = Timer.periodic(Duration(seconds: 2), (Timer t) {
      setState(() {
        if (widget.faceCount >= 1) {
          // 카메라뷰로 돌아오면 안찍히는 버그 있음....
          if (_detectTimer == null) {
            _detectTimer = Timer(
              const Duration(seconds: 4),
              () => _autoTakePicture(context),
            );
          }
        }
      });
    });
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
      appBar: AppBar(title: GradientText(
            'Check In or Out',
            gradient: LinearGradient(colors: [
              Color(0xffFA897B),
              Color(0xffCCABD8),
            ]),
          ),
          centerTitle: true,
          flexibleSpace: new Container(
            color: Color(0xffFFDD94),
          )
      ),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _controller.startImageStream(_processCameraImage);
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
    );
  }

  Future _autoTakePicture(context) async {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    if (widget.faceCount >= 1) {
      await _controller.stopImageStream();
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      widget.turnOffDetect();
      // Attempt to take a picture and get the file `image`
      // where it was saved.
      final image = await _controller.takePicture();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.only(left: width * 0.036),
            ),
            Text("Loading..."),
          ],
        ),
        duration: Duration(seconds: 10),
      ));
      await _postRequest(image);
      _detectTimer = null;
      widget.turnOnDetect();
      /*
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
        return TakeDetectScreen(
          title: 'Face Detector',
          customPaint: customPaint,
          onImage: widget.onImage,
          faceCount: widget.faceCount,
          initialDirection: CameraLensDirection.back,
          turnOffDetect: widget.turnOffDetect,
          turnOnDetect: widget.turnOnDetect,);
      }));
      */
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

  _postRequest(XFile image) async {
    File imageFile = File(image.path);
    List<int> imageBytes = imageFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    //teprint(base64Image);
    Uri url;

    //For Divide recog and add
    url = Uri.parse(UrlPrefix.urls+"face/detect/");

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
                  //"image": "$base64Image",
                }
              ],
            ),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => http.Response('error', 500),
          );
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      recogJson = await jsonDecode(response.body);
      if (recogJson["response"] == 1) {
        if (recogJson["isOnline"] == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Hello, " + recogJson["username"]),
              backgroundColor: Colors.lightGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Bye, " + recogJson["username"]),
              backgroundColor: Colors.lightGreen,
            ),
          );
        }
      } else if (recogJson["response"] == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Too Early to Exit",
                style: TextStyle(
                  color: Colors.white,
                )),
            backgroundColor: Colors.lightBlueAccent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please Add User First",
                style: TextStyle(
                  color: Colors.white,
                )),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException catch (e) {
      print('$e');
    } on Error catch (e) {
      print('Error: $e');
    }
  }
}
