# Cat Cafe Runtime - Implementation Summary

## Project Overview

A minimal, production-ready Node + TypeScript + Express backend foundation designed for multi-model agent orchestration via CLI subprocess architecture. Built specifically for external agent development (opencode CLI with GPT/Minimax models).

## Core Architecture

### 1. CLI Subprocess Runtime (`src/runtime/spawnCli.ts`)
**Critical Feature**: Dual-channel activity monitoring
- Both `stdout` AND `stderr` refresh the timeout timer
- Prevents false timeout when CLI writes to stderr
- Supports AbortSignal for cancellation
- Graceful shutdown with SIGTERM → SIGKILL fallback

### 2. Multi-Model Provider System
**Fixed Architecture**: All models use opencode CLI
- `GPT52Provider`: opencode CLI with `--model gpt-5.2`
- `MinimaxProvider`: opencode CLI with `--model minimax-m2.5`
- `AgentRegistry`: Routes requests based on catId and model preference

### 3. Session Management (`src/session/sessionManager.ts`)
**Key Design**: Thread-isolated sessions
- Session key format: `userId:catId:threadId`
- Prevents cross-thread pollution
- In-memory storage with automatic cleanup

### 4. Transcript Persistence (`src/transcript/transcriptWriter.ts`)
**Storage**: Local JSONL files
- File naming: `{userId}_{catId}_{threadId}.jsonl`
- Event types: user_message, agent_response, error, system
- Append-only for reliability

## API Endpoints

### GET /health
Health check endpoint
```json
{
  "status": "ok",
  "timestamp": "2026-03-01T15:00:00.000Z",
  "uptime": 123.456
}
```

### POST /api/chat
Main chat endpoint with validation
```json
{
  "threadId": "thread-123",
  "userId": "user-456",
  "catId": "architect" | "developer" | "frontend",
  "message": "Your message here",
  "model": "gpt52" | "minimax-m2.5"
}
```

## Project Structure

```
cat-cafe-runtime/
├── src/
│   ├── config/
│   │   └── env.ts              # Environment configuration
│   ├── runtime/
│   │   └── spawnCli.ts         # CLI subprocess runtime (CRITICAL)
│   ├── agents/
│   │   ├── types.ts            # Agent interfaces
│   │   ├── registry.ts         # Provider routing
│   │   └── providers/
│   │       ├── gpt52Provider.ts
│   │       └── minimaxProvider.ts
│   ├── session/
│   │   └── sessionManager.ts   # Thread-isolated sessions
│   ├── transcript/
│   │   └── transcriptWriter.ts # JSONL persistence
│   ├── routes/
│   │   ├── health.ts
│   │   └── chat.ts
│   ├── schemas/
│   │   └── chat.ts             # Zod validation
│   ├── app.ts                  # Express app setup
│   └── server.ts               # Entry point
├── data/
│   └── transcripts/            # Auto-created JSONL files
├── .env                        # Environment variables
├── package.json
├── tsconfig.json
└── README.md
```

## Configuration

`.env` variables:
- `PORT`: Server port (default: 3000)
- `CLI_TIMEOUT_MS`: CLI subprocess timeout (default: 300000 = 5 minutes)
- `CLI_OPENCODE_PATH`: Path to opencode CLI (default: "opencode")
- `DATA_DIR`: Data storage directory (default: ./data)
- `TRANSCRIPTS_DIR`: Transcript storage (default: ./data/transcripts)

## Development Commands

```bash
npm install          # Install dependencies
npm run dev          # Start development server with hot reload
npm run build        # Build for production
npm start            # Start production server
npm run typecheck    # Run TypeScript type checking
```

## Verification Checklist

✅ TypeScript compilation passes
✅ Health endpoint returns 200
✅ Chat endpoint validates input schema
✅ Provider routing works correctly
✅ Session isolation by threadId
✅ Transcript files created in data/transcripts/

## Next Steps for External Agents

1. **Install opencode CLI** and configure path in `.env`
2. **Test provider integration** with actual CLI commands
3. **Extend providers** with streaming support (SSE) if needed
4. **Add authentication** middleware for production
5. **Migrate storage** from local files to Redis/PostgreSQL
6. **Add monitoring** and observability (logs, metrics, traces)

## Key Design Decisions

1. **CLI over SDK**: Subprocess architecture for flexibility and isolation
2. **Dual-channel monitoring**: Prevents false timeouts from stderr output
3. **Thread-based sessions**: Prevents context leakage between conversations
4. **Local JSONL storage**: Simple, reliable, easy to migrate later
5. **Minimal abstractions**: Only what's needed for the current requirements

## Known Limitations

- In-memory session storage (will be lost on restart)
- No streaming support yet (aggregated responses only)
- No authentication/authorization
- No rate limiting
- Local file storage (not suitable for distributed systems)

These are intentional simplifications for the initial foundation. External agents can extend as needed.
