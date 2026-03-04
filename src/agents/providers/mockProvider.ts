import { AgentProvider, AgentRequest } from '../types';

/**
 * Mock provider for testing multi-agent conversations
 * Returns simulated responses based on catId and message
 */
export class MockProvider implements AgentProvider {
  name = 'mock-provider';

  async invoke(request: AgentRequest) {
    const { catId, message } = request;
    const startTime = Date.now();

    // Simulate different personalities
    let response = '';

    if (catId === 'architect') {
      response = `[Architect] I've analyzed the requirements. The architecture should follow a modular design pattern. @developer can you implement the core logic?`;
    } else if (catId === 'developer') {
      response = `[Developer] I'll implement the core logic with proper error handling and tests. @frontend please prepare the UI components.`;
    } else if (catId === 'frontend') {
      response = `[Frontend] I'll create beautiful and responsive UI components that integrate seamlessly with the backend.`;
    } else {
      response = `[${catId}] I'm ready to help with this task.`;
    }

    // Simulate some processing time
    await new Promise(resolve => setTimeout(resolve, 500));

    return {
      content: response,
      metadata: {
        model: request.model,
        duration: Date.now() - startTime,
      },
    };
  }
}
