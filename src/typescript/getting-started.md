---
order: -1
icon: rocket
---

# Getting Started

Welcome to WorkerBee, the powerful TypeScript library that makes building Hive blockchain bots as easy as writing regular web applications!

## :package: Installation

Install WorkerBee using your favorite package manager:

+++ pnpm

```bash
pnpm add @hiveio/workerbee
```

+++ yarn

```bash
yarn add @hiveio/workerbee
```

+++ npm

```bash
npm install @hiveio/workerbee
```

+++

## :zap: Quick Start

Here's a simple example that initializes and starts the bot:

```typescript
import { WorkerBee } from '@hiveio/workerbee';

const bot = new WorkerBee();

bot.start();
```

## :building_construction: Core Concepts

### :eyes: Observer Pattern

WorkerBee uses the Observer pattern, similar to modern reactive libraries. You define **what** you want to observe, and WorkerBee handles **how** to monitor the blockchain.

### :chains: Fluent API

Build complex queries using method chaining, e.g.:

```typescript
bot.observe
  .onPosts("alice")
  .onComments("bob")
  .subscribe({ /* your callback */ });
```

## :bulb: Key Benefits

### :no_entry_sign: No More Polling Loops

Instead of writing endless `while` loops and managing timers, just declare what you want to observe:

```typescript
// ❌ Old way - manual polling
setInterval(async () => {
  const posts = await api.getPosts();
  // Check for new posts...
}, 3000);

// ✅ WorkerBee way - declarative observation
bot.observe.onPosts("author").subscribe({ /* react */ });
```

### :shield: Error Handling

WorkerBee handles network errors, API limits, and blockchain reorganizations automatically:

```typescript:highlight="5-8"
bot.observe
  .onPosts("alice")
  .subscribe({
    next: (data) => { /* handle success */ },
    error: (error) => {
      // WorkerBee provides structured error information
      console.error(`Error type: ${error.type}, message: ${error.message}`);
    }
  });
```

### :arrows_counterclockwise: Flexible Data Sources

Switch between live blockchain data and historical analysis without changing your code:

```typescript:highlight="1"
bot.providePastData('-7d')
  .onPosts("alice")
  .onComments("bob")
  .subscribe({ /* your callback */ });
```
