import { Router, Request, Response } from 'express';
import { chatRequestSchema } from '../schemas/chat';
import { agentRegistry } from '../agents/registry';
import { sessionManager } from '../session/sessionManager';
import { transcriptWriter } from '../transcript/transcriptWriter';
import { redisStore } from '../memory/redisStore';
import { routeA2A, parseA2AMentions } from '../routing/a2aRouter';

const router = Router();

router.post('/chat', async (req: Request, res: Response) => {
  try {
    const parsed = chatRequestSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({
        error: 'Invalid request',
        details: parsed.error.issues,
      });
    }

    const { threadId, userId, catId, message, model } = parsed.data;

    const session = sessionManager.getOrCreate(userId, catId, threadId);

    await redisStore.addMessage(threadId, 'user', message);
    transcriptWriter.writeUserMessage(userId, catId, threadId, message);

    const provider = agentRegistry.getProvider(catId, model);

    const response = await provider.invoke({
      threadId,
      userId,
      catId,
      message,
      model,
    });

    await redisStore.addMessage(threadId, catId, response.content);

    sessionManager.updateActivity(userId, catId, threadId);

    transcriptWriter.writeAgentResponse(
      userId,
      catId,
      threadId,
      model,
      response.content,
      response.metadata
    );

    const mentions = parseA2AMentions(response.content, catId);
    const a2aResponses: Record<string, string> = {};

    for (const targetCatId of mentions) {
      try {
        const a2aResponse = await routeA2A({
          threadId,
          userId,
          sourceCatId: catId,
          targetCatId,
          message: response.content,
          model: model as any,
        });
        a2aResponses[targetCatId] = a2aResponse.content;
      } catch (err) {
        console.error(`[A2A Error] ${catId} -> ${targetCatId}:`, err);
      }
    }

    return res.status(200).json({
      success: true,
      response: response.content,
      metadata: response.metadata,
      a2aResponses,
      session: {
        threadId: session.threadId,
        messageCount: session.messageCount,
      },
    });

  } catch (error) {
    console.error('[Chat API Error]', error);

    const errorMessage = error instanceof Error ? error.message : 'Unknown error';

    if (req.body?.userId && req.body?.catId && req.body?.threadId) {
      transcriptWriter.writeError(
        req.body.userId,
        req.body.catId,
        req.body.threadId,
        errorMessage
      );
    }

    return res.status(500).json({
      success: false,
      error: errorMessage,
    });
  }
});

router.get('/thread/:threadId', async (req: Request, res: Response) => {
  try {
    const threadId = Array.isArray(req.params.threadId) ? req.params.threadId[0] : req.params.threadId;
    const messages = await redisStore.getMessages(threadId);
    return res.status(200).json({
      threadId,
      messages,
      context: await redisStore.getThreadContext(threadId),
    });
  } catch (error) {
    console.error('[Thread API Error]', error);
    return res.status(500).json({
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

export default router;
