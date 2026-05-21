import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../models/robot_models.dart';

class RobotSocketService {
  final StreamController<Telemetry> _telemetry = StreamController.broadcast();
  io.Socket? _socket;

  Stream<Telemetry> get telemetry => _telemetry.stream;

  Future<void> connect(String? host) async {
    final url = host == null || host.isEmpty ? 'http://localhost:8080' : 'http://$host:8080';
    _socket?.dispose();
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(800)
          .build(),
    );
    _socket!
      ..on('telemetry', (data) {
        if (data is Map) {
          _telemetry.add(Telemetry.fromJson(Map<String, dynamic>.from(data)));
        }
      })
      ..on('obstacle', (data) {
        if (data is Map) {
          _telemetry.add(Telemetry.fromJson(Map<String, dynamic>.from(data)));
        }
      })
      ..connect();
  }

  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
