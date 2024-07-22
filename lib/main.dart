import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth App',
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _requestPermissions() async {
    var status = await Permission.bluetoothScan.request();
    if (status.isGranted) {
      _startScan();
    } else {
      // Handle the case where the user denies the permission
      print('Bluetooth scan permission denied');
    }
  }

  void _startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.any((device) => device.id == result.device.id)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    }).onError((error) {
      print('Error starting scan: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (BuildContext context, int index) {
          BluetoothDevice device = devices[index];
          return ListTile(
            title: Text(device.name.isNotEmpty ? device.name : 'Unknown device'),
            subtitle: Text(device.id.toString()),
          );
        },
      ),
    );
  }
}