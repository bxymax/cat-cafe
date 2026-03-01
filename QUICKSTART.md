# Quick Start Guide for External Agents

This guide helps external agents (GPT/Minimax via opencode CLI) understand and extend the Cat Cafe Runtime.

## What You're Working With

A minimal Node + TypeScript + Express backend that:
- Spawns CLI subprocesses to invoke AI models
- Manages isolated conversation sessions
- Persists all interactions to local files
- Provides a REST API for chat interactions

## Architecture at a Glance

```
Client Request → Express API → Provider Registry → CLI Subprocess → Model Response
                      ↓                                    ↓
                Session Manager                    Transcript Writer
```

## Key Files to Understand

### 1. `src/runtime/spawnCli.ts` - The Heart of the System
This is the most critical file. It handles:
- Spawning child processes for CLI commands
- Monitoring both stdout AND stderr (prevents false timeouts)
- Timeout management with graceful shutdown
- Cancellation support via AbortSignal

**Why it matters**: This prevents the "CLI writes to stderr, system thinks it's hung" bug.

### 2. `src/agents/providers/*.ts` - Model Integration Points
Each provider wraps a specific model's CLI invocation:
- Builds command arguments
- Handles output parsing
- Reports errors and metadata

**To add a new model**: Copy an existing provider and modify the CLI args.

### 3. `src/routes/chat.ts` - Request Flow
Shows the complete request lifecycle:
1. Validate input (Zod schema)
2. Get/create session
3. Log user message
4. Invoke provider
5. Log agent response
6. Return result

### 4. `src/session/sessionManager.ts` - Conversation Isolation
Sessions are keyed by `userId:catId:threadId` to ensure:
- Different threads don't share context
- Same user can have multiple conversations
- Each "cat" (agent type) has independent state

## Common Extension Points

### Adding a New Model

1. Create provider in `src/agents/providers/`:
```typescript
export class NewModelProvider implements AgentProvider {
  name = 'new-model';

  async invoke(request: AgentRequest) {
    const args = ['chat', '--model', 'new-model', ...];
    const result = await spawnCli({ command: 'cli-tool', args, ... });
    return { content: result.stdout, metadata: {...} };
  }
}
```

2. Register in `src/agents/registry.ts`:
```typescript
this.registerProvider('new-model', new NewModelProvider());
```

3. Update schema in `src/schemas/chat.ts`:
```typescript
model: z.enum(['gpt52', 'minimax-m2.5', 'new-model']),
```

### Adding Streaming Support

Current implementation returns aggregated responses. To add streaming:

1. Modify provider to use `onLine` callback in `spawnCli()`
2. Change route to use Server-Sent Events (SSE)
3. Stream chunks as they arrive from CLI

Example:
```typescript
res.setHeader('Content-Type', 'text/event-stream');
await spawnCli({
  ...options,
  onLine: (line) => {
    res.write(`data: ${JSON.stringify({ chunk: line })}\n\n`);
  }
});
```

### Adding Authentication

Add middleware in `src/app.ts`:
```typescript
import { authMiddleware } from './middleware/auth';
app.use('/api', authMiddleware);
```

### Migrating to Database Storage

Replace `sessionManager` and `transcriptWriter` with database implementations:
- Sessions → Redis (for fast access)
- Transcripts → PostgreSQL (for querying/analytics)

Keep the same interfaces, just swap implementations.

## Testing Your Changes

```bash
# Type check
npm run typecheck

# Start dev server
npm run dev

# Test health
curl http://localhost:3000/health

# Test chat (requires opencode CLI)
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "threadId": "test-001",
    "userId": "user-123",
    "catId": "architect",
    "message": "Hello!",
    "model": "gpt52"
  }'
```

## Debugging Tips

### CLI Process Hangs
- Check if both stdout AND stderr are being read
- Verify timeout is long enough for your model
- Look at `data/transcripts/*.jsonl` for error events

### Session Not Persisting
- Sessions are in-memory only (lost on restart)
- Check session key format: `userId:catId:threadId`
- Verify all three components are provided

### Transcript Not Writing
- Check `DATA_DIR` and `TRANSCRIPTS_DIR` in `.env`
- Ensure directory exists and is writable
- Look for errors in console output

## Environment Variables

```bash
# Server
PORT=3000
NODE_ENV=development

# CLI Runtime
CLI_TIMEOUT_MS=300000          # 5 minutes
CLI_OPENCODE_PATH=opencode     # or full path: /usr/local/bin/opencode

# Storage
DATA_DIR=./data
TRANSCRIPTS_DIR=./data/transcripts
```

## Production Considerations

Before deploying:
1. Add authentication/authorization
2. Implement rate limiting
3. Add request logging and monitoring
4. Migrate to persistent storage (Redis + PostgreSQL)
5. Add health checks for CLI availability
6. Configure proper error handling and retries
7. Set up log aggregation
8. Add metrics and alerting

## Questions?

Check these files:
- `README.md` - Basic usage
- `IMPLEMENTATION.md` - Detailed architecture
- `src/runtime/spawnCli.ts` - CLI subprocess implementation
- `src/routes/chat.ts` - Request flow example
