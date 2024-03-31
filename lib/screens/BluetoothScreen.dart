import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';


class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  List<BluetoothDevice> devicesConnectedTo = [];
  String connectedDeviceName = '';
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool isConnected = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    //_showErrorSnackBar('Testing error bar ');
    super.initState();
    _requestLocationPermission();
    _fetchConnectedDevices();
    scanDevices();
  }

  // Method to display error message in a SnackBar
  void _showErrorSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(errorMessage),
    ));
  }


  Future<void> _requestLocationPermission() async {

    try{
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect
      ].request();

    }
    catch(e){
      print('Failed to ask for permissions: $e');
    }

  }

  Future<void> _fetchConnectedDevices() async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    setState(() {
      devicesList.addAll(connectedDevices);
      devicesConnectedTo.addAll(connectedDevices);
    });
  }

  Future<void> scanDevices() async {
    try {
      await Permission.location.request();
      _scanSubscription = flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          if (!devicesList.contains(result.device)) {
            setState(() {
              if(result.device.name != '')
                devicesList.add(result.device);
            });
          }
        }
      });
      try {
        flutterBlue.startScan();
        //_showErrorSnackBar('num devices: ${devicesList.length} ');
      } catch(e){
        _showErrorSnackBar('error: $e ');
      }
    } catch (error) {
      _showErrorSnackBar('Failed to start scanning for devices: $error');
    }
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
    print("check connection");
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
        setState(() {
          isConnected = false;
        });
      }
      else{
        connectToDevice(currentDevice);
      }
    }
    else{
      connectToDevice(currentDevice);
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
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(0, 70, 80, 0.57),
            elevation: 0,
            title: Text(
              'Bluetooth Devices',
              style: GoogleFonts.getFont(
                'Overlock',
                fontSize: 25,
                color: Colors.white,
              ),
            ),
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
                    bool isDeviceConnected = devicesConnectedTo.contains(devicesList[index]);
                    return Container(
                        decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(0, 5), // changes position of shadow
                          ),
                          ]
                        ),
                    margin: EdgeInsets.all(8.0),
                      child: ListTile(
                      title: Text(devicesList[index].name ?? 'Unknown'),
                      subtitle: Text(devicesList[index].id.toString()),
                      onTap: () async {

                        await checkConnection(devicesList[index]);
                        /*await Future.delayed(Duration(milliseconds: 1500));
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/bt');*/
                        if(isDeviceConnected){
                          _showErrorSnackBar('Please wait. Disconnecting... ');
                          StreamSubscription<
                              BluetoothDeviceState>? connectionSubscription;
                          connectionSubscription =
                              devicesList[index].state.listen((
                                  deviceState) async {
                                if (deviceState !=
                                    BluetoothDeviceState.connected) {
                                  // Cancel the subscription before navigating
                                  connectionSubscription?.cancel();
                                  await Future.delayed(Duration(milliseconds: 1500));
                                  Navigator.of(context).pop();
                                  Navigator.pushNamed(context, '/bt');
                                }
                              });

                          // Cancel the subscription if the device is already connected
                          if (!isDeviceConnected) {
                            connectionSubscription.cancel();
                          }
                        }

                        else if(!isDeviceConnected) {
                          _showErrorSnackBar('Please wait. Connecting... ');
                          // Subscribe to device connection state changes
                          StreamSubscription<
                              BluetoothDeviceState>? connectionSubscription;
                          connectionSubscription =
                              devicesList[index].state.listen((
                                  deviceState) async {
                                if (deviceState ==
                                    BluetoothDeviceState.connected) {
                                  // Cancel the subscription before navigating
                                  connectionSubscription?.cancel();
                                  Navigator.of(context).pop();
                                  Navigator.pushNamed(context, '/bt');
                                }
                              });

                          // Cancel the subscription if the device is already connected
                          if (isDeviceConnected) {
                            connectionSubscription.cancel();
                          }
                        }


                      },

                      trailing: isDeviceConnected
                      ? Icon(Icons.bluetooth_connected, color: Colors.blue)
                          : Icon(Icons.bluetooth),

                          //connectToDevice(devicesList[index]),
                      ),
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