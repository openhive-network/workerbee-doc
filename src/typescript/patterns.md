---
order: -5
icon: light-bulb
---

# Common Patterns

Learn proven patterns and best practices for building robust WorkerBee applications. These patterns solve common challenges and provide reusable solutions.

## :arrows_clockwise: Reactive Patterns

### Observer Chain Pattern

Chain multiple observers for complex workflows:

```typescript
import { WorkerBee } from '@hiveio/workerbee';

class BlogMonitoringService {
  private workerbee: WorkerBee;

  constructor() {
    this.workerbee = WorkerBee.create();
  }

  start() {
    // Primary observer: Monitor new posts
    this.workerbee.observe
      .onPosts("alice", "bob")
      .provideAccounts("alice", "bob")
      .subscribe({
        next: ({ posts, accounts }) => {
          // Trigger secondary observers based on post quality
          this.evaluateAndProcessPosts(posts, accounts);
        }
      });
  }

  private evaluateAndProcessPosts(posts: any, accounts: any) {
    Object.entries(posts).forEach(([author, authorPosts]) => {
      authorPosts.forEach((post: any) => {
        if (this.isHighQualityPost(post, accounts[author])) {
          // Chain to voting observer
          this.startVotingProcess(author, post.permlink);
        }
      });
    });
  }

  private startVotingProcess(author: string, permlink: string) {
    // Secondary observer: Monitor voting readiness
    this.workerbee.observe
      .onAccountsFullManabar("my_voter")
      .provideAccountsVotingManabar("my_voter")
      .subscribe({
        next: ({ votingManabar }) => {
          const manabar = votingManabar.my_voter;
          if (manabar.current_mana / manabar.max_mana > 0.8) {
            this.castVote(author, permlink);
          }
        }
      });
  }

  private isHighQualityPost(post: any, account: any): boolean {
    const wordCount = post.body.split(/\s+/).length;
    const reputation = parseInt(account.reputation);
    
    return wordCount > 200 && reputation > 60 && post.tags.length >= 3;
  }

  private async castVote(author: string, permlink: string) {
    console.log(`Voting on @${author}/${permlink}`);
    // Implement voting logic
  }
}
```

### State Management Pattern

Manage application state across multiple observers:

```typescript
interface AppState {
  userBalances: Map<string, number>;
  votingQueue: Array<{author: string, permlink: string}>;
  lastProcessedBlock: number;
}

class StateManager {
  private state: AppState = {
    userBalances: new Map(),
    votingQueue: [],
    lastProcessedBlock: 0
  };
  
  private workerbee: WorkerBee;
  private subscribers: Array<(state: AppState) => void> = [];

  constructor() {
    this.workerbee = WorkerBee.create();
    this.startMonitoring();
  }

  subscribe(callback: (state: AppState) => void) {
    this.subscribers.push(callback);
    callback(this.state); // Immediate callback with current state
  }

  private notifySubscribers() {
    this.subscribers.forEach(callback => callback(this.state));
  }

  private startMonitoring() {
    // Monitor balance changes
    this.workerbee.observe
      .onAccountsBalanceChange(false, "alice", "bob", "charlie")
      .subscribe({
        next: ({ accounts }) => {
          Object.entries(accounts).forEach(([name, account]) => {
            const balance = parseFloat(account.balance.replace(' HIVE', ''));
            this.state.userBalances.set(name, balance);
          });
          this.notifySubscribers();
        }
      });

    // Monitor posts for voting queue
    this.workerbee.observe
      .onPosts()
      .subscribe({
        next: ({ posts }) => {
          Object.entries(posts).forEach(([author, authorPosts]) => {
            authorPosts.forEach((post: any) => {
              if (this.shouldQueueForVoting(post)) {
                this.state.votingQueue.push({
                  author: post.author,
                  permlink: post.permlink
                });
              }
            });
          });
          this.notifySubscribers();
        }
      });

    // Monitor blocks for progress tracking
    this.workerbee.observe
      .onBlock()
      .subscribe({
        next: ({ block }) => {
          this.state.lastProcessedBlock = block.block_num;
          this.notifySubscribers();
        }
      });
  }

  private shouldQueueForVoting(post: any): boolean {
    return post.tags.includes('workerbee') && post.body.length > 100;
  }

  getState(): AppState {
    return { ...this.state }; // Return copy to prevent mutations
  }
}

// Usage
const stateManager = new StateManager();

stateManager.subscribe((state) => {
  console.log(`Voting queue length: ${state.votingQueue.length}`);
  console.log(`Last processed block: ${state.lastProcessedBlock}`);
  
  // Process voting queue
  if (state.votingQueue.length > 0) {
    const nextVote = state.votingQueue[0];
    console.log(`Next vote: @${nextVote.author}/${nextVote.permlink}`);
  }
});
```

