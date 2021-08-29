import 'package:cspc_recog_manage/auth/models/loginUser.dart';
import 'package:cspc_recog_manage/face_recog/face.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

List<CameraDescription> camera;

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final myUser = Provider.of<LoginUserProvier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Manager Version'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${myUser.myUser.myProfileList[0].nickName}"),
            ElevatedButton(
                onPressed: () async {
                  camera = await availableCameras();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FaceDetectorView()));
                },
                child: Text('Face Detect')),
          ],
        ),
      ),
    );
  }
}
