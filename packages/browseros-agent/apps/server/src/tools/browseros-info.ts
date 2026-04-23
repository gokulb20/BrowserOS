import { z } from 'zod'
import { defineToolWithCategory } from './framework'

const defineAssistantTool = defineToolWithCategory('assistant')

const PRODUCT_INFO = `crewm8 is an AI-native browser that turns plain English into browser actions. It runs AI agents that can click, type, navigate, fill forms, extract data, and handle multi-step browser tasks.

Modes:
- Chat — ask questions about any webpage: summarize, extract data, translate.
- Agent — describe a task and the agent executes it across tabs.`

export const browseros_info = defineAssistantTool({
  name: 'browseros_info',
  description:
    'Get information about crewm8 features and capabilities. Use when users ask "What is crewm8?" or "What can crewm8 do?".',
  input: z.object({
    topic: z
      .string()
      .optional()
      .describe('Specific topic to get info about (currently unused).'),
  }),
  output: z.object({
    topic: z.string().optional(),
    content: z.string(),
  }),
  handler: async (args, _ctx, response) => {
    response.text(PRODUCT_INFO)
    response.data({ topic: args.topic, content: PRODUCT_INFO })
  },
})
