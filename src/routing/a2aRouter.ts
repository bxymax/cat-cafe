import { AgentRequest, AgentResponse, CatId, ModelType } from '../agents/types';
import { agentRegistry } from '../agents/registry';
import { redisStore } from '../memory/redisStore';

export interface A2ARequest {
  threadId: string;
  userId: string;
  sourceCatId: string;
  targetCatId: CatId;
  message: string;
  model: ModelType;
}

export interface A2AResponse {
  content: string;
  metadata?: {
    model?: string;
    duration?: number;
  };
}

export async function routeA2A(request: A2ARequest): Promise<A2AResponse> {
  const { threadId, userId, sourceCatId, targetCatId, message, model } = request;

  const context = await redisStore.getThreadContext(threadId, 5);

  const contextPrefix = context ? `\n[Thread Context]\n${context}\n\n` : '';
  const fullMessage = `${contextPrefix}${message}`;

  const agentRequest: AgentRequest = {
    threadId,
    userId,
    catId: targetCatId,
    message: fullMessage,
    model,
  };

  const provider = agentRegistry.getProvider(targetCatId, model);
  const response = await provider.invoke(agentRequest);

  await redisStore.addMessage(threadId, targetCatId, response.content);

  return {
    content: response.content,
    metadata: response.metadata,
  };
}

export function parseA2AMentions(text: string, sourceCatId: string): CatId[] {
  const catIds: CatId[] = ['architect', 'developer', 'frontend'];
  const mentions: CatId[] = [];

  for (const catId of catIds) {
    if (catId === sourceCatId) continue;

    const patterns = [
      `@${catId}`,
      `@布偶猫`,
      `@缅因猫`,
      `@暹罗猫`,
    ];

    for (const pattern of patterns) {
      if (new RegExp(`^\\s*${pattern}`, 'mi').test(text)) {
        if (!mentions.includes(catId)) {
          mentions.push(catId);
        }
        break;
      }
    }
  }

  return mentions;
}
