---
order: -8
icon: beaker
---

# Advanced Examples

Explore sophisticated use cases and patterns with WorkerBee. These examples demonstrate real-world applications and advanced techniques.

## :robot: Intelligent Voting Bot

A smart voting bot that considers multiple factors before casting votes.

```typescript
import { WorkerBee, and } from '@hiveio/workerbee';

interface VotingConfig {
  minReputation: number;
  minFollowers: number;
  maxVotingPower: number;
  voteWeight: number;
  requiredTags: string[];
  blacklistedAuthors: string[];
}

class IntelligentVoter {
  private workerbee: WorkerBee;
  private config: VotingConfig;
  private voterAccount: string;

  constructor(voterAccount: string, config: VotingConfig) {
    this.workerbee = WorkerBee.create();
    this.voterAccount = voterAccount;
    this.config = config;
  }

  start() {
    this.workerbee.observe
      .onPosts() // Monitor all posts
      .provideAccounts() // Get author account data
      .provideFollowCounts() // Get follower counts
      .provideAccountsVotingManabar(this.voterAccount) // Get voter's manabar
      .subscribe({
        next: async ({ posts, accounts, followCounts, votingManabar }) => {
          const voterManabar = votingManabar[this.voterAccount];
          const votingPowerPercent = (voterManabar.current_mana / voterManabar.max_mana) * 100;

          // Don't vote if voting power is too low
          if (votingPowerPercent < this.config.maxVotingPower) {
            console.log(`Voting power too low: ${votingPowerPercent.toFixed(1)}%`);
            return;
          }

          // Evaluate each post
          for (const [author, authorPosts] of Object.entries(posts)) {
            // Skip blacklisted authors
            if (this.config.blacklistedAuthors.includes(author)) {
              continue;
            }

            const authorAccount = accounts[author];
            const authorFollowers = followCounts[author];
            
            if (!authorAccount || !authorFollowers) continue;

            // Check reputation
            const reputation = parseInt(authorAccount.reputation);
            if (reputation < this.config.minReputation) {
              console.log(`Skipping @${author}: reputation too low (${reputation})`);
              continue;
            }

            // Check follower count
            if (authorFollowers.follower_count < this.config.minFollowers) {
              console.log(`Skipping @${author}: not enough followers (${authorFollowers.follower_count})`);
              continue;
            }

            // Evaluate each post
            for (const post of authorPosts) {
              if (await this.shouldVote(post)) {
                await this.castVote(author, post.permlink);
              }
            }
          }
        },
        error: (error) => {
          console.error('Voting bot error:', error);
        }
      });
  }

  private async shouldVote(post: any): Promise<boolean> {
    // Check for required tags
    const hasRequiredTag = this.config.requiredTags.some(tag => 
      post.tags.includes(tag)
    );

    if (!hasRequiredTag) {
      console.log(`Skipping post "${post.title}": no required tags`);
      return false;
    }

    // Check post quality (simple heuristics)
    const wordCount = post.body.split(/\s+/).length;
    if (wordCount < 100) {
      console.log(`Skipping post "${post.title}": too short (${wordCount} words)`);
      return false;
    }

    // Check for spam indicators
    const exclamationCount = (post.body.match(/!/g) || []).length;
    if (exclamationCount > 10) {
      console.log(`Skipping post "${post.title}": too many exclamations`);
      return false;
    }

    console.log(`✅ Post qualifies for vote: "${post.title}" by @${post.author}`);
    return true;
  }

  private async castVote(author: string, permlink: string): Promise<void> {
    try {
      // In a real implementation, you'd use @hiveio/dhive or similar
      console.log(`🗳️  Voting on @${author}/${permlink} with ${this.config.voteWeight / 100}% weight`);
      
      // Simulated vote - replace with actual voting logic
      // const result = await hivejs.broadcast.vote(
      //   voterKey,
      //   this.voterAccount,
      //   author,
      //   permlink,
      //   this.config.voteWeight
      // );
      
      console.log(`Vote cast successfully!`);
    } catch (error) {
      console.error(`Failed to vote on @${author}/${permlink}:`, error);
    }
  }
}

// Usage
const voter = new IntelligentVoter('my-voter-account', {
  minReputation: 55,
  minFollowers: 100,
  maxVotingPower: 80, // Don't vote if below 80%
  voteWeight: 2500,   // 25% vote weight
  requiredTags: ['photography', 'art', 'technology'],
  blacklistedAuthors: ['spammer1', 'spammer2']
});

voter.start();
```

