import 'package:cspc_recog_manage/auth/login.dart';
import 'package:cspc_recog_manage/auth/models/loginUser.dart';
import 'package:cspc_recog_manage/face_recog/mainPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) => LoginUserProvier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginPage());
  }
}
