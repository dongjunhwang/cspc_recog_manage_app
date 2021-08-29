import 'package:cspc_recog_manage/face_recog/mainPage.dart';
import 'package:cspc_recog_manage/main.dart';
import 'package:cspc_recog_manage/auth/models/registerUser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../urls.dart';

import 'package:flutter/services.dart';
import 'package:cspc_recog_manage/auth/login.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  RegisterUser newMemb;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white12, Colors.blue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  headerSection(),
                  textSection(),
                  buttonSection(),
                ],
              ),
      ),
    );
  }

  signUp(String id, pass) async {
    final response = await http.post(
      Uri.parse(UrlPrefix.urls + "users/auth/register/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "username": id,
        "password": pass,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null) {
        newMemb = RegisterUser.fromJson(data);

        print(newMemb.user.userId);
        print(newMemb.user.userName);
        print(newMemb.token);

        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      /*
      print("hey");
      final data = json.decode(response.body);
      if (data != null) {
        newMemb = RegisterUser.fromJson(data);
        print("heyhey");
        print(newMemb.user.userName);
      }
      print("heyheyhey");
      */
      print(response.statusCode);
    }
  }

  Container buttonSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
      ),
      margin: EdgeInsets.only(top: 25.0),
      child: Column(children: <Widget>[
        ElevatedButton(
          child: Text(
            "Sign Up",
            style: TextStyle(color: Colors.white70, fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            primary: Colors.indigoAccent,
            onPrimary: Colors.black,
            minimumSize: Size(MediaQuery.of(context).size.width, 40),
          ),
          onPressed: () {
            setState(() {
              _isLoading = true;
            });
            signUp(idController.text, passwordController.text);
          },
        ),
        SizedBox(height: 20.0),
        TextButton(
          child: Text(
            "Do you have an account? Sign In",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            setState(() {
              _isLoading = true;
            });
            //Navigator.pop(context);

            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage()),
                (Route<dynamic> route) => false);
          },
        )
      ]),
    );
  }

  final TextEditingController idController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: idController,
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black12),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.black12),
              hintText: "ID",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12)),
              hintStyle: TextStyle(color: Colors.black12),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.black,
            obscureText: true,
            style: TextStyle(color: Colors.black12),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.black12),
              hintText: "Password",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12)),
              hintStyle: TextStyle(color: Colors.black12),
            ),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("Sign up",
          style: TextStyle(
              color: Colors.black26,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
}
