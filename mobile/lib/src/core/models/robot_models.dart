import 'dart:convert';
import 'dart:math';

enum AqiLevel {
  good,
  moderate,
  dangerous;

  static AqiLevel parse(String value) {
    switch (value.toUpperCase()) {
      case 'GOOD':
        return AqiLevel.good;
      case 'DANGEROUS':
      case 'HIGH':
      case 'POOR':
        return AqiLevel.dangerous;
      default:
        return AqiLevel.moderate;
    }
  }

  int get penalty => switch (this) {
        AqiLevel.good => 0,
        AqiLevel.moderate => 20,
        AqiLevel.dangerous => 45,
      };

  String get label => switch (this) {
        AqiLevel.good => 'Good',
        AqiLevel.moderate => 'Moderate',
        AqiLevel.dangerous => 'Dangerous',
      };
}

enum Direction { front, left, right, back }

class RobotQrPayload {
  const RobotQrPayload({
    required this.robotName,
    required this.bluetoothName,
    required this.robotId,
    required this.version,
  });

  final String robotName;
  final String bluetoothName;
  final String robotId;
  final String version;

  factory RobotQrPayload.fromRaw(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return RobotQrPayload(
      robotName: json['robot_name'] as String,
      bluetoothName: json['bt_name'] as String,
      robotId: json['robot_id'] as String,
      version: json['version'] as String,
    );
  }
}

class RobotProfile {
  const RobotProfile({
    required this.robotId,
    required this.robotName,
    required this.bluetoothName,
    this.macAddress,
    this.localIp,
    this.streamPath = '/stream',
  });

  final String robotId;
  final String robotName;
  final String bluetoothName;
  final String? macAddress;
  final String? localIp;
  final String streamPath;

  String? get streamUrl => localIp == null ? null : 'http://$localIp:81$streamPath';

  Map<String, dynamic> toJson() => {
        'robotId': robotId,
        'robotName': robotName,
        'bluetoothName': bluetoothName,
        'macAddress': macAddress,
        'localIp': localIp,
        'streamPath': streamPath,
      };

  factory RobotProfile.fromJson(Map<String, dynamic> json) => RobotProfile(
        robotId: json['robotId'] as String,
        robotName: json['robotName'] as String,
        bluetoothName: json['bluetoothName'] as String,
        macAddress: json['macAddress'] as String?,
        localIp: json['localIp'] as String?,
        streamPath: json['streamPath'] as String? ?? '/stream',
      );
}

class Telemetry {
  const Telemetry({
    required this.x,
    required this.y,
    required this.aqi,
    required this.front,
    required this.left,
    required this.right,
    required this.back,
    required this.battery,
    required this.obstacle,
    required this.timestamp,
  });

  final int x;
  final int y;
  final AqiLevel aqi;
  final int front;
  final int left;
  final int right;
  final int back;
  final int battery;
  final bool obstacle;
  final DateTime timestamp;

  factory Telemetry.fromJson(Map<String, dynamic> json) => Telemetry(
        x: (json['x'] as num?)?.round() ?? 0,
        y: (json['y'] as num?)?.round() ?? 0,
        aqi: AqiLevel.parse(json['aqi']?.toString() ?? 'MODERATE'),
        front: (json['front'] as num?)?.round() ?? 0,
        left: (json['left'] as num?)?.round() ?? 0,
        right: (json['right'] as num?)?.round() ?? 0,
        back: (json['back'] as num?)?.round() ?? 0,
        battery: (json['battery'] as num?)?.round() ?? 0,
        obstacle: json['obstacle'] == true,
        timestamp: DateTime.now(),
      );

  static Telemetry demo([int tick = 0]) {
    final wave = sin(tick / 5);
    return Telemetry(
      x: 5 + (tick % 8),
      y: 3 + ((tick ~/ 2) % 6),
      aqi: tick % 9 == 0 ? AqiLevel.dangerous : tick % 4 == 0 ? AqiLevel.moderate : AqiLevel.good,
      front: 170 + (wave * 70).round(),
      left: tick % 7 == 0 ? 34 : 110,
      right: 220,
      back: 120,
      battery: max(18, 88 - tick % 50),
      obstacle: tick % 7 == 0,
      timestamp: DateTime.now(),
    );
  }
}

class DirectionRecommendation {
  const DirectionRecommendation({
    required this.direction,
    required this.clearance,
    required this.aqi,
    required this.score,
    required this.blocked,
    required this.recommended,
  });

  final Direction direction;
  final int clearance;
  final AqiLevel aqi;
  final int score;
  final bool blocked;
  final bool recommended;

  String get label => switch (direction) {
        Direction.front => 'FORWARD',
        Direction.left => 'LEFT',
        Direction.right => 'RIGHT',
        Direction.back => 'BACK',
      };

  String get symbol => switch (direction) {
        Direction.front => 'UP',
        Direction.left => 'LEFT',
        Direction.right => 'RIGHT',
        Direction.back => 'DOWN',
      };
}

class SafeDirectionEngine {
  static const minClearanceCm = 55;

  static List<DirectionRecommendation> evaluate(Telemetry telemetry) {
    final clearances = {
      Direction.front: telemetry.front,
      Direction.left: telemetry.left,
      Direction.right: telemetry.right,
      Direction.back: telemetry.back,
    };

    final raw = clearances.entries.map((entry) {
      final blocked = entry.value < minClearanceCm;
      final clearanceScore = min(60, (entry.value / 4).round());
      final score = blocked ? 0 : max(0, 100 - telemetry.aqi.penalty + clearanceScore - 25);
      return DirectionRecommendation(
        direction: entry.key,
        clearance: entry.value,
        aqi: telemetry.aqi,
        score: score,
        blocked: blocked,
        recommended: false,
      );
    }).toList();

    raw.sort((a, b) => b.score.compareTo(a.score));
    final bestDirection = raw.first.direction;
    return Direction.values.map((direction) {
      final item = raw.firstWhere((candidate) => candidate.direction == direction);
      return DirectionRecommendation(
        direction: item.direction,
        clearance: item.clearance,
        aqi: item.aqi,
        score: item.score,
        blocked: item.blocked,
        recommended: item.direction == bestDirection && !item.blocked,
      );
    }).toList();
  }
}
