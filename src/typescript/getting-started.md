---
order: -1
icon: rocket
---

# Getting Started

Welcome to WorkerBee, the powerful TypeScript library that makes building Hive blockchain bots as easy as writing regular web applications!

## :package: Installation

Install WorkerBee using your favorite package manager:

=== npm

```bash
npm install @hiveio/workerbee
```

=== yarn

```bash
yarn add @hiveio/workerbee
```

=== pnpm

```bash
pnpm add @hiveio/workerbee
```

===

## :zap: Quick Start

Here's a simple example that monitors new posts from a specific author:

```typescript
import { WorkerBee } from '@hiveio/workerbee';

const workerbee = WorkerBee.create();

// Monitor new posts by "alice"
workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      console.log(`Alice created ${posts.alice.length} new posts!`);
      for (const post of posts.alice) {
        console.log(`New post: ${post.title} (${post.permlink})`);
      }
    },
    error: (error) => {
      console.error('Error occurred:', error);
    }
  });
```

## :building_construction: Core Concepts

### :eyes: Observer Pattern

WorkerBee uses the Observer pattern, similar to modern reactive libraries. You define **what** you want to observe, and WorkerBee handles **how** to monitor the blockchain.

### :chains: Fluent API

Build complex queries using method chaining:

```typescript
workerbee.observe
  .onPosts("alice")
  .onComments("bob")
  .onAccountsBalanceChange(false, "charlie")
  .subscribe({ /* your callback */ });
```

### :gear: Smart Caching

WorkerBee automatically caches blockchain data within each cycle, reducing API calls by up to 50% while ensuring data consistency.

## :scroll: Basic Example Walkthrough

Let's break down a more comprehensive example:

```typescript
import { WorkerBee } from '@hiveio/workerbee';

// 1. Create WorkerBee instance
const workerbee = WorkerBee.create({
  // Optional configuration
  apiEndpoint: 'https://api.hive.blog',
  cycleInterval: 2000 // Check every 2 seconds in live mode
});

// 2. Define what to observe
workerbee.observe
  .onPosts("alice")                    // Watch for Alice's new posts
  .onAccountsFullManabar("voter123")   // Watch for voter123's full manabar
  .provideAccounts("alice", "voter123") // Provide account data
  .subscribe({
    next: (data) => {
      // 3. React to events
      if (data.posts.alice.length > 0) {
        console.log(`Alice posted: ${data.posts.alice[0].title}`);
        
        // Check if voter123 has enough manabar to vote
        const voterAccount = data.accounts.voter123;
        if (voterAccount.voting_manabar.current_mana > 8000) {
          console.log("Voter123 has enough manabar to vote!");
          // Vote logic here...
        }
      }
    },
    error: (error) => {
      console.error('Subscription error:', error);
    },
    complete: () => {
      console.log('Observation completed');
    }
  });
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
workerbee.observe.onPosts("author").subscribe({ /* react */ });
```

### :shield: Error Handling

WorkerBee handles network errors, API limits, and blockchain reorganizations automatically:

```typescript
workerbee.observe
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

```typescript
// Live monitoring
const liveWorkerBee = WorkerBee.create({ mode: 'live' });

// Historical analysis
const historicalWorkerBee = WorkerBee.create({
  mode: 'historical',
  startBlock: 80000000,
  endBlock: 80001000
});

// Same observation logic works for both!
const observer = (wb) => wb.observe.onPosts("alice").subscribe({ /* ... */ });
observer(liveWorkerBee);
observer(historicalWorkerBee);
```
