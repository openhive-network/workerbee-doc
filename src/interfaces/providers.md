---
order: -4
icon: database
---

# Data Providers

Data Providers are WorkerBee's powerful data transformation layer that intelligently gathers, processes, and normalizes blockchain data into clean, type-safe objects for your application. They execute only when filters match, ensuring optimal performance and minimal resource usage.

## :mag: Provider Overview

Providers transform raw blockchain data into structured TypeScript objects, running concurrently with filters and automatically benefiting from WorkerBee's advanced caching system. They provide rich contextual data that complements the events detected by filters.

![Data flow diagram showing how providers enhance filter events with contextual blockchain data](../static/wb-cycle.png){.rounded-lg}

### Basic Provider Usage

!!!secondary
Note that the [`?.` operator](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Optional_chaining) is used to safely access nested properties, preventing runtime errors if data is not available for any reason, e.g. if the account is not found, or if an API endpoint is temporarily down.
!!!

!!!warning Provider Performance Impact
**Important**: Providers may trigger additional API calls to gather data not available from defined filters itself. This can impact performance when monitoring high-frequency events.
!!!

```typescript:highlight="8,12"
import { WorkerBee } from '@hiveio/workerbee';

const workerbee = new WorkerBee();

// Use providers to get additional data
workerbee.observe
  .onPosts("alice")           // FILTER: Detects when Alice creates a post
  .provideAccounts("bob")     // PROVIDER: Fetches Bob's account data (additional API call)
  .subscribe({
    next: ({ posts, accounts }) => {
      // DATA FROM FILTER (onPosts):
      // - posts.alice contains Alice's post operation data
      // - This data comes directly with filter from only get_block API call
      posts.alice?.forEach(({ operation }) => {
        console.log(`Alice created post: ${operation.permlink}`);
      });

      // DATA FROM PROVIDER (provideAccounts):
      // - accounts.bob contains Bob's current account state
      // - This data requires an additional API call to fetch current account info
      console.log(`Bob's current balance: ${accounts.bob?.balance.HIVE.liquid} HIVE`);
    }
  });
```

## :arrows_counterclockwise: Filters vs. Providers

Understanding the distinction between **Filters** and **Providers** is crucial for effective WorkerBee usage:

### Filters: The "WHEN" Layer

**Filters determine WHEN your callback should be triggered** by monitoring specific blockchain events:

- Monitor for specific events (posts, votes, transfers, etc.)
- Trigger your callbacks when conditions are met
- Work like event listeners - they detect what happened

### Providers: The "WHAT" Layer

**Providers determine WHAT additional data you need** when filters trigger:

- Fetch and structure additional contextual data
- Provide rich, normalized information about accounts, blocks, prices, etc.
- Work like data fetchers - they gather information you need to process the event
- Execute automatically when any filter matches

### Working Together

```typescript
workerbee.observe
  .onPosts("alice")           // FILTER: Watch for Alice's posts (WHEN)
  .provideAccounts("alice")   // PROVIDER: Get Alice's account data (WHAT)
  .subscribe({
    next: ({ posts, accounts }) => {
      // Filter detected the event: Alice posted
      // Provider supplied the data: Alice's account balance, reputation, etc.
      console.log(`Alice posted! Her balance: ${accounts.alice?.balance.HIVE.liquid}`);
    }
  });
```

This separation allows for:

- **Clean architecture**: Event detection separate from data fetching
- **Optimal performance**: Providers only run when filters match
- **Flexible combinations**: Mix any filters with any providers
- **Smart caching**: Reuse provider data across multiple filter matches

For detailed filters information, check out the filters chapter:

[!ref target="_blank" text="Browse Detailed Filters Information"](/interfaces/filters)

## :gear: How Providers Work

### Provider Squashing & Optimization

WorkerBee intelligently **combines multiple calls to the same provider type**, significantly optimizing performance. When you call the same provider multiple times, WorkerBee merges all parameters into a single efficient request.

```typescript
// Multiple provider calls...
workerbee.observe
  .onBlock()
  .provideAccounts("alice")
  .provideAccounts("bob")
  .provideAccounts("charlie")
  .subscribe({
    next: ({ accounts }) => {
      // ...receives data for all three accounts in one optimized call
      console.log(accounts.alice?.name);  // Alice's data
      console.log(accounts.bob?.name);    // Bob's data
      console.log(accounts.charlie?.name); // Charlie's data
    }
  });

