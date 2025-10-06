---
order: -10
icon: code
---

# API Reference

For a complete TypeScript API reference for WorkerBee you can visit [WorkerBee Wiki](https://gitlab.syncad.com/hive/workerbee/-/wikis/home).

This document covers all filters & providers, divided into categories, available in the library.

## Filters

**Data Mode Availability:**

- **🟢 Live Mode Only** - These filters require real-time blockchain data and are only available when using `workerbee.observe`
- **🔵 Live and Past Data Modes** - These filters work with both live data (`workerbee.observe`) and historical data (`workerbee.providePastOperations()`)

## 👤 Tracking Account Activity

### onAccountsFullManabar

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when any of the specified accounts reaches 98% manabar capacity.
The monitored manabar type is specified as the first parameter and can be one of 3 types: `UPVOTE`, `DOWNVOTE`, or `RC`.
The filter provides manabar information for each monitored account in the callback data.
When observing multiple accounts, remember to check if manabar data is available for the specific account.

:::code source="../static/snippets/src/typescript/api-reference/filters/onAccountsFullManabar.ts" language="typescript" range="17-38" title="Test it yourself: [src/typescript/api-reference/filters/onAccountsFullManabar.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonAccountsFullManabar.ts&startScript=test-api-reference-filters-onAccountsFullManabar)" :::

### onAccountsManabarPercent

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter works similarly to [`onAccountsFullManabar`](#onaccountsfullmanabar), but allows you to specify a custom manabar percentage threshold.
It provides the account's manabar data in the callback.

:::code source="../static/snippets/src/typescript/api-reference/filters/onAccountsManabarPercent.ts" language="typescript" range="18-39" title="Test it yourself: [src/typescript/api-reference/filters/onAccountsManabarPercent.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonAccountsManabarPercent.ts&startScript=test-api-reference-filters-onAccountsManabarPercent)" :::

### onAccountsMetadataChange

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when any of the specified accounts updates their metadata.
You can observe multiple accounts in a single observer call.
This filter provides the account data in the callback when metadata changes occur.

:::code source="../static/snippets/src/typescript/api-reference/filters/onAccountsMetadataChange.ts" language="typescript" range="13-32" title="Test it yourself: [src/typescript/api-reference/filters/onAccountsMetadataChange.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonAccountsMetadataChange.ts&startScript=test-api-reference-filters-onAccountsMetadataChange)" :::

### onImpactedAccounts

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when any new blockchain operation affects one of the specified accounts (transfers, votes, mentions, etc.),
also when the account is just referenced by operation that has been authorized by another account, i.e. when alice voted on bob's comment, bob is also and impacted account.
You can monitor multiple accounts in both live and past data modes.
Remember to check if data for a specific account actually exists when observing multiple accounts.

:::code source="../static/snippets/src/typescript/api-reference/filters/onImpactedAccounts.ts" language="typescript" range="17-39" title="Test it yourself: [src/typescript/api-reference/filters/onImpactedAccounts.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonImpactedAccounts.ts&startScript=test-api-reference-filters-onImpactedAccounts)" :::

### onNewAccount

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when new accounts are created on the blockchain through account creation operations.
It monitors three types of account creation operations: `account_create_operation`, `account_create_with_delegation_operation`, and `create_claimed_account_operation`.
The filter requires no input parameters as it monitors all new account creations globally.
The callback data includes detailed information about each newly created account, including the account name, creator, authorities, and metadata.

:::code source="../static/snippets/src/typescript/api-reference/filters/onNewAccount.ts" language="typescript" range="16-36" title="Test it yourself: [src/typescript/api-reference/filters/onNewAccount.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonNewAccount.ts&startScript=test-api-reference-filters-onNewAccount)" :::

## ⚙️ Blockchain Infrastructure

### onBlockNumber

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when the blockchain reaches a specific block number.
It is useful for scheduled operations, testing scenarios, or waiting for governance proposals that become active at a particular block.
The filter takes a single block number parameter and monitors the blockchain until that exact block is produced.
The filter provides no callback data as it is designed to be a simple notification mechanism - if you need block details, combine it with [block providers](#provideblockdata).

:::code source="../static/snippets/src/typescript/api-reference/filters/onBlockNumber.ts" language="typescript" range="13-36" title="Test it yourself: [src/typescript/api-reference/filters/onBlockNumber.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonBlockNumber.ts&startScript=test-api-reference-filters-onBlockNumber)" :::

### onBlock

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers on every new block produced on the blockchain.
Unlike [`onBlockNumber`](#onblocknumber) which waits for a specific block number to be reached and then triggers once, `onBlock` continuously monitors the blockchain and triggers for every single block that gets produced.
It provides comprehensive block header data in the callback, making it perfect for real-time blockchain monitoring and applications that need to process every block.
The filter requires no input parameters.
When processing past data, it will trigger for each block in the specified range, allowing you to replay blockchain history.

:::code source="../static/snippets/src/typescript/api-reference/filters/onBlock.ts" language="typescript" range="16-33" title="Test it yourself: [src/typescript/api-reference/filters/onBlock.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonBlock.ts&startScript=test-api-reference-filters-onBlock)" :::

### onTransactionIds

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specific transaction IDs appear on the blocks distributed by blockchain.
It is particularly useful for tracking the inclusion of specific transactions in blocks, monitoring transaction confirmations, or building applications that need to react when certain transactions are processed.
You can monitor multiple transaction IDs simultaneously, and the filter will trigger when any of them appears on the blockchain.
The callback provides detailed transaction data for each monitored transaction ID, allowing you to access the full transaction content and metadata.

:::code source="../static/snippets/src/typescript/api-reference/filters/onTransactionIds.ts" language="typescript" range="15-53" title="Test it yourself: [src/typescript/api-reference/filters/onTransactionIds.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonTransactionIds.ts&startScript=test-api-reference-filters-onTransactionIds)" :::

## 🏦 Financial Operations

### onAccountsBalanceChange

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when account balances change due to various financial operations on the blockchain.
It monitors all types of balance changes including incoming and outgoing transfers, author/curation rewards, witness rewards, power ups/downs, savings operations, and conversions.
The filter allows you to specify whether to include internal balance changes through the `includeInternal` parameter.
You can monitor multiple accounts simultaneously, making it perfect for portfolio tracking, payment processing, or automated financial applications.
This filter provides the account data in the callback when balance changes occur.

:::code source="../static/snippets/src/typescript/api-reference/filters/onAccountsBalanceChange.ts" language="typescript" range="16-34" title="Test it yourself: [src/typescript/api-reference/filters/onAccountsBalanceChange.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonAccountsBalanceChange.ts&startScript=test-api-reference-filters-onAccountsBalanceChange)" :::

### onExchangeTransfer

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when transfers involve known cryptocurrency exchange accounts on the Hive blockchain.
WorkerBee maintains an internal list of recognized exchange accounts and automatically monitors all transfer operations that either originate from or are directed to these exchanges.
This is particularly useful for tracking market movements, analyzing trading patterns, detecting large deposits/withdrawals, or building exchange monitoring applications.
The filter requires no input parameters as it globally monitors all exchange-related transfers, making it ideal for market analysis and trading bot applications.
It provides detailed transfer data including amounts, sender/receiver information, and memo fields, allowing you to analyze exchange activity patterns.

:::code source="../static/snippets/src/typescript/api-reference/filters/onExchangeTransfer.ts" language="typescript" range="16-36" title="Test it yourself: [src/typescript/api-reference/filters/onExchangeTransfer.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonExchangeTransfer.ts&startScript=test-api-reference-filters-onExchangeTransfer)" :::

### onFeedPriceChange

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when the Hive price feed changes by a specified percentage threshold.
It monitors the official price feed data published by witnesses and detects significant price movements that exceed your defined percentage threshold.
This is particularly useful for building trading bots, price alert systems, or applications that need to react to market volatility.
The filter allows you to set a custom percentage threshold (e.g., 5 for 5% change) to control the sensitivity of price change detection.
It's perfect for monitoring market conditions without constantly polling price data.
The filter is essential for financial applications that need to respond to significant price movements on the Hive blockchain.

:::code source="../static/snippets/src/typescript/api-reference/filters/onFeedPriceChange.ts" language="typescript" range="14-30" title="Test it yourself: [src/typescript/api-reference/filters/onFeedPriceChange.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonFeedPriceChange.ts&startScript=test-api-reference-filters-onFeedPriceChange)" :::

### onFeedPriceNoChange

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when the Hive price feed remains completely unchanged for a specified number of hours.
Unlike [`onFeedPriceChange`](#onfeedpricechange) which detects price movements, this filter is designed to detect periods of price stability and low market volatility.
The filter monitors the price history feed data and checks if the exact same price value has been maintained for the specified duration.
This is particularly useful for detecting market stagnation, low trading volume periods, or identifying optimal times for certain trading strategies that work best in stable market conditions.
The filter accepts a parameter specifying the number of hours of required stability, with a default of 24 hours if no parameter is provided.

:::code source="../static/snippets/src/typescript/api-reference/filters/onFeedPriceNoChange.ts" language="typescript" range="14-30" title="Test it yourself: [src/typescript/api-reference/filters/onFeedPriceNoChange.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonFeedPriceNoChange.ts&startScript=test-api-reference-filters-onFeedPriceNoChange)" :::

### onInternalMarketOperation

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when operations occur on Hive's built-in internal decentralized exchange (DEX) for HIVE ↔ HBD trading.
It monitors three specific types of market operations: limit order creation, order cancellation, and automatic order fills when orders are matched.
The internal market allows users to trade between HIVE and HBD (Hive Backed Dollars) directly on the blockchain without using external exchanges.
This filter is particularly useful for building market analysis tools, arbitrage bots, trading dashboards, or applications that need to track decentralized trading activity.
The filter requires no input parameters as it globally monitors all internal market operations, providing comprehensive coverage of the built-in DEX activity.

:::code source="../static/snippets/src/typescript/api-reference/filters/onInternalMarketOperation.ts" language="typescript" range="16-36" title="Test it yourself: [src/typescript/api-reference/filters/onInternalMarketOperation.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonInternalMarketOperation.ts&startScript=test-api-reference-filters-onInternalMarketOperation)" :::

### onWhaleAlert

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when large transfers exceed a specified amount threshold, making it perfect for monitoring significant financial movements on the Hive blockchain.
It monitors four specific types of transfer operations: regular transfers, transfers from savings, escrow transfers, and recurrent transfers.
The filter is commonly known as "whale watching" in crypto communities, as it helps detect when large holders (whales) move substantial amounts of cryptocurrency.
You can specify any asset type and amount threshold using the chain's helper methods like `bot.chain.hiveCoins(1000)`.
This filter is particularly useful for market analysis, detecting potential market-moving transactions, building trading alerts, or monitoring large account movements for security purposes.

:::code source="../static/snippets/src/typescript/api-reference/filters/onWhaleAlert.ts" language="typescript" range="16-42" title="Test it yourself: [src/typescript/api-reference/filters/onWhaleAlert.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonWhaleAlert.ts&startScript=test-api-reference-filters-onWhaleAlert)" :::

## 🔐 Security & Governance

### onAlarm

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when monitored accounts experience security or governance-related situations that require attention.

#### Supported Alarm Types

The `onAlarm` filter detects the following five specific alarm types:

1. **Legacy Recovery Account Configuration (`LEGACY_RECOVERY_ACCOUNT_SET`)**
   - Accounts still using "steem" as recovery account from the old blockchain
   - Indicates outdated security configuration that should be updated

2. **Governance Vote Expiration Soon (`GOVERNANCE_VOTE_EXPIRATION_SOON`)**
   - Governance votes expiring within one month
   - Allows proactive governance participation management

3. **Governance Vote Expired (`GOVERNANCE_VOTE_EXPIRED`)**
   - Accounts that haven't participated in governance for extended periods
   - Indicates accounts with expired or missing governance votes

4. **Recovery Account Change in Progress (`RECOVERY_ACCOUNT_IS_CHANGING`)**
   - Active recovery account changes during the 30-day waiting period
   - Critical security event requiring monitoring

5. **Declining Voting Rights (`DECLINING_VOTING_RIGHTS`)**
   - Accounts that have declined their voting rights
   - Important for tracking account voting status changes

The filter is essential for account security monitoring, governance participation tracking, and detecting potentially compromised or misconfigured accounts.
You can monitor multiple accounts simultaneously, making it perfect for wallet applications, account management tools, or security monitoring systems.

:::code source="../static/snippets/src/typescript/api-reference/filters/onAlarm.ts" language="typescript" range="16-39" title="Test it yourself: [src/typescript/api-reference/filters/onAlarm.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonAlarm.ts&startScript=test-api-reference-filters-onAlarm)" :::

### onWitnessesMissedBlocks

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when specified witness accounts miss a threshold number of consecutive blocks during their scheduled block production turns.
It monitors witness performance by tracking the `totalMissedBlocks` counter and `lastConfirmedBlockNum` to detect when witnesses fail to produce blocks when they're supposed to.
The filter is essential for network health monitoring, witness performance analysis, and detecting potential issues with witness nodes (server downtime, connectivity problems, or configuration issues).
It intelligently resets its tracking when a witness successfully produces a block again, preventing duplicate notifications for the same missed block streak.
You can monitor multiple witnesses simultaneously with different threshold values, making it perfect for witness monitoring dashboards, alerting systems, or blockchain infrastructure monitoring tools.

:::code source="../static/snippets/src/typescript/api-reference/filters/onWitnessesMissedBlocks.ts" language="typescript" range="16-33" title="Test it yourself: [src/typescript/api-reference/filters/onWitnessesMissedBlocks.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonWitnessesMissedBlocks.ts&startScript=test-api-reference-filters-onWitnessesMissedBlocks)" :::

## 👥 Social & Content

### onCommentsIncomingPayout

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when **replies/comments** (not top-level posts) by specified authors are approaching their payout window expiration, allowing you to monitor engagement performance before final reward distribution.
On the Hive blockchain, comments have a 7-day payout window after creation, and this filter detects when they're nearing that critical payout moment.
The filter specifically monitors replies to posts or other comments (content with a non-empty `parent_author` field), distinguishing them from top-level posts.
You can specify a relative time offset (like "-30m" for 30 minutes before payout or "-1h" for 1 hour before) to receive notifications at your preferred timing.
This is particularly useful for content creators, curators, or applications that need to take action before payout finalization - such as last-minute promotion, vote adjustments, or performance analytics.
You can monitor multiple authors simultaneously, making it perfect for content management dashboards, curation tools, or automated content promotion systems.
Remember that you need to collect past operations to access old posts and comments to monitor their payout right after starting the application.

**Note:** For monitoring top-level posts approaching payout, use [`onPostsIncomingPayout`](#onpostsincomingpayout) instead.

:::code source="../static/snippets/src/typescript/api-reference/filters/onCommentsIncomingPayout.ts" language="typescript" range="17-36" title="Test it yourself: [src/typescript/api-reference/filters/onCommentsIncomingPayout.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonCommentsIncomingPayout.ts&startScript=test-api-reference-filters-onCommentsIncomingPayout)" :::

### onComments

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specified authors create new comments on the Hive blockchain. Top level posts are ignored by this filter.
Comments are replies to posts or other comments, distinguished from posts by having a non-empty `parent_author` field in the underlying `comment_operation`.
The filter monitors all comment creation activity and provides detailed comment data in the callback, including operation details like author, permlink, parent information, and content metadata.
You can monitor multiple authors simultaneously, making it perfect for content moderation tools, engagement tracking systems, discussion monitoring applications, or building comment notification services.
It's particularly useful for building social media applications, content curation tools, or automated response systems that need to react to new comment activity.

:::code source="../static/snippets/src/typescript/api-reference/filters/onComments.ts" language="typescript" range="16-36" title="Test it yourself: [src/typescript/api-reference/filters/onComments.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonComments.ts&startScript=test-api-reference-filters-onComments)" :::

### onCustomOperation

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when custom JSON operations with specified operation IDs appear on the Hive blockchain.
Custom operations are the primary mechanism for decentralized applications (dApps), games, and services to extend Hive's functionality with their own custom logic and data structures.
The filter monitors both `custom_json_operation` and `custom_operation` types, allowing you to track specific application protocols by their unique identifiers.
Popular examples include gaming operations like Splinterlands rewards ("sm_claim_reward"), community actions ("community"), or any other dApp-specific functionality.
You can monitor multiple operation IDs simultaneously, making it perfect for building application-specific monitoring tools, analytics dashboards, bot automation systems, or cross-platform dApp integration services.
It's essential for developers building on Hive who need to track their own custom operations or monitor activity from other applications in the ecosystem.

**Note:** For social interactions like "follow" and "reblog", use the specialized [`onFollow`](#onfollow) and [`onReblog`](#onreblog) filters instead, which provide more targeted functionality and enhanced data.

:::code source="../static/snippets/src/typescript/api-reference/filters/onCustomOperation.ts" language="typescript" range="16-42" title="Test it yourself: [src/typescript/api-reference/filters/onCustomOperation.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonCustomOperation.ts&startScript=test-api-reference-filters-onCustomOperation)" :::

### onFollow

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specified accounts perform social relationship operations on the Hive blockchain, including following, unfollowing, muting, and blacklisting other accounts.
The filter monitors custom JSON operations with the "follow" ID, which contain the social graph interaction data that powers Hive's decentralized social networking features.
It tracks various relationship types through the `what` field in the operation, supporting actions like "blog" (follow), "mute", "blacklist", and their corresponding removal operations.
These operations are fundamental to Hive's social layer, allowing users to build their feeds, manage unwanted content, and create curated social experiences.
You can monitor multiple accounts simultaneously, making it perfect for building social analytics tools, relationship tracking dashboards, follower notification systems, or automated social interaction bots.
It's essential for applications that need to track social dynamics, build recommendation systems, or provide users with insights about their social network activity.

:::code source="../static/snippets/src/typescript/api-reference/filters/onFollow.ts" language="typescript" range="16-37" title="Test it yourself: [src/typescript/api-reference/filters/onFollow.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonFollow.ts&startScript=test-api-reference-filters-onFollow)" :::

### onMention

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specified accounts are mentioned in posts or comments using the standard @username syntax on the Hive blockchain.
The filter scans the text content of all posts and comments to detect username mentions and match them against your monitored account list.
It processes both new posts (top-level content) and comments (replies), providing comprehensive mention detection across all content types on the platform.
The filter is essential for building notification systems, social engagement tools, and automated response applications that need to react when specific users are mentioned in discussions.
You can monitor multiple accounts simultaneously, making it perfect for community management tools, brand monitoring applications, or personal notification services.
It's particularly valuable for social media managers, content creators, and businesses who need to stay informed about when their accounts or brands are being discussed in the Hive community.

:::code source="../static/snippets/src/typescript/api-reference/filters/onMention.ts" language="typescript" range="16-39" title="Test it yourself: [src/typescript/api-reference/filters/onMention.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonMention.ts&startScript=test-api-reference-filters-onMention)" :::

### onPostsIncomingPayout

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when **top-level posts** (not replies/comments) by specified authors are approaching their payout window expiration, allowing you to monitor content performance before final reward distribution.
On the Hive blockchain, posts have a 7-day payout window after creation, and this filter detects when they're nearing that critical payout moment.
The filter specifically monitors top-level posts (content with an empty `parent_author` field), distinguishing them from replies and comments.
You can specify a relative time offset (like "-30m" for 30 minutes before payout or "-1h" for 1 hour before) to receive notifications at your preferred timing.
This is particularly useful for content creators, curators, or applications that need to take action before payout finalization - such as last-minute promotion, vote adjustments, or performance analytics.
You can monitor multiple authors simultaneously, making it perfect for content management dashboards, curation tools, or automated content promotion systems.
Remember that you need to collect past operations to access old posts and comments to monitor their payout right after starting the application.

**Note:** For monitoring replies/comments approaching payout, use [`onCommentsIncomingPayout`](#oncommentsincomingpayout) instead.

:::code source="../static/snippets/src/typescript/api-reference/filters/onPostsIncomingPayout.ts" language="typescript" range="17-36" title="Test it yourself: [src/typescript/api-reference/filters/onPostsIncomingPayout.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonPostsIncomingPayout.ts&startScript=test-api-reference-filters-onPostsIncomingPayout)" :::

### onPosts

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specified authors create new posts on the Hive blockchain. Replies (comments) to posts are ignored by this filter.
Posts are top-level content pieces, distinguished from comments by having an empty `parent_author` field in the underlying `comment_operation`.
The filter monitors all post creation activity and provides detailed post data in the callback, including operation details like author, permlink, title, body, and content metadata.
You can monitor multiple authors simultaneously, making it perfect for content aggregation platforms, feed generation systems, blog monitoring applications, or building post notification services.
It's particularly useful for building social media applications, content curation tools, or automated promotion systems that need to react to new post publications.

:::code source="../static/snippets/src/typescript/api-reference/filters/onPosts.ts" language="typescript" range="16-38" title="Test it yourself: [src/typescript/api-reference/filters/onPosts.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonPosts.ts&startScript=test-api-reference-filters-onPosts)" :::

### onReblog

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specified accounts reblog (share/repost) content on the Hive blockchain.
Reblogs are a social sharing mechanism that allows users to reshare posts from other authors to their own feed, helping content reach a wider audience through the social network.
The filter monitors custom JSON operations with the "follow" ID that contain reblog actions, tracking when users share content they find valuable or interesting.
Reblogging is fundamental to content discovery and viral spread on Hive, allowing quality content to gain visibility beyond the original author's followers.
You can monitor multiple accounts simultaneously, making it perfect for building content distribution analytics, engagement tracking systems, influencer monitoring tools, or automated content promotion platforms.
The filter works with both live and past data modes, enabling real-time reblog monitoring and historical analysis of content sharing patterns.
It's particularly useful for understanding content virality, measuring influence networks, tracking brand mentions through shares, or building recommendation systems based on social sharing behavior.

:::code source="../static/snippets/src/typescript/api-reference/filters/onReblog.ts" language="typescript" range="16-36" title="Test it yourself: [src/typescript/api-reference/filters/onReblog.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonReblog.ts&startScript=test-api-reference-filters-onReblog)" :::

### onVotes

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter monitors voting activity on the Hive blockchain, triggering when specified accounts cast votes on posts or comments. It tracks both upvotes and downvotes, providing complete voting operation details including vote weights, target content, and transaction information. The filter supports monitoring multiple voters simultaneously and provides voting data organized by voter account.

The filter captures all vote operations including upvotes, downvotes, and vote deletions (zero weight votes). Each vote operation contains information about the voter, target author/permlink, vote weight, and associated blockchain transaction. This enables comprehensive tracking of content curation activities, voting patterns, and community engagement behaviors.

Key capabilities include:

- **Real-time vote monitoring**: Tracks voting activity as it happens on the blockchain
- **Multi-voter support**: Monitor voting activity from multiple accounts in a single observer
- **Complete vote data**: Access to vote weight, target content, voter information, and transaction details

It's particularly useful for building content curation dashboards, vote tracking systems, community engagement analytics, and voting behavior analysis tools.

:::code source="../static/snippets/src/typescript/api-reference/filters/onVotes.ts" language="typescript" range="16-37" title="Test it yourself: [src/typescript/api-reference/filters/onVotes.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Ffilters%2FonVotes.ts&startScript=test-api-reference-filters-onVotes)" :::

## Providers

**Data Mode Availability:**

- **🟢 Live Mode Only** - These providers require real-time blockchain data and are only available when using `workerbee.observe`
- **🔵 Live and Past Data Modes** - These providers work with both live data (`workerbee.observe`) and historical data (`workerbee.providePastOperations()`)

Providers are specialized data suppliers that enhance WorkerBee filters by delivering enriched blockchain data directly to your observer callbacks. While filters detect specific events or conditions on the blockchain, providers add contextual data and detailed information about accounts, transactions, blocks, and other blockchain entities.

Providers automatically integrate with filters and deliver their data through the same subscription callback, eliminating the need for separate API calls. This creates a seamless development experience where you can access both event notifications and related data in a single observer. They also are able to reuse already acquired data by filters if possible and avoid additional queries. What's important to note, they start to work only when filter condition matches.

## 👤 Account Data Providers

### provideAccounts

**🟢 Live Mode Only** - This provider requires real-time blockchain data and is not available in past data mode.

This provider extends the data passed to specified callback function by comprehensive account information for specified accounts.
It retrieves detailed account data including balances, voting power, profile metadata, and recovery account.
The provider automatically fetches current account state data and delivers it alongside your filter results.
You can specify multiple accounts to monitor simultaneously, making it perfect for portfolio tracking, account management applications, or social media dashboards.
The provider is essential for applications that need detailed user information, wallet interfaces, or account analysis tools.

:::code source="../static/snippets/src/typescript/api-reference/providers/provideAccounts.ts" language="typescript" range="16-35" title="Test it yourself: [src/typescript/api-reference/providers/provideAccounts.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Fproviders%2FprovideAccounts.ts&startScript=test-api-reference-providers-provideAccounts)" :::

### provideManabarData

**🟢 Live Mode Only** - This provider requires real-time blockchain data and is not available in past data mode.

This provider delivers detailed manabar information for specified accounts and manabar types.
It provides real-time data about account resource usage including current mana levels, last update time, and percentage capacity.
The provider supports all three manabar types: upvote, downvote, and resource credits (RC).
Manabar data is crucial for applications that need to manage account resources efficiently or provide users with resource usage insights.
You can monitor multiple accounts simultaneously, making it perfect for account management tools, automated posting applications, or resource optimization systems.

:::code source="../static/snippets/src/typescript/api-reference/providers/provideManabarData.ts" language="typescript" range="17-40" title="Test it yourself: [src/typescript/api-reference/providers/provideManabarData.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Fproviders%2FprovideManabarData.ts&startScript=test-api-reference-providers-provideManabarData)" :::

### provideRcAccounts

**🟢 Live Mode Only** - This provider requires real-time blockchain data and is not available in past data mode.

This provider supplies comprehensive resource credit (RC) account information for specified accounts.
It delivers detailed RC system data including current RC balance, maximum capacity, and last update time.
The provider gives access to advanced RC metrics that are essential for applications managing blockchain resource consumption.
Resource credits are fundamental to Hive's bandwidth system, determining how many operations accounts can perform without fees.
You can monitor multiple accounts simultaneously, making it perfect for account management tools, resource optimization applications, or automated systems that need to track RC usage.

:::code source="../static/snippets/src/typescript/api-reference/providers/provideRcAccounts.ts" language="typescript" range="16-38" title="Test it yourself: [src/typescript/api-reference/providers/provideRcAccounts.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Fproviders%2FprovideRcAccounts.ts&startScript=test-api-reference-providers-provideRcAccounts)" :::

### provideWitnesses

**🟢 Live Mode Only** - This provider requires real-time blockchain data and is not available in past data mode.

This provider delivers comprehensive witness information for specified witness accounts.
It provides detailed witness data including owner, version and block production performance.
The provider gives access to witness performance metrics, like missed block counts that are essential for monitoring network infrastructure.
Witnesses are the block producers on the Hive blockchain, and their performance directly affects network security and stability.
You can monitor multiple witnesses simultaneously, making it perfect for witness monitoring dashboards, network health analysis tools, or voting decision applications.

:::code source="../static/snippets/src/typescript/api-reference/providers/provideWitnesses.ts" language="typescript" range="15-35" title="Test it yourself: [src/typescript/api-reference/providers/provideWitnesses.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Fproviders%2FprovideWitnesses.ts&startScript=test-api-reference-providers-provideWitnesses)" :::

## ⚙️ Blockchain Data Providers

### provideBlockData

**🔵 Live and Past Data Modes** - This provider is available in both live and past data modes.

This provider delivers comprehensive block information including both block header (already collected by onBlock filter) and full block data (like all included transactions).
It provides detailed block content including all transactions, operations, witness signatures, and block metadata.
The provider combines block header data (block number, timestamp, witness) with complete block content for comprehensive blockchain monitoring.
Block data is fundamental for applications that need to process all blockchain activity or analyze transaction patterns.
The provider automatically delivers block information with your filter results, eliminating the need for separate block API calls.

:::code source="../static/snippets/src/typescript/api-reference/providers/provideBlockData.ts" language="typescript" range="16-35" title="Test it yourself: [src/typescript/api-reference/providers/provideBlockData.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Fproviders%2FprovideBlockData.ts&startScript=test-api-reference-providers-provideBlockData)" :::

### provideBlockHeaderData

**🔵 Live and Past Data Modes** - This provider is available in both live and past data modes.

This provider supplies essential block header information including block number, timestamp, witness, and basic block metadata.
It provides lightweight block data that is perfect for applications that need block timing and identification information without the overhead of full block content.
Block header data includes critical blockchain timing information and witness rotation details that are essential for many blockchain applications.
The provider delivers header information efficiently, making it ideal for high-frequency monitoring applications or resource-constrained environments.
It automatically integrates with your filters, providing block context alongside event notifications.

:::code source="../static/snippets/src/typescript/api-reference/providers/provideBlockHeaderData.ts" language="typescript" range="16-38" title="Test it yourself: [src/typescript/api-reference/providers/provideBlockHeaderData.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Fproviders%2FprovideBlockHeaderData.ts&startScript=test-api-reference-providers-provideBlockHeaderData)" :::

## 🏦 Financial Data Providers

### provideFeedPriceData

**🟢 Live Mode Only** - This provider requires real-time blockchain data and is not available in past data mode.

This provider delivers comprehensive HIVE price feed information including current prices, price history, and statistical price data.
It provides access to the official witness-published price feeds that determine HIVE-to-HBD conversion rates on the blockchain.
The provider supplies current median, minimum, and maximum price values along with historical price data for trend analysis.
Price feed data is essential for financial applications, trading bots, conversion calculators, and economic analysis tools.
The provider delivers real-time price information alongside your filter results, enabling applications to react to both events and current market conditions.

:::code source="../static/snippets/src/typescript/api-reference/providers/provideFeedPriceData.ts" language="typescript" range="16-34" title="Test it yourself: [src/typescript/api-reference/providers/provideFeedPriceData.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Fproviders%2FprovideFeedPriceData.ts&startScript=test-api-reference-providers-provideFeedPriceData)" :::

## 🛠️ Custom Filters & Providers

### filter

**🔵 Live and Past Data Modes** - Custom filters work with both live and historical data.

This powerful method allows you to create custom filters that aren't provided by WorkerBee out of the box. You can create complex conditions using external APIs, database queries, or any custom logic. Custom filters have access to the Data Evaluation Context (DEC), enabling them to use cached data from WorkerBee's collectors for optimal performance.

:::code source="../static/snippets/src/typescript/api-reference/custom/filter.ts" language="typescript" range="20-40" title="Test it yourself: [src/typescript/api-reference/custom/filter.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Fcustom%2Ffilter.ts&startScript=test-api-reference-custom-filter)" :::

### provide

**🔵 Live and Past Data Modes** - Custom providers work with both live and historical data.

Create custom data providers to extend WorkerBee's functionality with your own data sources. Custom providers can access the DEC to use cached blockchain data and add their own computed results to the notification data.

:::code source="../static/snippets/src/typescript/api-reference/custom/provide.ts" language="typescript" range="21-45" title="Test it yourself: [src/typescript/api-reference/custom/provide.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Fcustom%2Fprovide.ts&startScript=test-api-reference-custom-provide)" :::

### filterPiped

**🔵 Live and Past Data Modes** - Filter piped functionality works with both live and historical data.

This advanced method creates a filter that uses data provided by a custom provider in the same evaluation chain. The provider is guaranteed to run before the filter, enabling complex conditional logic based on external data sources. The piped data becomes part of the final notification data.

:::code source="../static/snippets/src/typescript/api-reference/custom/filterPiped.ts" language="typescript" range="23-49" title="Test it yourself: [src/typescript/api-reference/custom/filterPiped.ts](https://stackblitz.com/github/openhive-network/workerbee-doc-snippets?file=src%2Ftypescript%2Fapi-reference%2Fcustom%2FfilterPiped.ts&startScript=test-api-reference-custom-filterPiped)" :::
