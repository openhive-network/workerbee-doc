---
order: -6
icon: tools
---

# Troubleshooting Guide

Common issues, solutions, and debugging techniques for WorkerBee applications.

## :bug: Common Issues

### Connection Problems

#### Issue: "Cannot connect to Hive API"

**Symptoms:**

- Observer never triggers
- Connection timeout errors
- Network-related error messages

**Solutions:**

```typescript
// 1. Try different API endpoints
const workerbee = WorkerBee.create({
  apiEndpoint: 'https://api.hive.blog', // Primary
  // apiEndpoint: 'https://anyx.io', // Alternative
  // apiEndpoint: 'https://hive-api.arcange.eu', // Alternative
  timeout: 15000, // Increase timeout
  maxRetries: 5   // Increase retry attempts
});

// 2. Test connection manually
async function testConnection() {
  try {
    const response = await fetch('https://api.hive.blog', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        jsonrpc: '2.0',
        method: 'database_api.get_dynamic_global_properties',
        params: {},
        id: 1
      })
    });
    
    if (response.ok) {
      console.log('✅ API connection successful');
      const data = await response.json();
      console.log('Current head block:', data.result.head_block_number);
    } else {
      console.log('❌ API connection failed:', response.status);
    }
  } catch (error) {
    console.error('❌ Connection error:', error);
  }
}
```

#### Issue: "Rate limiting errors"

**Symptoms:**

- 429 "Too Many Requests" errors
- Intermittent failures
- Slow response times

**Solutions:**

```typescript
// 1. Implement request throttling
const workerbee = WorkerBee.create({
  cycleInterval: 5000, // Slower polling (5 seconds instead of 2)
  maxRetries: 3,
  timeout: 20000
});

// 2. Use multiple API endpoints with rotation
class APIRotator {
  private endpoints = [
    'https://api.hive.blog',
    'https://anyx.io',
    'https://hive-api.arcange.eu'
  ];
  private currentIndex = 0;
  private failureCounts = new Map<string, number>();

  getNextEndpoint(): string {
    // Skip endpoints with recent failures
    for (let i = 0; i < this.endpoints.length; i++) {
      const endpoint = this.endpoints[this.currentIndex];
      const failures = this.failureCounts.get(endpoint) || 0;
      
      if (failures < 3) {
        return endpoint;
      }
      
      this.currentIndex = (this.currentIndex + 1) % this.endpoints.length;
    }
    
    // Reset failure counts if all endpoints are failing
    this.failureCounts.clear();
    return this.endpoints[0];
  }

  recordFailure(endpoint: string) {
    const failures = (this.failureCounts.get(endpoint) || 0) + 1;
    this.failureCounts.set(endpoint, failures);
    this.currentIndex = (this.currentIndex + 1) % this.endpoints.length;
  }
}
```

### Observer Issues

#### Issue: "Observer never triggers"

**Symptoms:**

- `next` callback never called
- No error messages
- Application appears to hang

**Solutions:**

```typescript
// 1. Add comprehensive logging
workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: (data) => {
      console.log('✅ Observer triggered:', data);
    },
    error: (error) => {
      console.error('❌ Observer error:', error);
    },
    complete: () => {
      console.log('Observer completed');
    }
  });

// 2. Test with broader filters first
workerbee.observe
  .onBlock() // This should trigger every ~3 seconds
  .subscribe({
    next: ({ block }) => {
      console.log(`Block ${block.block_num} at ${block.timestamp}`);
    }
  });

// 3. Check if the specified author actually posts
workerbee.observe
  .onOperation('comment') // Monitor all comments/posts
  .subscribe({
    next: ({ operations }) => {
      const posts = operations.comment.filter(op => !op.parent_author);
      console.log(`Found ${posts.length} new posts from various authors`);
      posts.forEach(post => {
        console.log(`Post by @${post.author}: "${post.title}"`);
      });
    }
  });
```

#### Issue: "Data is incomplete or undefined"

**Symptoms:**

- `TypeError: Cannot read property of undefined`
- Missing data in callback
- Inconsistent data structure

**Solutions:**

