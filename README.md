# EcoGuardian X

EcoGuardian X is an Android-first Flutter mobile app plus a Node.js realtime backend for an ESP32 / ESP32-CAM environmental navigation robot.

## What is included

- Flutter mobile app using Material 3 and Riverpod.
- QR onboarding with `mobile_scanner`.
- Bluetooth provisioning service using `flutter_blue_plus`.
- Secure local robot storage.
- Socket.IO telemetry client.
- MJPEG ESP32-CAM rendering.
- Safe direction engine using obstacle clearance, AQI, and score ranking.
- Home, Map, AQI Map, Track, and Settings sections.
- Node.js Express + Socket.IO backend.
- Supabase PostgreSQL schema for telemetry, scans, and history.
- ESP32 integration notes in `docs/esp32_integration.md`.

## Mobile setup

```bash
cd mobile
flutter pub get
flutter run
```

Android permissions are declared in `mobile/android/app/src/main/AndroidManifest.xml` for Bluetooth, WiFi/network state, camera, notifications, and location required by BLE scanning.

## Backend setup

```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

To simulate robot telemetry:

```bash
curl -X POST http://localhost:8080/api/robot/simulate/start -H "content-type: application/json" -d "{\"robot_id\":\"EGX-001\"}"
```

## Supabase

Run `docs/supabase_schema.sql` in the Supabase SQL editor, then configure:

```bash
SUPABASE_URL=...
SUPABASE_SERVICE_ROLE_KEY=...
ROBOT_API_KEY=...
```

## Production notes

Bluetooth is intentionally limited to onboarding, WiFi provisioning, and emergency reconnect. Real telemetry, obstacle updates, AQI history, map updates, and camera preview use WiFi transports: HTTP, WebSocket, and MJPEG. The safe-direction system is deterministic and robotics-realistic: obstacle-free directions win first, then AQI quality, then larger ultrasonic clearance.
