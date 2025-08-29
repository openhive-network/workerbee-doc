---
order: -10
icon: code
---

# API Reference

For a complete TypeScript API reference for WorkerBee you can visit [WorkerBee Wiki](https://gitlab.syncad.com/hive/workerbee/-/wikis/home).

This document covers all filters & providers, divided into categories, available in the library.

XXX: Remember to embed snippets with lines after `import` (without preceding JSDoc).

## Filters

**Data Mode Availability:**

- **🟢 Live Mode Only** - These filters require real-time blockchain data and are only available when using `workerbee.observe`
- **🔵 Live and Past Data Modes** - These filters work with both live data (`workerbee.observe`) and historical data (`workerbee.providePastOperations()`)

### 👤 Account Management

#### onAccountsFullManabar

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when any of the specified accounts reaches 98% manabar capacity.
The monitored manabar type is specified as the first parameter and can be one of 3 types: `UPVOTE`, `DOWNVOTE`, or `RC`.
The filter provides manabar information for each monitored account in the callback data.
When observing multiple accounts, remember to check if manabar data is available for the specific account.

``` ts
/**
 * Category: 👤 Account Management
 * Demo: onAccountsFullManabar() — notify when accounts reach 98% manabar.
 *
 * This observer monitors manabar levels and triggers when any specified account reaches 98% manabar capacity.
 * You can specify a manabar kind to be monitored (expressed by values of {@link EManabarType}).
 * Multiple account names can be observed at single observer call.
 *
 * Filter Function Inputs:
 * - `manabarType: EManabarType` - The type of manabar to monitor (RC, UPVOTE, or DOWNVOTE)
 * - `...accounts: TAccountName[]` - Account names to monitor for full manabar
 *
 * Callback Data:
 * The callback receives data of type {@link IManabarProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import { EManabarType } from "@hiveio/wax";
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for accounts with full RC manabar...");

bot.observe.onAccountsFullManabar(EManabarType.RC, "guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when either guest4test or guest4test1 reaches 98% RC manabar.
   * The callback receives data of type {@link IManabarProviderData}, which includes:
   * - `data.manabarData` - Contains manabar information for each monitored account
   * The callback receives data for all monitored account even if only one reaches 98% manabar.
   * The rest of the accounts will point to undefined so you should check for their existence before accessing their properties.
   */
  next(data) {
    if (data.manabarData.guest4test)
      console.log(`⚡ Account guest4test has ${data.manabarData.guest4test?.[EManabarType.RC]?.percent}% RC manabar!`);
  },
  error: console.error
});
```

#### onAccountsManabarPercent

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter works similarly to [`onAccountsFullManabar`](#onaccountsfullmanabar), but allows you to specify a custom manabar percentage threshold.
It provides the account's manabar data in the callback.

``` ts
/**
 * Category: 👤 Account Management
 * Demo: onAccountsManabarPercent() — watch for manabar threshold percentage.
 *
 * This observer triggers when accounts reach a specific manabar percentage threshold.
 * You can specify a manabar kind to be monitored (expressed by values of {@link EManabarType}).
 * Multiple account names can be observed at single observer call.
 *
 * Filter Function Inputs:
 * - `manabarType: EManabarType` - The type of manabar to monitor (RC, UPVOTE, or DOWNVOTE)
 * - `percent: number` - The percentage threshold to trigger on (0-100)
 * - `...accounts: TAccountName[]` - Account names to monitor for threshold
 *
 * Callback Data:
 * The callback receives data of type {@link IManabarProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import { EManabarType } from "@hiveio/wax";
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for accounts with 90%+ RC manabar...");

bot.observe.onAccountsManabarPercent(EManabarType.RC, 90, "guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when either guest4test or guest4test1 reaches 90% RC manabar.
   * The callback receives data of type {@link IManabarProviderData}, which includes:
   * - `data.manabarData` - Contains manabar information for each monitored account
   * The callback receives data for all monitored accounts even if only one reaches the threshold.
   * The rest of the accounts will point to undefined so you should check for their existence before accessing their properties.
   */
  next(data) {
    if (data.manabarData.guest4test)
      console.log(`🔋 Account guest4test has ${data.manabarData.guest4test?.[EManabarType.RC]?.percent}% RC manabar!`);
  },
  error: console.error
});
```

#### onAccountsMetadataChange

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when any of the specified accounts updates their metadata.
You can observe multiple accounts in a single observer call.
XXX: Remember to update description here when this filter will provide some callback data

``` ts
/**
 * Category: 👤 Account Management
 * Demo: onAccountsMetadataChange() — watch accounts for metadata updates.
 *
 * This observer triggers when accounts update their profile data or other metadata via account_update operations.
 * Multiple account names can be observed at single observer call.
 *
 * Filter Function Inputs:
 * - `...accounts: TAccountName[]` - Account names to monitor for metadata changes
 *
 * There is no callback data for this observer.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for account metadata changes...");

bot.observe.onAccountsMetadataChange("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when guest4test or guest4test1 updates their account metadata.
   * Account metadata changes include profile updates.
   * There is no callback data for this observer - it simply notifies when any of monitored accounts change the metadata.
   */
  next() {
    console.log("👤 Account metadata changed");
  },
  error: console.error
});
```

#### onImpactedAccounts

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when any new blockchain operation affects one of the specified accounts (transfers, votes, mentions, etc.),
also when the account is just referenced by operation that has been authorized by another account, i.e. when alice voted on bob's comment, bob is also and impacted account.
You can monitor multiple accounts in both live and past data modes.
Remember to check if data for a specific account actually exists when observing multiple accounts.

``` ts
/**
 * Category: 👤 Account Management
 * Demo: onImpactedAccounts() — monitor all operations affecting accounts.
 *
 * This observer triggers when ANY operation affects the specified accounts
 * (transfers, votes received, mentions, follows, etc.). This provides comprehensive
 * account activity monitoring across all operation types.
 *
 * Filter Function Inputs:
 * - `...accounts: TAccountName[]` - Account names to monitor for any activity
 *
 * Callback Data:
 * The callback receives data of type {@link IImpactedAccountProviderData},
 * which is automatically deduced from the set of configured filters.
 * Collected operations are grouped by account to allow easy association to the impacted account.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for account impacts...");

bot.observe.onImpactedAccounts("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when guest4test or guest4test1 is affected by any blockchain operation.
   * The callback receives data of type {@link IImpactedAccountProviderData}, which includes:
   * - `data.impactedAccounts` - Contains operations that impacted each monitored account
   * Each account's data contains arrays of operation-transaction pairs affecting that account.
   * The callback receives data for all monitored accounts even if only one is impacted,
   * but the content for account that is not impacted will be undefined.
   */
  next(data) {
    data.impactedAccounts.guest4test?.forEach(({ operation }) => {
      console.log(`💥 Account guest4test impacted in operation: ${operation}`);
    });
  },
  error: console.error
});
```

#### onNewAccount

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when new accounts are created on the blockchain through account creation operations.
It monitors three types of account creation operations: `account_create_operation`, `account_create_with_delegation_operation`, and `create_claimed_account_operation`.
The filter requires no input parameters as it monitors all new account creations globally.
The callback data includes detailed information about each newly created account, including the account name, creator, authorities, and metadata.

``` ts
/**
 * Category: 👤 Account Management
 * Demo: onNewAccount() — monitor newly created accounts.
 *
 * This observer triggers when new accounts are created on the blockchain via
 * account_create or account_create_with_delegation operations. No input parameters
 * required as it monitors all new account creations.
 *
 * Filter Function Inputs:
 * - No parameters required (monitors all new account creations)
 *
 * Callback Data:
 * The callback receives data of type {@link INewAccountProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for new accounts...");

bot.observe.onNewAccount().subscribe({
  /*
   * This observer will trigger when any new account is created on the blockchain.
   * The callback receives data of type {@link INewAccountProviderData}, which includes:
   * - `data.newAccounts` - Array of newly created account data with account details
   * Each new account object contains information like accountName, creator, and creation details.
   */
  next(data) {
    data.newAccounts.forEach(account => {
      console.log(`👶 New account created: - ${account.accountName} by ${account.creator}`);
    });
  },
  error: console.error
});
```

### ⚙️ Blockchain Infrastructure

#### onBlockNumber

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when the blockchain reaches a specific block number.
It is useful for scheduled operations, testing scenarios, or waiting for governance proposals that become active at a particular block.
The filter takes a single block number parameter and monitors the blockchain until that exact block is produced.
The filter provides no callback data as it is designed to be a simple notification mechanism - if you need block details, combine it with block providers.
XXX: Add link to block provider

``` ts
/**
 * Category: ⚙️ Blockchain Infrastructure
 * Demo: onBlockNumber() — wait for a specific upcoming block number.
 *
 * This observer triggers when a specific block number is reached.
 * Useful for scheduled operations, testing, or waiting for governance proposals.
 *
 * Filter Function Inputs:
 * - `blockNumber: number` - The specific block number to wait for
 *
 * There is no callback data for this observer.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

// Wait for a future block (adjust this number as needed)
const targetBlock = 99999999;

console.log(`⏳ Waiting for block #${targetBlock}...`);

bot.observe.onBlockNumber(targetBlock).subscribe({
  /*
   * This observer will trigger when the blockchain reaches the specified block number.
   * Useful for scheduled operations, testing, or waiting for governance proposals.
   * There is no callback data for this observer - it simply notifies when the target block is reached.
   * The main concept of this observer is to monitor only head block number changes,
   * without a need to acquire whole block data (e.g. by using `block_api` calls).
   * This is why the block header data is also not available in the callback.
   */
  next() {
    console.log("🎯 Target block reached!");
  },
  error: console.error
});
```

#### onBlock

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers on every new block produced on the blockchain.
Unlike [`onBlockNumber`](#onblocknumber) which waits for a specific block number to be reached and then triggers once, `onBlock` continuously monitors the blockchain and triggers for every single block that gets produced.
It provides comprehensive block header data in the callback, making it perfect for real-time blockchain monitoring and applications that need to process every block.
The filter requires no input parameters.
When processing past data, it will trigger for each block in the specified range, allowing you to replay blockchain history.

``` ts
/**
 * Category: ⚙️ Blockchain Infrastructure
 * Demo: onBlock() — logs new block headers for a short duration.
 *
 * This is the foundational snippet that demonstrates WorkerBee's core concepts.
 * The observer triggers on every new block and provides comprehensive block header data.
 * No input parameters required as it monitors all blocks.
 *
 * Filter Function Inputs:
 * - No parameters required (monitors all new blocks)
 *
 * Callback Data:
 * The callback receives data of type {@link IBlockHeaderProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Listening for new blocks...");

bot.observe.onBlock().subscribe({
  /*
   * This observer will trigger on every new block produced on the blockchain.
   * The callback receives data of type {@link IBlockHeaderProviderData}, which includes:
   * - `data.block` - Contains complete block header information like id, number and timestamp
   */
  next(data) {
    console.log(`📦 Block #${data.block.number} id=${data.block.id} time=${data.block.timestamp}`);
  },
  error: console.error
});
```

#### onTransactionIds

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specific transaction IDs appear on the blocks distributed by blockchain.
It is particularly useful for tracking the inclusion of specific transactions in blocks, monitoring transaction confirmations, or building applications that need to react when certain transactions are processed.
You can monitor multiple transaction IDs simultaneously, and the filter will trigger when any of them appears on the blockchain.
The callback provides detailed transaction data for each monitored transaction ID, allowing you to access the full transaction content and metadata.

``` ts
/**
 * Category: ⚙️ Blockchain Infrastructure
 * Demo: onTransactionIds() — monitor specific transaction IDs.
 *
 * This observer triggers when specific transaction IDs appear on the blockchain.
 * Useful for tracking specific transactions and their inclusion in blocks.
 *
 * Filter Function Inputs:
 * - `...transactionIds: string[]` - Transaction IDs to monitor
 *
 * Callback Data:
 * The callback receives data of type {@link ITransactionProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

// You can access chain only after calling start method.
const tx = await bot.chain!.createTransaction();

// Push transfer operation to the transaction
tx.pushOperation({
  transfer_operation: {
    from: 'bob',
    to: 'alice',
    amount: bot.chain!.hbdSatoshis('1000'),
    memo: 'For dinner'
  }
});

// Get id and also legacy_id, since some wallets still implicitly sign transactions using legacy mode.
const id = tx.id;
const legacyId = tx.legacy_id;

console.log("⏳ Watching for specific transaction IDs...");

// Example transaction IDs (replace with actual ones)
bot.observe.onTransactionIds(id, legacyId).subscribe({
  /*
   * This observer will trigger when any of the specified transaction IDs appear on the blockchain.
   * The callback receives data of type {@link ITransactionProviderData}, which includes:
   * - `data.transactions` - Contains transaction data for each found transaction ID
   * All transaction IDs will be present in the data object, but those not found will have undefined values.
   * You should check for the existence of each transaction before accessing its properties when observing multiple IDs.
   */
  next(data) {
    if (data.transactions[id])
      console.log(`🔍 Transaction found: ${id}`);
  },
  error: console.error
});
```

### 🏦 Financial Operations

#### onAccountsBalanceChange

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when account balances change due to various financial operations on the blockchain.
It monitors all types of balance changes including incoming and outgoing transfers, author/curation rewards, witness rewards, power ups/downs, savings operations, and conversions.
The filter allows you to specify whether to include internal balance changes through the `includeInternal` parameter.
You can monitor multiple accounts simultaneously, making it perfect for portfolio tracking, payment processing, or automated financial applications.
XXX: Update description when callback data will be available

``` ts
/**
 * Category: 🏦 Financial Operations
 * Demo: onAccountsBalanceChange() — monitor account balance updates.
 *
 * This observer triggers when account balances change due to transfers, rewards,
 * or other financial operations. You can specify whether to include internal
 * balance changes and monitor multiple accounts.
 *
 * Filter Function Inputs:
 * - `includeInternal: boolean` - Whether to include internal balance changes
 * - `...accounts: TAccountName[]` - Account names to monitor for balance changes
 *
 * Callback Data:
 * There is no callback data for this observer.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for balance changes...");

bot.observe.onAccountsBalanceChange(true, "guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when guest4test or guest4test1 has a balance change.
   * Balance changes include transfers, rewards, power ups/downs, and savings operations.
   * There is no callback data for this observer - it simply notifies when the change in any of monitored accounts occurs.
   */
  next() {
    console.log("💰 Balance changed");
  },
  error: console.error
});
```

#### onExchangeTransfer

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when transfers involve known cryptocurrency exchange accounts on the Hive blockchain.
WorkerBee maintains an internal list of recognized exchange accounts and automatically monitors all transfer operations that either originate from or are directed to these exchanges.
XXX: `to` is not implemented yet
This is particularly useful for tracking market movements, analyzing trading patterns, detecting large deposits/withdrawals, or building exchange monitoring applications.
The filter requires no input parameters as it globally monitors all exchange-related transfers, making it ideal for market analysis and trading bot applications.
It provides detailed transfer data including amounts, sender/receiver information, and memo fields, allowing you to analyze exchange activity patterns.

``` ts
/**
 * Category: 🏦 Financial Operations
 * Demo: onExchangeTransfer() — monitor transfers to/from known exchanges.
 *
 * This observer triggers when transfers involve known exchange accounts.
 * WorkerBee maintains a list of known exchanges automatically, monitoring
 * both deposits to and withdrawals from these exchange accounts.
 *
 * Filter Function Inputs:
 * - No parameters required (monitors all transfers involving known exchanges)
 *
 * Callback Data:
 * The callback receives data of type {@link IExchangeTransferProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for exchange transfers...");

bot.observe.onExchangeTransfer().subscribe({
  /*
   * This observer will trigger when transfers involve known exchange accounts.
   * The callback receives data of type {@link IExchangeTransferProviderData}, which includes:
   * - `data.exchangeTransferOperations` - Array of transfer-operation pairs involving exchanges
   * Each transaction/operation contains transfer details with standard hive transfer properties.
   */
  next(data) {
    data.exchangeTransferOperations.forEach(({ operation }) => {
      console.log(`🏦 Exchange transfer: ${operation.from} -> ${operation.to} (${operation.amount})`);
    });
  },
  error: console.error
});
```

#### onFeedPriceChange

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when the Hive price feed changes by a specified percentage threshold.
It monitors the official price feed data published by witnesses and detects significant price movements that exceed your defined percentage threshold.
This is particularly useful for building trading bots, price alert systems, or applications that need to react to market volatility.
The filter allows you to set a custom percentage threshold (e.g., 5 for 5% change) to control the sensitivity of price change detection.
It's perfect for monitoring market conditions without constantly polling price data.
The filter is essential for financial applications that need to respond to significant price movements on the Hive blockchain.

``` ts
/**
 * Category: 🏦 Financial Operations
 * Demo: onFeedPriceChange() — monitor when feed price changes by percentage.
 *
 * This observer triggers when the Hive price feed changes by a specified percentage
 * threshold. Useful for monitoring significant market movements and price volatility.
 *
 * Filter Function Inputs:
 * - `percentThreshold: number` - Minimum percentage change required to trigger (e.g., 5 for 5%)
 *
 * Callback Data:
 * The callback receives no data.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for price changes (5%+)...");

bot.observe.onFeedPriceChange(5).subscribe({
  /*
   * This observer will trigger when the Hive price feed changes by 5% or more.
   * The callback receives no data.
   */
  next() {
    console.log("📈 Price changed by 5%+");
  },
  error: console.error
});
```

#### onFeedPriceNoChange

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when the Hive price feed remains completely unchanged for a specified number of hours.
Unlike [`onFeedPriceChange`](#onfeedpricechange) which detects price movements, this filter is designed to detect periods of price stability and low market volatility.
The filter monitors the price history feed data and checks if the exact same price value has been maintained for the specified duration.
This is particularly useful for detecting market stagnation, low trading volume periods, or identifying optimal times for certain trading strategies that work best in stable market conditions.
The filter accepts a parameter specifying the number of hours of required stability, with a default of 24 hours if no parameter is provided.

``` ts
/**
 * Category: 🏦 Financial Operations
 * Demo: onFeedPriceNoChange() — monitor when feed price stays stable.
 *
 * This observer triggers when the Hive price feed remains stable (unchanged)
 * for a specified number of hours. Useful for detecting periods of low volatility.
 *
 * Filter Function Inputs:
 * - `hours: number` - Number of hours of required price stability to trigger
 *
 * Callback Data:
 * The callback receives no data.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for price stability (24h+)...");

bot.observe.onFeedPriceNoChange(24).subscribe({
  /*
   * This observer will trigger when the Hive price feed remains stable for 24 hours.
   * The callback receives no data.
   */
  next() {
    console.log("🧊 Price stable for 24h");
  },
  error: console.error
});
```

#### onInternalMarketOperation

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when operations occur on Hive's built-in internal decentralized exchange (DEX) for HIVE ↔ HBD trading.
It monitors three specific types of market operations: limit order creation, order cancellation, and automatic order fills when orders are matched.
The internal market allows users to trade between HIVE and HBD (Hive Backed Dollars) directly on the blockchain without using external exchanges.
This filter is particularly useful for building market analysis tools, arbitrage bots, trading dashboards, or applications that need to track decentralized trading activity.
The filter requires no input parameters as it globally monitors all internal market operations, providing comprehensive coverage of the built-in DEX activity.

``` ts
/**
 * Category: 🏦 Financial Operations
 * Demo: onInternalMarketOperation() — monitor internal market activity.
 *
 * This observer monitors the Hive internal market for limit order creation,
 * cancellation, and order fills. Tracks HIVE ↔ HBD trading activity on the
 * built-in decentralized exchange.
 *
 * Filter Function Inputs:
 * - No parameters required (monitors all internal market operations)
 *
 * Callback Data:
 * The callback receives data of type {@link IInternalMarketProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for internal market operations...");

bot.observe.onInternalMarketOperation().subscribe({
  /*
   * This observer will trigger when internal market operations occur (order create/cancel/fill).
   * The callback receives data of type {@link IInternalMarketProviderData}, which includes:
   * - `data.internalMarketOperations` - Array of market transaction/operation pairs (create/cancel/fill)
   * Each transaction/operation follows either {@link IInternalMarketCreateOperation}.
   */
  next(data) {
    data.internalMarketOperations.forEach(({ operation }) => {
      console.log(`🏪 Market operation: ${operation.owner}, order ${operation.orderId}`);
    });
  },
  error: console.error
});
```

#### onWhaleAlert

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when large transfers exceed a specified amount threshold, making it perfect for monitoring significant financial movements on the Hive blockchain.
It monitors four specific types of transfer operations: regular transfers, transfers from savings, escrow transfers, and recurrent transfers.
The filter is commonly known as "whale watching" in crypto communities, as it helps detect when large holders (whales) move substantial amounts of cryptocurrency.
You can specify any asset type and amount threshold using the chain's helper methods like `bot.chain.hiveCoins(1000)`.
This filter is particularly useful for market analysis, detecting potential market-moving transactions, building trading alerts, or monitoring large account movements for security purposes.

``` ts
/**
 * Category: 🏦 Financial Operations
 * Demo: onWhaleAlert() — monitor large transfers above a threshold.
 *
 * This observer triggers when transfers exceed a specified amount threshold,
 * useful for monitoring large financial movements on the blockchain.
 * The threshold can be specified for any supported asset type.
 *
 * Filter Function Inputs:
 * - `threshold: asset` - Minimum transfer amount to trigger alert (use bot.chain.hiveCoins() or similar)
 *
 * Callback Data:
 * The callback receives data of type {@link IWhaleAlertProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

/*
 * Monitor transfers of 1000 HIVE or more
 * Remember that chain is available only after calling `start` method.
 */
