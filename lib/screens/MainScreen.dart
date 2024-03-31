import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../screens/SettingsScreen.dart';



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

  String commandUP = SettingsScreen.newCommandUP;
  String commandLEFT = SettingsScreen.newCommandLEFT;
  String commandRIGHT = SettingsScreen.newCommandRIGHT;
  String commandDOWN = SettingsScreen.newCommandDOWN;


  @override
  void initState() {
    super.initState();
    _fetchConnectedDevices();
    print('commandUp= $commandUP');
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

  void updateCommands(String newCommandUP, String newCommandLEFT, String newCommandRIGHT, String newCommandDOWN) {
    setState(() {
      commandUP = newCommandUP;
      commandLEFT = newCommandLEFT;
      commandRIGHT = newCommandRIGHT;
      commandDOWN = newCommandDOWN;
    });
  }



  @override
  Widget build(BuildContext context) {
    _fetchConnectedDevices();

    return Stack(
      children: <Widget>[
        //Background Image
        Container(
          /*decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Designer.png'),
              fit: BoxFit.cover,
              //height: double.infinity,
              //width: double.infinity,
            ),
          ),*/
        ),
        Scaffold(
          backgroundColor: Color.fromRGBO(0, 70, 80, 0.57),
          appBar: AppBar(
              backgroundColor: Color.fromRGBO(250, 90, 50, 0.5),
              elevation: 0,
              title: Text(
                  'Centipede Remote Control',
                  style: GoogleFonts.getFont(
                    'Overlock',
                    fontSize: 25,
                    color: Colors.white,
                  ),
              ),
              centerTitle: true,
              shape: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.0),
              ),
              leading:
              IconButton(
                icon: Image.asset('assets/centipede.png'),
                onPressed: (){
                  Navigator.pushNamed(context, '/home');
                },
              ),
              actions:[
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu, color: Color.fromRGBO(255, 255, 255, 0.70),),
                  onSelected: (value) {
                    Navigator.pushNamed(context, '/' "$value");
                    //print('Selected: $value');
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
                      const PopupMenuItem<String>(
                        value: 'data',
                        child: Text('Data'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'settings',
                        child: Text('Settings'),
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
                      DPad(
                        sendCommand: sendCommand,
                        commandUP: commandUP, // Pass the command strings to DPad
                        commandLEFT: commandLEFT,
                        commandRIGHT: commandRIGHT,
                        commandDOWN: commandDOWN,
                      ),//SET (angle) command
                      SizedBox(width: 180),
                      Lever(sendCommand: sendCommand),
                      //WAVE (speed) command
                    ],
                  ),

                  /*Expanded( // Wrap the ListView with Expanded
                    child: ListView.builder( //bt devices list on controller screen
                      itemCount: devicesList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(devicesList[index].name ?? 'Unknown'),
                          subtitle: Text(devicesList[index].id.toString()),
                          onTap: () => connectToDevice(devicesList[index]),
                        );
                      },
                    ),
                  ),*/
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

  String commandUP = SettingsScreen.newCommandUP;
  String commandLEFT = SettingsScreen.newCommandLEFT;
  String commandRIGHT = SettingsScreen.newCommandRIGHT;
  String commandDOWN = SettingsScreen.newCommandDOWN;

  double setWidth= 108.33;
  double setHeight= 65;


  DPad({required this.sendCommand, required commandUP, required commandLEFT, required commandRIGHT, required commandDOWN});

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
              width: setWidth, // Set the desired width
              height: setHeight, // Set the desired height
              rotationAngle: math.pi/2, // Rotate by 90 degrees
              onTap: () {
                // Define the action for the bottom PentagonButton here
                sendCommand(commandUP);
              },
            ),


            Row(
              children: [
                PentagonButton(//left dpad
                  width: setWidth, // Set the desired width
                  height: setHeight, // Set the desired height
                  rotationAngle: 2*(math.pi), // Rotate by 360 degrees
                  onTap: () {
                    // Define the action for the bottom PentagonButton here
                    sendCommand(commandLEFT);
                  },
                ),

                SizedBox(width: 10),
                PentagonButton(//right dpad
                  width: setWidth, // Set the desired width
                  height: setHeight, // Set the desired height
                  rotationAngle: math.pi, // Rotate by 180 degrees
                  onTap: () {
                    // Define the action for the bottom PentagonButton here
                    sendCommand(commandRIGHT);
                    print("right");
                  },
                ),

              ],
            ),
            SizedBox(width: 10),
            PentagonButton(//bottom dpad
              width: setWidth, // Set the desired width
              height: setHeight, // Set the desired height
              rotationAngle: 3*math.pi / 2, // Rotate by 270 degrees
              onTap: () {
                // Define the action for the bottom PentagonButton here
                sendCommand(commandDOWN);
              },
            ),

            SizedBox(height: 10),

          ],

        ),

      ],
    );
  }

}

class PentagonButton extends StatefulWidget {
  final double width;
  final double height;
  final double rotationAngle; // Angle of rotation in radians
  final VoidCallback onTap; // Callback function for onTap event

  PentagonButton({
    required this.width,
    required this.height,
    this.rotationAngle = 0.0,
    required this.onTap,
  });

  @override
  _PentagonButtonState createState() => _PentagonButtonState();
}

class _PentagonButtonState extends State<PentagonButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
        _sendCommandRepeatedly();
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          size: Size(widget.width, widget.height),
          painter: PentagonPainter(rotationAngle: widget.rotationAngle),
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

  void _sendCommandRepeatedly() {
    if (_isPressed) {
      // Command to send when the button is pressed
      widget.onTap();
      // Add delay and recursively call this function while the button is pressed
      Future.delayed(Duration(milliseconds: 100), _sendCommandRepeatedly);
    }
  }
}




class PentagonPainter extends CustomPainter {
  final double rotationAngle; // Angle of rotation in radians
  final Paint fillPaint;
  final Paint strokePaint;

  PentagonPainter({
    this.rotationAngle = 0.0,
    Color fillColor = Colors.grey,
    Color strokeColor = Colors.black,
    double strokeWidth = 1.0,
  })  : fillPaint = Paint()..color = fillColor,
        strokePaint = Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
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
        centerX + size.width / 3 * math.cos(i * 2 * math.pi / 5),
        centerY + size.width / 3 * math.sin(i * 2 * math.pi / 5),
      );
    }
    path.close();

    // Draw the filled pentagon
    canvas.drawPath(path, fillPaint);

    // Draw the outline
    canvas.drawPath(path, strokePaint);
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
  double _leverPosition = 63.5; // Initial position corresponding to WAVE 64
  double sensitivity = 2.0; // Adjust the sensitivity value

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
          } else if (_leverPosition > 127.0) {
            _leverPosition = 127.0;
          }
          // Determine the command based on lever position and send it via Bluetooth
          widget.sendCommand('WAVE ${_leverPosition.round()}\r\n');
        });
      },
      onVerticalDragEnd: (details) {
        _controller.animateTo(
          _leverPosition / 127.0,
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
                        color: Color.fromRGBO(250, 90, 50, 0.77),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(' ( ͡° ͜ʖ ͡°)'),
                      )
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
