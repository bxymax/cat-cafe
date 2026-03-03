import { z } from 'zod';

export const chatRequestSchema = z.object({
  threadId: z.string().min(1),
  userId: z.string().min(1),
  catId: z.enum(['architect', 'developer', 'frontend']),
  message: z.string().min(1),
  model: z.enum(['openai/gpt52', 'minimax/minimax-m2.5']),
});

export type ChatRequest = z.infer<typeof chatRequestSchema>;
