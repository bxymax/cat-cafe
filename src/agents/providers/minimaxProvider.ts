import { AgentProvider, AgentRequest } from '../types';
import { spawnCli } from '../../runtime/spawnCli';
import { config } from '../../config/env';

export class MinimaxProvider implements AgentProvider {
  name = 'minimax-opencode';

  async invoke(request: AgentRequest) {
    const startTime = Date.now();

    // Build opencode CLI command for Minimax M2.5
    const args = [
      'chat',
      '--model', 'minimax-m2.5',
      '--message', request.message,
      '--thread-id', request.threadId,
    ];

    let outputBuffer = '';

    const result = await spawnCli({
      command: config.cli.opencodePath,
      args,
      timeoutMs: config.cli.timeoutMs,
      onStdout: (data) => {
        outputBuffer += data;
      },
      onStderr: (data) => {
        console.error('[MinimaxProvider stderr]', data);
      },
    });

    if (result.timedOut) {
      throw new Error('CLI process timed out');
    }

    if (result.cancelled) {
      throw new Error('CLI process was cancelled');
    }

    if (result.exitCode !== 0) {
      throw new Error(`CLI process exited with code ${result.exitCode}: ${result.stderr}`);
    }

    return {
      content: outputBuffer.trim() || result.stdout.trim(),
      metadata: {
        model: 'minimax-m2.5',
        duration: Date.now() - startTime,
      },
    };
  }
}