// ...is automatically optimized to a single efficient provider call
// equivalent to: .provideAccounts("alice", "bob", "charlie")
```

This optimization works for **every provider per type** and dramatically reduces API calls and processing overhead.

## :arrows_counterclockwise: Working with Iterators

Many providers return data as **WorkerBee iterators** for optimal performance and memory usage. These iterators are fully compatible with standard JavaScript iteration patterns.

!!!info Providers that return iterators
Example providers that return `WorkerBeeIterable`:

- **Feed Price Provider**: `data.feedPrice.priceHistory` - Historical price data
- **New Account Provider**: `data.newAccounts` - Newly created accounts
- **Impacted Account Provider**: `data.impactedAccounts[account]` - Operations affecting accounts
- **Whale Alert Provider**: `data.whaleOperations` - Large transfers
- **Exchange Transfer Provider**: `data.exchangeTransferOperations` - Exchange deposits/withdrawals
- **Internal Market Provider**: `data.internalMarketOperations` - DEX operations
- **Alarm Provider**: `data.alarmsPerAccount[account]` - Account security alerts

!!!

### For...of Loop (Recommended)

```typescript
workerbee.observe
  .onBlock()
  .provideFeedPriceData()
  .subscribe({
    next: ({ feedPrice }) => {
      // Iterate through historical price data from provider
      for (const price of feedPrice.priceHistory) {
        console.log(`Historical HIVE price: ${price.base.amount} ${price.base.symbol}`);
        console.log(`Exchange rate: ${price.quote.amount} ${price.quote.symbol}`);
      }
    }
  });
```

### forEach Method

```typescript
workerbee.observe
  .onNewAccount()  // Filter automatically adds NewAccountProvider
  .subscribe({
    next: ({ newAccounts }) => {
      // Provider returns WorkerBeeIterable of new accounts
      newAccounts.forEach((account) => {
        console.log(`🆕 New account created: @${account.accountName}`);
        console.log(`Created by: @${account.creator}`);
        console.log(`Memo key: ${account.memo}`);
      });
    }
  });
```

### Working with Multiple Provider Iterators

```typescript
workerbee.observe
  .onBlock()
  .provideFeedPriceData()      // Returns iterator: feedPrice.priceHistory
  .subscribe({
    next: ({ feedPrice }) => {
      // Calculate price statistics from provider data
      let totalPrices = 0;
      let priceCount = 0;
      let minPrice = Infinity;
      let maxPrice = 0;

      // Efficient iteration over provider's historical data
      for (const price of feedPrice.priceHistory) {
        const priceValue = parseFloat(price.base.amount);
        totalPrices += priceValue;
        priceCount++;
        minPrice = Math.min(minPrice, priceValue);
        maxPrice = Math.max(maxPrice, priceValue);
      }

      if (priceCount > 0) {
        const avgPrice = totalPrices / priceCount;
        console.log(`📊 HIVE Price Analysis (from ${priceCount} data points):`);
        console.log(`Average: $${avgPrice.toFixed(4)}`);
        console.log(`Range: $${minPrice.toFixed(4)} - $${maxPrice.toFixed(4)}`);
        console.log(`Current: $${feedPrice.currentMedianHistory.base.amount}`);
      }
    }
  });
```

## :link: Providers and Logical Filters Interaction

!!!warning
**Important**: Providers are **independent of logical operators** (`and`/`or`) and can be placed anywhere in the filter chain. They will **always execute when any filter matches**, regardless of logical grouping.
!!!

```typescript
// Providers work the same regardless of and/or placement
workerbee.observe
  .onPosts("alice")
  .provideAccounts("bob")        // ✅ Provider here
  .and.onComments("charlie")
  .provideAccounts("dave")       // ✅ Provider here too
  .or.onVotes("eve")
  .provideAccounts("frank")      // ✅ And here
  .subscribe({
    next: ({ accounts }) => {
      // All account data available when ANY filter matches:
      // accounts.bob, accounts.dave, accounts.frank
    }
  });
```

This design ensures that providers deliver consistent, complete data regardless of which specific filter triggered the event.

## :rocket: Advanced Example: Mixed Providers & Filters

Here's a sophisticated example demonstrating provider squashing, iterators, and complex filter combinations:

```typescript
import { WorkerBee, EManabarType } from '@hiveio/workerbee';

