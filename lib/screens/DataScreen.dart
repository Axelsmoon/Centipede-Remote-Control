import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  String statusCode1 = 'No Peripheral';
  String sensorType1 = '';
  String sensorData1 = '';

  String statusCode2 = 'No Peripheral';
  String sensorType2 = '';
  String sensorData2 = '';

  String statusCode3 = 'No Peripheral';
  String sensorType3 = '';
  String sensorData3 = '';

  Timer? timer;
  late BluetoothDevice device;
  late BluetoothCharacteristic characteristic;

  bool isFetchingData = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startDataFetch() {
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchData();
    });
  }

  void _initBluetooth() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
    if (devices.isNotEmpty) {
      device = devices.first;
      _subscribeToCharacteristic();
    }
  }

  void _subscribeToCharacteristic() async {
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      service.characteristics.forEach((char) {
        if (char.properties.notify || char.properties.indicate) {
          characteristic = char;
          characteristic.setNotifyValue(true);
          characteristic.value.listen(_handleData);
          // Start data fetching
          setState(() {
            isFetchingData = true;
          });
        }
      });
    });
  }

  void _handleData(List<int>? value) {
    if (value != null) {
      // Parse the received value and update state accordingly
      // This part depends on the format of data sent by the Bluetooth device
      // For example, if the data format is [statusCode, sensorType, sensorData]
      // you would parse it like this:
      setState(() {
        statusCode1 = 'OK';
        sensorType1 = value[1].toString(); // Example: Sensor type is at index 1
        sensorData1 = value[2].toString(); // Example: Sensor data is at index 2
      });
    }
  }

  void fetchData() {
    // Simulate receiving data from Bluetooth
    // Replace this with your actual data retrieval logic
    // For demonstration, I'm randomly updating data
    setState(() {
      updateData('Temperature', 'Sensor1', '25°C');
      updateData('Light', 'Sensor2', '50 lux');
      updateData('Temperature', 'Sensor3', '30°C');
    });
  }

  void updateData(String category, String type, String data) {
    if (category == 'Temperature') {
      setState(() {
        statusCode1 = 'OK';
        sensorType1 = type;
        sensorData1 = data;
      });
    } else if (category == 'Light') {
      setState(() {
        statusCode2 = 'OK';
        sensorType2 = type;
        sensorData2 = data;
      });
    } else {
      setState(() {
        statusCode3 = 'OK';
        sensorType3 = type;
        sensorData3 = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(80, 50, 80, 0.57),
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
                  value: 'about',
                  child: Text('About'),
                ),
                const PopupMenuItem<String>(
                  value: 'bt',
                  child: Text('Bluetooth'),
                ),
              ];
            },
          )
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Category: Temperature'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status Code: $statusCode1'),
                Text('Sensor Type: $sensorType1'),
                Text('Sensor Data: $sensorData1'),
              ],
            ),
          ),
          ListTile(
            title: Text('Category: Light'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status Code: $statusCode2'),
                Text('Sensor Type: $sensorType2'),
                Text('Sensor Data: $sensorData2'),
              ],
            ),
          ),
          ListTile(
            title: Text('Category: No Peripheral'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status Code: $statusCode3'),

              ],
            ),
          ),
        ],
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
