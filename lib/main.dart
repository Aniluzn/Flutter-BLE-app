import 'dart:convert';

import 'package:bluetoothledcontrol/bluetoothscanpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  BluetoothCharacteristic? findWritableCharacteristic(
      List<BluetoothService> services) {
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          return characteristic;
        }
      }
    }
    return null;
  }

  void sendData(BluetoothDevice device, String data) async {
    List<BluetoothService> services = await device.discoverServices();
    BluetoothCharacteristic? writableCharacteristic =
        findWritableCharacteristic(services);

    if (writableCharacteristic != null) {
      try {
        await writableCharacteristic.write(utf8.encode(data));
        print("'$data' Data sent successfully.");
      } catch (e) {
        print("Error while writing data: $e");
      }
    } else {
      print("No writable characteristic found on the device.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BluetoothDeviceList(),
    );
  }
}