```typescript
// 1. Always check data exists
workerbee.observe
  .onPosts("alice")
  .provideAccounts("alice")
  .subscribe({
    next: ({ posts, accounts }) => {
      // ✅ Safe data access
      if (posts?.alice?.length > 0) {
        posts.alice.forEach(post => {
          console.log(`Post: ${post.title}`);
          
          // Check account data exists
          if (accounts?.alice) {
            console.log(`Author balance: ${accounts.alice.balance}`);
          } else {
            console.log('⚠️ Account data not available');
          }
        });
      } else {
        console.log('No new posts from Alice');
      }
    }
  });

// 2. Use TypeScript for better type safety
interface ObserverData {
  posts?: Record<string, Post[]>;
  accounts?: Record<string, Account>;
  [key: string]: any;
}

workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: (data: ObserverData) => {
      // TypeScript will warn about potential undefined access
      const alicePosts = data.posts?.alice || [];
      console.log(`Alice has ${alicePosts.length} new posts`);
    }
  });
```

### Performance Issues

#### Issue: "Application is slow or unresponsive"

**Symptoms:**

- High memory usage
- Slow callback execution
- CPU spikes

**Solutions:**

```typescript
// 1. Optimize filters and providers
// ❌ Too many specific filters (inefficient)
workerbee.observe
  .onPosts("author1")
  .onPosts("author2")
  .onPosts("author3")
  // ... many more
  .subscribe({ /* ... */ });

// ✅ Use broader filter with custom logic
workerbee.observe
  .onOperation('comment')
  .subscribe({
    next: ({ operations }) => {
      const targetAuthors = new Set(['author1', 'author2', 'author3']);
      const relevantPosts = operations.comment.filter(op => 
        !op.parent_author && targetAuthors.has(op.author)
      );
      
      if (relevantPosts.length > 0) {
        this.processPosts(relevantPosts);
      }
    }
  });

// 2. Limit data processing
workerbee.observe
  .onPosts()
  .subscribe({
    next: ({ posts }) => {
      // ❌ Processing all posts synchronously
      // Object.entries(posts).forEach(([author, authorPosts]) => {
      //   authorPosts.forEach(post => {
      //     this.heavyProcessing(post); // Blocks event loop
      //   });
      // });

      // ✅ Process asynchronously with limits
      this.processPostsAsync(posts);
    }
  });

private async processPostsAsync(posts: any) {
  const allPosts = Object.values(posts).flat();
  const maxBatchSize = 10;
  
  for (let i = 0; i < allPosts.length; i += maxBatchSize) {
    const batch = allPosts.slice(i, i + maxBatchSize);
    
    // Process batch asynchronously
    await Promise.all(batch.map(post => this.processPost(post)));
    
    // Yield control back to event loop
    await new Promise(resolve => setImmediate(resolve));
  }
}
```

#### Issue: "Memory leaks"

**Symptoms:**

- Memory usage continuously increases
- Application crashes after running for hours
- Node.js heap out of memory errors

**Solutions:**

```typescript
// 1. Properly manage subscriptions
class MemoryEfficientBot {
  private subscriptions: Subscription[] = [];
  
  start() {
    const subscription = workerbee.observe
      .onPosts("alice")
      .subscribe({
        next: (data) => {
          this.processData(data);
        }
      });
    
    // Track subscription for cleanup
    this.subscriptions.push(subscription);
  }
  
  stop() {
    // Clean up all subscriptions
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.subscriptions = [];
  }
}

// 2. Clear data structures periodically
class DataManager {
  private cache = new Map<string, any>();
  
  constructor() {
    // Clear cache every hour
    setInterval(() => {
      this.cache.clear();
      console.log('Cache cleared to prevent memory leaks');
    }, 60 * 60 * 1000);
  }
}

// 3. Monitor memory usage
function logMemoryUsage() {
  const usage = process.memoryUsage();
  console.log('Memory Usage:');
  console.log(`  RSS: ${Math.round(usage.rss / 1024 / 1024 * 100) / 100} MB`);
  console.log(`  Heap Used: ${Math.round(usage.heapUsed / 1024 / 1024 * 100) / 100} MB`);
  console.log(`  Heap Total: ${Math.round(usage.heapTotal / 1024 / 1024 * 100) / 100} MB`);
}

// Log memory usage every 10 minutes
setInterval(logMemoryUsage, 10 * 60 * 1000);
```

