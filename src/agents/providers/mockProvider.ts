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

    // Simulate different personalities based on CLAUDE.md
    let response = '';

    if (catId === 'architect') {
      response = `🎨 布偶猫收到！我来帮你做架构设计和价值澄清。\n\n你的问题是："${message}"\n\n让我深度思考一下... 这个需求的核心价值在于提升用户体验和系统可维护性。建议采用模块化设计，确保各组件职责清晰。@缅因猫 可以帮忙验证技术可行性吗？`;
    } else if (catId === 'developer') {
      response = `💻 缅因猫来了！我负责落地验证和代码审查。\n\n关于"${message}"，我会确保实现细节到位，代码质量过关。让我检查一下现有代码结构... 建议先写单元测试，然后逐步实现功能。@暹罗猫 UI 设计准备好了吗？`;
    } else if (catId === 'frontend') {
      response = `🎭 暹罗猫登场！我擅长破框思维和视觉设计。\n\n"${message}" 这个需求很有意思！让我用不同的角度看看... 我们可以用更创意的方式呈现，比如添加动画效果和交互反馈，让用户体验更流畅。`;
    } else {
      response = `[${catId}] 收到消息："${message}"，正在处理中...`;
    }

    // Simulate some processing time
    await new Promise(resolve => setTimeout(resolve, 800));

    return {
      content: response,
      metadata: {
        model: request.model,
        catId: request.catId,
        duration: Date.now() - startTime,
      },
    };
  }
}
