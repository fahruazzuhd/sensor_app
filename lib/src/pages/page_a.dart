import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:battery_info/battery_info_plugin.dart';

class PageA extends StatefulWidget {
  @override
  State<PageA> createState() => _PageAState();
}

class _PageAState extends State<PageA> {
  String currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

  String _timeString = '';

  List<double> _accelerometerValues = [0, 0, 0];
  List<double> _gyroscopeValues = [0, 0, 0];
  List<double> _magnetometerValues = [0, 0, 0];

  double _latitude = 0.0;
  double _longitude = 0.0;

  int _batteryLevel = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getCurrentTime());

    // Menggunakan listener untuk mengambil nilai sensor terbaru
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    });

    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _magnetometerValues = <double>[event.x, event.y, event.z];
      });
    });

    _getCurrentLocation();
    _getBatteryLevel();
  }

  void _getCurrentTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('HH:mm:ss').format(now);
    setState(() {
      _timeString = formattedTime;
    });
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('Izin untuk mengakses lokasi belum diberikan.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              )
            ],
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    }
  }

  Future<void> _getBatteryLevel() async {
    final batteryLevel = (await BatteryInfoPlugin().androidBatteryInfo)?.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page A'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  Text(
                      _timeString,
                    style: TextStyle(
                      fontSize: 40
                    ),
                  ),
                  Text(currentDate),
                ],
              )
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Accelerometer (m/s²): \n'
                    'x: ${_accelerometerValues[0].toStringAsFixed(2)}, '
                    'y: ${_accelerometerValues[1].toStringAsFixed(2)}, '
                    'z: ${_accelerometerValues[2].toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Gyroscope (rad/s): \n'
                    'x: ${_gyroscopeValues[0].toStringAsFixed(2)}, '
                    'y: ${_gyroscopeValues[1].toStringAsFixed(2)}, '
                    'z: ${_gyroscopeValues[2].toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Magnetometer (µT): \n'
                    'x: ${_magnetometerValues[0].toStringAsFixed(2)}, '
                    'y: ${_magnetometerValues[1].toStringAsFixed(2)}, '
                    'z: ${_magnetometerValues[2].toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'GPS Coordinate: \n'
                    'lat: ${_latitude.toStringAsFixed(5)}, '
                    'long: ${_longitude.toStringAsFixed(5)}, ',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Battery Level: \n'
                   '$_batteryLevel%',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
