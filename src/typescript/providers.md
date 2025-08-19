---
order: -4
icon: database
---

# Data Providers

Data Providers are WorkerBee's data transformation layer. They gather, process, and normalize blockchain data into clean, easy-to-use objects for your application. Providers run only when filters match, ensuring optimal performance.

## :mag: Provider Overview

Providers transform raw blockchain data into structured TypeScript objects. They run concurrently with filters and automatically benefit from WorkerBee's caching system.

### :zap: Basic Provider Usage

```typescript
import { WorkerBee } from '@hiveio/workerbee';

const workerbee = WorkerBee.create();

// Use providers to get additional data
workerbee.observe
  .onPosts("alice")
  .provideAccounts("alice", "bob")      // Get account data
  .provideFollowCounts("alice")         // Get follower counts
  .subscribe({
    next: ({ posts, accounts, followCounts }) => {
      console.log(`Alice posted: ${posts.alice[0].title}`);
      console.log(`Alice has ${accounts.alice.post_count} total posts`);
      console.log(`Alice has ${followCounts.alice.follower_count} followers`);
    }
  });
```

## :bust_in_silhouette: Account Providers

Get comprehensive account information and statistics.

### provideAccounts(...accounts)

Provides full account objects with balance, power, and profile data.

```typescript
workerbee.observe
  .onPosts("alice")
  .provideAccounts("alice", "bob")
  .subscribe({
    next: ({ accounts }) => {
      const alice = accounts.alice;
      
      console.log(`Account: @${alice.name}`);
      console.log(`HIVE Balance: ${alice.balance}`);
      console.log(`HBD Balance: ${alice.hbd_balance}`);
      console.log(`Hive Power: ${alice.vesting_shares}`);
      console.log(`Delegated HP: ${alice.delegated_vesting_shares}`);
      console.log(`Received HP: ${alice.received_vesting_shares}`);
      console.log(`Reputation: ${alice.reputation}`);
      console.log(`Post Count: ${alice.post_count}`);
      console.log(`Created: ${alice.created}`);
      
      // Profile data from json_metadata
      try {
        const profile = JSON.parse(alice.json_metadata || '{}');
        console.log(`Display Name: ${profile.profile?.name || alice.name}`);
        console.log(`About: ${profile.profile?.about || 'No bio'}`);
        console.log(`Location: ${profile.profile?.location || 'Unknown'}`);
        console.log(`Website: ${profile.profile?.website || 'None'}`);
      } catch {
        console.log('No profile metadata');
      }
    }
  });
```

### provideAccountsVotingManabar(...accounts)

Provides detailed voting manabar information.

```typescript
workerbee.observe
  .onAccountsFullManabar("voter_bot")
  .provideAccountsVotingManabar("voter_bot")
  .subscribe({
    next: ({ votingManabar }) => {
      const manabar = votingManabar.voter_bot;
      
      console.log(`Current Mana: ${manabar.current_mana}`);
      console.log(`Max Mana: ${manabar.max_mana}`);
      console.log(`Percentage: ${(manabar.current_mana / manabar.max_mana * 100).toFixed(2)}%`);
      console.log(`Last Update: ${new Date(manabar.last_update_time * 1000)}`);
      
      // Time until full manabar
      const timeToFull = manabar.max_mana - manabar.current_mana;
      const hoursToFull = timeToFull / (60 * 60 * 24 * 1000) * 5; // 5 days to full
      console.log(`Hours until full: ${hoursToFull.toFixed(1)}`);
    }
  });
```

### provideAccountsRCManabar(...accounts)

Provides Resource Credit (RC) manabar information.

```typescript
workerbee.observe
  .onAccountsBalanceChange(false, "alice")
  .provideAccountsRCManabar("alice")
  .subscribe({
    next: ({ rcManabar }) => {
      const rc = rcManabar.alice;
      
      console.log(`Current RC: ${rc.current_mana}`);
      console.log(`Max RC: ${rc.max_mana}`);
      console.log(`RC Percentage: ${(rc.current_mana / rc.max_mana * 100).toFixed(2)}%`);
    }
  });
```

