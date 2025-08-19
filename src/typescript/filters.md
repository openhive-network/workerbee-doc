---
order: -3
icon: filter
---

# Filters & Conditions

Filters are the core of WorkerBee's event system. They define **when** your observers should be triggered by evaluating blockchain conditions in real-time.

## :mag: Filter Overview

Filters monitor the blockchain for specific events and trigger your callbacks when conditions are met. They run concurrently and use smart caching to minimize API calls.

### :zap: Basic Filter Usage

```typescript
import { WorkerBee } from '@hiveio/workerbee';

const workerbee = WorkerBee.create();

// Simple post filter
workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      console.log(`Alice created ${posts.alice.length} new posts!`);
    }
  });
```

## :memo: Content Filters

Monitor posts, comments, and other content operations.

### onPosts(author)

Triggers when the specified author creates new posts.

```typescript
// Monitor posts from single author
workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      for (const post of posts.alice) {
        console.log(`New post: "${post.title}" by @${post.author}`);
        console.log(`Tags: ${post.tags.join(', ')}`);
        console.log(`Created: ${post.created}`);
      }
    }
  });

// Monitor posts from multiple authors
workerbee.observe
  .onPosts("alice", "bob", "charlie")
  .subscribe({
    next: ({ posts }) => {
      // posts.alice, posts.bob, posts.charlie arrays
      Object.entries(posts).forEach(([author, authorPosts]) => {
        console.log(`${author} created ${authorPosts.length} posts`);
      });
    }
  });
```

### onComments(author)

Triggers when the specified author creates new comments.

```typescript
// Monitor comments from specific author
workerbee.observe
  .onComments("alice")
  .subscribe({
    next: ({ comments }) => {
      for (const comment of comments.alice) {
        console.log(`New comment by @${comment.author}`);
        console.log(`Replying to: @${comment.parent_author}/${comment.parent_permlink}`);
        console.log(`Comment: ${comment.body.substring(0, 100)}...`);
      }
    }
  });
```

### onVotes(voter)

Triggers when the specified account votes on content.

```typescript
// Monitor votes from specific voter
workerbee.observe
  .onVotes("alice")
  .subscribe({
    next: ({ votes }) => {
      for (const vote of votes.alice) {
        console.log(`@${vote.voter} voted on @${vote.author}/${vote.permlink}`);
        console.log(`Vote weight: ${vote.weight / 100}%`);
        console.log(`Vote value: ${vote.rshares} rshares`);
      }
    }
  });
```

### onReblog(account)

Triggers when the specified account reblogs content.

```typescript
// Monitor reblogs from specific account
workerbee.observe
  .onReblog("alice")
  .subscribe({
    next: ({ reblogs }) => {
      for (const reblog of reblogs.alice) {
        console.log(`@${reblog.account} reblogged @${reblog.author}/${reblog.permlink}`);
      }
    }
  });
```

## :bust_in_silhouette: Account Filters

Monitor account-related changes and states.

### onAccountsBalanceChange(hbd, ...accounts)

Triggers when account balance changes (HIVE or HBD).

```typescript
// Monitor HIVE balance changes
workerbee.observe
  .onAccountsBalanceChange(false, "alice", "bob") // false = HIVE, true = HBD
  .subscribe({
    next: ({ accounts }) => {
      console.log("Balance changes detected!");
      console.log(`Alice balance: ${accounts.alice.balance}`);
      console.log(`Bob balance: ${accounts.bob.balance}`);
    }
  });

// Monitor HBD balance changes
workerbee.observe
  .onAccountsBalanceChange(true, "alice") // true = HBD
  .subscribe({
    next: ({ accounts }) => {
      console.log(`Alice HBD balance: ${accounts.alice.hbd_balance}`);
    }
  });
```

### onAccountsVestingSharesChange(...accounts)

Triggers when account's vesting shares (Hive Power) change.

```typescript
workerbee.observe
  .onAccountsVestingSharesChange("alice")
  .subscribe({
    next: ({ accounts }) => {
      const account = accounts.alice;
      console.log(`Alice Hive Power changed to: ${account.vesting_shares}`);
      console.log(`Delegated: ${account.delegated_vesting_shares}`);
      console.log(`Received: ${account.received_vesting_shares}`);
    }
  });
```

### onAccountsFullManabar(...accounts)

Triggers when account's manabar is full (100% voting power).

