import 'package:flutter/material.dart';
import 'package:centipede_control/screens/MainScreen.dart';
import 'package:centipede_control/screens/BluetoothScreen.dart';
import '../screens/AboutScreen.dart';

class Routes {
  static const String MAINSCREEN = '/main';
  static const String BLUETOOTHSCREEN = '/bt';
  static const String ABOUTSCREEN = '/about';

  static Map<String, Widget Function(BuildContext)> get getroutes =>
      {
        '/': (context) => MainScreen(),
        MAINSCREEN: (context) => MainScreen(),
        BLUETOOTHSCREEN: (context) => BluetoothScreen(),
        ABOUTSCREEN: (context) => AboutScreen(),
      };
}