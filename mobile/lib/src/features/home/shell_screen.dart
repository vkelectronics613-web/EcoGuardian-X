import 'package:flutter/material.dart';

import '../aqi/aqi_map_screen.dart';
import '../map/map_screen.dart';
import '../settings/settings_screen.dart';
import '../track/track_screen.dart';
import 'home_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    MapScreen(),
    AqiMapScreen(),
    TrackScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_rounded), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.air_rounded), label: 'AQI'),
          NavigationDestination(icon: Icon(Icons.near_me_rounded), label: 'Track'),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
