import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/robot_models.dart';

class MiniMap extends StatelessWidget {
  const MiniMap({super.key, required this.telemetry, required this.history, this.interactive = false});

  final Telemetry telemetry;
  final List<Telemetry> history;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final painter = _MapPainter(telemetry: telemetry, history: history);
    return interactive
        ? InteractiveViewer(minScale: .8, maxScale: 4, child: CustomPaint(painter: painter, size: const Size.square(520)))
        : CustomPaint(painter: painter, size: Size.infinite);
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.telemetry, required this.history});
  final Telemetry telemetry;
  final List<Telemetry> history;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = EcoGuardianTheme.neon.withOpacity(.12)
      ..strokeWidth = 1;
    final cellW = size.width / 12;
    final cellH = size.height / 10;
    for (var i = 0; i <= 12; i++) {
      canvas.drawLine(Offset(i * cellW, 0), Offset(i * cellW, size.height), grid);
    }
    for (var i = 0; i <= 10; i++) {
      canvas.drawLine(Offset(0, i * cellH), Offset(size.width, i * cellH), grid);
    }

    final path = Paint()
      ..color = EcoGuardianTheme.cyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final route = Path();
    for (var i = 0; i < history.length; i++) {
      final point = Offset((history[i].x % 12 + .5) * cellW, (history[i].y % 10 + .5) * cellH);
      i == 0 ? route.moveTo(point.dx, point.dy) : route.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(route, path);

    final obstacle = Paint()..color = Colors.black;
    if (telemetry.obstacle) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH((telemetry.x % 12) * cellW, ((telemetry.y - 1) % 10) * cellH, cellW, cellH), const Radius.circular(4)),
        obstacle,
      );
    }

    final robot = Paint()..color = EcoGuardianTheme.neon;
    canvas.drawCircle(Offset((telemetry.x % 12 + .5) * cellW, (telemetry.y % 10 + .5) * cellH), 12, robot);
    canvas.drawCircle(Offset((telemetry.x % 12 + .5) * cellW, (telemetry.y % 10 + .5) * cellH), 24, Paint()..color = EcoGuardianTheme.neon.withOpacity(.12));
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => oldDelegate.telemetry != telemetry || oldDelegate.history.length != history.length;
}
