---
order: -9
icon: code
---

# API Reference

Complete TypeScript API reference for WorkerBee. This document covers all classes, interfaces, methods, and types available in the library.

## :package: Core Classes

### WorkerBee

The main entry point for the WorkerBee library.

```typescript
class WorkerBee {
  static create(config?: WorkerBeeConfig): WorkerBee;
  observe: ObserverBuilder;
}
```

#### WorkerBeeConfig

```typescript
interface WorkerBeeConfig {
  /** API endpoint for Hive node */
  apiEndpoint?: string;
  
  /** Cycle interval in milliseconds for live mode */
  cycleInterval?: number;
  
  /** Operation mode */
  mode?: 'live' | 'historical' | 'hybrid';
  
  /** Start block number for historical mode */
  startBlock?: number;
  
  /** End block number for historical mode */
  endBlock?: number;
  
  /** Maximum retries for failed API calls */
  maxRetries?: number;
  
  /** Timeout for API calls in milliseconds */
  timeout?: number;
  
  /** Custom collectors */
  collectors?: Record<string, CollectorConstructor>;
}
```

#### Example

```typescript
// Basic usage
const workerbee = WorkerBee.create();

// With configuration
const workerbee = WorkerBee.create({
  apiEndpoint: 'https://api.hive.blog',
  cycleInterval: 3000, // 3 seconds
  mode: 'live',
  maxRetries: 3,
  timeout: 10000 // 10 seconds
});
```

### ObserverBuilder

Fluent interface for building observations.

```typescript
interface ObserverBuilder {
  // Content Filters
  onPosts(...authors: string[]): ObserverBuilder;
  onComments(...authors: string[]): ObserverBuilder;
  onVotes(...voters: string[]): ObserverBuilder;
  onReblog(...accounts: string[]): ObserverBuilder;
  
  // Account Filters
  onAccountsBalanceChange(hbd: boolean, ...accounts: string[]): ObserverBuilder;
  onAccountsVestingSharesChange(...accounts: string[]): ObserverBuilder;
  onAccountsFullManabar(...accounts: string[]): ObserverBuilder;
  onAccountsManabarThreshold(threshold: number, ...accounts: string[]): ObserverBuilder;
  onAccountsMetadataChange(...accounts: string[]): ObserverBuilder;
  
  // Blockchain Filters
  onBlock(): ObserverBuilder;
  onTransaction(): ObserverBuilder;
  onOperation(operationType: OperationType): ObserverBuilder;
  
  // Custom Filters
  filter(filter: Filter | FilterFunction): ObserverBuilder;
  
  // Providers
  provideAccounts(...accounts: string[]): ObserverBuilder;
  provideAccountsVotingManabar(...accounts: string[]): ObserverBuilder;
  provideAccountsRCManabar(...accounts: string[]): ObserverBuilder;
  provideFollowCounts(...accounts: string[]): ObserverBuilder;
  providePostDetails(author: string, permlink: string): ObserverBuilder;
  provideCommentDetails(author: string, permlink: string): ObserverBuilder;
  provideDynamicGlobalProperties(): ObserverBuilder;
  provideWitnessSchedule(): ObserverBuilder;
  
  // Custom Providers
  provider(provider: Provider | ProviderFunction): ObserverBuilder;
  
  // Subscription
  subscribe(observer: Observer): Subscription;
}
```

## :mag_right: Filter Types

### Content Filter Methods

#### onPosts(...authors)

Monitor new posts from specific authors.

```typescript
// Single author
workerbee.observe.onPosts("alice").subscribe({ /* ... */ });

// Multiple authors
workerbee.observe.onPosts("alice", "bob", "charlie").subscribe({ /* ... */ });
```

**Parameters:**

- `authors: string[]` - Array of author usernames to monitor

**Returns:** `ObserverBuilder` for method chaining

**Callback Data:** `{ posts: Record<string, Post[]> }`

#### onComments(...authors)

Monitor new comments from specific authors.

```typescript
workerbee.observe.onComments("alice", "bob").subscribe({
  next: ({ comments }) => {
    // comments.alice: Comment[]
    // comments.bob: Comment[]
  }
});
```

**Parameters:**

- `authors: string[]` - Array of author usernames to monitor

**Returns:** `ObserverBuilder`

**Callback Data:** `{ comments: Record<string, Comment[]> }`

#### onVotes(...voters)

Monitor votes cast by specific accounts.

```typescript
workerbee.observe.onVotes("voter1", "voter2").subscribe({
  next: ({ votes }) => {
    // votes.voter1: Vote[]
    // votes.voter2: Vote[]
  }
});
```

**Parameters:**

