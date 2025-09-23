---
order: -5
icon: light-bulb
---

# Common Patterns

Learn proven patterns and best practices for building robust WorkerBee applications. These patterns solve common challenges and provide reusable solutions.

## 👥 Social & Content

**Use Cases:**

- Content creator activity dashboard
- User engagement analytics
- Community member monitoring
- Personal activity notifications
- Brand monitoring
- Community engagement alerts
- Customer service automation

**Key Filters:**

- [`onPosts()`](/interfaces/api-reference/#onposts) - Track new posts by specific authors
- [`onComments()`](/interfaces/api-reference/#oncomments) - Monitor comments and replies
- [`onCommentsIncomingPayout()`](/interfaces/api-reference/#oncommentsincomingpayout) - Track comment payouts
- [`onPostsIncomingPayout()`](/interfaces/api-reference/#onpostsincomingpayout) - Track post payouts
- [`onMention()`](/interfaces/api-reference/#onmention) - Detect @username mentions
- [`onReblog()`](/interfaces/api-reference/#onreblog) - Monitor content resharing
- [`onVotes()`](/interfaces/api-reference/#onvotes) - Watch voting activity
- [`onFollow()`](/interfaces/api-reference/#onfollow) - Track follow/unfollow actions

### Content Creator Dashboard

Comprehensive content creator monitoring that tracks all social activities.

```typescript
// Content Creator Dashboard - monitors all creator activities
bot.observe.onPosts("creator")
  .or.onComments("creator")
  .or.onMention("creator")
  .or.onReblog("creator")
  .or.onVotes("creator")
  .subscribe({
    next(data) {
      // Handle comprehensive creator activity tracking
      if (data.posts?.creator)
        for (const { operation } of data.posts.creator)
          console.log(`New post: ${operation.title}`);

      if (data.mentioned?.creator)
        for (const operation of data.mentioned.creator)
          console.log(`Creator mentioned in: ${operation.author}/${operation.permlink}`);

      if (data.votes?.creator)
        for (const { operation } of data.votes.creator)
          console.log(`Creator voted on: ${operation.author}/${operation.permlink}`);
    }
  });
```

### Content Engagement Tracker

Monitor brand mentions and content interactions for marketing purposes.

```typescript
// Content Engagement Tracker - tracks brand engagement
bot.observe.onMention("brand")
  .or.onPosts("brand")
  .or.onReblog("brand")
  .or.onComments("brand")
  .provideAccounts("brand")
  .subscribe({
    next(data) {
      // Track brand engagement metrics
      if (data.mentions?.brand)
        for (const { operation } of data.mentions.brand)
          console.log(`Brand mentioned by @${operation.author}`);

      if (data.reblogs?.brand)
        for (const { operation } of data.reblogs.brand)
          console.log(`Brand content reshared by @${operation.account}`);
    }
  });
```

## 🏦 Financial Operations

**Use Cases:**

- Market movement tracking
- Large transfer alerts
- Investment monitoring
- Risk management systems
- Portfolio tracking
- Trading bot integration

**Key Filters:**

- [`onWhaleAlert()`](/interfaces/api-reference/#onwhalealert) - Monitor large transfers above threshold
- [`onAccountsBalanceChange()`](/interfaces/api-reference/#onaccountsbalancechange) - Track balance changes
- [`onExchangeTransfer()`](/interfaces/api-reference/#onexchangetransfer) - Monitor exchange movements
- [`onInternalMarketOperation()`](/interfaces/api-reference/#oninternalmarketoperation) - Track market operations

### Market Movement Detector

Monitor significant market movements and financial activities.

```typescript
// Market Movement Detector - detects significant market changes
const threshold = bot.chain!.hiveCoins(10000);

bot.observe.onWhaleAlert(threshold)
  .or.onInternalMarketOperation()
  .or.onExchangeTransfer()
  .subscribe({
    next(data) {
      // Respond to market movements
      if (data.whaleOperations)
        for (const { operation } of data.whaleOperations)
          console.log(`🐋 Large transfer: ${operation.from} -> ${operation.to} (${operation.amount})`);

      if (data.internalMarketOperations)
        for (const { operation } of data.internalMarketOperations)
          console.log(`Market activity: ${operation.op}`);

      if (data.exchangeTransfers)
        for (const { operation } of data.exchangeTransfers)
          console.log(`Exchange transfer: ${operation.from} -> ${operation.to}`);
    }
  });
```

### Investment Portfolio Monitor

Monitor investment portfolios and account activities for financial tracking.

```typescript
// Investment Portfolio Monitor - tracks portfolio activities
bot.observe.onAccountsBalanceChange(true, "investor1", "investor2")
  .or.onWhaleAlert(bot.chain!.hiveCoins(5000))
  .provideAccounts("investor1", "investor2")
  .subscribe({
    next(data) {
      // Monitor investment activities
      for (const account in data.accounts) {
        if (data.accounts[account] !== undefined) {
          const acc = data.accounts[account];
          console.log(`${account} balance: ${acc.balance.HIVE.total} HIVE, ${acc.balance.HBD.total} HBD`);
        }
      }

      if (data.whaleOperations)
        for (const { operation } of data.whaleOperations)
          console.log(`Large transfer affecting portfolio: ${operation.amount}`);
    }
  });
```

## 👤 Account Management

**Use Cases:**

- Personal account monitoring
- Multi-account management dashboards
- Account lifecycle tracking
- Resource efficiency optimization
- Profile change notifications
- Account activity aggregation
- Delegation management
- Account recovery assistance

**Key Filters:**

- [`onAccountsBalanceChange()`](/interfaces/api-reference/#onaccountsbalancechange) - Monitor account balance updates
- [`onAccountsMetadataChange()`](/interfaces/api-reference/#onaccountsmetadatachange) - Track profile and metadata changes
- [`onAccountsFullManabar()`](/interfaces/api-reference/#onaccountsfullmanabar) - Detect when accounts reach 98% manabar capacity
- [`onAccountsManabarPercent()`](/interfaces/api-reference/#onaccountsmanabarpercent) - Monitor manabar threshold percentages
- [`onNewAccount()`](/interfaces/api-reference/#onnewaccount) - Monitor new account creation
- [`onImpactedAccounts()`](/interfaces/api-reference/#onimpactedaccounts) - Monitor all operations affecting accounts

### Multi-Account Dashboard

Comprehensive account management for monitoring multiple accounts across all activities.

```typescript
// Multi-Account Dashboard - monitors comprehensive account activities
bot.observe.onAccountsBalanceChange(true, "account1", "account2")
  .or.onAccountsMetadataChange("account1", "account2")
  .or.onImpactedAccounts("account1", "account2")
  .provideAccounts("account1", "account2")
  .subscribe({
    next(data) {
      // Monitor all account activities
      for (const account in data.accounts) {
        const acc = data.accounts[account];

        if (acc) {
          console.log(`Account ${account}:`);
          console.log(`Balance: ${acc.balance.HIVE.total} HIVE, ${acc.balance.HBD.total} HBD`);
          console.log(`Profile: ${acc.jsonMetadata?.profile?.name}`);
        }
      }

      if (data.impactedAccounts)
        for (const account in data.impactedAccounts)
          console.log(`📋 ${account} affected by ${data.impactedAccounts[account].length} operations`);
    }
  });
```

### Account Resource Optimizer

Optimize manabar usage across accounts for maximum efficiency and prevent resource waste.

```typescript
// Account Resource Optimizer - prevents mana waste and optimizes usage
bot.observe.onAccountsFullManabar(EManabarType.UPVOTE, "curator1", "curator2")
  .or.onAccountsFullManabar(EManabarType.DOWNVOTE, "curator1", "curator2")
  .or.onAccountsFullManabar(EManabarType.RC, "curator1", "curator2")
  .provideManabarData(EManabarType.UPVOTE, "curator1", "curator2")
  .provideManabarData(EManabarType.DOWNVOTE, "curator1", "curator2")
  .provideManabarData(EManabarType.RC, "curator1", "curator2")
  .subscribe({
    next(data) {
      for (const account in data.manabarData) {
        const manabar = data.manabarData[account];

        // Upvote mana optimization
        const upvoteMana = manabar[EManabarType.UPVOTE];
        console.log(`${account}: Upvote mana at ${upvoteMana.percent}%`);
        console.log(`Available upvote power: ${upvoteMana.current}`);

        // Downvote mana optimization
        const downvoteMana = manabar[EManabarType.DOWNVOTE];
        console.log(`${account}: Downvote mana full - moderate content now`);
        console.log(`Available downvote power: ${downvoteMana.current} / ${downvoteMana.max}`);

        // RC optimization
        const rcMana = manabar[EManabarType.RC];
        console.log(`${account}: RC at 100% - execute pending operations`);
        console.log(`Available RC: ${rcMana.current} / ${rcMana.max}`);
      }
    }
  });
```

## 🔐 Security & Governance

**Use Cases:**

- Account security monitoring
- Recovery account tracking
- Governance participation monitoring
- Security audit logging
- Resource optimization
- Account efficiency tracking

**Key Filters:**

- [`onAlarm()`](/interfaces/api-reference/#onalarm) - Monitor security and governance events
- [`onAccountsMetadataChange()`](/interfaces/api-reference/#onaccountsmetadatachange) - Track profile changes
- [`onNewAccount()`](/interfaces/api-reference/#onnewaccount) - Monitor new account creation
- [`onAccountsFullManabar()`](/interfaces/api-reference/#onaccountsfullmanabar) - Detect full mana recovery
- [`onAccountsManabarPercent()`](/interfaces/api-reference/#onaccountsmanabarpercent) - Monitor mana thresholds

### Account Security Monitor

Monitor account health indicators and security events.

```typescript
// Account Security Monitor - monitors account security
bot.observe.onAlarm("account")
  .or.onAccountsMetadataChange("account")
  .subscribe({
    next(data) {
      // Monitor security events
      if (data.alarmsPerAccount)
        for (const account in data.alarmsPerAccount)
          for (const { operation } of data.alarmsPerAccount[account])
            console.log(`Security event for ${account}: ${operation.op}`);

      if (data.accounts)
        for (const account of data.accounts)
          console.log(`Profile updated: ${account}`);
    }
  });
```

### Resource Management Bot

Optimize engagement timing based on resource availability.

```typescript
// Resource Management Bot - optimizes resource usage
bot.observe.onAccountsManabarPercent(90, EManabarType.UPVOTE, "curator")
  .or.onAccountsFullManabar(EManabarType.RC, "curator")
  .provideManabarData(EManabarType.UPVOTE, "curator")
  .provideManabarData(EManabarType.RC, "curator")
  .subscribe({
    next(data) {
      // Optimize based on mana levels
      const upvoteMana = data.manabarData?.curator?.[EManabarType.UPVOTE];
      const rcMana = data.manabarData?.curator?.[EManabarType.RC];

      if (upvoteMana && upvoteMana.percent >= 90)
        console.log(`Optimal voting conditions: ${upvoteMana.percent}% upvote mana`);

      if (rcMana && rcMana.percent === 100)
        console.log(`RC fully recharged: ${rcMana.percent}%`);
    }
  });
```

## ⚙️ Blockchain Infrastructure

**Use Cases:**

- Network performance monitoring
- Witness tracking
- Block production analysis
- Infrastructure alerting
- dApp-specific monitoring
- Custom protocol tracking

**Key Filters:**

- [`onBlock()`](/interfaces/api-reference/#onblock) - Monitor all new blocks
- [`onBlockNumber()`](/interfaces/api-reference/#onblocknumber) - Track specific block numbers
- [`onWitnessesMissedBlocks()`](/interfaces/api-reference/#onwitnessesmissedblocks) - Monitor witness performance
- [`onFeedPriceChange()`](/interfaces/api-reference/#onfeedpricechange) - Monitor price feed updates
- [`onFeedPriceNoChange()`](/interfaces/api-reference/#onfeedpricenochange) - Detect stale price feeds
- [`onCustomOperation()`](/interfaces/api-reference/#oncustomoperation) - Monitor custom JSON operations
- [`onTransactionIds()`](/interfaces/api-reference/#ontransactionids) - Track specific transactions
- [`onImpactedAccounts()`](/interfaces/api-reference/#onimpactedaccounts) - Monitor all affected accounts

### Witness Performance Monitor

Monitor witness performance and blockchain infrastructure health.

```typescript
// Witness Performance Monitor - monitors witness reliability
bot.observe.onWitnessesMissedBlocks(5, "witness1", "witness2")
  .or.onFeedPriceChange(3)
  .or.onFeedPriceNoChange(48)
  .provideWitnesses("witness1", "witness2")
  .provideFeedPriceData()
  .subscribe({
    next(data) {
      // Monitor blockchain infrastructure
      if (data.witnesses)
        for (const witness in data.witnesses)
          console.log(`Witness ${witness} missed 5 blocks`);

      if (data.feedPriceData)
        console.log(`Price feed update: ${data.feedPriceData.base}/${data.feedPriceData.quote}`);
    }
  });
```
