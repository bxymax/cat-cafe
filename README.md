# Cat Cafe Runtime

Node + TypeScript + Express backend foundation with CLI subprocess architecture for multi-model agent orchestration.

## Architecture

- **CLI Subprocess Runtime**: Unified `spawnCli()` with stdout/stderr dual-channel activity monitoring
- **Multi-Model Support**: GPT-5.2 and Minimax M2.5 via opencode CLI
- **Session Management**: Thread-isolated sessions with `userId:catId:threadId` keys
- **Transcript Persistence**: Local JSONL file storage for all interactions

## Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
npm start
```

## API Endpoints

### Health Check
```bash
GET /health
```

### Chat
```bash
POST /api/chat
Content-Type: application/json

{
  "threadId": "thread-123",
  "userId": "user-456",
  "catId": "architect",
  "message": "Design a REST API",
  "model": "gpt52"
}
```

## Configuration

Edit `.env`:
- `PORT`: Server port (default: 3000)
- `CLI_TIMEOUT_MS`: CLI subprocess timeout (default: 300000)
- `CLI_OPENCODE_PATH`: Path to opencode CLI (default: "opencode")
- `DATA_DIR`: Data storage directory
- `TRANSCRIPTS_DIR`: Transcript storage directory

## Project Structure

```
src/
├── config/          # Environment configuration
├── runtime/         # CLI subprocess runtime
├── agents/          # Agent providers and registry
├── session/         # Session management
├── transcript/      # Transcript persistence
├── routes/          # API routes
├── schemas/         # Request validation
├── app.ts           # Express app setup
└── server.ts        # Server entry point
```

## Key Features

- **Dual-channel timeout protection**: Both stdout and stderr refresh activity timer
- **Thread isolation**: Sessions keyed by `userId:catId:threadId`
- **Provider routing**: Automatic model selection based on catId
- **Persistent transcripts**: All interactions logged to JSONL files
