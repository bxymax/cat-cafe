import { createApp } from './app';
import { config } from './config/env';

const app = createApp();

app.listen(config.port, () => {
  console.log(`Cat Cafe Runtime Server`);
  console.log(`Environment: ${config.nodeEnv}`);
  console.log(`Port: ${config.port}`);
  console.log(`CLI Timeout: ${config.cli.timeoutMs}ms`);
  console.log(`Data Directory: ${config.data.dataDir}`);
  console.log(`Server ready at http://localhost:${config.port}`);
});