const threshold = bot.chain!.hiveCoins(1000);

console.log("⏳ Watching for whale transfers (1000+ HIVE)...");

bot.observe.onWhaleAlert(threshold).subscribe({
  /*
   * This observer will trigger when any transfer exceeds the specified threshold amount.
   * The callback receives data of type {@link IWhaleAlertProviderData}, which includes:
   * - `data.whaleOperations` - Array of large transfer transaction-operation pairs exceeding the threshold
   * You can access each transaction/operation that contains details like from, to, amount, and memo.
   */
  next(data) {
    data.whaleOperations.forEach(({ operation }) => {
      console.log(`🐋 Whale alert: ${operation.from} -> ${operation.to} (${operation.amount})`);
    });
  },
  error: console.error
});
```

### 🔐 Security & Governance

#### onAlarm

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when monitored accounts experience security or governance-related situations that require attention.
It detects five specific alarm types: legacy recovery account configuration (accounts still using "steem" as recovery account from old blockchain), expired governance votes (accounts that haven't participated in governance for extended periods), upcoming governance vote expiration (within one month), active recovery account changes (during the 30-day waiting period), and accounts that have declined their voting rights.
The filter is essential for account security monitoring, governance participation tracking, and detecting potentially compromised or misconfigured accounts.
You can monitor multiple accounts simultaneously, making it perfect for wallet applications, account management tools, or security monitoring systems.

``` ts
/**
 * Category: 🔐 Security & Governance
 * Demo: onAlarm() — monitor governance and security alarms.
 *
 * This observer triggers on various governance and security events like recovery
 * account changes, governance votes, witness actions, and other security-related
 * operations. Multiple accounts can be monitored simultaneously.
 *
 * Filter Function Inputs:
 * - `...accounts: TAccountName[]` - Account names to monitor for security and governance events
 *
 * Callback Data:
 * The callback receives data of type {@link IAlarmAccountsData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for governance alarms...");

bot.observe.onAlarm("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when security or governance events occur for guest4test or guest4test1.
   * The callback receives data of type {@link IAlarmAccountsData}, which includes:
   * - `data.alarmsPerAccount` - Contains alarm information grouped by account
   * Each account's alarms follow the {@link TAlarmAccounts} structure with {@link EAlarmType} categorization.
   */
  next(data) {
    data.alarmsPerAccount.guest4test?.forEach(alarm => {
      console.log(`🚨 Governance alarm for guest4test: ${alarm}`);
    });
    data.alarmsPerAccount.guest4test1?.forEach(alarm => {
      console.log(`🚨 Governance alarm for guest4test1: ${alarm}`);
    });
  },
  error: console.error
});
```

#### onWitnessesMissedBlocks

**🟢 Live Mode Only** - This filter requires real-time blockchain data and is not available in past data mode.

This filter triggers when specified witness accounts miss a threshold number of consecutive blocks during their scheduled block production turns.
It monitors witness performance by tracking the `totalMissedBlocks` counter and `lastConfirmedBlockNum` to detect when witnesses fail to produce blocks when they're supposed to.
The filter is essential for network health monitoring, witness performance analysis, and detecting potential issues with witness nodes (server downtime, connectivity problems, or configuration issues).
It intelligently resets its tracking when a witness successfully produces a block again, preventing duplicate notifications for the same missed block streak.
You can monitor multiple witnesses simultaneously with different threshold values, making it perfect for witness monitoring dashboards, alerting systems, or blockchain infrastructure monitoring tools.

``` ts
/**
 * Category: 🔐 Security & Governance
 * Demo: onWitnessesMissedBlocks() — monitor when witnesses miss blocks.
 *
 * This observer triggers when specified witnesses miss a certain number of blocks.
 * Essential for monitoring network health and witness performance. Can track
 * multiple witnesses simultaneously.
 *
 * Filter Function Inputs:
 * - `missedCount: number` - Number of missed blocks required to trigger
 * - `...witnesses: TAccountName[]` - Witness account names to monitor for missed blocks
 *
 * Callback Data:
 * There is no callback data for this observer.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for witnesses missing blocks...");

bot.observe.onWitnessesMissedBlocks(1, "guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when guest4test or guest4test1 (as witnesses) miss 1 or more blocks.
   * This filter monitors witness performance and network health by tracking missed block production.
   * There is no callback data for this observer - it simply notifies when the threshold is reached.
   */
  next() {
    console.log("🧭 A witness has missed blocks");
  },
  error: console.error
});
```

### 👥 Social & Content

#### onCommentsIncomingPayout

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when **replies/comments** (not top-level posts) by specified authors are approaching their payout window expiration, allowing you to monitor engagement performance before final reward distribution.
On the Hive blockchain, comments have a 7-day payout window after creation, and this filter detects when they're nearing that critical payout moment.
The filter specifically monitors replies to posts or other comments (content with a non-empty `parent_author` field), distinguishing them from top-level posts.
You can specify a relative time offset (like "-30m" for 30 minutes before payout or "-1h" for 1 hour before) to receive notifications at your preferred timing.
This is particularly useful for content creators, curators, or applications that need to take action before payout finalization - such as last-minute promotion, vote adjustments, or performance analytics.
You can monitor multiple authors simultaneously, making it perfect for content management dashboards, curation tools, or automated content promotion systems.
Remember that you need to collect past operations to access old posts and comments to monitor their payout right after starting the application.

**Note:** For monitoring top-level posts approaching payout, use [`onPostsIncomingPayout`](#onpostsincomingpayout) instead.

``` ts
/**
 * Category: 👥 Social & Content
 * Demo: onCommentsIncomingPayout() — monitor replies/comments near payout window.
 *
 * This observer triggers when replies/comments (not top-level posts) by specified authors are approaching their
 * payout window (7 days after creation). Useful for monitoring engagement performance
 * before final payout. Multiple authors can be monitored simultaneously.
 *
 * Filter Function Inputs:
 * - `relative: string` - Time window specification (e.g., "-30m" for last 30 minutes before payout)
 * - `...authors: TAccountName[]` - Author account names to monitor for upcoming comment payouts
 *
 * Callback Data:
 * The callback receives data of type {@link ICommentMetadataProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for comments near payout...");

bot.observe.onCommentsIncomingPayout("-30m", "guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when comments by guest4test or guest4test1 are 30 minutes away from payout.
   * The callback receives data of type {@link ICommentMetadataProviderData}, similar to the structure used in other comment-related events.
   */
  next(data) {
    for(const account in data.commentsMetadata)
      if(data.commentsMetadata[account] !== undefined)
        for(const permlink in data.commentsMetadata[account])
          console.log(`⏰ Comment about to payout: @${account}/${permlink}`);
  },
  error: console.error
});
```

#### onComments

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specified authors create new comments on the Hive blockchain. Top level posts are ignored by this filter.
Comments are replies to posts or other comments, distinguished from posts by having a non-empty `parent_author` field in the underlying `comment_operation`.
The filter monitors all comment creation activity and provides detailed comment data in the callback, including operation details like author, permlink, parent information, and content metadata.
You can monitor multiple authors simultaneously, making it perfect for content moderation tools, engagement tracking systems, discussion monitoring applications, or building comment notification services.
It's particularly useful for building social media applications, content curation tools, or automated response systems that need to react to new comment activity.

``` ts
/**
 * Category: 👥 Social & Content
 * Demo: onComments() — log new comments by authors.
 *
 * This observer monitors new comment creation on the Hive blockchain. Filters by
 * specific author account names and captures replies to posts and nested comment
 * threads. Multiple authors can be monitored at single observer call.
 *
 * Filter Function Inputs:
 * - `...authors: TAccountName[]` - Author account names to monitor for new comments
 *
 * Callback Data:
 * The callback receives data of type {@link ICommentProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for new comments...");

bot.observe.onComments("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when guest4test or guest4test1 creates a new comment.
   * See on-posts.ts for more details on how observing comment_operation works.
   * In this case, the callback will occur for comment_operation with not empty parent_author property.
   */
  next(data) {
    if (data.comments.guest4test)
      data.comments.guest4test?.forEach(({ operation }) => {
        console.log(`💬 New comment by guest4test: ${operation.author}/${operation.permlink}`);
      });
  },
  error: console.error
});
```

#### onCustomOperation

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when custom JSON operations with specified operation IDs appear on the Hive blockchain.
Custom operations are the primary mechanism for decentralized applications (dApps), games, and services to extend Hive's functionality with their own custom logic and data structures.
The filter monitors both `custom_json_operation` and `custom_operation` types, allowing you to track specific application protocols by their unique identifiers.
Popular examples include gaming operations like Splinterlands rewards ("sm_claim_reward"), community actions ("community"), or any other dApp-specific functionality.
You can monitor multiple operation IDs simultaneously, making it perfect for building application-specific monitoring tools, analytics dashboards, bot automation systems, or cross-platform dApp integration services.
It's essential for developers building on Hive who need to track their own custom operations or monitor activity from other applications in the ecosystem.

**Note:** For social interactions like "follow" and "reblog", use the specialized [`onFollow`](#onfollow) and [`onReblog`](#onreblog) filters instead, which provide more targeted functionality and enhanced data.

``` ts
/**
 * Category: 👥 Social & Content
 * Demo: onCustomOperation() — monitor custom JSON operations by ID.
 *
 * This observer triggers when custom_json operations with specified IDs occur.
 * Used extensively by dApps and games like Splinterlands, PeakD, and other
 * applications building on Hive. Multiple operation IDs can be monitored simultaneously.
 *
 * Filter Function Inputs:
 * - `...ids: Array<string | number>` - Custom operation IDs to monitor (e.g., "community", "sm_claim_reward")
 *
 * Callback Data:
 * The callback receives data of type {@link ICustomOperationProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for custom operations...");

bot.observe.onCustomOperation("community", "sm_claim_reward").subscribe({
  /*
   * This observer will trigger when custom operations with the specified IDs occur.
   * The callback receives data of type {@link ICustomOperationProviderData}, which includes:
   * - `data.customOperations` - Contains custom operations grouped by operation name
   * Each operation contains an array with transaction/operation pairs.
   *
   * Note: For "follow" and "reblog" operations, use specialized onFollow() and onReblog() filters instead.
   */
  next(data) {
    if (data.customOperations.community)
      data.customOperations.community.forEach(({ operation }) => {
        console.log(`🔧 Community operation detected: ${operation}`);
      });

    if (data.customOperations.sm_claim_reward)
      console.log(`🔧 Splinterlands reward claims detected: ${data.customOperations.sm_claim_reward.length}`);
  },
  error: console.error
});
```

#### onFollow

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specified accounts perform social relationship operations on the Hive blockchain, including following, unfollowing, muting, and blacklisting other accounts.
The filter monitors custom JSON operations with the "follow" ID, which contain the social graph interaction data that powers Hive's decentralized social networking features.
It tracks various relationship types through the `what` field in the operation, supporting actions like "blog" (follow), "mute", "blacklist", and their corresponding removal operations.
These operations are fundamental to Hive's social layer, allowing users to build their feeds, manage unwanted content, and create curated social experiences.
You can monitor multiple accounts simultaneously, making it perfect for building social analytics tools, relationship tracking dashboards, follower notification systems, or automated social interaction bots.
It's essential for applications that need to track social dynamics, build recommendation systems, or provide users with insights about their social network activity.

``` ts
/**
 * Category: 👥 Social & Content
 * Demo: onFollow() — watch follow/mute/blacklist events emitted by accounts.
 *
 * This observer monitors social graph changes on the Hive blockchain including
 * follow actions, mute actions, and blacklist actions. Tracks relationship changes
 * between accounts. Multiple accounts can be monitored simultaneously.
 *
 * Filter Function Inputs:
 * - `...accounts: TAccountName[]` - Account names to monitor for follow/mute/blacklist activity
 *
 * Callback Data:
 * The callback receives data of type {@link IFollowProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for follow events...");

bot.observe.onFollow("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when guest4test or guest4test1 performs follow/mute/blacklist actions.
   * The callback receives data of type {@link IFollowProviderData}, which includes:
   * - `data.follows` - Contains follow transaction/operation pairs grouped by account
   * Remember to check if follows for specific account actually exist when observing multiple accounts.
   */
  next(data) {
    if (data.follows.guest4test)
      data.follows.guest4test?.forEach(({ operation }) => {
        console.log(`🧭 Follow event by guest4test: @${operation.follower} -> @${operation.following} (${operation.what})`);
      });
  },
  error: console.error
});
```

#### onMention

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specified accounts are mentioned in posts or comments using the standard @username syntax on the Hive blockchain.
The filter scans the text content of all posts and comments to detect username mentions and match them against your monitored account list.
It processes both new posts (top-level content) and comments (replies), providing comprehensive mention detection across all content types on the platform.
The filter is essential for building notification systems, social engagement tools, and automated response applications that need to react when specific users are mentioned in discussions.
You can monitor multiple accounts simultaneously, making it perfect for community management tools, brand monitoring applications, or personal notification services.
It's particularly valuable for social media managers, content creators, and businesses who need to stay informed about when their accounts or brands are being discussed in the Hive community.

``` ts
/**
 * Category: 👥 Social & Content
 * Demo: onMention() — detect account mentions in posts/comments.
 *
 * This observer monitors when specific accounts are mentioned in post and comment
 * content using @username syntax. Essential for social engagement applications
 * and notification systems. Multiple accounts can be monitored simultaneously.
 *
 * Filter Function Inputs:
 * - `...accounts: TAccountName[]` - Account names to monitor for mentions
 *
 * Callback Data:
 * The callback receives data of type {@link IMentionedAccountProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for mentions...");

bot.observe.onMention("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when guest4test or guest4test1 is mentioned in content.
   * The callback receives data of type {@link IMentionedAccountProviderData}, which includes:
   * - `data.mentioned` - Contains mention instances (comment_operation) grouped by mentioned account
   * Remember to check if mentions for specific account actually exist when observing multiple accounts.
   */
  next(data) {
    data.mentioned.guest4test?.forEach(comment => {
      console.log(`📣 @guest4test mentioned by @${comment.author}`);
    });
    data.mentioned.guest4test1?.forEach(comment => {
      console.log(`📣 @guest4test1 mentioned by @${comment.author}`);
    });
  },
  error: console.error
});
```

#### onPostsIncomingPayout

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when **top-level posts** (not replies/comments) by specified authors are approaching their payout window expiration, allowing you to monitor content performance before final reward distribution.
On the Hive blockchain, posts have a 7-day payout window after creation, and this filter detects when they're nearing that critical payout moment.
The filter specifically monitors top-level posts (content with an empty `parent_author` field), distinguishing them from replies and comments.
You can specify a relative time offset (like "-30m" for 30 minutes before payout or "-1h" for 1 hour before) to receive notifications at your preferred timing.
This is particularly useful for content creators, curators, or applications that need to take action before payout finalization - such as last-minute promotion, vote adjustments, or performance analytics.
You can monitor multiple authors simultaneously, making it perfect for content management dashboards, curation tools, or automated content promotion systems.
Remember that you need to collect past operations to access old posts and comments to monitor their payout right after starting the application.

**Note:** For monitoring replies/comments approaching payout, use [`onCommentsIncomingPayout`](#oncommentsincomingpayout) instead.

``` ts
/**
 * Category: 👥 Social & Content
 * Demo: onPostsIncomingPayout() — monitor top-level posts near payout window.
 *
 * This observer triggers when top-level posts (not replies/comments) by specified authors are approaching their
 * payout window (7 days after creation). Useful for monitoring content performance
 * before final payout. Multiple authors can be monitored simultaneously.
 *
 * Filter Function Inputs:
 * - `relative: string` - Time window specification (e.g., "-1h" for last hour before payout)
 * - `...authors: TAccountName[]` - Author account names to monitor for upcoming payouts
 *
 * Callback Data:
 * The callback receives data of type {@link IPostMetadataProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for posts near payout...");

bot.observe.onPostsIncomingPayout("-1h", "guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when posts by guest4test or guest4test1 are 1 hour away from payout.
   * The callback receives data of type {@link IPostMetadataProviderData}, similar to the structure used in other post-related events.
   */
  next(data) {
    for(const account in data.postsMetadata)
      if(data.postsMetadata[account] !== undefined)
        for(const permlink in data.postsMetadata[account])
          console.log(`⏰ Post about to payout: @${account}/${permlink}`);
  },
  error: console.error
});
```

#### onPosts

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specified authors create new posts on the Hive blockchain. Replies (comments) to posts are ignored by this filter.
Posts are top-level content pieces, distinguished from comments by having an empty `parent_author` field in the underlying `comment_operation`.
The filter monitors all post creation activity and provides detailed post data in the callback, including operation details like author, permlink, title, body, and content metadata.
You can monitor multiple authors simultaneously, making it perfect for content aggregation platforms, feed generation systems, blog monitoring applications, or building post notification services.
It's particularly useful for building social media applications, content curation tools, or automated promotion systems that need to react to new post publications.

``` ts
/**
 * Category: 👥 Social & Content
 * Demo: onPosts() — monitor new posts by specific authors.
 *
 * This observer monitors new post creation on the Hive blockchain. Filters by
 * specific author account names and captures complete operations/transactions.
 * Multiple authors can be monitored at single observer call.
 *
 * Filter Function Inputs:
 * - `...authors: TAccountName[]` - Author account names to monitor for new posts
 *
 * Callback Data:
 * The callback receives data of type {@link IPostProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for new posts...");

bot.observe.onPosts("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when guest4test or guest4test1 creates a new post.
   * The callback receives data of type {@link IPostProviderData}, which includes:
   * - `data.posts` - Contains post operations/transactions (hive comment_operation with empty parent_author property)
   * Remember to check if content for specific author actually exists when observing multiple authors.
   */
  next(data) {
    if (data.posts.guest4test)
      data.posts.guest4test.forEach(({ operation }) => {
        console.log(`📝 New post by guest4test: ${operation.author}/${operation.permlink}`);
      });

  },
  error: console.error
});
```

#### onReblog

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter triggers when specified accounts reblog (share/repost) content on the Hive blockchain.
Reblogs are a social sharing mechanism that allows users to reshare posts from other authors to their own feed, helping content reach a wider audience through the social network.
The filter monitors custom JSON operations with the "follow" ID that contain reblog actions, tracking when users share content they find valuable or interesting.
Reblogging is fundamental to content discovery and viral spread on Hive, allowing quality content to gain visibility beyond the original author's followers.
You can monitor multiple accounts simultaneously, making it perfect for building content distribution analytics, engagement tracking systems, influencer monitoring tools, or automated content promotion platforms.
The filter works with both live and past data modes, enabling real-time reblog monitoring and historical analysis of content sharing patterns.
It's particularly useful for understanding content virality, measuring influence networks, tracking brand mentions through shares, or building recommendation systems based on social sharing behavior.

``` ts
/**
 * Category: 👥 Social & Content
 * Demo: onReblog() — watch reblog actions by accounts.
 *
 * This observer monitors when accounts reblog (share/repost) content. Captures
 * both the reblogger and original author information for content distribution
 * analysis. Multiple accounts can be monitored simultaneously.
 *
 * Filter Function Inputs:
 * - `...accounts: TAccountName[]` - Account names to monitor for reblog activity
 *
 * Callback Data:
 * The callback receives data of type {@link IReblogProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for reblogs...");

bot.observe.onReblog("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when guest4test or guest4test1 reblogs content.
   * The callback receives data of type {@link IReblogProviderData}, which includes:
   * - `data.reblogs` - Contains reblog (comment_operation) transaction/operation pairs grouped by reblogger account
   * Remember to check if reblogs for specific account actually exist when observing multiple accounts.
   */
  next(data) {
    data.reblogs.guest4test?.forEach(({ operation }) => {
      console.log(`🔁 guest4test reblogged: @${operation.author}/${operation.permlink}`);
    });
  },
  error: console.error
});
```

#### onVotes

**🔵 Live and Past Data Modes** - This filter is available in both live and past data modes.

This filter monitors voting activity on the Hive blockchain, triggering when specified accounts cast votes on posts or comments. It tracks both upvotes and downvotes, providing complete voting operation details including vote weights, target content, and transaction information. The filter supports monitoring multiple voters simultaneously and provides voting data organized by voter account.

The filter captures all vote operations including upvotes, downvotes, and vote deletions (zero weight votes). Each vote operation contains information about the voter, target author/permlink, vote weight, and associated blockchain transaction. This enables comprehensive tracking of content curation activities, voting patterns, and community engagement behaviors.

Key capabilities include:

- **Real-time vote monitoring**: Tracks voting activity as it happens on the blockchain
- **Multi-voter support**: Monitor voting activity from multiple accounts in a single observer
- **Complete vote data**: Access to vote weight, target content, voter information, and transaction details
- **Vote type detection**: Distinguish between upvotes, downvotes, and vote deletions
- **Manabar consumption tracking**: Monitor voting manabar and downvoting manabar usage

It's particularly useful for building content curation dashboards, vote tracking systems, community engagement analytics, and voting behavior analysis tools.

``` ts
/**
 * Category: 👥 Social & Content
 * Demo: onVotes() — monitor voting activity by specific accounts.
 *
 * This observer monitors voting activity on the Hive blockchain. Tracks upvotes
 * and downvotes by specific accounts with detailed voting information including
 * vote weight and target content. Multiple voters can be monitored simultaneously.
 *
 * Filter Function Inputs:
 * - `...voters: TAccountName[]` - Voter account names to monitor for voting activity
 *
 * Callback Data:
 * The callback receives data of type {@link IVoteProviderData},
 * which is automatically deduced from the set of configured filters.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Watching for votes...");

bot.observe.onVotes("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger when guest4test or guest4test1 casts a vote.
   * The callback receives data of type {@link IVoteProviderData}, which includes:
   * - `data.votes` - Contains vote transaction/operation pairs grouped by voter
   * Remember to check if votes for specific voter actually exist when observing multiple voters.
   */
  next(data) {
    if (data.votes.guest4test)
      data.votes.guest4test?.forEach(({ operation }) => {
        console.log(`👍 @guest4test voted: ${operation.author}/${operation.permlink} (weight: ${operation.weight})`);
      });
  },
  error: console.error
});
```

## Providers

**Data Mode Availability:**

- **🟢 Live Mode Only** - These providers require real-time blockchain data and are only available when using `workerbee.observe`
- **🔵 Live and Past Data Modes** - These providers work with both live data (`workerbee.observe`) and historical data (`workerbee.providePastOperations()`)

Providers are specialized data suppliers that enhance WorkerBee filters by delivering enriched blockchain data directly to your observer callbacks. While filters detect specific events or conditions on the blockchain, providers add contextual data and detailed information about accounts, transactions, blocks, and other blockchain entities.

Providers automatically integrate with filters and deliver their data through the same subscription callback, eliminating the need for separate API calls. This creates a seamless development experience where you can access both event notifications and related data in a single observer. They also are able to reuse already acquired data by filters if possible and avoid additional queries. What's important to note, they start to work only when filter condition matches.

### 👤 Account Data Providers

#### provideAccounts

**🟢 Live Mode Only** - This provider requires real-time blockchain data and is not available in past data mode.

This provider extends the data passed to specified callback function by comprehensive account information for specified accounts.
It retrieves detailed account data including balances, voting power, profile metadata, and recovery account.
The provider automatically fetches current account state data and delivers it alongside your filter results.
You can specify multiple accounts to monitor simultaneously, making it perfect for portfolio tracking, account management applications, or social media dashboards.
The provider is essential for applications that need detailed user information, wallet interfaces, or account analysis tools.

``` ts
/**
 * Category: 👤 Account Data Providers
 * Demo: provideAccounts() — provide comprehensive account information for specified accounts.
 *
 * This provider enriches your filter data with detailed account information including balances,
 * voting power, profile metadata, and recovery account.
 * Multiple account names can be provided in a single provider call.
 *
 * Provider Function Inputs:
 * - `...accounts: TAccountName[]` - Account names to provide data for
 *
 * Callback Data:
 * The callback receives data of type {@link IAccountProviderData},
 * which is automatically deduced from the set of configured providers.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Monitoring blocks with account data...");

bot.observe.onBlock().provideAccounts("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger on each new block and provide account data.
   * The callback receives data that includes both block information and account details.
   * Account data includes balances, voting power, and other account properties.
   */
  next(data) {
    console.log("Block:", data.block.number);
    console.log("Account 1 data:", data.accounts["guest4test"]);
    console.log("Account 2 data:", data.accounts["guest4test1"]);
  },
  error: console.error
});
```

#### provideManabarData

**🟢 Live Mode Only** - This provider requires real-time blockchain data and is not available in past data mode.

This provider delivers detailed manabar information for specified accounts and manabar types.
It provides real-time data about account resource usage including current mana levels, last update time, and percentage capacity.
The provider supports all three manabar types: upvote, downvote, and resource credits (RC).
Manabar data is crucial for applications that need to manage account resources efficiently or provide users with resource usage insights.
You can monitor multiple accounts simultaneously, making it perfect for account management tools, automated posting applications, or resource optimization systems.

``` ts
/**
 * Category: 👤 Account Data Providers
 * Demo: provideManabarData() — provide detailed manabar information for specified accounts.
 *
 * This provider delivers comprehensive manabar data including current levels, last update time,
 * and percentage capacity for specified accounts and manabar types.
 * Multiple accounts can be monitored simultaneously.
 *
 * Provider Function Inputs:
 * - `manabarType: EManabarType` - The type of manabar to monitor (RC, UPVOTE, or DOWNVOTE)
 * - `...accounts: TAccountName[]` - Account names to provide manabar data for
 *
 * Callback Data:
 * The callback receives data of type {@link IManabarProviderData},
 * which is automatically deduced from the set of configured providers.
 */
