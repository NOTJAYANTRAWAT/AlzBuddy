import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ws_ui/views/home.dart';
import 'package:ws_ui/views/login.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool status = false;
  Future checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var prefStatus = prefs.getBool('status');
    if (prefStatus != null) {
      setState(() {
        status = prefStatus;
      });
    }
  }

  @override
  void initState() {
    checkLoginStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: status ? HomePage() : Login(),
    );
  }
}
