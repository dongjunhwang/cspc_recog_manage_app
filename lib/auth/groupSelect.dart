import 'package:cspc_recog_manage/face_recog/mainPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../urls.dart';
import 'package:cspc_recog_manage/auth/models/loginUser.dart';

import 'package:flutter/services.dart';
import 'package:cspc_recog_manage/auth/register.dart';

import 'models/user.dart';

class GroupSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupSelectPageState();
}

class _GroupSelectPageState extends State<GroupSelectPage> {
  bool _isLoading = false;
  late LoginUser myLogin;
  late User myUser;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white70],
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

  getUserGroup(String id) async {
    final response = await http.post(
      Uri.parse(UrlPrefix.urls + "users/auth/user/group/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "user_id": id,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null) {
        setState(() {
          _isLoading = false;
        });
        myLogin = LoginUser.fromJson(data);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  userGet(String token) async {
    String knoxToken = 'Token ' + token;
    final response = await http.get(
      Uri.parse(UrlPrefix.urls + "users/auth/user/"),
      headers: <String, String>{
        'Authorization': knoxToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null) {
        myUser = User.fromJson(data);

        print(myUser.userName);
        print(myUser.userId);

        return myUser;
      }
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
            "Sign In",
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
            //signIn(idController.text, passwordController.text);
          },
        ),
        SizedBox(height: 20.0),
        TextButton(
          child: Text(
            "Don't have an account yet? Sign Up",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            setState(() {
              _isLoading = true;
            });

            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => MainPage()));
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
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.white70),
              hintText: "ID",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Password",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
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
      child: Text("GroupSection",
          style: TextStyle(
              color: Colors.indigo,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
}