import { EManabarType } from "@hiveio/wax";
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Monitoring manabar data...");

bot.observe.onBlock().provideManabarData(EManabarType.UPVOTE, "guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger on each new block and provide manabar data.
   * The callback receives manabar information for the specified accounts and manabar type.
   * Manabar data includes current mana, max mana, and percentage values.
   */
  next(data) {
    for (const account in data.manabarData) {
      const rcData = data.manabarData[account]?.[EManabarType.UPVOTE];

      if (rcData)
        console.log(`${account} upvote manabar: ${rcData.percent}% (${rcData.current_mana}/${rcData.max_mana})`);
    }
  },
  error: console.error
});
```

#### provideRcAccounts

**🟢 Live Mode Only** - This provider requires real-time blockchain data and is not available in past data mode.

This provider supplies comprehensive resource credit (RC) account information for specified accounts.
It delivers detailed RC system data including current RC balance, maximum capacity, and last update time.
The provider gives access to advanced RC metrics that are essential for applications managing blockchain resource consumption.
Resource credits are fundamental to Hive's bandwidth system, determining how many operations accounts can perform without fees.
You can monitor multiple accounts simultaneously, making it perfect for account management tools, resource optimization applications, or automated systems that need to track RC usage.

``` ts
/**
 * Category: 👤 Account Data Providers
 * Demo: provideRcAccounts() — provide comprehensive RC account information.
 *
 * This provider delivers detailed resource credit system data including current balance,
 * maximum capacity, regeneration rates, and last update time for specified accounts.
 * Multiple accounts can be monitored simultaneously.
 *
 * Provider Function Inputs:
 * - `...accounts: TAccountName[]` - Account names to provide RC data for
 *
 * Callback Data:
 * The callback receives data of type {@link IRcAccountProviderData},
 * which is automatically deduced from the set of configured providers.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Monitoring RC account data...");

bot.observe.onBlock().provideRcAccounts("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger on each new block and provide RC account data.
   * The callback receives detailed resource credit information for the specified accounts.
   * RC data includes current balance, maximum capacity, and last update time.
   */
  next(data) {
    for (const account in data.rcAccounts) {
      const rcData = data.rcAccounts[account];

      if (rcData)
        console.log(`${account} RC details:`, rcData);
    }
  },
  error: console.error
});
```

#### provideWitnesses

**🟢 Live Mode Only** - This provider requires real-time blockchain data and is not available in past data mode.

This provider delivers comprehensive witness information for specified witness accounts.
It provides detailed witness data including owner, version and block production performance.
The provider gives access to witness performance metrics, like missed block counts that are essential for monitoring network infrastructure.
Witnesses are the block producers on the Hive blockchain, and their performance directly affects network security and stability.
You can monitor multiple witnesses simultaneously, making it perfect for witness monitoring dashboards, network health analysis tools, or voting decision applications.

``` ts
/**
 * Category: 👤 Account Data Providers
 * Demo: provideWitnesses() — provide comprehensive witness information.
 *
 * This provider delivers detailed witness data including owner, version and block production performance.
 * Multiple witnesses can be monitored simultaneously.
 *
 * Provider Function Inputs:
 * - `...witnesses: TAccountName[]` - Witness names to provide data for
 *
 * Callback Data:
 * The callback receives data of type {@link IWitnessProviderData},
 * which is automatically deduced from the set of configured providers.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Monitoring witness data...");

bot.observe.onBlock().provideWitnesses("guest4test", "guest4test1").subscribe({
  /*
   * This observer will trigger on each new block and provide witness data.
   * The callback receives comprehensive witness information including performance metrics for the specified witnesses.
   */
  next(data) {
    for (const witness in data.witnesses) {
      const witnessData = data.witnesses[witness];
      if (witnessData)
        console.log(`Witness ${witness}:`, witnessData);
      }
  },
  error: console.error
});
```

### ⚙️ Blockchain Data Providers

#### provideBlockData

**🔵 Live and Past Data Modes** - This provider is available in both live and past data modes.

This provider delivers comprehensive block information including both block header (already collected by onBlock filter) and full block data (like all included transactions).
It provides detailed block content including all transactions, operations, witness signatures, and block metadata.
The provider combines block header data (block number, timestamp, witness) with complete block content for comprehensive blockchain monitoring.
Block data is fundamental for applications that need to process all blockchain activity or analyze transaction patterns.
The provider automatically delivers block information with your filter results, eliminating the need for separate block API calls.

``` ts
/**
 * Category: ⚙️ Blockchain Data Providers
 * Demo: provideBlockData() — provide comprehensive block information.
 *
 * This provider delivers complete block data including header information and full block content
 * with all transactions, operations, and witness signatures.
 * Block data includes comprehensive blockchain state information.
 *
 * Provider Function Inputs:
 * - No parameters required
 *
 * Callback Data:
 * The callback receives data of type {@link IBlockProviderData},
 * which is automatically deduced from the set of configured providers.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Monitoring blocks with full data...");

bot.observe.onBlock().provideBlockData().subscribe({
  /*
   * This observer will trigger on each new block and provide complete block data.
   * The callback receives comprehensive block information including all transactions
   * and operations contained within the block.
   */
  next(data) {
    console.log(`Block ${data.block.number} by @${data.block.witness}`);
    console.log(`Transactions: ${data.block.transactions.length}`);
    console.log(`Timestamp: ${data.block.timestamp}`);
  },
  error: console.error
});
```

#### provideBlockHeaderData

**🔵 Live and Past Data Modes** - This provider is available in both live and past data modes.

This provider supplies essential block header information including block number, timestamp, witness, and basic block metadata.
It provides lightweight block data that is perfect for applications that need block timing and identification information without the overhead of full block content.
Block header data includes critical blockchain timing information and witness rotation details that are essential for many blockchain applications.
The provider delivers header information efficiently, making it ideal for high-frequency monitoring applications or resource-constrained environments.
It automatically integrates with your filters, providing block context alongside event notifications.

``` ts
/**
 * Category: ⚙️ Blockchain Data Providers
 * Demo: provideBlockHeaderData() — provide essential block header information.
 *
 * This provider delivers lightweight block header data including block number, timestamp,
 * witness, and basic metadata without the overhead of full block content.
 * Header data provides essential timing and identification information.
 *
 * Provider Function Inputs:
 * - No parameters required
 *
 * Callback Data:
 * The callback receives data of type {@link IBlockHeaderProviderData},
 * which is automatically deduced from the set of configured providers.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Monitoring block headers...");

bot.observe.onPosts("guest4test").provideBlockHeaderData().subscribe({
  /*
   * This observer will trigger when account guest4test creates a new post and provide block header data.
   * The callback receives essential block timing and identification information
   * without the overhead of full block content processing.
   * This will allow to get for example the time when the post was created.
   */
  next(data) {
    data.posts["guest4test"]?.forEach(({ operation }) => {
      console.log(
        `New post created: ${operation.author}/${operation.permlink}. Creation date: ${data.block.timestamp.toISOString()}`
      );
    });
  },
  error: console.error
});
```

### 🏦 Financial Data Providers

#### provideFeedPriceData

**🟢 Live Mode Only** - This provider requires real-time blockchain data and is not available in past data mode.

This provider delivers comprehensive HIVE price feed information including current prices, price history, and statistical price data.
It provides access to the official witness-published price feeds that determine HIVE-to-HBD conversion rates on the blockchain.
The provider supplies current median, minimum, and maximum price values along with historical price data for trend analysis.
Price feed data is essential for financial applications, trading bots, conversion calculators, and economic analysis tools.
The provider delivers real-time price information alongside your filter results, enabling applications to react to both events and current market conditions.

``` ts
/**
 * Category: 🏦 Financial Data Providers
 * Demo: provideFeedPriceData() — provide comprehensive HIVE price feed information.
 *
 * This provider delivers complete price feed data including current prices, historical data,
 * and statistical price information from witness-published feeds.
 * Price data includes median, minimum, and maximum values with historical trends.
 *
 * Provider Function Inputs:
 * - No parameters required
 *
 * Callback Data:
 * The callback receives data of type {@link IFeedPriceProviderData},
 * which is automatically deduced from the set of configured providers.
 */
import WorkerBee from "@hiveio/workerbee";

const bot = new WorkerBee();
await bot.start();

console.log("⏳ Monitoring with price feed data...");

bot.observe.onBlock().provideFeedPriceData().subscribe({
  /*
   * This observer will trigger on each new block and provide price feed data.
   * The callback receives comprehensive price information including current rates,
   * historical data, and statistical price metrics from witness feeds.
   */
  next(data) {
    console.log("Current HIVE price:", data.feedPrice.currentMedianHistory);
    console.log("Price range:", data.feedPrice.currentMinHistory, "-", data.feedPrice.currentMaxHistory);
  },
  error: console.error
});
```
