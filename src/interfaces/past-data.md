---
order: -7
icon: telescope
---

# Past Data

WorkerBee provides a rich set of historical data that can be leveraged for various use cases, such as analytics, reporting, and machine learning. This section outlines how to access and utilize past data effectively.

You can also feed the bot using past blockchain data, before running into live to collect data and/or analyze trends and patterns.

## Overview: Live vs Past Data Modes

WorkerBee offers two powerful ways to work with blockchain data, each designed for different use cases:

### Live Data Mode

Monitor blockchain activity as it happens in real-time:

- **Purpose**: Real-time monitoring and immediate responses
- **Data**: Current blockchain state and live operations
- **Features**: Full access to account information, witness data, and live calculations
- **Best for**: Alerts, live dashboards, immediate notifications, trading bots

### Past Data Mode

Analyze historical blockchain data for insights and patterns:

- **Purpose**: Historical analysis and research
- **Data**: Operations and blocks from specific time periods
- **Features**: Efficient processing of large historical datasets
- **Best for**: Analytics, pattern recognition, backtesting, research

## Past data setup

### Specific block range setup

When you know the exact block numbers you want to analyze, you can specify them directly. This method provides precise control over the data range and is ideal for:

- **Analyzing specific events**: When you know a particular incident occurred between certain blocks
- **Reproducible analysis**: Ensuring consistent results by using fixed block ranges
- **Performance optimization**: Processing smaller, targeted datasets
- **Testing and debugging**: Working with known data ranges during development

The method accepts two parameters:

- **startBlock** (number): The first block to include in the analysis
- **endBlock** (number): The last block to include in the analysis (inclusive)

Both block numbers must be valid blocks that exist on the Hive blockchain. The range is processed sequentially from `startBlock` to `endBlock`.

+++ JavaScript

```typescript:highlight=1
bot.providePastOperations(startBlock, endBlock)
  .onBlock()
  .subscribe({
    next(data) {
      // Process blocks.
    }
  })
```

+++ Python

TBA

+++

### Relative timestamp setup

Instead of specifying exact block numbers, you can use relative timestamps to define how far back in time you want to analyze data. The syntax uses a minus sign followed by a number and a time unit:

- **Syntax**: `-{number}{unit}`
- **Time units**:
  - `s` - seconds
  - `m` - minutes
  - `h` - hours
  - `d` - days

**Examples**:

- `-30s` - last 30 seconds
- `-15m` - last 15 minutes
- `-24h` - last 24 hours
- `-7d` - last 7 days

When using relative timestamps, WorkerBee automatically calculates the block range:

- **endBlock**: Current head block (latest block on the chain)
- **startBlock**: Calculated by subtracting the time period from the current block, using Hive's 3-second block production interval

+++ JavaScript

```typescript:highlight=3
// Remember to await providePastOperations when using relative timestamp.
// This way, providePastOperations is executed asynchronously because we must make get_dynamic_global_properties API call to get current block data.
(await bot.providePastOperations("-24h"))
  .onBlock()
  .subscribe({
    next(data) {
      // Process blocks.
    }
  })
```

+++ Python

TBA

+++

!!!warning
It is preferred to feed the bot with past data only once per WorkerBee instance!
!!!

## Use Cases for Past Data

### 1. Pattern Analysis

Analyze historical voting patterns, posting behavior, or market trends:

+++ JavaScript

```typescript
// Analyze whale account's voting patterns over a specific period
bot.providePastOperations(startBlock, endBlock)
  .onVotes("whale")
  .onWhaleAlert(hiveCoins(10000))
  .subscribe({
    next(data) {
      console.log("Whale activity detected:", data);
    }
  });
```

+++ Python

TBA

+++

### 2. Market Trend Analysis

Study historical market movements and trading patterns:

+++ JavaScript

```typescript
// Analyze 7 days of market activity
bot.providePastOperations("-7d")
  .onInternalMarketOperation()
  .onExchangeTransfer()
  .subscribe({
    next(data) {
      // Process market data for trend analysis
    }
  });
```

+++ Python

TBA

+++

### 3. Community Growth Monitoring

Track community development over time:

+++ JavaScript

```typescript
// Monitor account creation and follow patterns
bot.providePastOperations(startBlock, endBlock)
  .onNewAccount()
  .onFollow("community")
  .subscribe({
    next(data) {
      // Analyze community growth metrics
    }
  });
```

+++ Python

TBA

+++

### 4. Content Analytics

Analyze posting patterns and engagement:

+++ JavaScript

```typescript
// Study content creation patterns
bot.providePastOperations("-7d")
  .onPosts("author")
  .onComments("author")
  .onVotes("voter")
  .subscribe({
    next(data) {
      // Analyze content performance
    }
  });
```

+++ Python

TBA

+++

## Basic Past Data Usage

### Simple Block Range Query

+++ JavaScript

```typescript
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

// Process specific block range
bot.providePastOperations(96549390, 96549415)
  .onPosts("guest4test")
  .subscribe({
    next(data) {
      data.posts.guest4test?.forEach(({ operation }) => {
        console.log(`Found post: ${operation.author}/${operation.permlink}`);
      });
    },
    complete() {
      console.log("Historical analysis complete");
    }
  });
```

+++ Python

TBA

+++

### Relative Time Queries

+++ JavaScript

```typescript
// Process last 7 days of data
const pastQueen = await bot.providePastOperations("-7d");
pastQueen.onBlock().subscribe({
  next(data) {
    // Process historical blocks
  }
});
```

