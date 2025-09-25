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

await bot.start();

// place your filtering conditions here
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

### Broadcasting Transactions

WorkerBee's `broadcast` method goes beyond regular broadcasting by providing L1 blockchain validation:

```typescript
// Assuming you have a signed transaction
await bot.broadcast(signedTransaction);

// With options for verification and timeout
await bot.broadcast(signedTransaction, {
  verifySignatures: true,
  expireInMs: 10000
});
```

**Key Difference from Regular Broadcasting:**

- **Regular broadcast**: Only ensures the transaction reaches the node and is valid
- **WorkerBee broadcast**: Guarantees the transaction was propagated and applied by witnesses in a block by verifying its actual presence in the blockchain

**Options explained:**

- `verifySignatures`: Checks if transaction signatures and their order/count remain unchanged after blockchain inclusion (detects tampering, not pre-broadcast validation)
- `expireInMs`: Maximum time to wait for the transaction to appear in a block (usually ~3 seconds). If timeout occurs, the transaction may still appear later in the blockchain, but an error is thrown

### Block Iteration

WorkerBee provides powerful async iterators for processing blockchain data in real-time:

```typescript
// Simple iteration over new blocks (IGNORES ERRORS)
for await (const { number, id } of bot) {
  console.log(`Processing block #${number} with ID: ${id}`);
}

// Also ignores errors (equivalent to above)
for await (const block of bot.iterate()) {
  console.log(`Block: ${block.number}`);
}

// With error handling via callback
for await (const block of bot.iterate(console.error)) {
  console.log(`Block: ${block.number}`);
}

// With try-catch error handling
try {
  for await (const block of bot.iterate(true)) {
    console.log(`Block: ${block.number}`);
  }
} catch (error) {
  console.error("Iterator error:", error);
}
```

**Error Handling Behavior:**

- **`for await (const block of bot)`** - **Ignores all errors** (uses default async iterator)
- **`bot.iterate()`** (no arguments) - **Ignores all errors**
- **`bot.iterate(callback)`** - Errors are passed to the callback function
- **`bot.iterate(true)`** - Errors are thrown and can be caught with try-catch

**Key Features:**

- **Real-time processing**: Automatically waits for new blocks as they arrive
- **Memory efficient**: Uses promise queues to handle backpressure when processing is slower than block production
- **Automatic cleanup**: Properly unsubscribes from observers when iteration is interrupted
- **Flexible error handling**: Support for callbacks, boolean flags, or try-catch patterns