## :mag: Debugging Techniques

### Enable Debug Logging

```typescript
// 1. Environment variable approach
if (process.env.DEBUG === 'workerbee') {
  console.log('Debug mode enabled');
  
  workerbee.observe
    .onPosts("alice")
    .subscribe({
      next: (data) => {
        console.log('DEBUG: Observer data:', JSON.stringify(data, null, 2));
      },
      error: (error) => {
        console.log('DEBUG: Observer error:', error);
      }
    });
}

// 2. Custom logger
class DebugLogger {
  private enabled: boolean;
  
  constructor(enabled = false) {
    this.enabled = enabled;
  }
  
  log(message: string, data?: any) {
    if (this.enabled) {
      console.log(`[DEBUG] ${message}`, data ? JSON.stringify(data, null, 2) : '');
    }
  }
  
  error(message: string, error?: any) {
    if (this.enabled) {
      console.error(`[DEBUG ERROR] ${message}`, error);
    }
  }
}

const logger = new DebugLogger(process.env.NODE_ENV === 'development');

workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: (data) => {
      logger.log('Received posts data', data);
    },
    error: (error) => {
      logger.error('Observer failed', error);
    }
  });
```

### Monitor API Calls

```typescript
class APIMonitor {
  private callCounts = new Map<string, number>();
  private startTime = Date.now();
  
  logAPICall(endpoint: string, method: string) {
    const key = `${endpoint}:${method}`;
    this.callCounts.set(key, (this.callCounts.get(key) || 0) + 1);
  }
  
  printStats() {
    const runtime = (Date.now() - this.startTime) / 1000 / 60; // minutes
    console.log(`\n📊 API Call Statistics (${runtime.toFixed(1)} minutes)`);
    console.log('================================================');
    
    let totalCalls = 0;
    for (const [endpoint, calls] of this.callCounts.entries()) {
      console.log(`${endpoint}: ${calls} calls (${(calls / runtime).toFixed(1)}/min)`);
      totalCalls += calls;
    }
    
    console.log(`Total: ${totalCalls} calls (${(totalCalls / runtime).toFixed(1)}/min)`);
  }
}

const apiMonitor = new APIMonitor();

// Log stats every 5 minutes
setInterval(() => apiMonitor.printStats(), 5 * 60 * 1000);
```

### Test Filters Individually

```typescript
// Test filters one by one to isolate issues
class FilterTester {
  async testPostFilter(author: string) {
    console.log(`Testing post filter for @${author}`);
    
    const testWorkerbee = WorkerBee.create();
    
    const subscription = testWorkerbee.observe
      .onPosts(author)
      .subscribe({
        next: ({ posts }) => {
          console.log(`✅ Post filter works! Found ${posts[author]?.length || 0} posts`);
          subscription.unsubscribe();
        },
        error: (error) => {
          console.error(`❌ Post filter failed:`, error);
          subscription.unsubscribe();
        }
      });
    
    // Timeout test after 30 seconds
    setTimeout(() => {
      console.log(`⏱️ Test timeout for @${author} - no posts detected in 30s`);
      subscription.unsubscribe();
    }, 30000);
  }
  
  async testAccountFilter(account: string) {
    console.log(`Testing account filter for @${account}`);
    
    const testWorkerbee = WorkerBee.create();
    
    const subscription = testWorkerbee.observe
      .onAccountsBalanceChange(false, account)
      .subscribe({
        next: ({ accounts }) => {
          console.log(`✅ Account filter works! Balance: ${accounts[account]?.balance}`);
          subscription.unsubscribe();
        },
        error: (error) => {
          console.error(`❌ Account filter failed:`, error);
          subscription.unsubscribe();
        }
      });
    
    setTimeout(() => {
      console.log(`⏱️ Test timeout for @${account} - no balance changes in 30s`);
      subscription.unsubscribe();
    }, 30000);
  }
}

// Usage
const tester = new FilterTester();
tester.testPostFilter('alice');
tester.testAccountFilter('alice');
```

## :warning: Common Pitfalls

### Avoid Infinite Loops

