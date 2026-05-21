import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/robot_models.dart';

class LocalRobotStore {
  static const _key = 'ecoguardian.saved_robot';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveRobot(RobotProfile profile) =>
      _storage.write(key: _key, value: jsonEncode(profile.toJson()));

  Future<RobotProfile?> loadRobot() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    return RobotProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clear() => _storage.delete(key: _key);
}
