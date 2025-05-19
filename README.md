# bullmq-repro

Reproduction of an issue with BullMQ's job schedulers that was reported here: https://github.com/taskforcesh/bullmq/issues/3272

## Steps to reproduce

Ensure redis is installed and running on `localhost:6379`.

From `redis-cli`, run `FLUSHALL` to ensure a clean slate.

Install necessary dependencies:

```bash
yarn install
```

Run the example:

```bash
./repro.sh
```

Observe that after the initial flurry of messages, no additional jobs are processed.

From `redis-cli`, run `KEYS *` to see the status of things. Observe that there is no `bull:prairietest-cron:delayed` key.

To observe the case where things work as expected, decrease `MAX_INSTANCES` to `1` in `repro.sh` and run again with `./repro.sh`. Observe that `Processing job ...` is printed every 10 seconds as expected.

Again, run `KEYS *`. This time observe that there is a `bull:prairietest-cron:delayed` key. This seems to indicate that things are working as expected.
