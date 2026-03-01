import { Router, Request, Response } from 'express';
import { chatRequestSchema } from '../schemas/chat';
import { agentRegistry } from '../agents/registry';
import { sessionManager } from '../session/sessionManager';
import { transcriptWriter } from '../transcript/transcriptWriter';

const router = Router();

router.post('/chat', async (req: Request, res: Response) => {
  try {
    // Validate request
    const parsed = chatRequestSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({
        error: 'Invalid request',
        details: parsed.error.issues,
      });
    }

    const { threadId, userId, catId, message, model } = parsed.data;

    // Get or create session
    const session = sessionManager.getOrCreate(userId, catId, threadId);

    // Write user message to transcript
    transcriptWriter.writeUserMessage(userId, catId, threadId, message);

    // Get provider and invoke
    const provider = agentRegistry.getProvider(catId, model);

    const response = await provider.invoke({
      threadId,
      userId,
      catId,
      message,
      model,
    });

    // Update session activity
    sessionManager.updateActivity(userId, catId, threadId);

    // Write agent response to transcript
    transcriptWriter.writeAgentResponse(
      userId,
      catId,
      threadId,
      model,
      response.content,
      response.metadata
    );

    return res.status(200).json({
      success: true,
      response: response.content,
      metadata: response.metadata,
      session: {
        threadId: session.threadId,
        messageCount: session.messageCount,
      },
    });

  } catch (error) {
    console.error('[Chat API Error]', error);

    const errorMessage = error instanceof Error ? error.message : 'Unknown error';

    // Try to write error to transcript if we have the context
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

export default router;