## :chart_with_upwards_trend: Real-Time Analytics Dashboard

Track and analyze blockchain metrics in real-time.

```typescript
import { WorkerBee } from '@hiveio/workerbee';
import { EventEmitter } from 'events';

interface BlockchainMetrics {
  blocksPerMinute: number;
  transactionsPerMinute: number;
  postsPerHour: number;
  commentsPerHour: number;
  votesPerHour: number;
  topAuthors: Array<{ author: string; posts: number; votes: number }>;
  topTags: Array<{ tag: string; count: number }>;
  activeWitnesses: string[];
}

class BlockchainAnalyzer extends EventEmitter {
  private workerbee: WorkerBee;
  private metrics: BlockchainMetrics;
  private startTime: number;
  private blockCount = 0;
  private transactionCount = 0;
  private postCount = 0;
  private commentCount = 0;
  private voteCount = 0;
  private authorStats = new Map<string, { posts: number; votes: number }>();
  private tagStats = new Map<string, number>();

  constructor() {
    super();
    this.workerbee = WorkerBee.create();
    this.startTime = Date.now();
    this.metrics = this.getEmptyMetrics();
  }

  start() {
    // Monitor all blockchain activity
    this.workerbee.observe
      .onBlock()
      .onOperation('comment')
      .onOperation('vote')
      .provideDynamicGlobalProperties()
      .provideWitnessSchedule()
      .subscribe({
        next: ({ block, operations, globalProperties, witnessSchedule }) => {
          this.updateBlockMetrics(block);
          this.updateOperationMetrics(operations);
          this.updateWitnessMetrics(witnessSchedule);
          this.updateGlobalMetrics(globalProperties);
          
          // Emit updated metrics every 10 blocks
          if (this.blockCount % 10 === 0) {
            this.emitMetrics();
          }
        },
        error: (error) => {
          console.error('Analytics error:', error);
        }
      });

    // Emit metrics every 60 seconds
    setInterval(() => {
      this.emitMetrics();
    }, 60000);
  }

  private updateBlockMetrics(block: any) {
    if (block) {
      this.blockCount++;
      this.transactionCount += block.transactions?.length || 0;
    }
  }

  private updateOperationMetrics(operations: any) {
    if (operations.comment) {
      for (const op of operations.comment) {
        if (op.parent_author === '') {
          // This is a post
          this.postCount++;
          
          // Update author stats
          const authorStat = this.authorStats.get(op.author) || { posts: 0, votes: 0 };
          authorStat.posts++;
          this.authorStats.set(op.author, authorStat);
          
          // Update tag stats
          try {
            const metadata = JSON.parse(op.json_metadata || '{}');
            const tags = metadata.tags || [];
            tags.forEach((tag: string) => {
              this.tagStats.set(tag, (this.tagStats.get(tag) || 0) + 1);
            });
          } catch {
            // Invalid JSON metadata
          }
        } else {
          // This is a comment
          this.commentCount++;
        }
      }
    }

    if (operations.vote) {
      this.voteCount += operations.vote.length;
      
      // Update vote stats for authors
      operations.vote.forEach((vote: any) => {
        const authorStat = this.authorStats.get(vote.author) || { posts: 0, votes: 0 };
        authorStat.votes++;
        this.authorStats.set(vote.author, authorStat);
      });
    }
  }

  private updateWitnessMetrics(witnessSchedule: any) {
    if (witnessSchedule?.active_witnesses) {
      this.metrics.activeWitnesses = witnessSchedule.active_witnesses.slice(0, 10);
    }
  }

  private updateGlobalMetrics(globalProperties: any) {
    // Additional global metrics can be added here
    if (globalProperties) {
      // Store relevant global properties
    }
  }

  private emitMetrics() {
    const now = Date.now();
    const elapsedMinutes = (now - this.startTime) / 60000;
    const elapsedHours = elapsedMinutes / 60;

    // Calculate rates
    this.metrics.blocksPerMinute = this.blockCount / elapsedMinutes;
    this.metrics.transactionsPerMinute = this.transactionCount / elapsedMinutes;
    this.metrics.postsPerHour = this.postCount / elapsedHours;
    this.metrics.commentsPerHour = this.commentCount / elapsedHours;
    this.metrics.votesPerHour = this.voteCount / elapsedHours;

    // Top authors
    this.metrics.topAuthors = Array.from(this.authorStats.entries())
      .map(([author, stats]) => ({ author, ...stats }))
      .sort((a, b) => (b.posts + b.votes) - (a.posts + a.votes))
      .slice(0, 10);

    // Top tags
    this.metrics.topTags = Array.from(this.tagStats.entries())
      .map(([tag, count]) => ({ tag, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 10);

    this.emit('metrics', { ...this.metrics });
    
    console.log('📊 Current Metrics:');
    console.log(`  Blocks/min: ${this.metrics.blocksPerMinute.toFixed(2)}`);
    console.log(`  Transactions/min: ${this.metrics.transactionsPerMinute.toFixed(2)}`);
    console.log(`  Posts/hour: ${this.metrics.postsPerHour.toFixed(2)}`);
    console.log(`  Comments/hour: ${this.metrics.commentsPerHour.toFixed(2)}`);
    console.log(`  Votes/hour: ${this.metrics.votesPerHour.toFixed(2)}`);
  }

  private getEmptyMetrics(): BlockchainMetrics {
    return {
      blocksPerMinute: 0,
      transactionsPerMinute: 0,
      postsPerHour: 0,
      commentsPerHour: 0,
      votesPerHour: 0,
      topAuthors: [],
      topTags: [],
      activeWitnesses: []
    };
  }
}

// Usage
const analyzer = new BlockchainAnalyzer();

analyzer.on('metrics', (metrics: BlockchainMetrics) => {
  // Send metrics to dashboard, database, or alerting system
  console.log('Updated metrics received:', metrics);
  
  // Example: Send to web dashboard via WebSocket
  // webSocket.send(JSON.stringify({ type: 'metrics', data: metrics }));
});

analyzer.start();
```

