import { createClient, RedisClientType } from 'redis';

interface Message {
  id: string;
  catId: string;
  content: string;
  timestamp: number;
}

class RedisStore {
  private client: RedisClientType | null = null;

  async connect(url: string = 'redis://localhost:6379') {
    this.client = createClient({ url });
    this.client.on('error', (err) => console.error('Redis error:', err));
    await this.client.connect();
  }

  async addMessage(threadId: string, catId: string, content: string): Promise<Message> {
    const message: Message = {
      id: `msg_${Date.now()}_${Math.random().toString(36).slice(2)}`,
      catId,
      content,
      timestamp: Date.now(),
    };

    const key = `thread:${threadId}:messages`;
    await this.client?.lPush(key, JSON.stringify(message));
    await this.client?.expire(key, 86400);

    return message;
  }

  async getMessages(threadId: string): Promise<Message[]> {
    const key = `thread:${threadId}:messages`;
    const data = await this.client?.lRange(key, 0, -1);
    return (data || []).map(d => JSON.parse(d)).reverse();
  }

  async getThreadContext(threadId: string, limit: number = 10): Promise<string> {
    const messages = await this.getMessages(threadId);
    const recent = messages.slice(-limit);
    return recent.map(m => `${m.catId}: ${m.content}`).join('\n');
  }

  async disconnect() {
    await this.client?.quit();
  }
}

export const redisStore = new RedisStore();
