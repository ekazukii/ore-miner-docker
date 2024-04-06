#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Function to handle termination signals
cleanup() {
    echo "Script is terminating..."
    exit 0
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
echo "$ID_KEY" > /path/to/created/id.json

# Infinite loop to keep the script running
while true; do
    # Run the ore-cli command with the required parameters
    ore --rpc $RPC --keypair /path/to/created/id.json --priority-fee 
$PRIORITY_FEE mine

    echo "ore-cli crashed with exit code $?. Respawning.."
    sleep 1
done

