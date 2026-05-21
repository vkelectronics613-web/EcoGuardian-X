import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/models/robot_models.dart';
import '../../core/state/robot_controller.dart';
import '../../shared/widgets/frosted_panel.dart';

class AqiMapScreen extends ConsumerWidget {
  const AqiMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final robot = ref.watch(robotControllerProvider);
    final history = robot.history.isEmpty ? List.generate(24, Telemetry.demo) : robot.history;
    return Scaffold(
      appBar: AppBar(title: const Text('AQI Map', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          FrostedPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Pollution Heatmap', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              AspectRatio(
                aspectRatio: 1.15,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 64,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8, crossAxisSpacing: 4, mainAxisSpacing: 4),
                  itemBuilder: (_, index) {
                    final level = history[index % history.length].aqi;
                    final color = level == AqiLevel.good ? EcoGuardianTheme.neon : level == AqiLevel.moderate ? EcoGuardianTheme.warning : EcoGuardianTheme.danger;
                    return DecoratedBox(decoration: BoxDecoration(color: color.withOpacity(.72), borderRadius: BorderRadius.circular(5)));
                  },
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          FrostedPanel(
            glow: EcoGuardianTheme.cyan,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Historical AQI Trend', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < history.length.clamp(0, 36); i++)
                            FlSpot(i.toDouble(), history[i].aqi == AqiLevel.good ? 30 : history[i].aqi == AqiLevel.moderate ? 65 : 95),
                        ],
                        isCurved: true,
                        color: EcoGuardianTheme.neon,
                        barWidth: 4,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const Text('Cleanest zone: north-east corridor', style: TextStyle(color: Colors.white70)),
            ]),
          ),
        ],
      ),
    );
  }
}
