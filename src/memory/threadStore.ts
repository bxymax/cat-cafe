interface Message {
  id: string;
  catId: string;
  content: string;
  timestamp: number;
}

interface Thread {
  threadId: string;
  messages: Message[];
}

class ThreadStore {
  private threads = new Map<string, Thread>();

  getOrCreate(threadId: string): Thread {
    if (!this.threads.has(threadId)) {
      this.threads.set(threadId, { threadId, messages: [] });
    }
    return this.threads.get(threadId)!;
  }

  addMessage(threadId: string, catId: string, content: string): Message {
    const thread = this.getOrCreate(threadId);
    const message: Message = {
      id: `msg_${Date.now()}_${Math.random().toString(36).slice(2)}`,
      catId,
      content,
      timestamp: Date.now(),
    };
    thread.messages.push(message);
    return message;
  }

  getMessages(threadId: string): Message[] {
    return this.getOrCreate(threadId).messages;
  }

  getThreadContext(threadId: string, limit: number = 10): string {
    const messages = this.getMessages(threadId);
    const recent = messages.slice(-limit);
    return recent
      .map((m) => `${m.catId}: ${m.content}`)
      .join('\n');
  }
}

export const threadStore = new ThreadStore();
