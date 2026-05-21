import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/theme.dart';
import '../../core/models/robot_models.dart';
import '../../core/state/robot_controller.dart';
import '../../shared/widgets/frosted_panel.dart';

class ConnectRobotScreen extends ConsumerStatefulWidget {
  const ConnectRobotScreen({super.key});

  @override
  ConsumerState<ConnectRobotScreen> createState() => _ConnectRobotScreenState();
}

class _ConnectRobotScreenState extends ConsumerState<ConnectRobotScreen> {
  RobotQrPayload? payload;
  bool scanning = false;
  final ssid = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    ssid.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final robot = ref.watch(robotControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 24),
            const Text('EcoGuardian X', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Autonomous environmental navigation robot', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 28),
            if (scanning)
              SizedBox(
                height: 360,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: MobileScanner(
                    onDetect: (capture) {
                      final raw = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
                      if (raw == null) return;
                      setState(() {
                        payload = RobotQrPayload.fromRaw(raw);
                        scanning = false;
                      });
                    },
                  ),
                ),
              )
            else
              FrostedPanel(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.memory_rounded, size: 72, color: EcoGuardianTheme.neon),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => setState(() => scanning = true),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('Connect Robot'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        payload = const RobotQrPayload(
                          robotName: 'EcoGuardian_X',
                          bluetoothName: 'EcoGuardian_X_BT',
                          robotId: 'EGX-001',
                          version: '1.0',
                        );
                      }),
                      child: const Text('Use demo robot profile'),
                    ),
                  ],
                ),
              ),
            if (payload != null) ...[
              const SizedBox(height: 18),
              FrostedPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payload!.robotName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    Text('Robot ID ${payload!.robotId} • Firmware ${payload!.version}'),
                    const SizedBox(height: 18),
                    TextField(controller: ssid, decoration: const InputDecoration(labelText: 'Home WiFi Name')),
                    const SizedBox(height: 12),
                    TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Home WiFi Password')),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () async {
                        await ref.read(robotControllerProvider.notifier).pair(payload!, ssid.text, password.text);
                        if (context.mounted) Navigator.of(context).pushReplacementNamed('/home');
                      },
                      icon: const Icon(Icons.bluetooth_connected_rounded),
                      label: const Text('Pair & Provision WiFi'),
                    ),
                  ],
                ),
              ),
            ],
            if (robot.profile != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                icon: const Icon(Icons.memory_rounded),
                label: const Text('Open Command Center'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
