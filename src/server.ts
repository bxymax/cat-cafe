import { createApp } from './app';
import { config } from './config/env';
import { redisStore } from './memory/redisStore';

const app = createApp();

async function start() {
  // Temporarily disable Redis to unblock server startup
  // TODO: Fix Redis connection issue
  console.log('⚠️  Redis disabled temporarily');

  app.listen(config.port, () => {
    console.log(`\n🐱 Cat Cafe Runtime Server`);
    console.log(`Environment: ${config.nodeEnv}`);
    console.log(`Port: ${config.port}`);
    console.log(`CLI Timeout: ${config.cli.timeoutMs}ms`);
    console.log(`Data Directory: ${config.data.dataDir}`);
    console.log(`\n✨ Server ready at http://localhost:${config.port}\n`);
  });
}

start().catch(err => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
