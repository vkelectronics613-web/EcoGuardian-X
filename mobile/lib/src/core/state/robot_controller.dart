import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/robot_models.dart';
import '../services/bluetooth_robot_service.dart';
import '../services/local_robot_store.dart';
import '../services/robot_socket_service.dart';

final robotControllerProvider = StateNotifierProvider<RobotController, RobotState>((ref) {
  return RobotController(
    store: LocalRobotStore(),
    bluetooth: BluetoothRobotService(),
    socket: RobotSocketService(),
  )..bootstrap();
});

class RobotState {
  const RobotState({
    this.profile,
    this.telemetry,
    this.history = const [],
    this.connected = false,
    this.bluetoothReady = false,
    this.wifiReady = false,
    this.cameraConnected = false,
    this.alerts = const ['Ready for secure robot pairing'],
    this.demoTick = 0,
  });

  final RobotProfile? profile;
  final Telemetry? telemetry;
  final List<Telemetry> history;
  final bool connected;
  final bool bluetoothReady;
  final bool wifiReady;
  final bool cameraConnected;
  final List<String> alerts;
  final int demoTick;

  List<DirectionRecommendation> get directions =>
      SafeDirectionEngine.evaluate(telemetry ?? Telemetry.demo(demoTick));

  RobotState copyWith({
    RobotProfile? profile,
    Telemetry? telemetry,
    List<Telemetry>? history,
    bool? connected,
    bool? bluetoothReady,
    bool? wifiReady,
    bool? cameraConnected,
    List<String>? alerts,
    int? demoTick,
  }) {
    return RobotState(
      profile: profile ?? this.profile,
      telemetry: telemetry ?? this.telemetry,
      history: history ?? this.history,
      connected: connected ?? this.connected,
      bluetoothReady: bluetoothReady ?? this.bluetoothReady,
      wifiReady: wifiReady ?? this.wifiReady,
      cameraConnected: cameraConnected ?? this.cameraConnected,
      alerts: alerts ?? this.alerts,
      demoTick: demoTick ?? this.demoTick,
    );
  }
}

class RobotController extends StateNotifier<RobotState> {
  RobotController({
    required this.store,
    required this.bluetooth,
    required this.socket,
  }) : super(const RobotState());

  final LocalRobotStore store;
  final BluetoothRobotService bluetooth;
  final RobotSocketService socket;
  StreamSubscription<Telemetry>? _telemetrySub;
  Timer? _demoTimer;

  Future<void> bootstrap() async {
    final saved = await store.loadRobot();
    if (saved != null) {
      state = state.copyWith(profile: saved, alerts: ['Saved robot found. Auto reconnect armed.']);
      await connectWifi(saved);
    } else {
      _startDemoTelemetry();
    }
  }

  Future<void> pair(RobotQrPayload qr, String ssid, String password) async {
    state = state.copyWith(bluetoothReady: true, alerts: ['Connecting to ${qr.bluetoothName}']);
    final provisioned = await bluetooth.provisionWifi(qr, ssid, password);
    await store.saveRobot(provisioned);
    state = state.copyWith(
      profile: provisioned,
      bluetoothReady: true,
      wifiReady: true,
      alerts: ['Robot joined WiFi. Secure profile saved locally.'],
    );
    await connectWifi(provisioned);
  }

  Future<void> connectWifi(RobotProfile profile) async {
    await _telemetrySub?.cancel();
    await socket.connect(profile.localIp);
    _telemetrySub = socket.telemetry.listen(_onTelemetry);
    state = state.copyWith(connected: true, wifiReady: true, profile: profile);
  }

  Future<void> disconnect() async {
    await socket.disconnect();
    state = state.copyWith(connected: false, wifiReady: false, alerts: ['Robot disconnected manually']);
    _startDemoTelemetry();
  }

  Future<void> clearRobot() async {
    await store.clear();
    await disconnect();
    state = const RobotState(alerts: ['Saved robots cleared']);
  }

  void markCamera(bool connected) => state = state.copyWith(cameraConnected: connected);

  void _onTelemetry(Telemetry telemetry) {
    final history = [...state.history, telemetry].takeLast(240).toList();
    final alerts = [...state.alerts];
    if (telemetry.obstacle) alerts.insert(0, 'New obstacle detected ahead');
    if (telemetry.battery < 20) alerts.insert(0, 'Battery low: ${telemetry.battery}%');
    if (telemetry.aqi == AqiLevel.dangerous) alerts.insert(0, 'High pollution zone detected');
    state = state.copyWith(
      telemetry: telemetry,
      history: history,
      connected: true,
      demoTick: state.demoTick + 1,
      alerts: alerts.take(5).toList(),
    );
  }

  void _startDemoTelemetry() {
    _demoTimer?.cancel();
    _demoTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.connected) return;
      _onTelemetry(Telemetry.demo(state.demoTick + 1));
    });
  }

  @override
  void dispose() {
    _telemetrySub?.cancel();
    _demoTimer?.cancel();
    socket.disconnect();
    super.dispose();
  }
}

extension _TakeLast<T> on List<T> {
  Iterable<T> takeLast(int count) => skip(length > count ? length - count : 0);
}
