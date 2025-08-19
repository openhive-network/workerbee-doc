---
order: -2
icon: gear
label: Configuration
---

# :gear: Base Configuration

Configure WorkerBee for different environments and use cases. The configuration system allows you to customize behavior, performance, and data sources.

## :wrench: Basic Configuration

### WorkerBeeConfig Interface

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

### Default Configuration

```typescript
import { WorkerBee } from '@hiveio/workerbee';

// Using default configuration
const workerbee = WorkerBee.create();

// Default values:
const defaultConfig = {
  apiEndpoint: 'https://api.hive.blog',
  cycleInterval: 2000,      // 2 seconds
  mode: 'live',
  maxRetries: 3,
  timeout: 10000           // 10 seconds
};
```

## :satellite: API Endpoint Configuration

### Single Endpoint

```typescript
const workerbee = WorkerBee.create({
  apiEndpoint: 'https://api.hive.blog'
});
```

### Popular Hive API Endpoints

```typescript
const endpoints = {
  // Official endpoints
  hiveApi: 'https://api.hive.blog',
  hiveApiAlt: 'https://hived.emre.sh',
  
  // Community endpoints
  anyx: 'https://anyx.io',
  arcange: 'https://hive-api.arcange.eu',
  mahdiyari: 'https://rpc.mahdiyari.info',
  techcoderx: 'https://techcoderx.com',
  
  // Geographic options
  finland: 'https://finn.hive.3speak.tv',
  germany: 'https://rpc.ausbit.dev'
};

// Choose based on your location and requirements
const workerbee = WorkerBee.create({
  apiEndpoint: endpoints.anyx  // Often faster
});
```

### Multiple Endpoints with Failover

```typescript
class MultiEndpointWorkerbee {
  private endpoints = [
    'https://api.hive.blog',
    'https://anyx.io', 
    'https://hive-api.arcange.eu'
  ];
  private currentEndpointIndex = 0;
  private workerbee: WorkerBee;

  constructor() {
    this.workerbee = this.createWithCurrentEndpoint();
  }

  private createWithCurrentEndpoint(): WorkerBee {
    return WorkerBee.create({
      apiEndpoint: this.endpoints[this.currentEndpointIndex],
      maxRetries: 2 // Lower retries since we'll switch endpoints
    });
  }

  start() {
    this.workerbee.observe
      .onPosts("alice")
      .subscribe({
        next: (data) => {
          console.log('Received data:', data);
        },
        error: (error) => {
          console.error('Error with endpoint:', this.endpoints[this.currentEndpointIndex]);
          this.switchEndpoint();
        }
      });
  }

  private switchEndpoint() {
    this.currentEndpointIndex = (this.currentEndpointIndex + 1) % this.endpoints.length;
    console.log('Switching to endpoint:', this.endpoints[this.currentEndpointIndex]);
    
    // Recreate WorkerBee with new endpoint
    this.workerbee = this.createWithCurrentEndpoint();
    this.start(); // Restart observation
  }
}
```

## :clock3: Timing Configuration

### Cycle Interval

Controls how often WorkerBee checks for new data in live mode:

```typescript
// Fast polling (every 1 second) - higher load, faster detection
const fastWorkerbee = WorkerBee.create({
  cycleInterval: 1000
});

// Standard polling (every 2 seconds) - balanced
const standardWorkerbee = WorkerBee.create({
  cycleInterval: 2000
});

// Slow polling (every 10 seconds) - lower load, slower detection
const slowWorkerbee = WorkerBee.create({
  cycleInterval: 10000
});
```

### Timeout Configuration

```typescript
// Short timeout for local/fast networks
const quickWorkerbee = WorkerBee.create({
  timeout: 5000  // 5 seconds
});

// Standard timeout
const standardWorkerbee = WorkerBee.create({
  timeout: 10000 // 10 seconds  
});

// Long timeout for slow/unreliable networks
const patientWorkerbee = WorkerBee.create({
  timeout: 30000 // 30 seconds
});
```

