import 'dotenv/config';
import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import http from 'http';
import morgan from 'morgan';
import { Server } from 'socket.io';

import { createRobotRouter } from './routes/robot.js';
import { createScanScheduler } from './services/scanScheduler.js';
import { createTelemetryStore } from './services/telemetryStore.js';

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
});

const telemetryStore = createTelemetryStore();
const scheduler = createScanScheduler({ telemetryStore, io });

app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '256kb' }));
app.use(morgan('dev'));

app.get('/health', (_req, res) => {
  res.json({ ok: true, product: 'EcoGuardian X', transport: 'wifi-websocket' });
});

app.use('/api/robot', createRobotRouter({ io, telemetryStore, scheduler }));

io.on('connection', (socket) => {
  socket.emit('system', { status: 'connected', message: 'EcoGuardian X realtime channel ready' });
  socket.on('subscribe_robot', ({ robotId }) => socket.join(`robot:${robotId}`));
});

const port = Number(process.env.PORT ?? 8080);
server.listen(port, () => {
  console.log(`EcoGuardian X backend listening on ${port}`);
});
