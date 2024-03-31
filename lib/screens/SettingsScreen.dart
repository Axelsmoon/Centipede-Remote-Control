import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {


  static String newCommandUP= 'WAVE 15\r\n';
  static String newCommandLEFT= "WAVE 64 -30\r\n";
  static String newCommandRIGHT= "WAVE 64 30\r\n";
  static String newCommandDOWN= 'WAVE 0\r\n';



  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController _commandControllerUP = TextEditingController();
  TextEditingController _commandControllerLEFT = TextEditingController();
  TextEditingController _commandControllerRIGHT = TextEditingController();
  TextEditingController _commandControllerDOWN = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 90, 50, 0.5),
          elevation: 0,
          title: Text(
            'Settings',
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
          /*leading:
          IconButton(
            icon: Image.asset('assets/centipede.png'),
            onPressed: (){
              Navigator.pushNamed(context, '/main');
            },
          ),*/
          actions:[
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Color.fromRGBO(255, 255, 255, 0.70),),
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
                  const PopupMenuItem<String>(
                    value: 'data',
                    child: Text('Data'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'main',
                    child: Text('Controller'),
                  ),
                ];
              },
            )
          ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter new TOP sendCommand string:',
                        style: TextStyle(fontSize: 18),
                      ),
                      TextField(
                        controller: _commandControllerUP,
                        decoration: InputDecoration(
                          hintText: 'e.g., WAVE 50\r\n',
                        ),
                      ),
                      SizedBox(height: 20),

                      Text(
                        'Enter new LEFT sendCommand string:',
                        style: TextStyle(fontSize: 18),
                      ),
                      TextField(
                        controller: _commandControllerLEFT,
                        decoration: InputDecoration(
                          hintText: 'e.g., WAVE 50\r\n',
                        ),
                      ),
                      SizedBox(height: 20),

                      Text(
                        'Enter new RIGHT sendCommand string:',
                        style: TextStyle(fontSize: 18),
                      ),
                      TextField(
                        controller: _commandControllerRIGHT,
                        decoration: InputDecoration(
                          hintText: 'e.g., WAVE 50\r\n',
                        ),
                      ),
                      SizedBox(height: 20),

                      Text(
                        'Enter new DOWN sendCommand string:',
                        style: TextStyle(fontSize: 18),
                      ),
                      TextField(
                        controller: _commandControllerDOWN,
                        decoration: InputDecoration(
                          hintText: 'e.g., WAVE 50\r\n',
                        ),
                      ),
                      SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          if (_commandControllerUP.text.isNotEmpty) {
                            SettingsScreen.newCommandUP = _commandControllerUP.text.trim() + '\r\n';
                          }
                          if (_commandControllerLEFT.text.isNotEmpty) {
                            SettingsScreen.newCommandLEFT = _commandControllerLEFT.text.trim() + '\r\n';
                          }
                          if (_commandControllerRIGHT.text.isNotEmpty) {
                            SettingsScreen.newCommandRIGHT = _commandControllerRIGHT.text.trim() + '\r\n';
                          }
                          if (_commandControllerDOWN.text.isNotEmpty) {
                            SettingsScreen.newCommandDOWN = _commandControllerDOWN.text.trim() + '\r\n';
                          }

                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, '/main');
                        },
                        child: Text('Save'),
                      ),
                      SizedBox(height: 20), // Additional space between each item
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),




    );
  }

  @override
  void dispose() {
    _commandControllerUP.dispose();
    _commandControllerLEFT.dispose();
    _commandControllerRIGHT.dispose();
    _commandControllerDOWN.dispose();
    super.dispose();
  }
}
