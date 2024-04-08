import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {


  static int newCommandUP= 15;
  static String newCommandLEFT= "64";
  static String angleLeft= "-30";
  static String newCommandRIGHT= "64";
  static String angleRight= "30";
  static int newCommandDOWN= 0;
  static bool useInput=false;
  static double leverSensitivity= 2.0;



  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController _commandControllerUP = TextEditingController();
  TextEditingController _commandControllerLEFT = TextEditingController();
  TextEditingController _commandControllerLEFTAngle = TextEditingController();
  TextEditingController _commandControllerRIGHT = TextEditingController();
  TextEditingController _commandControllerRIGHTAngle = TextEditingController();
  TextEditingController _commandControllerDOWN = TextEditingController();
  TextEditingController _leverSensitive = TextEditingController();

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
                        'Turn on to input custom Speed Values :',
                        style: TextStyle(fontSize: 18),
                      ),
                      Switch(value: SettingsScreen.useInput,
                          onChanged: (value){
                            setState(() {
                              SettingsScreen.useInput= value;
                            });
                          }
                      ),

                      SizedBox(height: 20),

                      if(SettingsScreen.useInput)
                        Text(
                          'Enter new Top Dpad value:',
                          style: TextStyle(fontSize: 18),
                        ),
                      if(SettingsScreen.useInput)
                        TextField(
                          controller: _commandControllerUP,
                          decoration: InputDecoration(
                            hintText: 'Speed value between 0 & 127\r\n',
                          ),
                        ),
                      if(SettingsScreen.useInput)
                        SizedBox(height: 20),

                      Text(
                        'Enter new Left DPad value(s):',
                        style: TextStyle(fontSize: 18),
                      ),
                      Row(
                        children: [
                          if(SettingsScreen.useInput)
                            Expanded(
                              child: TextField(
                                controller: _commandControllerLEFT,
                                decoration: InputDecoration(
                                  hintText: 'Speed between 0 & 127\r\n',
                                ),
                              ),
                            ),
                          if (SettingsScreen.useInput)
                            SizedBox(width: 20), // Adjust as needed
                          Expanded(
                            child: TextField(
                              controller: _commandControllerLEFTAngle,
                              decoration: InputDecoration(
                                hintText: 'Angle between -60 & 60\r\n',
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      Text(
                        'Enter new Right DPad value(s):',
                        style: TextStyle(fontSize: 18),
                      ),
                      Row(
                        children: [
                          if(SettingsScreen.useInput)
                            Expanded(
                              child: TextField(
                                controller: _commandControllerRIGHT,
                                decoration: InputDecoration(
                                  hintText: 'Speed between 0 & 127\r\n',
                                ),
                              ),
                            ),
                          if (SettingsScreen.useInput)
                            SizedBox(width: 20), // Adjust as needed
                          Expanded(
                            child: TextField(
                              controller: _commandControllerRIGHTAngle,
                              decoration: InputDecoration(
                                hintText: 'Angle between -60 & 60\r\n',
                              ),
                            ),
                          ),
                        ],
                      ),

                      if(SettingsScreen.useInput)
                        Text(
                          'Enter new Down DPad value:',
                          style: TextStyle(fontSize: 18),
                        ),
                      if(SettingsScreen.useInput)
                        TextField(
                          controller: _commandControllerDOWN,
                          decoration: InputDecoration(
                            hintText: 'Speed value between 0 & 127\r\n',
                          ),
                        ),

                      SizedBox(height: 20),

                      Text(
                        'Enter new Lever sensitivity:',
                        style: TextStyle(fontSize: 18),
                      ),
                      TextField(
                        controller: _leverSensitive,
                        decoration: InputDecoration(
                          hintText: 'Sensitivity value between 0.1 & 5.0 (Default= 2.0)\r\n',
                        ),
                      ),

                      SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          if (_commandControllerUP.text.isNotEmpty) {
                            SettingsScreen.newCommandUP = int.parse(_commandControllerUP.text.trim());
                          }
                          if (_commandControllerLEFT.text.isNotEmpty) {
                            SettingsScreen.newCommandLEFT = _commandControllerLEFT.text.trim();
                          }
                          if (_commandControllerLEFTAngle.text.isNotEmpty) {
                            SettingsScreen.angleLeft= _commandControllerLEFTAngle.text.trim();
                          }
                          if (_commandControllerRIGHT.text.isNotEmpty) {
                            SettingsScreen.newCommandRIGHT = _commandControllerRIGHT.text.trim();
                          }
                          if (_commandControllerRIGHTAngle.text.isNotEmpty) {
                            SettingsScreen.angleRight= _commandControllerRIGHTAngle.text.trim();
                          }
                          if (_commandControllerDOWN.text.isNotEmpty) {
                            SettingsScreen.newCommandDOWN = int.parse(_commandControllerDOWN.text.trim());
                          }
                          if (_leverSensitive.text.isNotEmpty) {
                            SettingsScreen.leverSensitivity = double.parse(_leverSensitive.text.trim());
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
