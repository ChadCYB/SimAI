#!/bin/bash

# Script to run SimAI in Docker with mapped volumes for input and results
# Usage: ./run_simai_docker.sh [--skip-topo]

set -e  # Exit on any error

# Parse command-line arguments
SKIP_TOPO=false
for arg in "$@"; do
  case $arg in
    --skip-topo)
      SKIP_TOPO=true
      shift
      ;;
    *)
      # Unknown option
      ;;
  esac
done

# Generate timestamp for results folder
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
INPUT_DIR="$(pwd)/input"
RESULT_DIR="$(pwd)/result_${TIMESTAMP}"

# Create directories
mkdir -p "$INPUT_DIR"
mkdir -p "$RESULT_DIR"
echo "Created directories:"
echo "- Input: $INPUT_DIR"
echo "- Results: $RESULT_DIR"

# Run Docker container with the script
echo "Starting Docker container with mapped volumes..."

if [ "$SKIP_TOPO" = true ]; then
  SCRIPT_ARG="skip-topo"
else
  SCRIPT_ARG=""
fi

# Run Docker command and save output to log file
LOG_FILE="$RESULT_DIR/log.txt"
echo "Starting SimAI docker container at $(date)" > "$LOG_FILE"
echo "Command parameters: $@" >> "$LOG_FILE"
echo "--------------------------------------------" >> "$LOG_FILE"

sudo docker run --rm --gpus all --runtime=nvidia \
  -v "$INPUT_DIR:/input" \
  -v "$RESULT_DIR:/result" \
  simai /bin/bash -c "cd /input && bash /input/run_script.sh $SCRIPT_ARG" 2>&1 | tee -a "$LOG_FILE"

echo "--------------------------------------------" >> "$LOG_FILE"
echo "Docker container completed at $(date)" >> "$LOG_FILE"

echo ""
echo "Simulation completed successfully!"
echo "Results are available in: $RESULT_DIR"
echo "Input files are in: $INPUT_DIR"
echo "Log file: $LOG_FILE"
echo "" 