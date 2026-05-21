import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/robot_controller.dart';
import '../../shared/widgets/frosted_panel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final robot = ref.watch(robotControllerProvider);
    final controller = ref.read(robotControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          FrostedPanel(
            child: Column(
              children: [
                _Tile(title: 'Reconnect robot', icon: Icons.sync_rounded, onTap: robot.profile == null ? null : () => controller.connectWifi(robot.profile!)),
                _Tile(title: 'Disconnect robot', icon: Icons.link_off_rounded, onTap: controller.disconnect),
                _Tile(title: 'Reset map', icon: Icons.layers_clear_rounded, onTap: () {}),
                _Tile(title: 'Recalibrate sensors', icon: Icons.settings_input_component_rounded, onTap: () {}),
                _Tile(title: 'Change WiFi', icon: Icons.wifi_rounded, onTap: () => Navigator.of(context).pushReplacementNamed('/')),
                _Tile(title: 'Clear saved robots', icon: Icons.delete_outline_rounded, onTap: controller.clearRobot),
                _Tile(title: 'Export reports', icon: Icons.ios_share_rounded, onTap: () {}),
                SwitchListTile(value: true, onChanged: (_) {}, title: const Text('Dark operating mode'), secondary: const Icon(Icons.dark_mode_rounded)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FrostedPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Robot Information', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 8),
              Text('ID: ${robot.profile?.robotId ?? 'Not paired'}'),
              Text('Bluetooth: ${robot.profile?.bluetoothName ?? 'Not paired'}'),
              Text('Connection: ${robot.connected ? 'Persistent WiFi socket' : 'Standby'}'),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.icon, required this.onTap});
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
}