```typescript
workerbee.observe
  .onAccountsFullManabar("voter_bot")
  .subscribe({
    next: ({ accounts }) => {
      console.log("Voter bot has full manabar! Time to vote!");
      const account = accounts.voter_bot;
      console.log(`Voting power: ${account.voting_power}%`);
    }
  });
```

### onAccountsManabarThreshold(threshold, ...accounts)

Triggers when account's manabar reaches a specific threshold.

```typescript
// Trigger when manabar reaches 80%
workerbee.observe
  .onAccountsManabarThreshold(8000, "alice") // 8000 = 80%
  .subscribe({
    next: ({ accounts }) => {
      console.log("Alice's manabar reached 80%!");
    }
  });
```

### onAccountsMetadataChange(...accounts)

Triggers when account metadata (profile) changes.

```typescript
workerbee.observe
  .onAccountsMetadataChange("alice")
  .subscribe({
    next: ({ accounts }) => {
      const profile = JSON.parse(accounts.alice.json_metadata || '{}');
      console.log(`Alice updated profile: ${profile.profile?.about || 'No bio'}`);
    }
  });
```

## :chains: Blockchain Filters

Monitor blockchain-level events.

### onBlock()

Triggers on every new block.

```typescript
workerbee.observe
  .onBlock()
  .subscribe({
    next: ({ block }) => {
      console.log(`New block: #${block.block_num}`);
      console.log(`Timestamp: ${block.timestamp}`);
      console.log(`Transactions: ${block.transactions.length}`);
    }
  });
```

### onTransaction()

Triggers on every new transaction.

```typescript
workerbee.observe
  .onTransaction()
  .subscribe({
    next: ({ transactions }) => {
      console.log(`${transactions.length} new transactions`);
      transactions.forEach(tx => {
        console.log(`Transaction ID: ${tx.transaction_id}`);
        console.log(`Operations: ${tx.operations.length}`);
      });
    }
  });
```

### onOperation(operationType)

Triggers on specific operation types.

```typescript
// Monitor all comment operations (posts + comments)
workerbee.observe
  .onOperation('comment')
  .subscribe({
    next: ({ operations }) => {
      console.log(`${operations.comment.length} comment operations`);
    }
  });

// Monitor transfer operations
workerbee.observe
  .onOperation('transfer')
  .subscribe({
    next: ({ operations }) => {
      for (const transfer of operations.transfer) {
        console.log(`Transfer: ${transfer.amount} from @${transfer.from} to @${transfer.to}`);
        console.log(`Memo: ${transfer.memo}`);
      }
    }
  });
```

## :link: Logical Operators

Combine filters using logical operators for complex conditions.

### Implicit OR Logic

Multiple filters have implicit OR logic:

```typescript
// Triggers when EITHER Alice posts OR Bob comments
workerbee.observe
  .onPosts("alice")
  .onComments("bob")
  .subscribe({
    next: (data) => {
      if (data.posts?.alice?.length > 0) {
        console.log("Alice posted!");
      }
      if (data.comments?.bob?.length > 0) {
        console.log("Bob commented!");
      }
    }
  });
```

### Explicit AND Logic

Use the `and()` function for AND conditions:

```typescript
import { and } from '@hiveio/workerbee';

// Triggers only when Alice posts AND has full manabar
workerbee.observe
  .filter(
    and(
      onPosts("alice"),
      onAccountsFullManabar("alice")
    )
  )
  .subscribe({
    next: (data) => {
      console.log("Alice posted and has full manabar!");
    }
  });
```

### Complex Logic Expressions

Combine `and()` and `or()` for sophisticated conditions:

```typescript
import { and, or } from '@hiveio/workerbee';

// Triggers when Alice posts AND (Bob has full manabar OR Charlie has full manabar)
workerbee.observe
  .filter(
    and(
      onPosts("alice"),
      or(
        onAccountsFullManabar("bob"),
        onAccountsFullManabar("charlie")
      )
    )
  )
  .subscribe({
    next: (data) => {
      console.log("Alice posted and at least one voter is ready!");
    }
  });
```

## :gear: Custom Filters

Create your own filters for specialized conditions.

### Custom Filter Class

```typescript
import { BaseFilter, DataEvaluationContext } from '@hiveio/workerbee';

class CustomPostFilter extends BaseFilter {
  constructor(
    private author: string,
    private minWordCount: number
  ) {
    super();
  }

