import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/robot_models.dart';
import '../../core/state/robot_controller.dart';
import '../../shared/widgets/frosted_panel.dart';
import '../map/mini_map.dart';

class TrackScreen extends ConsumerWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final robot = ref.watch(robotControllerProvider);
    final telemetry = robot.telemetry ?? Telemetry.demo(robot.demoTick);
    return Scaffold(
      appBar: AppBar(title: const Text('Robot Track', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          FrostedPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Live coordinates X:${telemetry.x} Y:${telemetry.y}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Scans stored this session: ${robot.history.length}', style: const TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 460, child: FrostedPanel(child: MiniMap(telemetry: telemetry, history: robot.history, interactive: true))),
          const SizedBox(height: 16),
          FrostedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Scan History', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 8),
                for (final sample in robot.history.reversed.take(8))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.route_rounded),
                    title: Text('X:${sample.x} Y:${sample.y} • ${sample.aqi.label}'),
                    subtitle: Text('${sample.front} cm front clearance'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
