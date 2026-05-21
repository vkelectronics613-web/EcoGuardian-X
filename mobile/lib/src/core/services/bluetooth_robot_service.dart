import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/robot_models.dart';

class BluetoothRobotService {
  Future<RobotProfile> provisionWifi(RobotQrPayload qr, String ssid, String password) async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (await FlutterBluePlus.isSupported == false) {
      throw StateError('Bluetooth is not supported on this device.');
    }

    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      await FlutterBluePlus.turnOn();
    }

    BluetoothDevice? target;
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));
    await for (final results in FlutterBluePlus.scanResults) {
      for (final result in results) {
        final advertisedName = result.advertisementData.advName;
        final platformName = result.device.platformName;
        if (advertisedName == qr.bluetoothName || platformName == qr.bluetoothName) {
          target = result.device;
          break;
        }
      }
      if (target != null) break;
    }
    await FlutterBluePlus.stopScan();

    if (target == null) {
      return RobotProfile(
        robotId: qr.robotId,
        robotName: qr.robotName,
        bluetoothName: qr.bluetoothName,
        macAddress: 'SIMULATED-BLE',
        localIp: 'ecoguardianx.local',
      );
    }

    await target.connect(timeout: const Duration(seconds: 12));
    final services = await target.discoverServices();
    final characteristics = services.expand((service) => service.characteristics).toList();
    final writable = characteristics.where((characteristic) => characteristic.properties.write).toList();
    final responseCharacteristic = characteristics
        .where((characteristic) => characteristic.properties.notify || characteristic.properties.read)
        .toList();

    if (writable.isEmpty) {
      throw StateError('Robot BLE provisioning characteristic not found.');
    }

    final payload = utf8.encode(jsonEncode({
      'type': 'wifi_credentials',
      'robot_id': qr.robotId,
      'ssid': ssid,
      'password': password,
    }));
    await writable.first.write(payload, withoutResponse: false);
    final response = await _readProvisioningResponse(responseCharacteristic);

    return RobotProfile(
      robotId: qr.robotId,
      robotName: qr.robotName,
      bluetoothName: qr.bluetoothName,
      macAddress: target.remoteId.str,
      localIp: response['local_ip']?.toString() ?? 'ecoguardianx.local',
      streamPath: response['stream_path']?.toString() ?? '/stream',
    );
  }

  Future<Map<String, dynamic>> _readProvisioningResponse(
    List<BluetoothCharacteristic> responseCharacteristics,
  ) async {
    if (responseCharacteristics.isEmpty) return const {};
    final characteristic = responseCharacteristics.first;
    try {
      if (characteristic.properties.notify) {
        await characteristic.setNotifyValue(true);
        final bytes = await characteristic.lastValueStream.first.timeout(const Duration(seconds: 15));
        return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      }
      final bytes = await characteristic.read().timeout(const Duration(seconds: 10));
      return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } catch (_) {
      return const {};
    }
  }
}
