import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceControlPage extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceControlPage({super.key, required this.device});

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
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Device Control',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                sendData(device, 'up');
              },
              child: const Text('Up'),
            ),
            ElevatedButton(
              onPressed: () {
                sendData(device, 'down');
              },
              child: const Text('Down'),
            ),
            ElevatedButton(
              onPressed: () {
                sendData(device, 'stop');
              },
              child: const Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
}