- `voters: string[]` - Array of voter usernames to monitor

**Returns:** `ObserverBuilder`

**Callback Data:** `{ votes: Record<string, Vote[]> }`

#### onReblog(...accounts)

Monitor reblogs by specific accounts.

```typescript
workerbee.observe.onReblog("alice").subscribe({
  next: ({ reblogs }) => {
    // reblogs.alice: Reblog[]
  }
});
```

**Parameters:**

- `accounts: string[]` - Array of account usernames to monitor

**Returns:** `ObserverBuilder`

**Callback Data:** `{ reblogs: Record<string, Reblog[]> }`

### Account Filter Methods

#### onAccountsBalanceChange(hbd, ...accounts)

Monitor balance changes for specific accounts.

```typescript
// Monitor HIVE balance
workerbee.observe.onAccountsBalanceChange(false, "alice").subscribe({ /* ... */ });

// Monitor HBD balance  
workerbee.observe.onAccountsBalanceChange(true, "alice").subscribe({ /* ... */ });
```

**Parameters:**

- `hbd: boolean` - `true` for HBD, `false` for HIVE
- `accounts: string[]` - Array of account usernames to monitor

**Returns:** `ObserverBuilder`

**Callback Data:** `{ accounts: Record<string, Account> }`

#### onAccountsVestingSharesChange(...accounts)

Monitor Hive Power (vesting shares) changes.

```typescript
workerbee.observe.onAccountsVestingSharesChange("alice", "bob").subscribe({
  next: ({ accounts }) => {
    console.log(`Alice HP: ${accounts.alice.vesting_shares}`);
    console.log(`Bob HP: ${accounts.bob.vesting_shares}`);
  }
});
```

**Parameters:**

- `accounts: string[]` - Array of account usernames to monitor

**Returns:** `ObserverBuilder`

**Callback Data:** `{ accounts: Record<string, Account> }`

#### onAccountsFullManabar(...accounts)

Trigger when accounts reach 100% voting power.

```typescript
workerbee.observe.onAccountsFullManabar("voter_bot").subscribe({
  next: ({ accounts }) => {
    console.log("Voter bot ready to vote!");
  }
});
```

**Parameters:**

- `accounts: string[]` - Array of account usernames to monitor

**Returns:** `ObserverBuilder`

**Callback Data:** `{ accounts: Record<string, Account> }`

#### onAccountsManabarThreshold(threshold, ...accounts)

Trigger when accounts reach a specific manabar threshold.

```typescript
// Trigger at 80% manabar
workerbee.observe.onAccountsManabarThreshold(8000, "alice").subscribe({
  next: ({ accounts }) => {
    console.log("Alice reached 80% voting power");
  }
});
```

**Parameters:**

- `threshold: number` - Threshold value (0-10000, where 10000 = 100%)
- `accounts: string[]` - Array of account usernames to monitor

**Returns:** `ObserverBuilder`

**Callback Data:** `{ accounts: Record<string, Account> }`

#### onAccountsMetadataChange(...accounts)

Monitor changes to account metadata (profile).

```typescript
workerbee.observe.onAccountsMetadataChange("alice").subscribe({
  next: ({ accounts }) => {
    const profile = JSON.parse(accounts.alice.json_metadata || '{}');
    console.log(`Alice updated profile: ${profile.profile?.about}`);
  }
});
```

**Parameters:**

- `accounts: string[]` - Array of account usernames to monitor

**Returns:** `ObserverBuilder`

**Callback Data:** `{ accounts: Record<string, Account> }`

### Blockchain Filter Methods

#### onBlock()

Trigger on every new block.

```typescript
workerbee.observe.onBlock().subscribe({
  next: ({ block }) => {
    console.log(`New block: #${block.block_num}`);
    console.log(`Transactions: ${block.transactions.length}`);
  }
});
```

**Returns:** `ObserverBuilder`

**Callback Data:** `{ block: Block }`

#### onTransaction()

Trigger on every new transaction.

```typescript
workerbee.observe.onTransaction().subscribe({
  next: ({ transactions }) => {
    console.log(`${transactions.length} new transactions`);
  }
});
```

**Returns:** `ObserverBuilder`

**Callback Data:** `{ transactions: Transaction[] }`

#### onOperation(operationType)

Trigger on specific operation types.

```typescript
workerbee.observe.onOperation('transfer').subscribe({
  next: ({ operations }) => {
    operations.transfer.forEach(transfer => {
      console.log(`${transfer.amount} from @${transfer.from} to @${transfer.to}`);
    });
  }
});
```

**Parameters:**

- `operationType: OperationType` - The operation type to monitor

**Returns:** `ObserverBuilder`

**Callback Data:** `{ operations: Record<OperationType, Operation[]> }`

## :truck: Provider Methods

### Account Providers

#### provideAccounts(...accounts)

Get full account objects.

```typescript
workerbee.observe
  .onPosts("alice")
  .provideAccounts("alice", "bob")
  .subscribe({
    next: ({ accounts }) => {
      const alice = accounts.alice;
      console.log(`Balance: ${alice.balance}`);
      console.log(`Reputation: ${alice.reputation}`);
      console.log(`Post Count: ${alice.post_count}`);
    }
  });