const workerbee = new WorkerBee();

await workerbee.start();

workerbee.observe
  // 🔍 Complex filter combinations
  .onPosts("alice", "bob")
  .or.onComments("alice", "bob")
  .or.onVotes("charlie")
  .or.onWhaleAlert(workerbee.chain.hiveCoins(5000))

  // 📋 Multiple provider calls (automatically optimized)
  .provideAccounts("alice")        // Will be squashed
  .provideAccounts("bob", "charlie") // into single call
  .provideAccounts("whale-watcher")  // for all accounts

  // ⚡ Manabar data for different types
  .provideManabarData(EManabarType.UPVOTE, "alice")
  .provideManabarData(EManabarType.RC, "alice", "bob")
  .provideManabarData(EManabarType.DOWNVOTE, "charlie")

  // 🏗️ Block and market data
  .provideBlockData()
  .provideFeedPriceData()

  .subscribe({
    next: (data) => {
      // 📝 Handle post creation
      if (data.posts) {
        for (const [author, posts] of Object.entries(data.posts)) {
          posts.forEach(({ operation }) => {
            console.log(`📄 New post by @${author}: "${operation.title}"`);
            console.log(`💰 Author balance: ${data.accounts[author]?.balance.HIVE.liquid}`);
          });
        }
      }

      // 💬 Handle comments
      if (data.comments) {
        for (const [author, comments] of Object.entries(data.comments)) {
          comments.forEach(({ operation }) => {
            console.log(`💬 Comment by @${author} on @${operation.parent_author}/${operation.parent_permlink}`);

            // Check author's RC level
            const rcManabar = data.manabarData[author]?.[EManabarType.RC];
            if (rcManabar && rcManabar.percent < 20) {
              console.log(`⚠️ Warning: @${author} has low RC (${rcManabar.percent.toFixed(1)}%)`);
            }
          });
        }
      }

      // 👍 Handle votes
      if (data.votes?.charlie) {
        data.votes.charlie.forEach(({ operation }) => {
          const voteValue = operation.weight > 0 ? '👍 Upvote' : '👎 Downvote';
          console.log(`${voteValue} by @${operation.voter}: ${Math.abs(operation.weight/100)}%`);

          // Check voter's voting power
          const upvoteManabar = data.manabarData[operation.voter]?.[EManabarType.UPVOTE];
          if (upvoteManabar) {
            console.log(`🔋 Voting power: ${upvoteManabar.percent.toFixed(1)}%`);
          }
        });
      }

      // 🐋 Handle whale transfers
      if (data.whaleOperations) {
        data.whaleOperations.forEach(({ operation, transaction }) => {
          console.log(`🐋 WHALE ALERT: ${operation.amount.amount} ${operation.amount.symbol}`);
          console.log(`From: @${operation.from} → To: @${operation.to}`);
          console.log(`Block: #${data.block.number} | TX: ${transaction.id}`);

          // Check if whale accounts are in our data
          const fromAccount = data.accounts[operation.from];
          const toAccount = data.accounts[operation.to];

          if (fromAccount) {
            console.log(`Sender total HIVE: ${fromAccount.balance.HIVE.total}`);
          }
          if (toAccount) {
            console.log(`Receiver total HIVE: ${toAccount.balance.HIVE.total}`);
          }
        });
      }

      // 📊 Market context
      console.log(`💱 Current HIVE price: $${data.feedPrice?.currentMedianHistory?.base?.amount || 'N/A'}`);
      console.log(`📦 Block #${data.block.number} by @${data.block.witness}`);
    },

    error: (error) => {
      console.error('❌ WorkerBee error:', error);
    }
  });
```

This example demonstrates:

- **Provider squashing**: Multiple `provideAccounts` calls are automatically optimized
- **Iterator usage**: Clean iteration over posts, comments, votes, and whale operations
- **Data correlation**: Using account data alongside manabar information
- **Complex filtering**: Multiple OR conditions with independent provider execution
- **Performance optimization**: Parallel provider execution with intelligent caching

---

## :books: Complete Reference

For comprehensive examples of all available providers, check out the complete API reference:

[!ref text="Browse All Provider Examples in API Reference"](/interfaces/api-reference/#providers)
