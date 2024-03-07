import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;
  String characteristicUuid = "0000ffe1-0000-1000-8000-00805f9b34fb"; // Replace with your characteristic UUID


  @override
  void initState() {
    super.initState();
    _fetchConnectedDevices();
  }

  // Function to initialize Bluetooth connection to already connected device
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
      service.characteristics.forEach((char) {
        if (char.uuid.toString() == characteristicUuid) {
          characteristic = char;
          //print("charactersitic= $characteristic");
        }
      });
    });
  }


// Function to send commands using the discovered characteristic
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


  @override
  Widget build(BuildContext context) {
    _fetchConnectedDevices();

    return Stack(
      children: <Widget>[
        //Background Image
        Container(
        ),
        Scaffold(
          backgroundColor: Colors.blue,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text('Centipede'),
              centerTitle: true,
              shape: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.0),
              ),
              leading:
              IconButton(
                icon: Image.asset('assets/IMG_0387.png'),
                onPressed: (){
                  Navigator.pushNamed(context, '/home');
                },
              ),
              actions:[
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu),
                  onSelected: (value) {
                    Navigator.pushNamed(context, '/' "$value");

                  },
                  itemBuilder: (BuildContext context){
                    return[
                      const PopupMenuItem<String>(
                        value: 'bt',
                        child: Text('Bluetooth'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'about',
                        child: Text('About'),
                      ),
                    ];
                  },
                )
              ]
          ),
          body: Center(
            child:

            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DPad(sendCommand: sendCommand), // Pass the sendCommand method to DPad
                      //SET (angle) command
                      Lever(sendCommand: sendCommand),
                      //WAVE (speed) command
                    ],
                  ),

                  ListView.builder(
                      itemCount: devicesList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(devicesList[index].name ?? 'Unknown'),
                          subtitle: Text(devicesList[index].id.toString()),
                          onTap: () => connectToDevice(devicesList[index]),
                        );
                      },
                    ),
                ],
              ),

            ),
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



class DPad extends StatelessWidget {
  final void Function(String) sendCommand;

  DPad({required this.sendCommand});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            PentagonButton(//top dpad
              width: 50, // Set the desired width
              height: 30, // Set the desired height
              rotationAngle: math.pi/2, // Rotate by 90 degrees
              onTap: () {
                // Define the action for the bottom PentagonButton here
                sendCommand('WAVE 15\r\n');
              },
            ),


            Row(
              children: [
                PentagonButton(//left dpad
                  width: 50, // Set the desired width
                  height: 30, // Set the desired height
                  rotationAngle: 2*(math.pi), // Rotate by 360 degrees
                  onTap: () {
                    // Define the action for the bottom PentagonButton here
                    sendCommand("WAVE 64 -30\r\n");
                  },
                ),

                SizedBox(width: 10),
                PentagonButton(//right dpad
                  width: 50, // Set the desired width
                  height: 30, // Set the desired height
                  rotationAngle: math.pi, // Rotate by 180 degrees
                  onTap: () {
                    // Define the action for the bottom PentagonButton here
                    sendCommand("WAVE 64 30\r\n");
                  },
                ),

              ],
            ),
            SizedBox(width: 10),
            PentagonButton(//bottom dpad
              width: 50, // Set the desired width
              height: 30, // Set the desired height
              rotationAngle: 3*math.pi / 2, // Rotate by 270 degrees
              onTap: () {
                // Define the action for the bottom PentagonButton here
                sendCommand('WAVE 0\r\n');
              },
            ),

            SizedBox(height: 10),

          ],

        ),

      ],
    );
  }
}

class PentagonButton extends StatelessWidget {
  final double width;
  final double height;
  final double rotationAngle; // Angle of rotation in radians
  final VoidCallback onTap; // Callback function for onTap event

  PentagonButton({required this.width,
    required this.height,
    this.rotationAngle = 0.0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: PentagonPainter(rotationAngle: rotationAngle),
        child: InkWell(
          onTap: onTap, // Call the provided callback function onTap
          child: Center(
            child: Text(
              '+',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}



class PentagonPainter extends CustomPainter {
  final double rotationAngle; // Angle of rotation in radians

  PentagonPainter({this.rotationAngle = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.grey;
    Path path = Path();

    // Calculate the center of the pentagon
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    // Rotate the canvas around the center
    canvas.translate(centerX, centerY);
    canvas.rotate(rotationAngle);
    canvas.translate(-centerX, -centerY);

    // Calculate the vertices of the rotated pentagon
    path.moveTo(centerX + size.width / 2 * math.cos(0), centerY + size.width / 2 * math.sin(0));
    for (int i = 1; i <= 5; i++) {
      path.lineTo(
        centerX + size.width / 2 * math.cos(i * 2 * math.pi / 5),
        centerY + size.width / 2 * math.sin(i * 2 * math.pi / 5),
      );
    }
    path.close();

    // Draw the rotated pentagon
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class Lever extends StatefulWidget {
  BluetoothDevice? get connectedDevice => null;
  final void Function(String) sendCommand; // Define sendCommand with a String parameter

  Lever({required this.sendCommand});

  @override
  _LeverState createState() => _LeverState();
}

class _LeverState extends State<Lever> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _leverPosition = 0.5;
  double sensitivity = 100.0; // Adjust the sensitivity value

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          // Adjust the sensitivity here
          _leverPosition -= details.delta.dy / sensitivity;
          if (_leverPosition < 0.0) {
            _leverPosition = 0.0;
          } else if (_leverPosition > 1.0) {
            _leverPosition = 1.0;
          }
          // Determine the command based on lever position and send it via Bluetooth
          if (_leverPosition > 0.5) {
            widget.sendCommand('WAVE 64\r\n'); // Example command for moving forward
          } else {
            widget.sendCommand('WAVE 0\r\n'); // Example command for moving backward
          }
        });
      },
      onVerticalDragEnd: (details) {
        _controller.animateTo(
          _leverPosition,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: 50,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  top: (200 - 50) * (1 - _controller.value), // Subtract lever height
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
