#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Set the maximum number of concurrent processes
MAX_PROCESSES=6

# Array to store process IDs
declare -a pids

# Flag to control the monitoring loop
keep_running=true

# Function to handle termination signals
cleanup() {
    echo "Killing all child processes..."
    for pid in "${pids[@]}"; do
        kill $pid 2>/dev/null
    done
    keep_running=false
    exit 0  # Exit the script cleanly
}

# Catch termination signals
trap cleanup SIGTERM SIGINT

# Check if ID_KEY environment variable is set
if [ -z "$ID_KEY" ]; then
    echo "Error: ID_KEY environment variable is not set."
    exit 1
fi

# Check if RPC environment variable is set
if [ -z "$RPC" ]; then
    echo "Error: RPC environment variable is not set."
    exit 1
fi

# Check if PRIORITY_FEE environment variable is set
if [ -z "$PRIORITY_FEE" ]; then
    echo "Error: PRIORITY_FEE environment variable is not set."
    exit 1
fi

# Create the id.json file with the ID_KEY environment variable as its content
echo "$ID_KEY" > /tmp/id.json

# Command to be executed
COMMAND="ore --rpc $RPC --keypair /tmp/id.json --priority-fee $PRIORITY_FEE mine"

# Start the processes
for (( i=0; i<$MAX_PROCESSES; i++ )); do
    $COMMAND &
    sleep 0.2
    pids[$i]=$!
    echo "Started process $i with PID ${pids[$i]}"
done

# Monitor all processes and restart if any stops
while $keep_running; do
    for i in "${!pids[@]}"; do
        pid="${pids[$i]}"
        if ! kill -0 $pid 2>/dev/null; then
            echo "Process $i with PID $pid has stopped. Restarting..."
            $COMMAND &
            pids[$i]=$!
            echo "Restarted process $i with new PID ${pids[$i]}"
        fi
    done
    sleep 1
done