### provideFollowCounts(...accounts)

Provides follower and following counts.

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

## :memo: Content Providers

Get detailed information about posts, comments, and votes.

### Automatic Content Providers

When using content filters, related data is automatically provided:

```typescript
workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      for (const post of posts.alice) {
        // Full post object automatically provided
        console.log(`Title: ${post.title}`);
        console.log(`Body: ${post.body.substring(0, 200)}...`);
        console.log(`Tags: ${post.tags.join(', ')}`);
        console.log(`Created: ${post.created}`);
        console.log(`Author: ${post.author}`);
        console.log(`Permlink: ${post.permlink}`);
        console.log(`Category: ${post.category}`);
        console.log(`Pending Payout: ${post.pending_payout_value}`);
        console.log(`Vote Count: ${post.net_votes}`);
      }
    }
  });
```

### providePostDetails(author, permlink)

Get detailed information about specific posts:

```typescript
workerbee.observe
  .onPosts("alice")
  .providePostDetails("alice", "my-post")
  .subscribe({
    next: ({ postDetails }) => {
      const post = postDetails["alice/my-post"];
      
      console.log(`Total Payout: ${post.total_payout_value}`);
      console.log(`Curator Payout: ${post.curator_payout_value}`);
      console.log(`Author Rewards: ${post.author_rewards}`);
      console.log(`Active Votes: ${post.active_votes.length}`);
      console.log(`Children (Comments): ${post.children}`);
      console.log(`Net Rshares: ${post.net_rshares}`);
      
      // Vote details
      post.active_votes.forEach(vote => {
        console.log(`Vote: @${vote.voter} - ${vote.percent / 100}% - ${vote.rshares} rshares`);
      });
    }
  });
```

### provideCommentDetails(author, permlink)

Get detailed information about specific comments:

```typescript
workerbee.observe
  .onComments("alice")
  .provideCommentDetails("alice", "my-comment")
  .subscribe({
    next: ({ commentDetails }) => {
      const comment = commentDetails["alice/my-comment"];
      
      console.log(`Comment by: @${comment.author}`);
      console.log(`Replying to: @${comment.parent_author}/${comment.parent_permlink}`);
      console.log(`Content: ${comment.body}`);
      console.log(`Votes: ${comment.net_votes}`);
    }
  });
```

## :chains: Blockchain Providers

Get blockchain-level information.

### Automatic Block Provider

When using `onBlock()` filter, block data is automatically provided:

```typescript
workerbee.observe
  .onBlock()
  .subscribe({
    next: ({ block }) => {
      console.log(`Block Number: ${block.block_num}`);
      console.log(`Timestamp: ${block.timestamp}`);
      console.log(`Previous: ${block.previous}`);
      console.log(`Witness: ${block.witness}`);
      console.log(`Transaction Count: ${block.transactions.length}`);
      
      // Transaction details
      block.transactions.forEach((tx, index) => {
        console.log(`Transaction ${index}: ${tx.operations.length} operations`);
      });
    }
  });
```

### provideDynamicGlobalProperties()

Provides current blockchain global properties:

```typescript
workerbee.observe
  .onBlock()
  .provideDynamicGlobalProperties()
  .subscribe({
    next: ({ globalProperties }) => {
      const props = globalProperties;
      
      console.log(`Head Block: ${props.head_block_number}`);
      console.log(`Total Accounts: ${props.total_accounts}`);
      console.log(`Current Supply: ${props.current_supply}`);
      console.log(`Virtual Supply: ${props.virtual_supply}`);
      console.log(`HBD Supply: ${props.current_hbd_supply}`);
      console.log(`Total Reward Fund: ${props.total_reward_fund_steem}`);
      console.log(`Total Vesting Shares: ${props.total_vesting_shares}`);
    }
  });
```

### provideWitnessSchedule()