```typescript
// ❌ DON'T: Create observers inside observer callbacks
workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      // This creates a new observer on every post!
      workerbee.observe
        .onAccountsFullManabar("voter")
        .subscribe({ /* ... */ });
    }
  });

// ✅ DO: Create all observers upfront
const postSubscription = workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      posts.alice.forEach(post => {
        this.queueForVoting(post);
      });
    }
  });

const voterSubscription = workerbee.observe
  .onAccountsFullManabar("voter")
  .subscribe({
    next: () => {
      this.processVotingQueue();
    }
  });
```

### Handle Async Operations Properly

```typescript
// ❌ DON'T: Block the observer callback
workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      posts.alice.forEach(async (post) => {
        // This doesn't wait for the async operation!
        await this.processPost(post);
      });
    }
  });

// ✅ DO: Handle async operations correctly
workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: async ({ posts }) => {
      // Option 1: Process sequentially
      for (const post of posts.alice) {
        await this.processPost(post);
      }
      
      // Option 2: Process in parallel
      await Promise.all(
        posts.alice.map(post => this.processPost(post))
      );
      
      // Option 3: Queue for background processing
      posts.alice.forEach(post => {
        this.backgroundQueue.add(() => this.processPost(post));
      });
    }
  });
```

### Resource Cleanup

```typescript
class ProperResourceManagement {
  private workerbee: WorkerBee;
  private subscriptions: Subscription[] = [];
  private timers: NodeJS.Timeout[] = [];
  
  constructor() {
    this.workerbee = WorkerBee.create();
  }
  
  start() {
    // Track all subscriptions
    const postSub = this.workerbee.observe
      .onPosts("alice")
      .subscribe({ /* ... */ });
    this.subscriptions.push(postSub);
    
    // Track all timers
    const timer = setInterval(() => {
      this.doPeriodicTask();
    }, 60000);
    this.timers.push(timer);
  }
  
  stop() {
    // Clean up subscriptions
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.subscriptions = [];
    
    // Clean up timers
    this.timers.forEach(timer => clearInterval(timer));
    this.timers = [];
    
    console.log('✅ All resources cleaned up');
  }
}

// Handle process signals for graceful shutdown
process.on('SIGINT', () => {
  console.log('Received SIGINT, shutting down gracefully...');
  app.stop();
  process.exit(0);
});
```

## :wrench: Environment-Specific Issues

### Development vs Production

```typescript
const isDevelopment = process.env.NODE_ENV === 'development';

const workerbee = WorkerBee.create({
  // More verbose logging in development
  apiEndpoint: isDevelopment 
    ? 'https://api.hive.blog' 
    : process.env.HIVE_API_ENDPOINT,
  
  // Faster cycles in development for testing
  cycleInterval: isDevelopment ? 1000 : 3000,
  
  // More retries in production
  maxRetries: isDevelopment ? 1 : 5,
  
  // Shorter timeout in development
  timeout: isDevelopment ? 5000 : 15000
});

if (isDevelopment) {
  // Enable additional debugging in development
  workerbee.observe
    .onBlock()
    .subscribe({
      next: ({ block }) => {
        console.log(`DEV: Block ${block.block_num} processed`);
      }
    });
}
```

### Testing Patterns

```typescript
// Mock WorkerBee for unit tests
class MockWorkerBee {
  private mockData: any = {};
  
  observe = {
    onPosts: () => ({
      subscribe: (observer: any) => {
        // Simulate data after delay
        setTimeout(() => {
          observer.next({ posts: this.mockData.posts || {} });
        }, 100);
        
        return { unsubscribe: () => {} };
      }
    })
  };
  
  setMockData(data: any) {
    this.mockData = data;
  }
}

// Test example
describe('BlogMonitor', () => {
  it('should process new posts', (done) => {
    const mockWorkerbee = new MockWorkerBee();
    mockWorkerbee.setMockData({
      posts: {
        alice: [{ title: 'Test Post', permlink: 'test' }]
      }
    });
    
    const monitor = new BlogMonitor(mockWorkerbee as any);
    monitor.onNewPost = (post) => {
      expect(post.title).toBe('Test Post');
      done();
    };
    
    monitor.start();
  });
});
```

This troubleshooting guide should help you diagnose and resolve most common issues when working with WorkerBee. Remember to always check the basics first: network connectivity, API endpoints, and data availability.
