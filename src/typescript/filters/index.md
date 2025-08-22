---
order: -3
icon: filter
---

# Filters & Conditions

Filters are the core of WorkerBee's event system. They define **when** your observers should be triggered by evaluating blockchain conditions in real-time.

## :mag: Filter Overview

Filters monitor the blockchain for specific events and trigger your callbacks when conditions are met. They run concurrently and use smart caching to minimize API calls.

![WorkerBee filter categories](../../static/wb-categories.png){.rounded-lg}

### :zap: Basic Filter Usage

```typescript:highlight="9"
import { WorkerBee } from '@hiveio/workerbee';

const bot = new WorkerBee();

await bot.start();

// Simple post filter
bot.observe
  .onPosts("alice")
  .subscribe({
    next: () => {
      console.log(`Alice created new post!`);
    }
  });
```
