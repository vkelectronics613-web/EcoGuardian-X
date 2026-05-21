import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/models/robot_models.dart';
import '../../core/state/robot_controller.dart';
import '../../shared/widgets/frosted_panel.dart';
import '../map/mini_map.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final robot = ref.watch(robotControllerProvider);
    final telemetry = robot.telemetry ?? Telemetry.demo(robot.demoTick);
    final best = robot.directions.firstWhere((item) => item.recommended, orElse: () => robot.directions.first);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoGuardian X', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              avatar: Icon(robot.connected ? Icons.sensors_rounded : Icons.sensors_off_rounded, size: 18),
              label: Text(robot.connected ? 'ONLINE' : 'DEMO'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          _HeroDirection(best: best),
          const SizedBox(height: 16),
          _DirectionGrid(directions: robot.directions),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _MetricCard(title: 'Battery', value: '${telemetry.battery}%', icon: Icons.battery_charging_full_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(title: 'AQI', value: telemetry.aqi.label, icon: Icons.air_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          FrostedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Live Map', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                SizedBox(height: 180, child: MiniMap(telemetry: telemetry, history: robot.history)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _CameraPreview(streamUrl: robot.profile?.streamUrl),
          const SizedBox(height: 16),
          FrostedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coordinates X:${telemetry.x} Y:${telemetry.y}', style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(label: robot.wifiReady ? 'WiFi linked' : 'WiFi standby'),
                    _StatusPill(label: robot.bluetoothReady ? 'Bluetooth ready' : 'Bluetooth idle'),
                    _StatusPill(label: telemetry.obstacle ? 'Obstacle detected' : 'Path scanning'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FrostedPanel(
            glow: telemetry.obstacle ? EcoGuardianTheme.danger : EcoGuardianTheme.cyan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Alerts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 10),
                for (final alert in robot.alerts) Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [const Icon(Icons.warning_amber_rounded, size: 18), const SizedBox(width: 8), Expanded(child: Text(alert))]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDirection extends StatefulWidget {
  const _HeroDirection({required this.best});
  final DirectionRecommendation best;

  @override
  State<_HeroDirection> createState() => _HeroDirectionState();
}

class _HeroDirectionState extends State<_HeroDirection> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final glow = Color.lerp(EcoGuardianTheme.neon, EcoGuardianTheme.cyan, controller.value)!;
        return FrostedPanel(
          glow: glow,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.best.label} RECOMMENDED', style: const TextStyle(fontSize: 31, height: 1.02, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Text('${widget.best.clearance} cm clearance • ${widget.best.aqi.label} AQI • Safety ${widget.best.score}'),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: widget.best.score / 100, minHeight: 9, borderRadius: BorderRadius.circular(999)),
            ],
          ),
        );
      },
    );
  }
}

class _DirectionGrid extends StatelessWidget {
  const _DirectionGrid({required this.directions});
  final List<DirectionRecommendation> directions;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.45,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        for (final direction in directions)
          FrostedPanel(
            glow: direction.blocked ? EcoGuardianTheme.danger : direction.recommended ? EcoGuardianTheme.neon : EcoGuardianTheme.warning,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(direction.blocked ? '${direction.label} BLOCKED' : '${direction.label} SAFE', style: const TextStyle(fontWeight: FontWeight.w900)),
                const Spacer(),
                Text('${direction.clearance} cm'),
                Text('Score ${direction.score}', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: EcoGuardianTheme.neon),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Chip(label: Text(label), side: BorderSide(color: EcoGuardianTheme.neon.withOpacity(.3)));
}

class _CameraPreview extends StatelessWidget {
  const _CameraPreview({required this.streamUrl});
  final String? streamUrl;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ESP32-CAM', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: streamUrl == null
                  ? Container(
                      color: Colors.black,
                      child: const Center(child: Text('Camera stream armed after robot pairing')),
                    )
                  : Mjpeg(
                      stream: streamUrl!,
                      isLive: true,
                      error: (_, __, ___) => const Center(child: Text('Reconnecting camera stream')),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