+++ Python

TBA

+++

## Technical Architecture Differences

### Collector Factories

WorkerBee uses different factory patterns for live and past data. The mediator automatically switches between these factories without user interaction, preserving the internal application state. This seamless transition is possible thanks to the factories' extend functionality - each factory can extend itself with state from other factories.

#### JsonRpcFactory (Live Data)

The `JsonRpcFactory` provides a comprehensive set of collectors for real-time data:

- **AccountCollector**: Real-time account information
- **FeedPriceCollector**: Current feed price data
- **WitnessCollector**: Witness information and schedules
- **RcAccountCollector**: Resource Credit account data
- **ManabarCollector**: Live manabar calculations

#### HistoryDataFactory (Past Data)

The `HistoryDataFactory` uses a more limited set optimized for historical analysis:

- **BlockCollector**: Historical block data via `get_block_range`
- **DynamicGlobalPropertiesCollector**: Chain state at specific points
- **ImpactedAccountCollector**: Accounts affected by operations
- **OperationCollector**: Historical operations from blocks

### Data Collection Limitations

Due to architectural differences, certain types of data are **not available** in past data mode:

#### Unavailable in Past Data Mode

1. **Account Data (`provideAccounts`)**
   - Account information is not stored in block history
   - Current account states may differ from historical states
   - **Reason**: Accounts change over time, block data only contains operations

2. **Feed Price Data (`provideFeedPriceData`)**
   - Feed prices are witness-provided data not stored in blocks
   - **Reason**: Price feeds are published separately from block operations

3. **Manabar Data (`onAccountsFullManabar`, `onAccountsBalanceChange`)**
   - Manabar calculations require real-time RC and voting power
   - **Reason**: These are calculated values, not stored in blockchain

4. **Witness Data (`provideWitnesses`, `onWitnessesMissedBlocks`)**
   - Witness schedules and missed blocks require live monitoring
   - **Reason**: Witness information changes dynamically

5. **Alarm Events (`onAlarm`)**
   - Alarms are time-based triggers, not historical data
   - **Reason**: Time-based events don't exist in past block data

## Advanced Examples

### Switching Between Past and Live Data

You can seamlessly transition from historical analysis to live monitoring:

+++ JavaScript

```typescript
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

// First, analyze historical data
console.log("📊 Analyzing historical data...");

await new Promise<void>((resolve) => {
  // Analyze block range
  bot.providePastOperations(96549390, 96549415)
    .onPosts("guest4test")
    .onVotes("guest4test")
    .subscribe({
      next(data) {
        // Process historical posts and votes
        if (data.posts.guest4test) {
          data.posts.guest4test.forEach(({ operation }) => {
            console.log(`📝 Historical post: ${operation.permlink}`);
          });
        }

        if (data.votes.guest4test) {
          data.votes.guest4test.forEach(({ operation }) => {
            console.log(`👍 Historical vote: ${operation.permlink}`);
          });
        }
      },
      complete: resolve
    });
});

console.log("🔴 Switching to live monitoring...");

// Now switch to live data monitoring
// The historical data context is preserved!
bot.observe
  .onPosts("guest4test")
  .onVotes("guest4test")
  .subscribe({
    next(data) {
      // Process live posts and votes
      if (data.posts.guest4test) {
        data.posts.guest4test.forEach(({ operation }) => {
          console.log(`📝 Live post: ${operation.permlink}`);
        });
      }
    }
  });
```

+++ Python

TBA

+++

### Complex Historical Analysis

+++ JavaScript

```typescript
// Multi-dimensional whale activity analysis
const bot = new WorkerBee();
await bot.start();

const whaleAccounts = ["guest4test", "guest4test2", "guest4test3"];
const analysisResults = {
  posts: new Map<string, number>(),
  votes: new Map<string, number>(),
  transfers: new Map<string, number>()
};

await new Promise<void>((resolve) => {
  // Analyze relative timestamp (last 24 hours)
  bot.providePastOperations("-24h")
    .onPosts(...whaleAccounts)
    .onVotes(...whaleAccounts)
    .onWhaleAlert(bot.chain!.hiveCoins(1000))
    .provideBlockData()
    .subscribe({
      next(data) {
        // Count posts per whale
        whaleAccounts.forEach(whale => {
          if (data.posts[whale]) {
            analysisResults.posts.set(whale,
              (analysisResults.posts.get(whale) || 0) + data.posts[whale].length
            );
          }

          if (data.votes[whale]) {
            analysisResults.votes.set(whale,
              (analysisResults.votes.get(whale) || 0) + data.votes[whale].length
            );
          }
        });

        // Track large transfers
        data.whaleOperations.forEach(({ operation }) => {
          const account = operation.from;
          analysisResults.transfers.set(account,
            (analysisResults.transfers.get(account) || 0) + 1
          );
        });

        // Log block progress
        if (data.blockData) {
          console.log(`📦 Processed block ${data.blockData.blockNumber}`);
        }
      },
      error(err) {
        console.error("Analysis error:", err);
      },
      complete() {
        console.log("📊 Analysis Results:");
        console.log("Posts:", Object.fromEntries(analysisResults.posts));
        console.log("Votes:", Object.fromEntries(analysisResults.votes));
        console.log("Large transfers:", Object.fromEntries(analysisResults.transfers));
        resolve();
      }
    });
});
```

+++ Python

TBA

+++
