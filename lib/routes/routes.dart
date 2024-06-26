import 'package:flutter/material.dart';
import 'package:centipede_control/screens/MainScreen.dart';
import 'package:centipede_control/screens/BluetoothScreen.dart';
import '../screens/AboutScreen.dart';
import '../screens/DataScreen.dart';
import '../screens/MonitorScreen.dart';
import '../screens/SettingsScreen.dart';

class Routes {
  static const String MAINSCREEN = '/main';
  static const String BLUETOOTHSCREEN = '/bt';
  static const String ABOUTSCREEN = '/about';
  static const String DATASCREEN = '/data';
  static const String SETTINGSSCREEN = '/settings';
  static const String MONITORSCREEN = '/monitor';

  static Map<String, Widget Function(BuildContext)> get getroutes =>
      {
        '/': (context) => MainScreen(),
        MAINSCREEN: (context) => MainScreen(),
        BLUETOOTHSCREEN: (context) => BluetoothScreen(),
        ABOUTSCREEN: (context) => AboutScreen(),
        DATASCREEN: (context) => DataScreen(),
        SETTINGSSCREEN: (context) => SettingsScreen(),
        MONITORSCREEN: (context) => MonitorScreen(),
      };
}