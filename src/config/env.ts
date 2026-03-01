import dotenv from 'dotenv';
import path from 'path';

dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',

  cli: {
    timeoutMs: parseInt(process.env.CLI_TIMEOUT_MS || '300000', 10),
    opencodePath: process.env.CLI_OPENCODE_PATH || 'opencode',
  },

  data: {
    dataDir: path.resolve(process.env.DATA_DIR || './data'),
    transcriptsDir: path.resolve(process.env.TRANSCRIPTS_DIR || './data/transcripts'),
  },
};