## :bell: Advanced Notification System

A comprehensive notification system for multiple channels and conditions.

```typescript
import { WorkerBee, or } from '@hiveio/workerbee';

interface NotificationChannel {
  send(message: string, data?: any): Promise<void>;
}

class EmailChannel implements NotificationChannel {
  async send(message: string, data?: any): Promise<void> {
    console.log(`📧 EMAIL: ${message}`);
    // Implement actual email sending
  }
}

class SlackChannel implements NotificationChannel {
  constructor(private webhookUrl: string) {}

  async send(message: string, data?: any): Promise<void> {
    console.log(`💬 SLACK: ${message}`);
    // Implement Slack webhook
    // await fetch(this.webhookUrl, {
    //   method: 'POST',
    //   body: JSON.stringify({ text: message })
    // });
  }
}

class DiscordChannel implements NotificationChannel {
  constructor(private webhookUrl: string) {}

  async send(message: string, data?: any): Promise<void> {
    console.log(`🎮 DISCORD: ${message}`);
    // Implement Discord webhook
  }
}

class NotificationRule {
  constructor(
    public name: string,
    public condition: () => any, // WorkerBee filter chain
    public template: (data: any) => string,
    public channels: NotificationChannel[],
    public cooldown: number = 0 // Minutes between notifications
  ) {}

  private lastNotification = 0;

  shouldNotify(): boolean {
    const now = Date.now();
    return (now - this.lastNotification) > (this.cooldown * 60000);
  }

  async notify(data: any): Promise<void> {
    if (!this.shouldNotify()) return;

    const message = this.template(data);
    
    await Promise.all(
      this.channels.map(channel => 
        channel.send(message, data).catch(error => 
          console.error(`Failed to send notification via channel:`, error)
        )
      )
    );

    this.lastNotification = Date.now();
  }
}

class AdvancedNotificationSystem {
  private workerbee: WorkerBee;
  private rules: NotificationRule[] = [];
  private channels = {
    email: new EmailChannel(),
    slack: new SlackChannel('https://hooks.slack.com/your-webhook'),
    discord: new DiscordChannel('https://discord.com/api/webhooks/your-webhook')
  };

  constructor() {
    this.workerbee = WorkerBee.create();
    this.setupRules();
  }

  private setupRules() {
    // Rule 1: High-value posts
    this.rules.push(new NotificationRule(
      'high-value-posts',
      () => this.workerbee.observe
        .onPosts()
        .providePostDetails(),
      (data) => {
        const highValuePosts = Object.entries(data.postDetails)
          .filter(([_, post]: [string, any]) => 
            parseFloat(post.pending_payout_value.replace(' HBD', '')) > 50
          );
        
        return `💰 High-value posts detected: ${highValuePosts.length} posts with >$50 pending payout`;
      },
      [this.channels.slack, this.channels.discord],
      30 // 30 minute cooldown
    ));

    // Rule 2: Whale activity
    this.rules.push(new NotificationRule(
      'whale-activity',
      () => this.workerbee.observe
        .onPosts('blocktrades', 'freedom', 'smooth', 'theycallmedan')
        .provideAccounts(),
      (data) => {
        const whales = Object.keys(data.posts);
        return `🐋 Whale activity: ${whales.join(', ')} just posted!`;
      },
      [this.channels.email, this.channels.slack],
      0 // No cooldown for whale activity
    ));

    // Rule 3: New large accounts
    this.rules.push(new NotificationRule(
      'new-large-accounts',
      () => this.workerbee.observe
        .onAccountsVestingSharesChange()
        .provideAccounts(),
      (data) => {
        const largeAccounts = Object.entries(data.accounts)
          .filter(([_, account]: [string, any]) => {
            const vests = parseFloat(account.vesting_shares.replace(' VESTS', ''));
            return vests > 1000000; // 1M+ VESTS
          })
          .map(([name]) => name);

        if (largeAccounts.length === 0) return null;

        return `🦣 Large account activity: ${largeAccounts.join(', ')} changed their Hive Power`;
      },
      [this.channels.email],
      60 // 1 hour cooldown
    ));

    // Rule 4: Network issues
    this.rules.push(new NotificationRule(
      'network-issues',
      () => this.workerbee.observe
        .onBlock()
        .provideDynamicGlobalProperties(),
      (data) => {
        const timeSinceLastBlock = Date.now() - new Date(data.block.timestamp + 'Z').getTime();
        
        if (timeSinceLastBlock > 60000) { // More than 1 minute
          return `⚠️ Network issue: Last block was ${Math.round(timeSinceLastBlock / 1000)}s ago`;
        }
        
        return null; // No notification needed
      },
      [this.channels.email, this.channels.slack, this.channels.discord],
      15 // 15 minute cooldown
    ));
  }

  start() {
    this.rules.forEach(rule => {
      rule.condition().subscribe({
        next: async (data) => {
          try {
            const message = rule.template(data);
            if (message) {
              await rule.notify(data);
              console.log(`📢 Notification sent for rule: ${rule.name}`);
            }
          } catch (error) {
            console.error(`Error processing rule ${rule.name}:`, error);
          }
        },
        error: (error) => {
          console.error(`Error in rule ${rule.name}:`, error);
        }
      });
    });

    console.log(`🚀 Advanced notification system started with ${this.rules.length} rules`);
  }

  addRule(rule: NotificationRule) {
    this.rules.push(rule);
  }

  removeRule(name: string) {
    this.rules = this.rules.filter(rule => rule.name !== name);
  }
}

// Usage
const notificationSystem = new AdvancedNotificationSystem();
notificationSystem.start();
```

