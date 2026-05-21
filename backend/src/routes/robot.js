import { Router } from 'express';
import { z } from 'zod';

import { evaluateSafeDirections } from '../services/safety.js';

const telemetrySchema = z.object({
  robot_id: z.string().default('EGX-001'),
  x: z.number(),
  y: z.number(),
  aqi: z.enum(['GOOD', 'MODERATE', 'DANGEROUS', 'HIGH', 'POOR']).default('MODERATE'),
  front: z.number().nonnegative(),
  left: z.number().nonnegative(),
  right: z.number().nonnegative(),
  back: z.number().nonnegative(),
  battery: z.number().min(0).max(100),
  obstacle: z.boolean(),
});

export function createRobotRouter({ io, telemetryStore, scheduler }) {
  const router = Router();

  router.post('/telemetry', async (req, res) => {
    const apiKey = req.header('x-robot-key');
    if (process.env.ROBOT_API_KEY && apiKey !== process.env.ROBOT_API_KEY) {
      return res.status(401).json({ error: 'Invalid robot API key' });
    }

    const telemetry = telemetrySchema.parse(req.body);
    const enriched = {
      ...telemetry,
      timestamp: new Date().toISOString(),
      safe_directions: evaluateSafeDirections(telemetry),
    };

    await telemetryStore.insertTelemetry(enriched);
    io.emit('telemetry', toAppPayload(enriched));
    io.to(`robot:${telemetry.robot_id}`).emit('telemetry', toAppPayload(enriched));

    if (telemetry.obstacle) io.emit('obstacle', toAppPayload(enriched));
    res.json({ ok: true, recommendation: enriched.safe_directions[0] });
  });

  router.get('/:robotId/history', async (req, res) => {
    const rows = await telemetryStore.getHistory(req.params.robotId, Number(req.query.limit ?? 200));
    res.json({ robot_id: req.params.robotId, rows });
  });

  router.post('/:robotId/rescan', async (req, res) => {
    scheduler.queueRescan(req.params.robotId);
    res.json({ ok: true, status: 'rescan_queued' });
  });

  router.post('/simulate/start', (req, res) => {
    scheduler.startSimulator(req.body?.robot_id ?? 'EGX-001');
    res.json({ ok: true, status: 'simulator_started' });
  });

  router.post('/simulate/stop', (_req, res) => {
    scheduler.stopSimulator();
    res.json({ ok: true, status: 'simulator_stopped' });
  });

  return router;
}

function toAppPayload(row) {
  return {
    x: row.x,
    y: row.y,
    aqi: normalizeAqi(row.aqi),
    front: row.front,
    left: row.left,
    right: row.right,
    back: row.back,
    battery: row.battery,
    obstacle: row.obstacle,
  };
}

function normalizeAqi(aqi) {
  if (aqi === 'HIGH' || aqi === 'POOR') return 'DANGEROUS';
  return aqi;
}
