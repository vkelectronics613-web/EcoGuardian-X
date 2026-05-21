# EcoGuardian X ESP32 Integration

## QR payload

Print a QR code containing:

```json
{
  "robot_name": "EcoGuardian_X",
  "bt_name": "EcoGuardian_X_BT",
  "robot_id": "EGX-001",
  "version": "1.0"
}
```

## Bluetooth provisioning

Expose a writable BLE characteristic on the ESP32. The app writes:

```json
{
  "type": "wifi_credentials",
  "robot_id": "EGX-001",
  "ssid": "HomeWiFi",
  "password": "secret"
}
```

After WiFi connects, the ESP32 should make its HTTP/WebSocket service reachable on the LAN and expose the ESP32-CAM MJPEG stream at `/stream` on port `81`.

## WiFi telemetry

Send telemetry once per second to the backend or local robot gateway:

```http
POST /api/robot/telemetry
x-robot-key: shared-secret
content-type: application/json
```

```json
{
  "robot_id": "EGX-001",
  "x": 5,
  "y": 3,
  "aqi": "MODERATE",
  "front": 230,
  "left": 40,
  "right": 180,
  "back": 120,
  "battery": 78,
  "obstacle": true
}
```

AQI should be derived from MQ135 calibration bands. Ultrasonic clearances are centimeters.
