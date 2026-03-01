import { AgentProvider, AgentRequest } from '../types';
import { spawnCli } from '../../runtime/spawnCli';
import { config } from '../../config/env';

export class GPT52Provider implements AgentProvider {
  name = 'gpt52-opencode';

  async invoke(request: AgentRequest) {
    const startTime = Date.now();

    // Build opencode CLI command for GPT-5.2
    const args = [
      'chat',
      '--model', 'gpt-5.2',
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
        console.error('[GPT52Provider stderr]', data);
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
        model: 'gpt-5.2',
        duration: Date.now() - startTime,
      },
    };
  }
}
