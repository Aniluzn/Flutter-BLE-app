import 'dart:convert';

import 'package:bluetoothledcontrol/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'devicecontrol.dart';

class BluetoothDeviceList extends StatefulWidget {
  const BluetoothDeviceList({super.key});

  @override
  _BluetoothDeviceListState createState() => _BluetoothDeviceListState();
}

class _BluetoothDeviceListState extends State<BluetoothDeviceList> {
  List<BluetoothDevice> devices = [];
  bool bluetoothState = false;
  String password = '';
  late TextEditingController controller;
  bool deviceStatus = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  void bluetoothOnOff(bool value) async {
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }
    if (value == true) {
      FlutterBluePlus.turnOn();
    }
  }

  void startScan() {
    FlutterBluePlus.adapterState.listen(
      (BluetoothAdapterState state) {
        print(state);
        if (state == BluetoothAdapterState.on) {
          FlutterBluePlus.scanResults.listen(
            (List<ScanResult> results) {
              for (ScanResult result in results) {
                if (!devices.contains(result.device)) {
                  setState(
                    () {
                      devices.add(result.device);
                    },
                  );
                }
              }
            },
          );
        }
      },
    );

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      if (!device.isConnected) {
        await device.connect();
        print('Connected to ${device.advName}');
      } else {
        print('device is already connected!');
      }
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  Future<void> disconnect(BluetoothDevice device) async {
    try {
      await device.disconnect();
      deviceStatus = false;
      print('Disconnected to ${device.advName}');
    } catch (e) {
      print('Disconnection failed: $e');
    }
  }

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

  Future<List<int>> receiveData(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.properties.read) {
          List<int> value = (await c.read());
          return value;
        }
      }
    }

    return List.empty();
  }

  Future<void> openDialog(BluetoothDevice device) async {
    if (!device.isConnected) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enter the password'),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Enter your password',
            ),
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                sendData(device, controller.text);
                List<int> data = await receiveData(device);
                String a = String.fromCharCodes(data);
                print('Received data:$a');
                if (String.fromCharCodes(data) == "ESP32") {
                  print('321321');
                  return deneme(device);
                }
              },
              child: const Text('Connect'),
            ),
            const TextButton(
              onPressed: null,
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  void goToDeviceControl(BluetoothDevice device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceControlPage(device: device),
      ),
    );
  }

  void deneme(BluetoothDevice device) {
    Navigator.of(context).pop();
    controller.clear();
    setState(
      () {
        deviceStatus = true;
      },
    );
    print('222222132131');
    if (deviceStatus) {
      goToDeviceControl(device);
    } else {
      print('Error: Device is null or empty.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
            icon: const Icon(Icons.settings),
            color: Colors.white,
          )
        ],
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Bluetooth Scan',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () => disconnect(devices[0]),
            child: const Text('Disconnect'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                if (devices[index].advName != '') {
                  return ListTile(
                    title: Text(devices[index].advName),
                    subtitle: Text(
                      devices[index].remoteId.toString(),
                    ),
                    onTap: () async {
                      try {
                        if (devices.isNotEmpty) {
                          connect(devices[index]);
                          openDialog(devices[index]);
                        }
                      } catch (e) {
                        print('Error in onTap: $e');
                      }
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple,
        height: 80,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                goToDeviceControl(devices[0]);
              },
              child: const Text('Control Page'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          setState(() {
            devices.clear();
          });
          startScan();
        },
        shape: const CircleBorder(side: BorderSide.none, eccentricity: 0.0),
        child: const Icon(
          Icons.bluetooth,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