  async evaluate(context: DataEvaluationContext): Promise<boolean> {
    const operations = await context.getOperations();
    
    for (const op of operations) {
      if (op[0] === 'comment' && op[1].author === this.author && !op[1].parent_author) {
        // This is a post by our author
        const wordCount = op[1].body.split(/\s+/).length;
        if (wordCount >= this.minWordCount) {
          return true; // Condition met
        }
      }
    }
    
    return false; // Condition not met
  }
}

// Usage
const customFilter = new CustomPostFilter("alice", 100);
workerbee.observe
  .filter(customFilter)
  .subscribe({
    next: (data) => {
      console.log("Alice posted a long-form article!");
    }
  });
```

### Custom Filter Function

For simpler cases, use filter functions:

```typescript
// Filter for posts with specific tags
const techPostFilter = (requiredTag: string) => {
  return async (context: DataEvaluationContext): Promise<boolean> => {
    const operations = await context.getOperations();
    
    return operations.some(op => {
      if (op[0] === 'comment' && !op[1].parent_author) {
        try {
          const metadata = JSON.parse(op[1].json_metadata || '{}');
          return metadata.tags?.includes(requiredTag);
        } catch {
          return false;
        }
      }
      return false;
    });
  };
};

// Usage
workerbee.observe
  .filter(techPostFilter("technology"))
  .subscribe({
    next: () => {
      console.log("New technology post detected!");
    }
  });
```

## :racing_car: Performance Considerations

### Short-Circuit Evaluation

WorkerBee uses short-circuit evaluation to optimize performance:

```typescript
// If Alice posts, other filters are cancelled
workerbee.observe
  .onPosts("alice")              // ✅ Matches first
  .onComments("bob")             // ❌ Cancelled
  .onAccountsBalanceChange(false, "charlie") // ❌ Cancelled
  .subscribe({ /* ... */ });
```

### Filter Ordering

Put most likely conditions first for better performance:

```typescript
// Good: Common condition first
workerbee.observe
  .onPosts("popular_author")    // High frequency
  .onAccountsFullManabar("rare_voter") // Low frequency
  .subscribe({ /* ... */ });

// Less optimal: Rare condition first
workerbee.observe
  .onAccountsFullManabar("rare_voter") // Low frequency
  .onPosts("popular_author")    // High frequency  
  .subscribe({ /* ... */ });
```

### Caching Benefits

Filters automatically benefit from WorkerBee's caching:

```typescript
// These filters share cached operation data
workerbee.observe
  .onPosts("alice")      // Uses operation cache
  .onComments("alice")   // Reuses operation cache
  .onVotes("alice")      // Reuses operation cache
  .subscribe({ /* ... */ });
// Result: 1 API call instead of 3!
```

## :warning: Common Pitfalls

### Avoid Too Many Specific Filters

```typescript
// ❌ Inefficient: Too many specific filters
workerbee.observe
  .onPosts("alice")
  .onPosts("bob")
  .onPosts("charlie")
  // ... 50 more authors
  .subscribe({ /* ... */ });

// ✅ Better: Use operation filter and process in callback
workerbee.observe
  .onOperation('comment')
  .subscribe({
    next: ({ operations }) => {
      const authorList = ['alice', 'bob', 'charlie' /* ... */];
      const relevantPosts = operations.comment.filter(op => 
        !op.parent_author && authorList.includes(op.author)
      );
      // Process relevant posts
    }
  });
```

### Handle Missing Data

```typescript
workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      // ✅ Always check data exists
      if (posts?.alice?.length > 0) {
        posts.alice.forEach(post => {
          console.log(post.title);
        });
      }
    }
  });
```

## :books: Filter Reference Summary

### Content Filters

- `onPosts(author)` - New posts by author
- `onComments(author)` - New comments by author  
- `onVotes(voter)` - New votes by voter
- `onReblog(account)` - New reblogs by account

### Account Filters

- `onAccountsBalanceChange(hbd, ...accounts)` - Balance changes
- `onAccountsVestingSharesChange(...accounts)` - Hive Power changes
- `onAccountsFullManabar(...accounts)` - Full voting power
- `onAccountsManabarThreshold(threshold, ...accounts)` - Manabar threshold
- `onAccountsMetadataChange(...accounts)` - Profile changes

### Blockchain Filters

- `onBlock()` - New blocks
- `onTransaction()` - New transactions
- `onOperation(type)` - Specific operation types

### Logical Operators

- Implicit OR for multiple filters
- `and()` for AND logic
- `or()` for OR logic
- Nested combinations supported

Filters are the foundation of WorkerBee's reactive architecture. Master them to build sophisticated blockchain monitoring applications!
