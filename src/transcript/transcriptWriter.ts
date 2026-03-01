import fs from 'fs';
import path from 'path';
import { config } from '../config/env';

export interface TranscriptEvent {
  timestamp: number;
  type: 'user_message' | 'agent_response' | 'error' | 'system';
  userId: string;
  catId: string;
  threadId: string;
  model?: string;
  content?: string;
  metadata?: Record<string, any>;
}

class TranscriptWriter {
  private ensureDir() {
    if (!fs.existsSync(config.data.transcriptsDir)) {
      fs.mkdirSync(config.data.transcriptsDir, { recursive: true });
    }
  }

  private getFilePath(userId: string, catId: string, threadId: string): string {
    const filename = `${userId}_${catId}_${threadId}.jsonl`;
    return path.join(config.data.transcriptsDir, filename);
  }

  write(event: TranscriptEvent) {
    this.ensureDir();
    const filePath = this.getFilePath(event.userId, event.catId, event.threadId);
    const line = JSON.stringify(event) + '\n';

    try {
      fs.appendFileSync(filePath, line, 'utf8');
    } catch (err) {
      console.error('[TranscriptWriter] Failed to write event:', err);
    }
  }

  writeUserMessage(userId: string, catId: string, threadId: string, message: string) {
    this.write({
      timestamp: Date.now(),
      type: 'user_message',
      userId,
      catId,
      threadId,
      content: message,
    });
  }

  writeAgentResponse(
    userId: string,
    catId: string,
    threadId: string,
    model: string,
    content: string,
    metadata?: Record<string, any>
  ) {
    this.write({
      timestamp: Date.now(),
      type: 'agent_response',
      userId,
      catId,
      threadId,
      model,
      content,
      metadata,
    });
  }

  writeError(userId: string, catId: string, threadId: string, error: string) {
    this.write({
      timestamp: Date.now(),
      type: 'error',
      userId,
      catId,
      threadId,
      content: error,
    });
  }
}

export const transcriptWriter = new TranscriptWriter();
