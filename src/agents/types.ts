export interface AgentRequest {
  threadId: string;
  userId: string;
  catId: string;
  message: string;
  model: string;
}

export interface AgentResponse {
  content: string;
  metadata?: {
    model?: string;
    tokensUsed?: number;
    duration?: number;
  };
}

export interface AgentProvider {
  name: string;
  invoke(request: AgentRequest): Promise<AgentResponse>;
}

export type ModelType = 'gpt52' | 'minimax-m2.5';
export type CatId = 'architect' | 'developer' | 'frontend';
