import { createApp } from './app';
import { config } from './config/env';
import { redisStore } from './memory/redisStore';

const app = createApp();

async function start() {
  try {
    // Connect to Redis
    await redisStore.connect(process.env.REDIS_URL || 'redis://localhost:6379');
    console.log('Redis connected');
  } catch (err) {
    console.warn('Redis connection failed, using memory store:', err);
  }

  app.listen(config.port, () => {
    console.log(`Cat Cafe Runtime Server`);
    console.log(`Environment: ${config.nodeEnv}`);
    console.log(`Port: ${config.port}`);
    console.log(`CLI Timeout: ${config.cli.timeoutMs}ms`);
    console.log(`Data Directory: ${config.data.dataDir}`);
    console.log(`Server ready at http://localhost:${config.port}`);
  });
}

start().catch(err => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