## :mag_right: Content Quality Analyzer

Analyze and score content quality using various metrics.

```typescript
import { WorkerBee } from '@hiveio/workerbee';

interface QualityMetrics {
  wordCount: number;
  imageCount: number;
  linkCount: number;
  readingTime: number;
  sentimentScore: number;
  grammarScore: number;
  originalityScore: number;
  engagementPotential: number;
}

interface QualityReport {
  author: string;
  permlink: string;
  title: string;
  overallScore: number;
  metrics: QualityMetrics;
  recommendations: string[];
}

class ContentQualityAnalyzer {
  private workerbee: WorkerBee;
  private positiveWords = ['excellent', 'amazing', 'wonderful', 'fantastic', 'great', 'good', 'love', 'beautiful', 'perfect', 'awesome'];
  private negativeWords = ['terrible', 'awful', 'horrible', 'bad', 'hate', 'disgusting', 'worst', 'ugly', 'boring', 'stupid'];

  constructor() {
    this.workerbee = WorkerBee.create();
  }

  start() {
    this.workerbee.observe
      .onPosts() // Analyze all new posts
      .provideAccounts()
      .subscribe({
        next: async ({ posts, accounts }) => {
          for (const [author, authorPosts] of Object.entries(posts)) {
            const authorAccount = accounts[author];
            
            for (const post of authorPosts) {
              const report = await this.analyzePost(post, authorAccount);
              this.handleQualityReport(report);
            }
          }
        },
        error: (error) => {
          console.error('Quality analyzer error:', error);
        }
      });
  }

  private async analyzePost(post: any, authorAccount: any): Promise<QualityReport> {
    const metrics = this.calculateMetrics(post);
    const overallScore = this.calculateOverallScore(metrics, authorAccount);
    const recommendations = this.generateRecommendations(metrics, post);

    return {
      author: post.author,
      permlink: post.permlink,
      title: post.title,
      overallScore,
      metrics,
      recommendations
    };
  }

  private calculateMetrics(post: any): QualityMetrics {
    const body = post.body.toLowerCase();
    const words = body.split(/\s+/).filter(word => word.length > 0);
    
    // Word count
    const wordCount = words.length;
    
    // Image count
    const imageCount = (post.body.match(/!\[.*?\]\([^)]+\)/g) || []).length;
    
    // Link count  
    const linkCount = (post.body.match(/\[.*?\]\([^)]+\)/g) || []).length;
    
    // Reading time (assuming 200 words per minute)
    const readingTime = Math.ceil(wordCount / 200);
    
    // Sentiment score
    const sentimentScore = this.calculateSentiment(words);
    
    // Grammar score (simplified)
    const grammarScore = this.calculateGrammarScore(post.body);
    
    // Originality score (simplified check for common phrases)
    const originalityScore = this.calculateOriginalityScore(body);
    
    // Engagement potential
    const engagementPotential = this.calculateEngagementPotential(post, wordCount, imageCount);

    return {
      wordCount,
      imageCount,
      linkCount,
      readingTime,
      sentimentScore,
      grammarScore,
      originalityScore,
      engagementPotential
    };
  }

  private calculateSentiment(words: string[]): number {
    let score = 50; // Neutral baseline
    
    words.forEach(word => {
      if (this.positiveWords.includes(word)) {
        score += 2;
      } else if (this.negativeWords.includes(word)) {
        score -= 2;
      }
    });
    
    return Math.max(0, Math.min(100, score));
  }

  private calculateGrammarScore(text: string): number {
    let score = 100;
    
    // Simple grammar checks
    const sentences = text.split(/[.!?]+/).filter(s => s.trim());
    
    sentences.forEach(sentence => {
      const trimmed = sentence.trim();
      
      // Check capitalization
      if (trimmed && trimmed[0] !== trimmed[0].toUpperCase()) {
        score -= 2;
      }
      
      // Check for very long sentences (>50 words)
      if (trimmed.split(/\s+/).length > 50) {
        score -= 3;
      }
    });
    
    // Check for excessive punctuation
    const exclamationCount = (text.match(/!/g) || []).length;
    if (exclamationCount > 5) {
      score -= exclamationCount;
    }
    
    return Math.max(0, Math.min(100, score));
  }

  private calculateOriginalityScore(text: string): number {
    const commonPhrases = [
      'please upvote',
      'follow me',
      'thanks for reading',
      'what do you think',
      'leave a comment'
    ];
    
    let score = 100;
    
    commonPhrases.forEach(phrase => {
      if (text.includes(phrase)) {
        score -= 10;
      }
    });
    
    // Check for repetitive patterns
    const words = text.split(/\s+/);
    const uniqueWords = new Set(words).size;
    const repetitionRatio = uniqueWords / words.length;
    
    if (repetitionRatio < 0.3) {
      score -= 20; // Very repetitive
    } else if (repetitionRatio < 0.5) {
      score -= 10; // Somewhat repetitive
    }
    
    return Math.max(0, Math.min(100, score));
  }

  private calculateEngagementPotential(post: any, wordCount: number, imageCount: number): number {
    let score = 0;
    
    // Word count scoring
    if (wordCount >= 300 && wordCount <= 1500) {
      score += 30; // Optimal length
    } else if (wordCount >= 150) {
      score += 15; // Decent length
    }
    
    // Image scoring
    if (imageCount >= 1 && imageCount <= 5) {
      score += 25; // Good visual content
    } else if (imageCount > 5) {
      score += 10; // Maybe too many images
    }
    
    // Title scoring
    const titleWords = post.title.split(/\s+/).length;
    if (titleWords >= 3 && titleWords <= 12) {
      score += 20; // Good title length
    }
    
    // Tags scoring
    if (post.tags && post.tags.length >= 3) {
      score += 15; // Good categorization
    }
    
    // Question or discussion prompt
    if (post.body.includes('?') || post.body.includes('what do you')) {
      score += 10; // Encourages engagement
    }
    
    return Math.max(0, Math.min(100, score));
  }

  private calculateOverallScore(metrics: QualityMetrics, authorAccount: any): number {
    const weights = {
      wordCount: 0.15,
      sentiment: 0.20,
      grammar: 0.25,
      originality: 0.25,
      engagement: 0.15
    };
    
    // Normalize word count score (300-1500 words = 100 points)
    let wordScore = 0;
    if (metrics.wordCount >= 300 && metrics.wordCount <= 1500) {
      wordScore = 100;
    } else if (metrics.wordCount >= 150) {
      wordScore = 60;
    } else if (metrics.wordCount >= 50) {
      wordScore = 30;
    }
    
    const score = 
      (wordScore * weights.wordCount) +
      (metrics.sentimentScore * weights.sentiment) +
      (metrics.grammarScore * weights.grammar) +
      (metrics.originalityScore * weights.originality) +
      (metrics.engagementPotential * weights.engagement);
    
    // Author reputation bonus
    const reputation = parseInt(authorAccount.reputation);
    let reputationBonus = 0;
    if (reputation > 70) reputationBonus = 5;
    else if (reputation > 60) reputationBonus = 3;
    else if (reputation > 50) reputationBonus = 1;
    
    return Math.min(100, score + reputationBonus);
  }

  private generateRecommendations(metrics: QualityMetrics, post: any): string[] {
    const recommendations: string[] = [];
    
    if (metrics.wordCount < 150) {
      recommendations.push('Consider expanding your content. Longer posts tend to get more engagement.');
    }
    
    if (metrics.wordCount > 2000) {
      recommendations.push('Your post is quite long. Consider breaking it into parts or adding more images.');
    }
    
    if (metrics.imageCount === 0) {
      recommendations.push('Adding images can significantly improve engagement and readability.');
    }
    
    if (metrics.grammarScore < 70) {
      recommendations.push('Review your post for grammar and punctuation errors.');
    }
    
    if (metrics.sentimentScore < 30) {
      recommendations.push('Your post seems quite negative. Consider balancing with positive elements.');
    }
    
    if (metrics.originalityScore < 50) {
      recommendations.push('Try to avoid common phrases and make your content more unique.');
    }
    
    if (metrics.engagementPotential < 50) {
      recommendations.push('Add questions or discussion prompts to encourage reader interaction.');
    }
    
    if (!post.tags || post.tags.length < 3) {
      recommendations.push('Use more relevant tags to help others discover your content.');
    }
    
    return recommendations;
  }

  private handleQualityReport(report: QualityReport) {
    console.log(`\n📊 Quality Report for @${report.author}/${report.permlink}`);
    console.log(`📝 Title: "${report.title}"`);
    console.log(`⭐ Overall Score: ${report.overallScore.toFixed(1)}/100`);
    
    console.log('\n📈 Metrics:');
    console.log(`  Words: ${report.metrics.wordCount}`);
    console.log(`  Images: ${report.metrics.imageCount}`);
    console.log(`  Reading Time: ${report.metrics.readingTime} min`);
    console.log(`  Sentiment: ${report.metrics.sentimentScore.toFixed(1)}/100`);
    console.log(`  Grammar: ${report.metrics.grammarScore.toFixed(1)}/100`);
    console.log(`  Originality: ${report.metrics.originalityScore.toFixed(1)}/100`);
    console.log(`  Engagement: ${report.metrics.engagementPotential.toFixed(1)}/100`);
    
    if (report.recommendations.length > 0) {
      console.log('\n💡 Recommendations:');
      report.recommendations.forEach((rec, i) => {
        console.log(`  ${i + 1}. ${rec}`);
      });
    }
    
    // You could store this data in a database, send it to the author, etc.
    if (report.overallScore >= 80) {
      console.log('🏆 High quality content detected!');
    } else if (report.overallScore < 40) {
      console.log('⚠️ Low quality content detected.');
    }
  }
}

// Usage
const qualityAnalyzer = new ContentQualityAnalyzer();
qualityAnalyzer.start();
```

