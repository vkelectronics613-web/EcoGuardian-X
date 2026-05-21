import { evaluateSafeDirections } from './safety.js';

export function createScanScheduler({ telemetryStore, io }) {
  let simulator;

  setInterval(() => {
    queueRescan('EGX-001');
  }, 24 * 60 * 60 * 1000);

  async function queueRescan(robotId) {
    io.emit('scan_status', {
      robot_id: robotId,
      status: 'daily_rescan_requested',
      timestamp: new Date().toISOString(),
    });
  }

  function startSimulator(robotId) {
    stopSimulator();
    let tick = 0;
    simulator = setInterval(async () => {
      tick += 1;
      const row = createDemoTelemetry(robotId, tick);
      await telemetryStore.insertTelemetry(row);
      io.emit('telemetry', {
        x: row.x,
        y: row.y,
        aqi: row.aqi,
        front: row.front,
        left: row.left,
        right: row.right,
        back: row.back,
        battery: row.battery,
        obstacle: row.obstacle,
      });
      if (row.obstacle) io.emit('obstacle', row);
    }, 1000);
  }

  function stopSimulator() {
    if (simulator) clearInterval(simulator);
    simulator = undefined;
  }

  return { queueRescan, startSimulator, stopSimulator };
}

function createDemoTelemetry(robotId, tick) {
  const row = {
    robot_id: robotId,
    x: 4 + (tick % 8),
    y: 2 + (Math.floor(tick / 2) % 7),
    aqi: tick % 11 === 0 ? 'DANGEROUS' : tick % 4 === 0 ? 'MODERATE' : 'GOOD',
    front: tick % 9 === 0 ? 36 : 190 + Math.round(Math.sin(tick / 4) * 50),
    left: 90 + Math.round(Math.cos(tick / 3) * 45),
    right: 210,
    back: 120,
    battery: Math.max(18, 90 - (tick % 70)),
    obstacle: tick % 9 === 0,
    timestamp: new Date().toISOString(),
  };
  row.safe_directions = evaluateSafeDirections(row);
  return row;
}