```

**Parameters:**

- `accounts: string[]` - Array of account usernames

**Returns:** `ObserverBuilder`

**Provides:** `accounts: Record<string, Account>`

#### provideAccountsVotingManabar(...accounts)

Get detailed voting manabar information.

```typescript
workerbee.observe
  .onAccountsFullManabar("voter")
  .provideAccountsVotingManabar("voter")
  .subscribe({
    next: ({ votingManabar }) => {
      const manabar = votingManabar.voter;
      const percentage = (manabar.current_mana / manabar.max_mana) * 100;
      console.log(`Voting power: ${percentage.toFixed(2)}%`);
    }
  });
```

**Parameters:**

- `accounts: string[]` - Array of account usernames

**Returns:** `ObserverBuilder`

**Provides:** `votingManabar: Record<string, VotingManabar>`

#### provideAccountsRCManabar(...accounts)

Get Resource Credit manabar information.

```typescript
workerbee.observe
  .onPosts("alice")
  .provideAccountsRCManabar("alice")
  .subscribe({
    next: ({ rcManabar }) => {
      const rc = rcManabar.alice;
      console.log(`RC: ${rc.current_mana}/${rc.max_mana}`);
    }
  });
```

**Parameters:**

- `accounts: string[]` - Array of account usernames

**Returns:** `ObserverBuilder`

**Provides:** `rcManabar: Record<string, RCManabar>`

#### provideFollowCounts(...accounts)

Get follower and following counts.

```typescript
workerbee.observe
  .onAccountsMetadataChange("alice")
  .provideFollowCounts("alice")
  .subscribe({
    next: ({ followCounts }) => {
      const counts = followCounts.alice;
      console.log(`Followers: ${counts.follower_count}`);
      console.log(`Following: ${counts.following_count}`);
    }
  });
```

**Parameters:**

- `accounts: string[]` - Array of account usernames

**Returns:** `ObserverBuilder`

**Provides:** `followCounts: Record<string, FollowCounts>`

### Content Providers

#### providePostDetails(author, permlink)

Get detailed information about a specific post.

```typescript
workerbee.observe
  .onPosts("alice")
  .providePostDetails("alice", "my-post")
  .subscribe({
    next: ({ postDetails }) => {
      const post = postDetails["alice/my-post"];
      console.log(`Payout: ${post.total_payout_value}`);
      console.log(`Votes: ${post.active_votes.length}`);
    }
  });
```

**Parameters:**

- `author: string` - Post author username
- `permlink: string` - Post permlink

**Returns:** `ObserverBuilder`

**Provides:** `postDetails: Record<string, PostDetails>`

#### provideCommentDetails(author, permlink)

Get detailed information about a specific comment.

```typescript
workerbee.observe
  .onComments("alice")
  .provideCommentDetails("alice", "my-comment")
  .subscribe({
    next: ({ commentDetails }) => {
      const comment = commentDetails["alice/my-comment"];
      console.log(`Votes: ${comment.net_votes}`);
    }
  });
```

**Parameters:**

- `author: string` - Comment author username
- `permlink: string` - Comment permlink

**Returns:** `ObserverBuilder`

**Provides:** `commentDetails: Record<string, CommentDetails>`

### Blockchain Providers

#### provideDynamicGlobalProperties()

Get current blockchain global properties.

```typescript
workerbee.observe
  .onBlock()
  .provideDynamicGlobalProperties()
  .subscribe({
    next: ({ globalProperties }) => {
      console.log(`Head Block: ${globalProperties.head_block_number}`);
      console.log(`Total Accounts: ${globalProperties.total_accounts}`);
    }
  });
```

**Returns:** `ObserverBuilder`

**Provides:** `globalProperties: DynamicGlobalProperties`

#### provideWitnessSchedule()

Get current witness schedule.

```typescript
workerbee.observe
  .onBlock()
  .provideWitnessSchedule()
  .subscribe({
    next: ({ witnessSchedule }) => {
      console.log(`Current Witness: ${witnessSchedule.current_witness}`);
      console.log(`Active Witnesses: ${witnessSchedule.active_witnesses.length}`);
    }
  });
