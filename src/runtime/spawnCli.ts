import { spawn, ChildProcess } from 'child_process';

export interface CliSpawnOptions {
  command: string;
  args: string[];
  timeoutMs: number;
  signal?: AbortSignal;
  onStdout?: (data: string) => void;
  onStderr?: (data: string) => void;
  onLine?: (line: string) => void;
  cwd?: string; // Working directory for the subprocess
}

export interface CliSpawnResult {
  exitCode: number | null;
  signal: string | null;
  stdout: string;
  stderr: string;
  timedOut: boolean;
  cancelled: boolean;
}

/**
 * Spawn CLI subprocess with unified stdout/stderr monitoring
 * CRITICAL: Both stdout AND stderr refresh activity timer to prevent false timeout
 */
export async function spawnCli(options: CliSpawnOptions): Promise<CliSpawnResult> {
  const { command, args, timeoutMs, signal, onStdout, onStderr, onLine, cwd } = options;

  return new Promise((resolve, reject) => {
    const result: CliSpawnResult = {
      exitCode: null,
      signal: null,
      stdout: '',
      stderr: '',
      timedOut: false,
      cancelled: false,
    };

    let proc: ChildProcess | null = null;
    let timeoutHandle: NodeJS.Timeout | null = null;
    let lastActivityTime = Date.now();

    const refreshActivity = () => {
      lastActivityTime = Date.now();
      if (timeoutHandle) {
        clearTimeout(timeoutHandle);
      }
      timeoutHandle = setTimeout(() => {
        if (proc && !proc.killed) {
          result.timedOut = true;
          proc.kill('SIGTERM');
          setTimeout(() => {
            if (proc && !proc.killed) {
              proc.kill('SIGKILL');
            }
          }, 5000);
        }
      }, timeoutMs);
    };

    const cleanup = () => {
      if (timeoutHandle) {
        clearTimeout(timeoutHandle);
        timeoutHandle = null;
      }
      if (signal) {
        signal.removeEventListener('abort', abortHandler);
      }
    };

    const abortHandler = () => {
      result.cancelled = true;
      if (proc && !proc.killed) {
        proc.kill('SIGTERM');
      }
      cleanup();
    };

    if (signal) {
      if (signal.aborted) {
        result.cancelled = true;
        return resolve(result);
      }
      signal.addEventListener('abort', abortHandler);
    }

    try {
      proc = spawn(command, args, {
        stdio: ['pipe', 'pipe', 'pipe'], // Use pipe for stdin instead of ignore
        env: process.env, // Inherit parent process environment variables
        cwd: cwd || process.cwd(), // Use specified working directory or current
      });

      // Close stdin immediately to prevent hanging
      if (proc.stdin) {
        proc.stdin.end();
      }

      refreshActivity();

      proc.stdout?.on('data', (chunk: Buffer) => {
        const data = chunk.toString();
        result.stdout += data;
        refreshActivity(); // stdout activity refreshes timeout

        if (onStdout) {
          onStdout(data);
        }

        if (onLine) {
          const lines = data.split('\n');
          lines.forEach(line => {
            if (line.trim()) {
              onLine(line);
            }
          });
        }
      });

      proc.stderr?.on('data', (chunk: Buffer) => {
        const data = chunk.toString();
        result.stderr += data;
        refreshActivity(); // stderr activity ALSO refreshes timeout (critical fix)

        if (onStderr) {
          onStderr(data);
        }
      });

      proc.on('error', (err) => {
        cleanup();
        reject(err);
      });

      proc.on('close', (code, sig) => {
        result.exitCode = code;
        result.signal = sig;
        cleanup();
        resolve(result);
      });

    } catch (err) {
      cleanup();
      reject(err);
    }
  });
}
