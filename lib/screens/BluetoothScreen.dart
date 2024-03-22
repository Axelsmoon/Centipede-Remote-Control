import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  String connectedDeviceName = '';
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool isConnected = false;

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchConnectedDevices();
    scanDevices();
  }

  Future<void> _requestLocationPermission() async {
    try{
      await Permission.bluetooth.request();
      await Permission.nearbyWifiDevices.request();
    }
    catch(e){
      print('Failed to ask for permissions: $e');
    }

    await Permission.location.request();
  }

  Future<void> _fetchConnectedDevices() async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    setState(() {
      devicesList.addAll(connectedDevices);
    });
  }

  Future<void> scanDevices() async {
    await Permission.location.request();
    _scanSubscription = flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (!devicesList.contains(result.device)) {
          setState(() {
            devicesList.add(result.device);
          });
        }
      }
    });
    flutterBlue.startScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();

      // You can add further actions after successful connection if needed
    } catch (e) {
      print('Failed to connect to the device: $e');

    }
  }

  Future<void> disconnectToDevice(BluetoothDevice device) async{
    try {
      await device.disconnect();

      // You can add further actions after successful connection if needed
    } catch (e) {
      print('Failed to disconnect to the device: $e');

    }
  }

  Future<void> checkConnection(BluetoothDevice currentDevice) async{
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    //FlutterBlue flutterBlue= FlutterBlue.instance;
    BluetoothDevice connectedDevice;
    if(connectedDevices.isNotEmpty){
      for(var device in connectedDevices){
        if(device.id == currentDevice.id){
          setState(() {
            isConnected = true;
          });
        }
      }
      if(isConnected){
        disconnectToDevice(currentDevice);
      }
      else{
        connectToDevice(currentDevice);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[

        Container(  // Background Image
          /*decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Sandy_Background.png'),
              fit: BoxFit.cover,
              //height: double.infinity,
              //width: double.infinity,
            ),
          ),*/
        ),
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(0, 70, 80, 0.57),
            elevation: 0,
            title: Text('Bluetooth Devices'),
            centerTitle: true,
            shape: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            /*leading: IconButton(
              icon: Image.asset('assets/IMG_0387.png'),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),*/
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                onSelected: (value) {
                  Navigator.pushNamed(context, '/' "$value");
                  //print('Selected: $value');
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'main',
                      child: Text('Controller'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'about',
                      child: Text('About'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'data',
                      child: Text('Data'),
                    ),
                  ];
                },
              )
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: devicesList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(devicesList[index].name ?? 'Unknown'),
                      subtitle: Text(devicesList[index].id.toString()),
                      onTap: () async {
                        await checkConnection(devicesList[index]);
                      }
                          //connectToDevice(devicesList[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}