```

**Returns:** `ObserverBuilder`

**Provides:** `witnessSchedule: WitnessSchedule`

## :gear: Data Types

### Core Content Types

#### Post

```typescript
interface Post {
  author: string;
  permlink: string;
  title: string;
  body: string;
  category: string;
  tags: string[];
  created: string;
  updated: string;
  pending_payout_value: string;
  net_votes: number;
  json_metadata: string;
}
```

#### Comment

```typescript
interface Comment {
  author: string;
  permlink: string;
  parent_author: string;
  parent_permlink: string;
  body: string;
  created: string;
  updated: string;
  net_votes: number;
  json_metadata: string;
}
```

#### Vote

```typescript
interface Vote {
  voter: string;
  author: string;
  permlink: string;
  weight: number;
  rshares: number;
  time: string;
}
```

#### Reblog

```typescript
interface Reblog {
  account: string;
  author: string;
  permlink: string;
  time: string;
}
```

### Account Types

#### Account

```typescript
interface Account {
  name: string;
  balance: string;
  hbd_balance: string;
  vesting_shares: string;
  delegated_vesting_shares: string;
  received_vesting_shares: string;
  reputation: string;
  post_count: number;
  created: string;
  json_metadata: string;
  voting_manabar: {
    current_mana: number;
    last_update_time: number;
  };
}
```

#### VotingManabar

```typescript
interface VotingManabar {
  current_mana: number;
  max_mana: number;
  last_update_time: number;
}
```

#### RCManabar

```typescript
interface RCManabar {
  current_mana: number;
  max_mana: number;
  last_update_time: number;
}
```

#### FollowCounts

```typescript
interface FollowCounts {
  follower_count: number;
  following_count: number;
}
```

### Blockchain Types

#### Block

```typescript
interface Block {
  block_num: number;
  timestamp: string;
  previous: string;
  witness: string;
  transactions: Transaction[];
  extensions: any[];
}
```

#### Transaction

```typescript
interface Transaction {
  transaction_id: string;
  operations: Operation[];
  signatures: string[];
}
```

#### Operation

```typescript
type Operation = [OperationType, OperationData];

type OperationType = 
  | 'comment'
  | 'vote'
  | 'transfer'
  | 'account_update'
  | 'custom_json'
  | 'delete_comment'
  | 'comment_options'
  | 'author_reward'
  | 'curation_reward'
  | 'transfer_to_vesting'
  | 'withdraw_vesting'
  | 'limit_order_create'
  | 'limit_order_cancel'
  | 'feed_publish'
  | 'convert'
  | 'account_create'
  | 'account_update'
  | 'witness_update'
  | 'account_witness_vote'
  | 'account_witness_proxy'
  | 'pow'
  | 'custom'
  | 'report_over_production'
  | 'fill_convert_request'
  | 'liquidity_reward'
  | 'interest'
  | 'fill_vesting_withdraw'
  | 'fill_order'
  | 'shutdown_witness'
  | 'fill_transfer_from_savings'
  | 'hardfork'
  | 'comment_payout_update'
  | 'return_vesting_delegation'
  | 'comment_benefactor_reward';
```

#### DynamicGlobalProperties

```typescript
interface DynamicGlobalProperties {
  head_block_number: number;
  head_block_id: string;
  time: string;
  current_witness: string;
  total_pow: number;
  num_pow_witnesses: number;
  virtual_supply: string;
  current_supply: string;
  confidential_supply: string;
  current_hbd_supply: string;
  confidential_hbd_supply: string;
  total_vesting_fund_hive: string;
  total_vesting_shares: string;
  total_reward_fund_hive: string;
  total_reward_shares2: string;
  pending_rewarded_vesting_shares: string;
  pending_rewarded_vesting_hive: string;
  hbd_interest_rate: number;
  hbd_print_rate: number;
  maximum_block_size: number;
  current_aslot: number;
  recent_slots_filled: string;
  participation_count: number;
  last_irreversible_block_num: number;
  vote_power_reserve_rate: number;
  delegation_return_period: number;
  reverse_auction_seconds: number;
  available_account_subsidies: number;
  hbd_stop_percent: number;
  hbd_start_percent: number;
  next_maintenance_time: string;
  last_budget_time: string;
  content_reward_percent: number;
  vesting_reward_percent: number;
  proposal_fund_percent: number;
  dhf_interval_ledger: string;
}
```

#### WitnessSchedule

```typescript
interface WitnessSchedule {
  current_witness: string;
  next_witness: string;
  active_witnesses: string[];
}
```

## :link: Logical Operators

### and(filter1, filter2, ...)

Combine filters with AND logic.

```typescript
import { and } from '@hiveio/workerbee';

