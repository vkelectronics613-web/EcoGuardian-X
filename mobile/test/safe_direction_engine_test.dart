import 'package:ecoguardian_x/src/core/models/robot_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recommends a clear low-pollution route with strongest clearance', () {
    final telemetry = Telemetry(
      x: 5,
      y: 3,
      aqi: AqiLevel.good,
      front: 45,
      left: 120,
      right: 230,
      back: 80,
      battery: 78,
      obstacle: true,
      timestamp: DateTime(2026),
    );

    final directions = SafeDirectionEngine.evaluate(telemetry);
    final recommended = directions.singleWhere((item) => item.recommended);

    expect(recommended.direction, Direction.right);
    expect(directions.firstWhere((item) => item.direction == Direction.front).blocked, isTrue);
  });
}