Provides current witness schedule:

```typescript
workerbee.observe
  .onBlock()
  .provideWitnessSchedule()
  .subscribe({
    next: ({ witnessSchedule }) => {
      const schedule = witnessSchedule;
      
      console.log(`Current Witness: ${schedule.current_witness}`);
      console.log(`Next Witness: ${schedule.next_witness}`);
      console.log(`Active Witnesses: ${schedule.active_witnesses.length}`);
      
      schedule.active_witnesses.forEach(witness => {
        console.log(`Active Witness: ${witness}`);
      });
    }
  });
```

## :gear: Custom Providers

Create your own providers for specialized data transformation.

### Custom Provider Class

```typescript
import { BaseProvider, DataEvaluationContext } from '@hiveio/workerbee';

interface CustomPostStats {
  author: string;
  wordCount: number;
  imageCount: number;
  linkCount: number;
  estimatedReadTime: number;
}

class PostAnalysisProvider extends BaseProvider<{ postStats: CustomPostStats[] }> {
  async provide(context: DataEvaluationContext): Promise<{ postStats: CustomPostStats[] }> {
    const posts = await context.getPosts();
    const postStats: CustomPostStats[] = [];
    
    for (const [author, authorPosts] of Object.entries(posts)) {
      for (const post of authorPosts) {
        const wordCount = post.body.split(/\s+/).length;
        const imageCount = (post.body.match(/!\[.*?\]\(.*?\)/g) || []).length;
        const linkCount = (post.body.match(/\[.*?\]\(.*?\)/g) || []).length;
        const estimatedReadTime = Math.ceil(wordCount / 200); // 200 words per minute
        
        postStats.push({
          author: post.author,
          wordCount,
          imageCount,
          linkCount,
          estimatedReadTime
        });
      }
    }
    
    return { postStats };
  }
}

// Usage
const customProvider = new PostAnalysisProvider();
workerbee.observe
  .onPosts("alice")
  .provider(customProvider)
  .subscribe({
    next: ({ postStats }) => {
      for (const stats of postStats) {
        console.log(`Post by @${stats.author}:`);
        console.log(`  Words: ${stats.wordCount}`);
        console.log(`  Images: ${stats.imageCount}`);
        console.log(`  Links: ${stats.linkCount}`);
        console.log(`  Read Time: ${stats.estimatedReadTime} min`);
      }
    }
  });
```

### Custom Provider Function

For simpler cases, use provider functions:

```typescript
// Provider for post sentiment analysis
const sentimentProvider = async (context: DataEvaluationContext) => {
  const posts = await context.getPosts();
  const sentiments: Record<string, Array<{author: string, permlink: string, sentiment: string}>> = {};
  
  for (const [author, authorPosts] of Object.entries(posts)) {
    sentiments[author] = [];
    
    for (const post of authorPosts) {
      // Simple sentiment analysis (in real app, use proper NLP library)
      const positiveWords = ['good', 'great', 'awesome', 'excellent', 'amazing'];
      const negativeWords = ['bad', 'terrible', 'awful', 'horrible', 'hate'];
      
      const text = post.body.toLowerCase();
      const positiveCount = positiveWords.reduce((count, word) => 
        count + (text.split(word).length - 1), 0
      );
      const negativeCount = negativeWords.reduce((count, word) => 
        count + (text.split(word).length - 1), 0
      );
      
      let sentiment = 'neutral';
      if (positiveCount > negativeCount) sentiment = 'positive';
      else if (negativeCount > positiveCount) sentiment = 'negative';
      
      sentiments[author].push({
        author: post.author,
        permlink: post.permlink,
        sentiment
      });
    }
  }
  
  return { sentiments };
};

// Usage
workerbee.observe
  .onPosts("alice", "bob")
  .provider(sentimentProvider)
  .subscribe({
    next: ({ sentiments }) => {
      Object.entries(sentiments).forEach(([author, authorSentiments]) => {
        authorSentiments.forEach(({ permlink, sentiment }) => {
          console.log(`@${author}/${permlink}: ${sentiment} sentiment`);
        });
      });
    }
  });
```

