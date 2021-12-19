import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:ws_ui/services/api.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:ws_ui/views/login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  late LatLng _pos2;
  bool loaded = false;
  bool info = false;
  String user = '';
  String number = '';
  String code = '';
  late FlutterLocalNotificationsPlugin fltrNotification;

  Future getCurrentPosition() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _pos2 = LatLng(pos.latitude, pos.longitude);
      loaded = true;
    });
  }

  Future getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = prefs.getString('user').toString();
    });

    var res = await http.get(Uri.parse(APIRoutes.getSingleUser + '$user'));
    var decode = jsonDecode(res.body);
    if (res.statusCode == 200) {
      dev.log('$user');
      dev.log('$decode');
      setState(() {
        number = decode[0]['mobile'].toString();
        code = decode[0]['code'];
        info = true;
      });
    }
  }
  

 
  @override
  void initState() {
    super.initState();
  
    

    
    getCurrentPosition();
    getUserDetails();
    
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Hello,\n$user',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: info ? Text('$number') : CircularProgressIndicator(),
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: info ? Text('$code') : CircularProgressIndicator(),
            ),
            TextButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('status', false);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login()));
                },
                child: Text('Sign Out'))
          ],
        ),
      ),
      body: Stack(
        children: [
          loaded
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(_pos2.latitude, _pos2.longitude),
                      zoom: 15),
                  markers: <Marker>{
                    Marker(markerId: MarkerId('poop'), position: _pos2)
                  },
                )
              : Center(child: CircularProgressIndicator()),
          Container(
            alignment: Alignment(-0.7, 0.7),
            child: FloatingActionButton(
                backgroundColor: Colors.black,
                child: Icon(Icons.location_pin),
                onPressed: () async {
                  var res = await http.patch(
                      Uri.parse(APIRoutes.updateLocation),
                      headers: <String, String>{
                        'Content-Type': 'application/json'
                      },
                      body: jsonEncode(<String, dynamic>{
                        'username': user,
                        'latitude': _pos2.latitude,
                        'longitude': _pos2.longitude
                      }));
                  if (res.statusCode == 221) {
                    dev.log('location updated');
                  } else {
                    dev.log('some error');
                  }
                }),
          ),
          Container(
            alignment: Alignment(0.3, 0.7),
            child: FloatingActionButton(
                backgroundColor: Colors.black,
                child: Icon(Icons.call),
                onPressed: () async {
                  String uri = 'tel:$number?';
                  if (await canLaunch(uri)) {
                    await launch(uri);
                  }
                  dev.log('calling');
                }),
          ),
          Container(
            alignment: Alignment(-0.2, 0.7),
            child: FloatingActionButton(
                backgroundColor: Colors.black,
                child: Icon(Icons.message),
                onPressed: () async {
                  String uri =
                      'sms:$number?body=${_pos2.latitude}, ${_pos2.longitude}';
                  if (await canLaunch(uri)) {
                    await launch(uri);
                  }

                  dev.log('message sent');
                }),
          ),
          Container(
            alignment: Alignment(0.8, 0.7),
            child: FloatingActionButton(
                backgroundColor: Colors.black,
                child: Icon(Icons.calendar_today),
                onPressed: () async {
                  dev.log("calender pressed");
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(2021, 12, 1),
                      maxTime: DateTime(2023, 12, 1), onChanged: (date) {
                    dev.log('selecting');
                  }, onConfirm: (date) {
                    dev.log('selected $date');
                  }, currentTime: DateTime.now());
                }),
          ),
          Container(
            alignment: Alignment(-0.9, -0.9),
            child: FloatingActionButton(
                backgroundColor: Colors.black,
                child: Icon(Icons.menu),
                onPressed: () {
                  dev.log("${_pos2.latitude} + ${_pos2.longitude}");
                  _key.currentState!.openDrawer();
                }),
          )
        ],
      ),
    );
  }
}