## :trophy: Achievement System

Gamify user engagement with an achievement system.

```typescript
import { WorkerBee } from '@hiveio/workerbee';

interface Achievement {
  id: string;
  title: string;
  description: string;
  condition: (userStats: UserStats) => boolean;
  points: number;
  badge: string;
}

interface UserStats {
  author: string;
  postsCount: number;
  commentsCount: number;
  votesReceived: number;
  totalPayout: number;
  followerCount: number;
  streak: number;
  lastPostDate: string;
}

class AchievementSystem {
  private workerbee: WorkerBee;
  private userStats = new Map<string, UserStats>();
  private achievements: Achievement[] = [];

  constructor() {
    this.workerbee = WorkerBee.create();
    this.setupAchievements();
  }

  private setupAchievements() {
    this.achievements = [
      {
        id: 'first_post',
        title: 'First Steps',
        description: 'Published your first post',
        condition: (stats) => stats.postsCount >= 1,
        points: 10,
        badge: '🎯'
      },
      {
        id: 'prolific_writer',
        title: 'Prolific Writer',
        description: 'Published 100 posts',
        condition: (stats) => stats.postsCount >= 100,
        points: 500,
        badge: '📚'
      },
      {
        id: 'commentator',
        title: 'Active Commentator',
        description: 'Made 500 comments',
        condition: (stats) => stats.commentsCount >= 500,
        points: 250,
        badge: '💬'
      },
      {
        id: 'popular_author',
        title: 'Popular Author',
        description: 'Received 1000+ votes on your content',
        condition: (stats) => stats.votesReceived >= 1000,
        points: 750,
        badge: '⭐'
      },
      {
        id: 'big_earner',
        title: 'Big Earner',
        description: 'Earned over $1000 total',
        condition: (stats) => stats.totalPayout >= 1000,
        points: 1000,
        badge: '💰'
      },
      {
        id: 'influencer',
        title: 'Influencer',
        description: 'Have 1000+ followers',
        condition: (stats) => stats.followerCount >= 1000,
        points: 800,
        badge: '👑'
      },
      {
        id: 'consistent_poster',
        title: 'Consistent Poster',
        description: 'Posted daily for 30 days',
        condition: (stats) => stats.streak >= 30,
        points: 600,
        badge: '🔥'
      }
    ];
  }

  start() {
    this.workerbee.observe
      .onPosts()
      .onComments()
      .provideAccounts()
      .provideFollowCounts()
      .subscribe({
        next: ({ posts, comments, accounts, followCounts }) => {
          // Update stats for authors with new posts
          Object.keys(posts).forEach(author => {
            this.updateUserStats(author, 'posts', accounts[author], followCounts[author]);
          });

          // Update stats for authors with new comments
          Object.keys(comments).forEach(author => {
            this.updateUserStats(author, 'comments', accounts[author], followCounts[author]);
          });
        }
      });

    // Also monitor votes to update vote statistics
    this.workerbee.observe
      .onVotes()
      .subscribe({
        next: ({ votes }) => {
          Object.values(votes).flat().forEach((vote: any) => {
            this.updateVoteStats(vote.author);
          });
        }
      });
  }

  private updateUserStats(author: string, activity: 'posts' | 'comments', account: any, followCount: any) {
    if (!account) return;

    let stats = this.userStats.get(author) || {
      author,
      postsCount: 0,
      commentsCount: 0,
      votesReceived: 0,
      totalPayout: 0,
      followerCount: 0,
      streak: 0,
      lastPostDate: ''
    };

    // Update basic stats from account
    stats.postsCount = account.post_count || 0;
    stats.followerCount = followCount?.follower_count || 0;

    // Calculate total payout (simplified)
    const authorRewards = parseFloat((account.author_rewards || '0').replace(' HBD', ''));
    const curatorRewards = parseFloat((account.curation_rewards || '0').replace(' HP', '')) / 1000; // Convert HP to HBD approximation
    stats.totalPayout = authorRewards + curatorRewards;

    // Update activity-specific stats
    if (activity === 'posts') {
      this.updatePostingStreak(stats, new Date().toISOString());
    } else if (activity === 'comments') {
      stats.commentsCount++;
    }

    this.userStats.set(author, stats);
    this.checkAchievements(author, stats);
  }

  private updateVoteStats(author: string) {
    let stats = this.userStats.get(author);
    if (stats) {
      stats.votesReceived++;
      this.checkAchievements(author, stats);
    }
  }

  private updatePostingStreak(stats: UserStats, currentDate: string) {
    const today = new Date(currentDate).toDateString();
    const lastPost = stats.lastPostDate ? new Date(stats.lastPostDate).toDateString() : '';
    
    if (lastPost === today) {
      // Already posted today, no change to streak
      return;
    }

    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayString = yesterday.toDateString();

    if (lastPost === yesterdayString) {
      // Posted yesterday, continue streak
      stats.streak++;
    } else if (lastPost === '') {
      // First post ever
      stats.streak = 1;
    } else {
      // Gap in posting, reset streak
      stats.streak = 1;
    }

    stats.lastPostDate = currentDate;
  }

  private checkAchievements(author: string, stats: UserStats) {
    this.achievements.forEach(achievement => {
      if (achievement.condition(stats)) {
        this.awardAchievement(author, achievement);
      }
    });
  }

  private awardAchievement(author: string, achievement: Achievement) {
    // Check if user already has this achievement (in real app, use database)
    // For demo, we'll just log it
    console.log(`\n🏆 Achievement Unlocked!`);
    console.log(`👤 User: @${author}`);
    console.log(`${achievement.badge} ${achievement.title}`);
    console.log(`📝 ${achievement.description}`);
    console.log(`🎯 Points Earned: ${achievement.points}`);
    
    // In a real implementation, you might:
    // - Store in database
    // - Send notification to user
    // - Update user's total points
    // - Trigger additional rewards
    
    this.notifyUserOfAchievement(author, achievement);
  }

  private async notifyUserOfAchievement(author: string, achievement: Achievement) {
    // This could send a comment, transfer tokens, or notify via external service
    console.log(`📢 Notifying @${author} of their new achievement!`);
    
    // Example: Post a congratulatory comment (you'd need to implement the actual commenting)
    /*
    const congratsMessage = `
    🎉 Congratulations @${author}! 
    
    You've earned the "${achievement.title}" achievement! ${achievement.badge}
    ${achievement.description}
    
    Points earned: ${achievement.points}
    
    Keep up the great work! 🚀
    `;
    
    // await postComment(author, congratsMessage);
    */
  }

  getLeaderboard(): Array<{ author: string; totalPoints: number; achievementCount: number }> {
    return Array.from(this.userStats.entries()).map(([author, stats]) => {
      const earnedAchievements = this.achievements.filter(a => a.condition(stats));
      const totalPoints = earnedAchievements.reduce((sum, a) => sum + a.points, 0);
      
      return {
        author,
        totalPoints,
        achievementCount: earnedAchievements.length
      };
    }).sort((a, b) => b.totalPoints - a.totalPoints);
  }

  getUserAchievements(author: string): Achievement[] {
    const stats = this.userStats.get(author);
    if (!stats) return [];
    
    return this.achievements.filter(achievement => achievement.condition(stats));
  }
}

// Usage
const achievementSystem = new AchievementSystem();
achievementSystem.start();

// Check leaderboard periodically
setInterval(() => {
  const leaderboard = achievementSystem.getLeaderboard().slice(0, 10);
  console.log('\n🏆 Top 10 Achievement Leaderboard:');
  leaderboard.forEach((entry, index) => {
    console.log(`${index + 1}. @${entry.author} - ${entry.totalPoints} points (${entry.achievementCount} achievements)`);
  });
}, 300000); // Every 5 minutes
```

These advanced examples showcase WorkerBee's power for building sophisticated blockchain applications. Each example demonstrates different architectural patterns, real-world use cases, and advanced features of the library.
