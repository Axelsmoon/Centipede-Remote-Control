import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';

class MonitorScreen extends StatefulWidget {
  @override
  _MonitorScreenState createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;
  String characteristicUuid = "0000ffe1-0000-1000-8000-00805f9b34fb"; // Replace with your characteristic UUID
  Timer? timer;
  List<String> messages= [];
  List<String> messagesRcv= [];
  List<String> messagesSnt= [];
  List<Message> messagesClass = [];
  TextEditingController _chatMsg = TextEditingController();
  bool isSent = false;

  @override
  void initState() {
    super.initState();
    _fetchConnectedDevices();
  }

  /*void _initBluetooth() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
    if (devices.isNotEmpty) {
      device = devices.first;
      _subscribeToCharacteristic();
    }
  }*/
  void sendCommand(String command) {
    if (characteristic != null && connectedDevice != null) {
      // Send command using the characteristic
      characteristic!.write(utf8.encode(command));
    } else {
      //print("charactersitic= $characteristic");
      //print("device= $device");
      print('Bluetooth not initialized or characteristic not found.');
    }
  }

  Future<void> _fetchConnectedDevices() async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    setState(() {
      devicesList.addAll(connectedDevices);
      if (connectedDevices.isNotEmpty) {
        connectedDevice = connectedDevices.first;
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
            processReceivedCommand(receivedData);
          });
          //print("charactersitic= $characteristic");
        }
      });
    });
  }

  /*void _subscribeToCharacteristic() async {
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
  }*/
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        connectedDevice = device;
      });
    } catch (e) {
      print('Failed to connect to the device: $e');
    }
  }

  void processReceivedCommand(String receivedData) {
    setState(() {
      messages.add(receivedData);
      //messagesRcv.add(receivedData);

      isSent = false; // or false for received messages
      messagesClass.add(Message(receivedData, isSent));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(80, 50, 80, 0.57),
          title: Text(
            'Serial Bluetooth Terminal',
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
                    value: 'data',
                    child: Text('Data'),
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

        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messagesClass.length,
                itemBuilder: (context, index) {
                  //bool isSentMessage = messagesSnt.contains(messages[index]);
                  Message message = messagesClass[index];

                  // Adjust padding based on message length
                  double paddingValue = messagesClass[index].content.length.toDouble() * 2.0;
                  EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: 8.0, horizontal: paddingValue);


                  AlignmentGeometry alignment = message.isSent ? Alignment.centerLeft : Alignment.centerRight;
                  Color color = message.isSent ? Colors.green : Colors.blue;

                  return ListTile(
                    title: Container(
                      alignment: alignment,
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: message.isSent ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        borderRadius: message.isSent ? const BorderRadius.only(topRight: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0)
                        )
                            : const BorderRadius.only(topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0)
                        ),
                      ),
                      child: Text(
                      message.content,
                      style: TextStyle(color: Colors.black),
                  ),
                    ),

                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatMsg,
                      decoration: InputDecoration(
                        hintText: 'Enter your command',
                      ),
                      //onSubmitted: (text) {// Send the command over Bluetooth},
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      // Send the command over Bluetooth
                      String text= _chatMsg.text.trim() + '\r\n';
                      sendCommand(text);
                      setState(() {
                        messages.add(text);
                        //messagesSnt.add(text);

                        isSent = true; // or false for received messages
                        messagesClass.add(Message(text, isSent));
                      });
                      _chatMsg.clear(); // Clear the text in the TextField
                    },
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }

}

class Message {
  final String content;
  final bool isSent;

  Message(this.content, this.isSent);
}



