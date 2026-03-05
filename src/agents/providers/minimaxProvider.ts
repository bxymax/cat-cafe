import { AgentProvider, AgentRequest } from '../types';
import { spawnCli } from '../../runtime/spawnCli';
import { config } from '../../config/env';

export class MinimaxProvider implements AgentProvider {
  name = 'minimax-opencode';

  async invoke(request: AgentRequest) {
    const startTime = Date.now();

    // Build opencode CLI command for Minimax M2.5
    // Use --title to create a new session with a descriptive name
    const args = [
      'run',
      '--model', 'minimax-cn/MiniMax-M2.5',
      '--title', `${request.userId}_${request.catId}_${request.threadId}`,
      request.message,
    ];

    let outputBuffer = '';
    let finalContent = '';

    const result = await spawnCli({
      command: config.cli.opencodePath,
      args,
      timeoutMs: config.cli.timeoutMs,
      onStdout: (data) => {
        outputBuffer += data;
        // Parse NDJSON events from opencode
        const lines = data.split('\n');
        for (const line of lines) {
          if (line.trim()) {
            try {
              const event = JSON.parse(line);
              // Extract text content from opencode events
              if (event.type === 'text' && event.part?.text) {
                finalContent += event.part.text;
              }
            } catch (e) {
              // Not JSON, might be plain text output
              // Ignore parsing errors
            }
          }
        }
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
      const errorMsg = result.stderr || result.stdout || 'Unknown error';
      console.error('[MinimaxProvider] CLI failed:', {
        exitCode: result.exitCode,
        stderr: result.stderr,
        stdout: result.stdout,
      });
      throw new Error(`CLI process exited with code ${result.exitCode}: ${errorMsg}`);
    }

    return {
      content: finalContent.trim() || outputBuffer.trim() || result.stdout.trim(),
      metadata: {
        model: 'minimax/minimax-m2.5',
        catId: request.catId,
        duration: Date.now() - startTime,
      },
    };
  }
}
