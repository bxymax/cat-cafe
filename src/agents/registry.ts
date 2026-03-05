import { AgentProvider, CatId, ModelType } from './types';
import { GPT52Provider } from './providers/gpt52Provider';
import { MinimaxProvider } from './providers/minimaxProvider';
import { MockProvider } from './providers/mockProvider';

class AgentRegistry {
  private providers = new Map<string, AgentProvider>();

  constructor() {
    // Register real providers
    this.registerProvider('openai/gpt5.2', new GPT52Provider());
    this.registerProvider('minimax/minimax-m2.5', new MinimaxProvider());

    // Register mock provider as fallback
    const mockProvider = new MockProvider();
    this.registerProvider('mock', mockProvider);
  }

  registerProvider(model: string, provider: AgentProvider) {
    this.providers.set(model, provider);
  }

  getProvider(catId: CatId, model: ModelType): AgentProvider {
    // Try to get the requested provider
    let provider = this.providers.get(model);

    if (!provider) {
      // Fallback to mock provider for testing
      provider = this.providers.get('mock');
    }

    if (!provider) {
      throw new Error(`No provider found for catId=${catId}, model=${model}`);
    }

    return provider;
  }
}

export const agentRegistry = new AgentRegistry();