## :arrows_clockwise: Operation Modes

### Live Mode (Default)

Monitor real-time blockchain data:

```typescript
const liveWorkerbee = WorkerBee.create({
  mode: 'live',
  cycleInterval: 2000
});

// Monitors current blockchain head
liveWorkerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      console.log('New posts detected in real-time!');
    }
  });
```

### Historical Mode  

Analyze past blockchain data:

```typescript
const historicalWorkerbee = WorkerBee.create({
  mode: 'historical',
  startBlock: 80000000,  // Start from this block
  endBlock: 80001000     // Process until this block
});

// Processes blocks 80,000,000 to 80,001,000
historicalWorkerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      console.log('Historical posts found:', posts);
    },
    complete: () => {
      console.log('Historical analysis complete!');
    }
  });
```

### Hybrid Mode

Start with historical data, then switch to live:

```typescript
const hybridWorkerbee = WorkerBee.create({
  mode: 'hybrid',
  startBlock: 80500000  // Catch up from this block to current, then go live
});

// Processes from block 80,500,000 to current head, then continues live
hybridWorkerbee.observe
  .onPosts("alice")
  .subscribe({
    next: ({ posts }) => {
      console.log('Posts found (historical or live):', posts);
    }
  });
```

## :shield: Reliability Configuration

### Retry Configuration

```typescript
const resilientWorkerbee = WorkerBee.create({
  maxRetries: 5,           // Retry failed requests up to 5 times
  timeout: 15000,          // 15 second timeout per request
  cycleInterval: 5000      // Wait 5 seconds between cycles
});
```

### Network Error Handling

```typescript
const robustWorkerbee = WorkerBee.create({
  maxRetries: 3,
  timeout: 20000
});

robustWorkerbee.observe
  .onPosts("alice")
  .subscribe({
    next: (data) => {
      console.log('Success:', data);
    },
    error: (error) => {
      console.error('Failed after retries:', error);
      
      // Implement custom recovery logic
      setTimeout(() => {
        console.log('Attempting to restart...');
        this.restartWorkerbee();
      }, 30000); // Wait 30 seconds before restart
    }
  });
```

## :computer: Environment-Based Configuration

### Development Configuration

```typescript
const developmentConfig = {
  apiEndpoint: 'https://api.hive.blog',
  cycleInterval: 1000,     // Fast cycles for testing
  maxRetries: 1,           // Fail fast in development
  timeout: 5000,           // Short timeout
  mode: 'historical' as const,
  startBlock: 80500000,    // Small historical range
  endBlock: 80500100
};

const devWorkerbee = WorkerBee.create(developmentConfig);
```

### Production Configuration  

```typescript
const productionConfig = {
  apiEndpoint: process.env.HIVE_API_ENDPOINT || 'https://anyx.io',
  cycleInterval: 3000,     // Moderate cycles
  maxRetries: 5,           // More resilient
  timeout: 20000,          // Generous timeout
  mode: 'live' as const
};

const prodWorkerbee = WorkerBee.create(productionConfig);
```

### Configuration Factory

```typescript
class WorkerbeeConfigFactory {
  static create(environment: 'development' | 'production' | 'test'): WorkerBeeConfig {
    const baseConfig = {
      apiEndpoint: 'https://api.hive.blog',
      maxRetries: 3,
      timeout: 10000
    };

    switch (environment) {
      case 'development':
        return {
          ...baseConfig,
          cycleInterval: 1000,
          maxRetries: 1,
          timeout: 5000
        };
        
      case 'production':
        return {
          ...baseConfig,
          apiEndpoint: process.env.HIVE_API_ENDPOINT || 'https://anyx.io',
          cycleInterval: 3000,
          maxRetries: 5,
          timeout: 20000
        };
        
      case 'test':
        return {
          ...baseConfig,
          mode: 'historical',
          startBlock: 80000000,
          endBlock: 80000010, // Very small range for fast tests
          cycleInterval: 100
        };
        
      default:
        return baseConfig;
    }
  }
}

// Usage
const config = WorkerbeeConfigFactory.create(
  process.env.NODE_ENV as 'development' | 'production' | 'test'
);

const workerbee = WorkerBee.create(config);
```

