import 'dart:convert';

import 'package:cspc_recog_manage/auth/models/loginUser.dart';
import 'package:cspc_recog_manage/face_recog/face.dart';
import 'package:cspc_recog_manage/face_recog/recog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

import 'package:cspc_recog_manage/style.dart';

late List<CameraDescription> camera;

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final myUser = Provider.of<LoginUserProvier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        title: GradientText(
          'Manage App',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.5, 0.5),
            colors: <Color>[
              const Color(0xff86E3CE),
              const Color(0xffCCABD8),
            ],
            stops: <double>[0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Text("Hello, ${myUser.myUser!.myProfileList[0].nickName}"),
            TextButton(
                onPressed: () async {
                  camera = await availableCameras();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FaceDetectorView()));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Icon(Icons.add, size: 60, color: Colors.white),
                      padding: EdgeInsets.all(10),
                    ),
                    Container(
                       child: Text('Add Face',
                            style: new TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 36.0,
                            )),
                      padding: EdgeInsets.all(10),
                    )
                  ],
                )
            ),
            SizedBox(height:100),
            TextButton(
                onPressed: () async {
                  camera = await availableCameras();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FaceRecogView()));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Icon(Icons.face, size: 60, color: Colors.white),
                      padding: EdgeInsets.all(10),
                    ),
                    Container(
                      child: Text('Check\nIn or Out',
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 36.0,
                          )),
                      padding: EdgeInsets.all(10),
                    )
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}
