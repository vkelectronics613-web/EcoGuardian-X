import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/robot_models.dart';
import '../../core/state/robot_controller.dart';
import '../../shared/widgets/frosted_panel.dart';
import 'mini_map.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final robot = ref.watch(robotControllerProvider);
    final telemetry = robot.telemetry ?? Telemetry.demo(robot.demoTick);
    return Scaffold(
      appBar: AppBar(title: const Text('Indoor Map', style: TextStyle(fontWeight: FontWeight.w900))),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: FrostedPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Live obstacle and safe path visualization', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              Expanded(child: MiniMap(telemetry: telemetry, history: robot.history, interactive: true)),
            ],
          ),
        ),
      ),
    );
  }
}