## :gear: Performance Optimization

### High-Throughput Configuration

For processing large amounts of historical data:

```typescript
const highThroughputConfig = {
  apiEndpoint: 'https://anyx.io', // Fast endpoint
  cycleInterval: 100,             // Very fast cycles
  maxRetries: 1,                  // Fail fast
  timeout: 5000,                  // Short timeout
  mode: 'historical' as const,
  startBlock: 70000000,
  endBlock: 80000000
};

const fastWorkerbee = WorkerBee.create(highThroughputConfig);
```

### Low-Resource Configuration

For resource-constrained environments:

```typescript
const lowResourceConfig = {
  cycleInterval: 10000,           // Slow cycles (10 seconds)
  maxRetries: 2,                  // Fewer retries
  timeout: 30000,                 // Patient timeout
  mode: 'live' as const
};

const efficientWorkerbee = WorkerBee.create(lowResourceConfig);
```

## :warning: Configuration Best Practices

### Environment Variables

```typescript
// Use environment variables for sensitive/environment-specific config
const workerbee = WorkerBee.create({
  apiEndpoint: process.env.HIVE_API_ENDPOINT || 'https://api.hive.blog',
  cycleInterval: parseInt(process.env.CYCLE_INTERVAL || '2000'),
  maxRetries: parseInt(process.env.MAX_RETRIES || '3'),
  timeout: parseInt(process.env.TIMEOUT || '10000')
});
```

### Configuration Validation

```typescript
function validateConfig(config: WorkerBeeConfig): WorkerBeeConfig {
  // Validate cycle interval
  if (config.cycleInterval && config.cycleInterval < 100) {
    console.warn('Cycle interval too low, setting to 1000ms');
    config.cycleInterval = 1000;
  }

  // Validate timeout
  if (config.timeout && config.timeout < 1000) {
    console.warn('Timeout too low, setting to 5000ms');
    config.timeout = 5000;
  }

  // Validate historical mode
  if (config.mode === 'historical') {
    if (!config.startBlock || !config.endBlock) {
      throw new Error('Historical mode requires startBlock and endBlock');
    }
    
    if (config.startBlock >= config.endBlock) {
      throw new Error('startBlock must be less than endBlock');
    }
  }

  return config;
}

// Usage
const config = validateConfig({
  mode: 'historical',
  startBlock: 80000000,
  endBlock: 80001000,
  cycleInterval: 50 // Will be corrected to 1000
});
```

### Dynamic Configuration Updates

```typescript
class ConfigurableWorkerbee {
  private currentConfig: WorkerBeeConfig;
  private workerbee: WorkerBee;

  constructor(initialConfig: WorkerBeeConfig) {
    this.currentConfig = initialConfig;
    this.workerbee = WorkerBee.create(this.currentConfig);
  }

  updateConfig(newConfig: Partial<WorkerBeeConfig>) {
    this.currentConfig = { ...this.currentConfig, ...newConfig };
    
    // Recreate WorkerBee with new configuration
    this.workerbee = WorkerBee.create(this.currentConfig);
    
    console.log('Configuration updated:', this.currentConfig);
  }

  // Example: Dynamically adjust based on performance
  adjustForPerformance(avgResponseTime: number) {
    if (avgResponseTime > 5000) {
      // Slow network detected
      this.updateConfig({
        timeout: 20000,
        cycleInterval: 5000
      });
    } else if (avgResponseTime < 1000) {
      // Fast network detected  
      this.updateConfig({
        timeout: 8000,
        cycleInterval: 1500
      });
    }
  }
}
```

This configuration guide covers all aspects of setting up WorkerBee for different environments and use cases. Choose the configuration that best matches your requirements!
