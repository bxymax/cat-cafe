import { Router, Request, Response } from 'express';
import { redisStore } from '../memory/redisStore';

const router = Router();

// MCP callback: post message to thread
router.post('/callbacks/post-message', async (req: Request, res: Response) => {
  try {
    const { threadId, catId, content } = req.body;

    if (!threadId || !catId || !content) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    await redisStore.addMessage(threadId, catId, content);

    return res.status(200).json({
      success: true,
      message: 'Posted to thread',
    });
  } catch (error) {
    console.error('[Callback Error]', error);
    return res.status(500).json({
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

// Get thread context for MCP
router.get('/callbacks/thread-context/:threadId', async (req: Request, res: Response) => {
  try {
    const threadId = Array.isArray(req.params.threadId) ? req.params.threadId[0] : req.params.threadId;
    const context = await redisStore.getThreadContext(threadId);

    return res.status(200).json({
      threadId,
      context,
    });
  } catch (error) {
    console.error('[Callback Error]', error);
    return res.status(500).json({
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

export default router;
