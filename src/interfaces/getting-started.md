---
order: -1
icon: rocket
---

# Getting Started

Welcome to WorkerBee, the powerful TypeScript library that makes building Hive blockchain bots as easy as writing regular web applications!

## :package: Installation

Install WorkerBee:

[!ref icon="../static/npm.svg" target="_blank" text="View **WorkerBee** package on npmjs 🡭"](https://npmjs.com/package/@hiveio/workerbee)

```bash
pnpm add @hiveio/workerbee
```

> You can also use other package managers, such as: [`npm`](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm#using-a-node-version-manager-to-install-nodejs-and-npm) or [`yarn`](https://yarnpkg.com/getting-started/install)

## :zap: Quick Start

Here's a simple example that initializes and starts the bot:

```typescript
import { WorkerBee } from '@hiveio/workerbee';

const bot = new WorkerBee();

bot.start();
```

## :building_construction: Core Concepts

### Observer Pattern

WorkerBee uses the Observer pattern, similar to modern reactive libraries. You define **what** you want to observe, and WorkerBee handles **how** to monitor the blockchain.

### Fluent API

Build complex queries using method chaining, e.g.:

```typescript
bot.observe
  .onPosts("alice")
  .onComments("bob")
  .subscribe({ /* your callback */ });
```

## :bulb: Key Benefits

### No More Polling Loops

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

### Error Handling

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

### Flexible Data Sources

Switch between live blockchain data and historical analysis without changing your code:

```typescript:highlight="1"
bot.providePastData('-7d')
  .onPosts("alice")
  .onComments("bob")
  .subscribe({ /* your callback */ });
```
