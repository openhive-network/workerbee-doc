---
order: -4
icon: database
---

# Data Providers

Data Providers are WorkerBee's data transformation layer. They gather, process, and normalize blockchain data into clean, easy-to-use objects for your application. Providers run only when filters match, ensuring optimal performance.

## :mag: Provider Overview

Providers transform raw blockchain data into structured TypeScript objects. They run concurrently with filters and automatically benefit from WorkerBee's caching system.

### :zap: Basic Provider Usage

+++ JavaScript

!!!secondary
Note that the [`?.` operator](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Optional_chaining) is used to safely access nested properties, preventing runtime errors if `bob` account is not available for any reason, e.g. if the account is not found, or accounts endpoint is down.
!!!

```typescript:highlight="8,12"
import { WorkerBee } from '@hiveio/workerbee';

const workerbee = WorkerBee.create();

// Use providers to get additional data
workerbee.observe
  .onPosts("alice")
  .provideAccounts("bob")      // Get account data
  .subscribe({
    next: ({ accounts }) => {
      console.log(`Alice created a post`);
      console.log(`And bob has ${accounts.bob?.balance.HIVE.liquid} HIVE`)
    }
  });
```

+++ Python

TBA

+++
