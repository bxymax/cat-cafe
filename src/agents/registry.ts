import { AgentProvider, CatId, ModelType } from './types';
import { GPT52Provider } from './providers/gpt52Provider';
import { MinimaxProvider } from './providers/minimaxProvider';

class AgentRegistry {
  private providers = new Map<string, AgentProvider>();

  constructor() {
    this.registerProvider('openai/gpt52', new GPT52Provider());
    this.registerProvider('minimax/minimax-m2.5', new MinimaxProvider());
  }

  registerProvider(model: string, provider: AgentProvider) {
    this.providers.set(model, provider);
  }

  getProvider(catId: CatId, model: ModelType): AgentProvider {
    // Route based on model preference, with fallback logic
    let provider = this.providers.get(model);

    if (!provider) {
      // Fallback routing based on catId
      if (catId === 'frontend') {
        provider = this.providers.get('minimax/minimax-m2.5');
      } else {
        provider = this.providers.get('openai/gpt52');
      }
    }

    if (!provider) {
      throw new Error(`No provider found for catId=${catId}, model=${model}`);
    }

    return provider;
  }
}

export const agentRegistry = new AgentRegistry();