## :racing_car: Performance Optimization

### Provider Caching

Providers automatically benefit from WorkerBee's caching system:

```typescript
// These providers share cached account data
workerbee.observe
  .onAccountsBalanceChange(false, "alice")
  .provideAccounts("alice")           // Uses account cache
  .provideFollowCounts("alice")       // Reuses account cache
  .provideAccountsVotingManabar("alice") // Reuses account cache
  .subscribe({ /* ... */ });
```

### Concurrent Execution

All providers run concurrently for maximum performance:

```typescript
workerbee.observe
  .onPosts("alice")
  .provideAccounts("alice", "bob")      // Provider 1 (parallel)
  .provideFollowCounts("alice")         // Provider 2 (parallel)  
  .provideDynamicGlobalProperties()     // Provider 3 (parallel)
  .subscribe({ /* ... */ });
// All providers execute simultaneously!
```

### Conditional Providers

Only request data you actually need:

```typescript
workerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      // Only get account data for posts with high vote count
      if (posts.alice.some(post => post.net_votes > 10)) {
        // Request additional data for popular posts
        workerbee.observe
          .filter(() => true) // Always true for immediate execution
          .provideAccounts("alice")
          .subscribe({
            next: ({ accounts }) => {
              console.log(`Popular post by @${accounts.alice.name}`);
            }
          });
      }
    }
  });
```

## :warning: Common Patterns

### Data Enrichment Pattern

Combine multiple providers to enrich your data:

```typescript
workerbee.observe
  .onPosts("alice")
  .provideAccounts("alice")
  .provideFollowCounts("alice")
  .provideAccountsVotingManabar("alice")
  .subscribe({
    next: ({ posts, accounts, followCounts, votingManabar }) => {
      const post = posts.alice[0];
      const account = accounts.alice;
      const social = followCounts.alice;
      const voting = votingManabar.alice;
      
      // Rich context for decision making
      console.log(`New post by @${account.name} (${social.follower_count} followers)`);
      console.log(`Author has ${(voting.current_mana / voting.max_mana * 100).toFixed(1)}% voting power`);
      console.log(`Post: "${post.title}" with ${post.tags.join(', ')} tags`);
    }
  });
```

### Conditional Processing Pattern

Use provider data to make decisions:

```typescript
workerbee.observe
  .onPosts("alice")
  .provideAccounts("alice")
  .subscribe({
    next: ({ posts, accounts }) => {
      const account = accounts.alice;
      
      // Only vote on posts from accounts with good reputation
      const reputation = parseInt(account.reputation);
      if (reputation > 60) {
        console.log(`High reputation author (${reputation}), considering vote...`);
        
        for (const post of posts.alice) {
          if (post.tags.includes('photography')) {
            console.log(`Quality photography post detected: ${post.title}`);
            // Vote logic here...
          }
        }
      }
    }
  });
```

## :books: Provider Reference Summary

### Account Providers

- `provideAccounts(...accounts)` - Full account objects
- `provideAccountsVotingManabar(...accounts)` - Voting power details
- `provideAccountsRCManabar(...accounts)` - Resource credit details  
- `provideFollowCounts(...accounts)` - Follower/following counts

### Content Providers

- Automatic with content filters (posts, comments, votes)
- `providePostDetails(author, permlink)` - Detailed post information
- `provideCommentDetails(author, permlink)` - Detailed comment information

### Blockchain Providers

- Automatic with blockchain filters (blocks, transactions)
- `provideDynamicGlobalProperties()` - Global blockchain state
- `provideWitnessSchedule()` - Current witness information

### Custom Providers

- `provider(customProvider)` - Add custom data providers
- Custom provider classes extending `BaseProvider`
- Custom provider functions for simple transformations

Providers are essential for building rich, data-driven blockchain applications with WorkerBee!
