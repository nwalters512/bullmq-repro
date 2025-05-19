# bullmq-repro

Reproduction of an issue with BullMQ's job schedulers

## Steps to reproduce

Ensure redis is installed and running on `localhost:6379`.

Install necessary dependencies:

```bash
yarn install
```

Run the example:

```bash
./repro.sh
```

Observe that after the initial flurry of messages, no additional jobs are processed.

To observe the case where things work as expected, decrease `MAX_INSTANCES` to `1` in `repro.sh` and run again with `./repro.sh`. Observe that `Processing job ...` is printed every 10 seconds as expected.