workerbee.observe
  .filter(
    and(
      onPosts("alice"),
      onAccountsFullManabar("alice")
    )
  )
  .subscribe({
    next: (data) => {
      // Triggers only when BOTH conditions are true
      console.log("Alice posted AND has full manabar");
    }
  });
```

**Parameters:**

- `...filters: Filter[]` - Filters to combine with AND logic

**Returns:** `Filter` - Combined filter

### or(filter1, filter2, ...)

Combine filters with OR logic.

```typescript
import { or } from '@hiveio/workerbee';

workerbee.observe
  .filter(
    or(
      onAccountsFullManabar("voter1"),
      onAccountsFullManabar("voter2")
    )
  )
  .subscribe({
    next: (data) => {
      // Triggers when EITHER voter has full manabar
      console.log("At least one voter is ready");
    }
  });
```

**Parameters:**

- `...filters: Filter[]` - Filters to combine with OR logic

**Returns:** `Filter` - Combined filter

## :wrench: Custom Extensions

### Custom Filters

#### Filter Interface

```typescript
interface Filter {
  evaluate(context: DataEvaluationContext): Promise<boolean>;
}
```

#### FilterFunction Type

```typescript
type FilterFunction = (context: DataEvaluationContext) => Promise<boolean>;
```

#### Example Custom Filter

```typescript
class HighValuePostFilter implements Filter {
  constructor(private minValue: number) {}

  async evaluate(context: DataEvaluationContext): Promise<boolean> {
    const posts = await context.getPosts();
    
    return Object.values(posts)
      .flat()
      .some(post => {
        const payout = parseFloat(post.pending_payout_value.replace(' HBD', ''));
        return payout >= this.minValue;
      });
  }
}

// Usage
workerbee.observe
  .filter(new HighValuePostFilter(10))
  .subscribe({
    next: () => console.log("High-value post detected!")
  });
```

### Custom Providers

#### Provider Interface

```typescript
interface Provider<T = any> {
  provide(context: DataEvaluationContext): Promise<T>;
}
```

#### ProviderFunction Type

```typescript
type ProviderFunction<T = any> = (context: DataEvaluationContext) => Promise<T>;
```

#### Example Custom Provider

```typescript
class PostAnalysisProvider implements Provider<{ analysis: PostAnalysis[] }> {
  async provide(context: DataEvaluationContext): Promise<{ analysis: PostAnalysis[] }> {
    const posts = await context.getPosts();
    const analysis: PostAnalysis[] = [];
    
    Object.values(posts)
      .flat()
      .forEach(post => {
        analysis.push({
          author: post.author,
          permlink: post.permlink,
          wordCount: post.body.split(/\s+/).length,
          readingTime: Math.ceil(post.body.split(/\s+/).length / 200),
          sentiment: this.analyzeSentiment(post.body)
        });
      });
    
    return { analysis };
  }
  
  private analyzeSentiment(text: string): 'positive' | 'negative' | 'neutral' {
    // Simplified sentiment analysis
    const positiveWords = ['good', 'great', 'awesome', 'excellent'];
    const negativeWords = ['bad', 'terrible', 'awful', 'horrible'];
    
    const positive = positiveWords.some(word => text.toLowerCase().includes(word));
    const negative = negativeWords.some(word => text.toLowerCase().includes(word));
    
    if (positive && !negative) return 'positive';
    if (negative && !positive) return 'negative';
    return 'neutral';
  }
}

// Usage
workerbee.observe
  .onPosts("alice")
  .provider(new PostAnalysisProvider())
  .subscribe({
    next: ({ analysis }) => {
      analysis.forEach(item => {
        console.log(`${item.author}/${item.permlink}: ${item.wordCount} words, ${item.sentiment} sentiment`);
      });
    }
  });
```

## :bell: Observer Pattern

### Observer Interface

```typescript
interface Observer<T = any> {
  next?: (data: T) => void;
  error?: (error: any) => void;
  complete?: () => void;
}
```

### Subscription Interface

```typescript
interface Subscription {
  unsubscribe(): void;
  closed: boolean;
}
```

### Example Usage

```typescript
const subscription = workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: (data) => {
      console.log("New data:", data);
    },
    error: (error) => {
      console.error("Error occurred:", error);
    },
    complete: () => {
      console.log("Observation completed");
    }
  });

// Later, stop observing
subscription.unsubscribe();
```

This API reference provides comprehensive documentation for all WorkerBee TypeScript features. Use it as a complete guide for building blockchain applications with WorkerBee!
