interface Session {
  key: string;
  userId: string;
  catId: string;
  threadId: string;
  createdAt: number;
  lastActivityAt: number;
  messageCount: number;
}

class SessionManager {
  private sessions = new Map<string, Session>();

  private buildKey(userId: string, catId: string, threadId: string): string {
    return `${userId}:${catId}:${threadId}`;
  }

  getOrCreate(userId: string, catId: string, threadId: string): Session {
    const key = this.buildKey(userId, catId, threadId);
    let session = this.sessions.get(key);

    if (!session) {
      session = {
        key,
        userId,
        catId,
        threadId,
        createdAt: Date.now(),
        lastActivityAt: Date.now(),
        messageCount: 0,
      };
      this.sessions.set(key, session);
    }

    return session;
  }

  updateActivity(userId: string, catId: string, threadId: string) {
    const key = this.buildKey(userId, catId, threadId);
    const session = this.sessions.get(key);
    if (session) {
      session.lastActivityAt = Date.now();
      session.messageCount++;
    }
  }

  cleanup(maxAgeMs: number = 3600000) {
    const now = Date.now();
    for (const [key, session] of this.sessions.entries()) {
      if (now - session.lastActivityAt > maxAgeMs) {
        this.sessions.delete(key);
      }
    }
  }
}

export const sessionManager = new SessionManager();
