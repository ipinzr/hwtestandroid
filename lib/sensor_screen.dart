import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:location/location.dart';
import 'package:connectivity/connectivity.dart';
import 'package:vibration/vibration.dart';

class SensorScreen extends StatefulWidget {
  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  LocationData? _locationData;
  List<double> accelerometerValues = [0, 0, 0];
  List<double> gyroscopeValues = [0, 0, 0];
  late ConnectivityResult _connectivityResult;

  @override
  void initState() {
    super.initState();
    // Get location data
    getLocation();
    // Listen to accelerometer sensor
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        accelerometerValues = [event.x, event.y, event.z];
      });
    });

    // Listen to gyroscope sensor
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gyroscopeValues = [event.x, event.y, event.z];
      });
    });

    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
      });
    });
  }

  Future<void> getLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {});
  }

  void vibrate() {
    Vibration.vibrate(duration: 500);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Test'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _locationData != null
              ? Container(
                  height: 150,
                  child: Center(
                    child: Text(
                      'Location: ${_locationData!.latitude}, ${_locationData!.longitude}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : Center(child: Text('Location not available')),
          Card(
            elevation: 4,
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accelerometer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('X: ${accelerometerValues[0].toStringAsFixed(2)}'),
                  Text('Y: ${accelerometerValues[1].toStringAsFixed(2)}'),
                  Text('Z: ${accelerometerValues[2].toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          Card(
            elevation: 4,
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gyroscope',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('X: ${gyroscopeValues[0].toStringAsFixed(2)}'),
                  Text('Y: ${gyroscopeValues[1].toStringAsFixed(2)}'),
                  Text('Z: ${gyroscopeValues[2].toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          Card(
            elevation: 4,
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connectivity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('WiFi/Bluetooth: $_connectivityResult'),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: vibrate,
            child: Text('Vibrate'),
          ),
        ],
      ),
    );
  }
}
