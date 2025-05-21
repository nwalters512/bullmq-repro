#!/bin/bash

DELAY_MS=100
MAX_INSTANCES=4

# Array to store PIDs of the started processes
PIDS=()

# Function to kill all started processes
cleanup() {
  echo "Cleaning up..."
  for pid in "${PIDS[@]}"; do
    if ps -p "$pid" > /dev/null; then
      echo "Killing process $pid"
      kill -SIGTERM "$pid"
    fi
  done
  # Wait for a moment to allow processes to terminate
  sleep 1
  echo "Cleanup complete."
  exit 0
}

# Trap SIGINT (Ctrl+C) and SIGTERM to call the cleanup function
trap cleanup SIGINT SIGTERM

# Convert delay to seconds for the sleep command
DELAY_S=$(echo "$DELAY_MS / 1000" | bc -l)

echo "Starting up to $MAX_INSTANCES instances of repro.js..."
echo "Press Ctrl+C to stop all instances."

for i in $(seq 1 $MAX_INSTANCES)
do
  echo "Starting instance $i..."
  node repro.js &
  # Store the PID of the last backgrounded process
  PIDS+=($!)
  
  if [ "$i" -lt "$MAX_INSTANCES" ]; then
    echo "Waiting ${DELAY_S}s before starting the next instance..."
    # Use a version of sleep that can be interrupted by the trap
    # by running it in the background and waiting for it.
    # This allows Ctrl+C to be more responsive.
    sleep "$DELAY_S" &
    wait $!
  fi
done

echo "All $MAX_INSTANCES instances started with PIDs: ${PIDS[*]}"
echo "Waiting for Ctrl+C to terminate..."

# Keep the script alive until it's interrupted, so the trap can run
# Otherwise, if all node processes exit, the script would end and cleanup wouldn't run on Ctrl+C
# if the Ctrl+C happens after the loop finishes but before all node processes have exited on their own.
while true; do
  # Check if any of our PIDs are still running
  any_running=false
  for pid in "${PIDS[@]}"; do
    if ps -p "$pid" > /dev/null; then
      any_running=true
      break
    fi
  done
  if [ "$any_running" = false ]; then
    echo "All child processes have exited."
    break
  fi
  sleep 1
done

# Call cleanup in case all processes exited normally before Ctrl+C
cleanup
