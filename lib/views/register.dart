import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ws_ui/views/login.dart';
import 'package:ws_ui/services/api.dart';

class Register extends StatelessWidget {
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _number = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Register',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: TextFormField(
                  controller: _username,
                  decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: TextFormField(
                  controller: _password,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  controller: _number,
                  decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.black),
                    child: Text('Submit'),
                    onPressed: () async {
                      var res = await http.post(Uri.parse(APIRoutes.register),
                          headers: <String, String>{
                            'Content-Type': 'application/json'
                          },
                          body: jsonEncode(<String, dynamic>{
                            'username': _username.text,
                            'password': _password.text,
                            'mobile': _number.text
                          }));

                      if (res.statusCode == 201) {
                        // NAVIGATE TO LOGIN
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      } else {
                        _username.clear();
                        _password.clear();
                        _number.clear();
                        showDialogBoxReg(context);
                      }
                    },
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text('Already Have an account? Try signing in.'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.black),
                  child: Text('Login'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

showDialogBoxReg(BuildContext context) {
  AlertDialog alert = AlertDialog(
    title: Text("Invalid Credentials"),
    content:
        Text("The credentials you entered already exist.\nPlease try again."),
  );

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      });
}