## :hourglass_flowing_sand: Timing Patterns

### Debouncing Pattern

Avoid processing too many events in quick succession:

```typescript
class DebouncedProcessor {
  private workerbee: WorkerBee;
  private debounceTimeouts = new Map<string, NodeJS.Timeout>();
  private pendingData = new Map<string, any[]>();

  constructor() {
    this.workerbee = WorkerBee.create();
  }

  start() {
    this.workerbee.observe
      .onComments()
      .subscribe({
        next: ({ comments }) => {
          Object.entries(comments).forEach(([author, authorComments]) => {
            this.debounceProcess(author, authorComments);
          });
        }
      });
  }

  private debounceProcess(key: string, data: any[], delay: number = 5000) {
    // Clear existing timeout
    const existingTimeout = this.debounceTimeouts.get(key);
    if (existingTimeout) {
      clearTimeout(existingTimeout);
    }

    // Accumulate data
    const existing = this.pendingData.get(key) || [];
    this.pendingData.set(key, [...existing, ...data]);

    // Set new timeout
    const timeout = setTimeout(() => {
      const allData = this.pendingData.get(key) || [];
      this.processComments(key, allData);
      
      // Clean up
      this.debounceTimeouts.delete(key);
      this.pendingData.delete(key);
    }, delay);

    this.debounceTimeouts.set(key, timeout);
  }

  private processComments(author: string, comments: any[]) {
    console.log(`Processing ${comments.length} comments from @${author}`);
    
    // Analyze comment patterns
    const avgLength = comments.reduce((sum, c) => sum + c.body.length, 0) / comments.length;
    console.log(`Average comment length: ${avgLength.toFixed(0)} characters`);
    
    // Check for spam patterns
    const uniqueComments = new Set(comments.map(c => c.body.toLowerCase())).size;
    const spamRatio = 1 - (uniqueComments / comments.length);
    
    if (spamRatio > 0.5) {
      console.log(`⚠️ Potential spam detected from @${author} (${(spamRatio * 100).toFixed(1)}% similarity)`);
    }
  }
}
```

### Rate Limiting Pattern

Control the rate of operations to avoid API limits:

```typescript
class RateLimitedBot {
  private workerbee: WorkerBee;
  private actionQueue: Array<() => Promise<void>> = [];
  private isProcessing = false;
  private actionsPerMinute = 10; // Rate limit

  constructor() {
    this.workerbee = WorkerBee.create();
    this.startQueueProcessor();
  }

  start() {
    this.workerbee.observe
      .onPosts()
      .provideAccounts()
      .subscribe({
        next: ({ posts, accounts }) => {
          Object.entries(posts).forEach(([author, authorPosts]) => {
            authorPosts.forEach((post: any) => {
              if (this.shouldVote(post, accounts[author])) {
                // Queue the vote action instead of executing immediately
                this.queueAction(() => this.voteOnPost(author, post.permlink));
              }
            });
          });
        }
      });
  }

  private queueAction(action: () => Promise<void>) {
    this.actionQueue.push(action);
    console.log(`Action queued. Queue length: ${this.actionQueue.length}`);
  }

  private startQueueProcessor() {
    const intervalMs = (60 * 1000) / this.actionsPerMinute; // Time between actions
    
    setInterval(async () => {
      if (this.actionQueue.length > 0 && !this.isProcessing) {
        this.isProcessing = true;
        
        try {
          const action = this.actionQueue.shift()!;
          await action();
          console.log(`Action executed. ${this.actionQueue.length} actions remaining`);
        } catch (error) {
          console.error('Failed to execute action:', error);
        } finally {
          this.isProcessing = false;
        }
      }
    }, intervalMs);
  }

  private shouldVote(post: any, account: any): boolean {
    return post.tags.includes('photography') && parseInt(account.reputation) > 55;
  }

  private async voteOnPost(author: string, permlink: string): Promise<void> {
    console.log(`🗳️ Voting on @${author}/${permlink}`);
    
    // Simulate vote operation
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    console.log(`✅ Vote completed for @${author}/${permlink}`);
  }
}
```

## :shield: Error Handling Patterns

### Retry with Exponential Backoff

Handle temporary failures gracefully:

