---
order: -2
icon: gear
label: Configuration
---

# Base Configuration

Configure WorkerBee for different environments and use cases.

## :wrench: Basic Configuration

### WorkerBee Config Interface

+++ JavaScript

```typescript
export interface IStartConfiguration {
  /**
   * Wax chain options
   */
  chainOptions?: Partial<{
    /**
     * Endpoint for all of the API requests
     *
     * @default "https://api.hive.blog/"
     * @type {string}
     */
    apiEndpoint: string;
    /**
     * Endpoint for all of the REST API requests
     *
     * @default "https://api.syncad.com"
     * @type {string}
     */
    restApiEndpoint: string;
    /**
     * Timeout for all of the API requests in milliseconds.
     * Set to 0 to disable timeout
     *
     * @default 2_000
     * @type {number}
     */
    apiTimeout: number;
  }>;

  /**
   * Explicit instance of chain interface to be used by workerbee.
   * This option is exclusive to chainOptions
   */
  explicitChain?: IHiveChainInterface;
}
```

+++ Python

TBA

+++

## :satellite: API Endpoint Configuration

### Popular Hive API Endpoints

You can find a full list of Hive API endpoints in the [official Hive documentation](https://developers.hive.io/quickstart/#quickstart-hive-full-nodes)
and then choose the one that best fits your needs:

+++ JavaScript

```typescript:highlight="5-7"
import { WorkerBee } from "@hiveio/workerbee";

// Choose based on your location and requirements
const bot = new WorkerBee({
  chainOptions: {
    apiEndpoint: 'https://api.openhive.network'
  }
});

await bot.start();
```

+++ Python

TBA

+++

## :clock3: Timing Configuration

### Timeout Configuration

Sometimes you need to adjust the timeout settings based on your network conditions:

+++ JavaScript

```typescript:highlight="6"
import { WorkerBee } from "@hiveio/workerbee";

// Choose based on your location and requirements
const bot = new WorkerBee({
  chainOptions: {
    apiTimeout: 0
  }
});

await bot.start();
```

+++ Python

TBA

+++

Setting `apiTimeout` to `0` disables the timeout, which can be useful for long-running requests or low-quality networks.

## :ringed_planet: Wax chain usage

As shown in the [WorkerBee Config Interface](#workerbee-config-interface), you can provide an explicit chain that will be used for performing all API calls and data transformations. The Wax Chain instance is also accessible via the `chain` property on the WorkerBee instance.

If an explicit chain is not provided (which is optional), a default chain instance will be created when the `start` method is called.

!!!warning
Remember that before starting the bot, if no explicit chain was provided, the `chain` property will be undefined.
!!!
