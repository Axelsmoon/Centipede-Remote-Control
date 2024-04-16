import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';

import 'BluetoothScreen.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  Timer? timer;
  late BluetoothDevice device;
  //late BluetoothCharacteristic characteristic;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;
  String characteristicUuid = "0000ffe1-0000-1000-8000-00805f9b34fb"; // Replace with your characteristic UUID

  String resultSeg= '';
  String resultTemp= '';
  String resultHumid= '';
  List<String> dataList= [];
  Map<String, String> segmentData = {};

  bool isFetchingData = false;

  @override
  void initState() {
    super.initState();
    _fetchConnectedDevices();

    //_initBluetooth();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startDataFetch() {

    timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      print("started fetch");
      requestData("GET 10\r\n");
      await Future.delayed(Duration(milliseconds: 650));
      requestData("GET 20\r\n");
      await Future.delayed(Duration(milliseconds: 650));
      requestData("GET 30\r\n");
      await Future.delayed(Duration(milliseconds: 650));
      requestData("GET 40\r\n");
      await Future.delayed(Duration(milliseconds: 650));
      requestData("GET 50\r\n");
      //fetchData();
    });
  }

  //GET 40
  void requestData(String command) {
    if (characteristic != null && connectedDevice != null) {
      // Send command using the characteristic
      characteristic!.write(utf8.encode(command));
    } else {
      //print("charactersitic= $characteristic");
      //print("device= $connectedDevice");
      print('Bluetooth not initialized or characteristic not found.');
    }
  }

  Future<void> _fetchConnectedDevices() async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    setState(() {
      devicesList.addAll(connectedDevices);
      if (connectedDevices.isNotEmpty) {
        // connectedDevice = connectedDevices.first;
        connectedDevice = BluetoothScreen.deviceTapped;
        connectedDevice = connectedDevices.firstWhere(
              (device) => device.name == "Myriapod",
        );
        startDataFetch();
      }
    });

    List<BluetoothService> services = await connectedDevice!.discoverServices();
    List<String> uuids = [];
    for (BluetoothService service in services) {
      uuids.add(service.uuid.toString());
    }

    //print("uuids= $uuids");
    // Find the desired characteristic
    services.forEach((service) {
      service.characteristics.forEach((char) async {
        if (char.uuid.toString() == characteristicUuid) {
          characteristic = char;
          await characteristic?.setNotifyValue(true);

          characteristic?.value.listen((value) {
            // Handle received data
            String receivedData = utf8.decode(value);
            // Process received command/message
            fetchData(receivedData);
          });
          //print("charactersitic= $characteristic");
        }
      });
    });
  }

  void fetchData(String receivedData) {
    //example received data: 12.3 degrees C 52.6% humidity
    updateSegmentData(receivedData);
    print('melon');
    RegExp segRegex = RegExp(r'Segment\s(\d\d)');
    Match? segMatch = segRegex.firstMatch(receivedData);
    String segment = segMatch?.group(1) ?? '';

    // Extract temperature
    RegExp tempRegex = RegExp(r'(\d+\.\d+)\sdegrees\sC'); // Matches temperature in Celsius
    Match? tempMatch = tempRegex.firstMatch(receivedData);
    String temperature = tempMatch?.group(1) ?? ''; // Extract the matched temperature value

    // Extract humidity
    RegExp humidityRegex = RegExp(r'(\d+\.\d+)%\shumidity'); // Matches humidity percentage
    Match? humidityMatch = humidityRegex.firstMatch(receivedData);
    String humidity = humidityMatch?.group(1) ?? ''; // Extract the matched humidity value


    setState(() {
      dataList.add(receivedData); // Store received data
      resultSeg = segment;
      resultTemp = temperature;
      resultHumid = humidity;
    });
  }

  void updateSegmentData(String receivedData) {
    RegExp segRegex = RegExp(r'S(\d+)\s');
    Match? segMatch = segRegex.firstMatch(receivedData);
    String segment = segMatch?.group(1) ?? '';

    // Update segment data
    segmentData[segment] = receivedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(32, 168, 82, 0.57),
        title: Text(
          'Data',
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
                  value: 'bt',
                  child: Text('Bluetooth'),
                ),
                const PopupMenuItem<String>(
                  value: 'monitor',
                  child: Text('Terminal'),
                ),
                const PopupMenuItem<String>(
                  value: 'about',
                  child: Text('About'),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Text('Settings'),
                ),

              ];
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: segmentData.length,
        itemBuilder: (context, index) {
          // Get segment number and data from the map
          String segment = segmentData.keys.elementAt(index);
          String data = segmentData[segment] ?? '';

          // Parse the data
          RegExp segAndTypeRegex = RegExp(r'S(\d+)\s(\d)(?:\s(\d+\.\d+)\s(\d+\.\d+)|\s(\d+))?');
          Match? segAndTypeMatch = segAndTypeRegex.firstMatch(data);
          if (segAndTypeMatch != null) {
            String type = segAndTypeMatch.group(2)!;

            String status = '';
            if (type == '0') {
              status = 'No Peripheral';
            } else if (type == '1') {
              status = 'OK';
            } else if (type == '2') {
              status = 'OK'; // Assuming successful pressure reading
            }

            String? temperature = segAndTypeMatch.group(3);
            String? humidity = segAndTypeMatch.group(4);
            String? pressure = segAndTypeMatch.group(5);

            return ListTile(
              title: Text('Segment: $segment'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: $status'),
                  if (type == '1' && temperature != null) Text('Temperature: $temperature°C'),
                  if (type == '1' && humidity != null) Text('Humidity: $humidity%'),
                  if (type == '2' && pressure != null) Text('Pressure: $pressure Pa'),
                ],
              ),
            );
          } else if(data.isNotEmpty){
            // Handle invalid format
            return ListTile(
              title: Text('Invalid Format'),
              subtitle: Text(data),
            );
          } else{
            return Container(
              height: 35,
              child: ListTile(
              title: Text(
                  'Recieving Data:',
              style: TextStyle(fontSize: 10),
              ),
            ),
            );
          }
        },
      ),

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
