const { spawn } = require('child_process');
const path = require('path');

console.log('Testing opencode spawn...');
console.log('Node version:', process.version);
console.log('Platform:', process.platform);

const opencodePath = 'C:\\Users\\bai\\.opencode\\bin\\opencode.exe';
const args = ['run', '--model', 'openai/gpt-5.2', '你好'];

console.log('Command:', opencodePath);
console.log('Args:', args);

const proc = spawn(opencodePath, args, {
  env: process.env,
  windowsHide: true,
  stdio: ['pipe', 'pipe', 'pipe'], // Change from ignore to pipe for stdin
});

// Close stdin immediately
if (proc.stdin) {
  proc.stdin.end();
}

let stdout = '';
let stderr = '';

proc.stdout.on('data', (data) => {
  stdout += data.toString();
  console.log('[stdout]', data.toString());
});

proc.stderr.on('data', (data) => {
  stderr += data.toString();
  console.error('[stderr]', data.toString());
});

proc.on('close', (code) => {
  console.log('Exit code:', code);
  console.log('Stdout length:', stdout.length);
  console.log('Stderr length:', stderr.length);
  if (code !== 0) {
    console.error('Error output:', stderr);
  }
});

proc.on('error', (err) => {
  console.error('Process error:', err);
});