```typescript
class ResilientBot {
  private workerbee: WorkerBee;
  private maxRetries = 3;

  constructor() {
    this.workerbee = WorkerBee.create();
  }

  start() {
    this.workerbee.observe
      .onPosts("alice")
      .subscribe({
        next: ({ posts }) => {
          posts.alice.forEach(post => {
            this.processPostWithRetry(post, 0);
          });
        },
        error: (error) => {
          console.error('Observer error:', error);
          // Restart observer after delay
          setTimeout(() => this.start(), 30000);
        }
      });
  }

  private async processPostWithRetry(post: any, attempt: number): Promise<void> {
    try {
      await this.processPost(post);
    } catch (error) {
      if (attempt < this.maxRetries) {
        const delay = Math.pow(2, attempt) * 1000; // Exponential backoff: 1s, 2s, 4s
        console.log(`Retry ${attempt + 1}/${this.maxRetries} for post @${post.author}/${post.permlink} in ${delay}ms`);
        
        setTimeout(() => {
          this.processPostWithRetry(post, attempt + 1);
        }, delay);
      } else {
        console.error(`Failed to process post after ${this.maxRetries} attempts:`, error);
        // Could log to error tracking service, send alert, etc.
      }
    }
  }

  private async processPost(post: any): Promise<void> {
    // Simulate operation that might fail
    if (Math.random() < 0.3) {
      throw new Error('Network timeout');
    }
    
    console.log(`Successfully processed: ${post.title}`);
  }
}
```

### Circuit Breaker Pattern

Prevent cascading failures:

```typescript
enum CircuitState {
  CLOSED,  // Normal operation
  OPEN,    // Failing, don't try
  HALF_OPEN // Testing if service recovered
}

class CircuitBreaker {
  private state = CircuitState.CLOSED;
  private failureCount = 0;
  private failureThreshold = 5;
  private recoveryTimeout = 30000; // 30 seconds
  private lastFailureTime = 0;

  async execute<T>(operation: () => Promise<T>): Promise<T> {
    if (this.state === CircuitState.OPEN) {
      if (Date.now() - this.lastFailureTime > this.recoveryTimeout) {
        this.state = CircuitState.HALF_OPEN;
        console.log('Circuit breaker: Transitioning to HALF_OPEN');
      } else {
        throw new Error('Circuit breaker is OPEN');
      }
    }

    try {
      const result = await operation();
      
      if (this.state === CircuitState.HALF_OPEN) {
        this.reset();
        console.log('Circuit breaker: Service recovered, transitioning to CLOSED');
      }
      
      return result;
    } catch (error) {
      this.recordFailure();
      throw error;
    }
  }

  private recordFailure() {
    this.failureCount++;
    this.lastFailureTime = Date.now();

    if (this.failureCount >= this.failureThreshold) {
      this.state = CircuitState.OPEN;
      console.log(`Circuit breaker: Too many failures (${this.failureCount}), transitioning to OPEN`);
    }
  }

  private reset() {
    this.state = CircuitState.CLOSED;
    this.failureCount = 0;
  }
}

class RobustBot {
  private workerbee: WorkerBee;
  private externalServiceBreaker = new CircuitBreaker();

  constructor() {
    this.workerbee = WorkerBee.create();
  }

  start() {
    this.workerbee.observe
      .onPosts()
      .subscribe({
        next: ({ posts }) => {
          Object.entries(posts).forEach(([author, authorPosts]) => {
            authorPosts.forEach(post => {
              this.processPostSafely(post);
            });
          });
        }
      });
  }

  private async processPostSafely(post: any) {
    try {
      // Use circuit breaker for external service calls
      await this.externalServiceBreaker.execute(async () => {
        return this.callExternalService(post);
      });
      
      console.log(`Processed post: @${post.author}/${post.permlink}`);
    } catch (error) {
      if (error.message === 'Circuit breaker is OPEN') {
        console.log(`Skipping external service call for @${post.author}/${post.permlink} - circuit breaker open`);
      } else {
        console.error(`Failed to process post @${post.author}/${post.permlink}:`, error.message);
      }
    }
  }

  private async callExternalService(post: any): Promise<void> {
    // Simulate external service that might fail
    if (Math.random() < 0.4) {
      throw new Error('External service unavailable');
    }
    
    // Simulate service call delay
    await new Promise(resolve => setTimeout(resolve, 100));
  }
}
```

## :memo: Data Processing Patterns

### Aggregation Pattern

Collect and analyze data over time:

```typescript
interface AuthorMetrics {
  postCount: number;
  totalVotes: number;
  totalPayout: number;
  avgWordCount: number;
  topTags: Map<string, number>;
  lastActivity: string;
}

class DataAggregator {
  private workerbee: WorkerBee;
  private authorMetrics = new Map<string, AuthorMetrics>();
  private aggregationWindow = 24 * 60 * 60 * 1000; // 24 hours

  constructor() {
    this.workerbee = WorkerBee.create();
    this.startCleanupTimer();
  }

  start() {
    // Aggregate post data
    this.workerbee.observe
      .onPosts()
      .subscribe({
        next: ({ posts }) => {
          Object.entries(posts).forEach(([author, authorPosts]) => {
            authorPosts.forEach(post => {
              this.updateAuthorMetrics(post);
            });
          });
        }
      });

    // Aggregate vote data
    this.workerbee.observe
      .onVotes()
      .subscribe({
        next: ({ votes }) => {
          Object.values(votes).flat().forEach((vote: any) => {
            this.updateVoteMetrics(vote);
          });
        }
      });

    // Report aggregated data periodically
    setInterval(() => {
      this.reportTopAuthors();
    }, 60 * 60 * 1000); // Every hour
  }

  private updateAuthorMetrics(post: any) {
    let metrics = this.authorMetrics.get(post.author) || {
      postCount: 0,
      totalVotes: 0,
      totalPayout: 0,
      avgWordCount: 0,
      topTags: new Map(),
      lastActivity: post.created
    };

    // Update metrics
    metrics.postCount++;
    metrics.lastActivity = post.created;
    
    // Update average word count
    const wordCount = post.body.split(/\s+/).length;
    metrics.avgWordCount = ((metrics.avgWordCount * (metrics.postCount - 1)) + wordCount) / metrics.postCount;
    
    // Update tag frequencies
    post.tags?.forEach((tag: string) => {
      metrics.topTags.set(tag, (metrics.topTags.get(tag) || 0) + 1);
    });

    this.authorMetrics.set(post.author, metrics);
  }

  private updateVoteMetrics(vote: any) {
    const metrics = this.authorMetrics.get(vote.author);
    if (metrics) {
      metrics.totalVotes++;
      // Could also track vote values, voting patterns, etc.
    }
  }

  private reportTopAuthors() {
    console.log('\n📊 Top Authors Report (Last 24h)');
    console.log('=====================================');

    const recentAuthors = Array.from(this.authorMetrics.entries())
      .filter(([_, metrics]) => {
        const lastActivity = new Date(metrics.lastActivity).getTime();
        return Date.now() - lastActivity < this.aggregationWindow;
      })
      .sort(([_, a], [__, b]) => b.postCount - a.postCount)
      .slice(0, 10);

    recentAuthors.forEach(([author, metrics], index) => {
      const topTags = Array.from(metrics.topTags.entries())
        .sort(([_, a], [__, b]) => b - a)
        .slice(0, 3)
        .map(([tag, _]) => tag);

      console.log(`${index + 1}. @${author}`);
      console.log(`   Posts: ${metrics.postCount}`);
      console.log(`   Votes: ${metrics.totalVotes}`);
      console.log(`   Avg Words: ${metrics.avgWordCount.toFixed(0)}`);
      console.log(`   Top Tags: ${topTags.join(', ')}`);
      console.log('');
    });
  }

  private startCleanupTimer() {
    // Clean up old data every hour
    setInterval(() => {
      const cutoff = Date.now() - this.aggregationWindow;
      
      for (const [author, metrics] of this.authorMetrics.entries()) {
        const lastActivity = new Date(metrics.lastActivity).getTime();
        if (lastActivity < cutoff) {
          this.authorMetrics.delete(author);
        }
      }
      
      console.log(`Cleaned up old metrics. Tracking ${this.authorMetrics.size} active authors.`);
    }, 60 * 60 * 1000);
  }
}
```

### Transform and Filter Pattern

Process and clean data before analysis:

```typescript
interface CleanPost {
  author: string;
  permlink: string;
  title: string;
  cleanedBody: string;
  wordCount: number;
  readingTime: number;
  tags: string[];
  quality: 'high' | 'medium' | 'low';
}

class ContentProcessor {
  private workerbee: WorkerBee;

  constructor() {
    this.workerbee = WorkerBee.create();
  }

  start() {
    this.workerbee.observe
      .onPosts()
      .subscribe({
        next: ({ posts }) => {
          const processedPosts = this.transformAndFilterPosts(posts);
          this.analyzeCleanedPosts(processedPosts);
        }
      });
  }

  private transformAndFilterPosts(posts: any): CleanPost[] {
    const allPosts: CleanPost[] = [];

    Object.entries(posts).forEach(([author, authorPosts]) => {
      authorPosts.forEach((post: any) => {
        const cleanedPost = this.transformPost(post);
        
        // Filter out low-quality posts
        if (this.passesQualityFilter(cleanedPost)) {
          allPosts.push(cleanedPost);
        }
      });
    });

    return allPosts;
  }

  private transformPost(post: any): CleanPost {
    // Clean and normalize the post body
    const cleanedBody = this.cleanPostBody(post.body);
    const wordCount = cleanedBody.split(/\s+/).filter(word => word.length > 0).length;
    const readingTime = Math.ceil(wordCount / 200); // 200 words per minute

    return {
      author: post.author,
      permlink: post.permlink,
      title: post.title.trim(),
      cleanedBody,
      wordCount,
      readingTime,
      tags: (post.tags || []).map((tag: string) => tag.toLowerCase()),
      quality: this.assessQuality(cleanedBody, wordCount, post.tags || [])
    };
  }

  private cleanPostBody(body: string): string {
    return body
      // Remove HTML tags
      .replace(/<[^>]*>/g, '')
      // Remove markdown links but keep text
      .replace(/\[([^\]]+)\]\([^\)]+\)/g, '$1')
      // Remove excessive whitespace
      .replace(/\s+/g, ' ')
      // Remove special characters but keep basic punctuation
      .replace(/[^\w\s.,!?;:'"()-]/g, '')
      .trim();
  }

  private assessQuality(cleanedBody: string, wordCount: number, tags: string[]): 'high' | 'medium' | 'low' {
    let score = 0;

    // Word count scoring
    if (wordCount >= 300) score += 3;
    else if (wordCount >= 150) score += 2;
    else if (wordCount >= 50) score += 1;

    // Tag scoring
    if (tags.length >= 3) score += 2;
    else if (tags.length >= 1) score += 1;

    // Content quality indicators
    const sentences = cleanedBody.split(/[.!?]+/).filter(s => s.trim().length > 0);
    const avgSentenceLength = cleanedBody.length / sentences.length;
    
    if (avgSentenceLength > 20 && avgSentenceLength < 100) score += 1;

    // Check for spam indicators
    const repetitiveWords = this.detectRepetitiveContent(cleanedBody);
    if (repetitiveWords > 0.3) score -= 2; // High repetition penalty

    if (score >= 5) return 'high';
    else if (score >= 3) return 'medium';
    else return 'low';
  }

  private detectRepetitiveContent(text: string): number {
    const words = text.toLowerCase().split(/\s+/);
    const uniqueWords = new Set(words);
    return 1 - (uniqueWords.size / words.length);
  }

  private passesQualityFilter(post: CleanPost): boolean {
    return (
      post.quality !== 'low' &&
      post.wordCount >= 50 &&
      post.tags.length >= 1 &&
      !this.containsSpamPatterns(post)
    );
  }

  private containsSpamPatterns(post: CleanPost): boolean {
    const spamPhrases = [
      'please upvote',
      'follow me',
      'check my profile',
      'click here',
      'make money fast'
    ];

    const lowerBody = post.cleanedBody.toLowerCase();
    return spamPhrases.some(phrase => lowerBody.includes(phrase));
  }

  private analyzeCleanedPosts(posts: CleanPost[]) {
    console.log(`\n📝 Processed ${posts.length} quality posts`);
    
    const qualityDistribution = posts.reduce((acc, post) => {
      acc[post.quality] = (acc[post.quality] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    console.log('Quality Distribution:', qualityDistribution);

    const avgWordCount = posts.reduce((sum, p) => sum + p.wordCount, 0) / posts.length;
    console.log(`Average word count: ${avgWordCount.toFixed(0)} words`);

    const topAuthors = posts.reduce((acc, post) => {
      acc[post.author] = (acc[post.author] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    const sortedAuthors = Object.entries(topAuthors)
      .sort(([_, a], [__, b]) => b - a)
      .slice(0, 5);

    console.log('Top authors:', sortedAuthors.map(([author, count]) => `@${author} (${count})`).join(', '));
  }
}
```

These patterns provide a solid foundation for building robust, scalable, and maintainable WorkerBee applications. Mix and match these patterns based on your specific use case requirements.
