import { Queue, Worker } from 'bullmq';
import { Redis } from 'ioredis';

const redis = new Redis('redis://localhost:6379', { maxRetriesPerRequest: null });

const cronQueue = new Queue('prairietest-cron', {
  connection: redis,
  defaultJobOptions: {
    removeOnComplete: true,
    removeOnFail: true,
    attempts: 3,
    backoff: {
      type: 'fixed',
      delay: 1000,
    },
  },
});

cronQueue.upsertJobScheduler(
  'CloudWatchMetricsScheduler',
  { every: 10_000 },
  { name: 'CloudWatchMetrics' },
);
console.log('Scheduler created');

new Worker(
  'prairietest-cron',
  async (job) => {
    console.log(`Processing job ${job.id} of type ${job.name}`);
  },
  { connection: redis },
);
