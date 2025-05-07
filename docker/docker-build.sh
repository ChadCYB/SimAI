#!/bin/bash

# SimAI Docker Build Script
# This script builds the SimAI Docker image and optionally runs it

set -e  # Exit on any error

# Default values
IMAGE_NAME="simai"
IMAGE_TAG="latest"
RUN_AFTER_BUILD=false
MOUNT_VOLUME=false
GPU_ENABLED=true

# Print usage information
function show_help {
    echo "SimAI Docker Build Script"
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -r, --run               Run the container after building"
    echo "  -v, --volume            Mount the current directory as volume"
    echo "  -n, --name NAME         Set the image name (default: simai)"
    echo "  -t, --tag TAG           Set the image tag (default: latest)"
    echo "  --no-gpu                Run without GPU support"
    echo
    echo "Example:"
    echo "  $0 --run --volume       Build and run with current directory mounted"
    exit 0
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -r|--run)
            RUN_AFTER_BUILD=true
            shift
            ;;
        -v|--volume)
            MOUNT_VOLUME=true
            shift
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -t|--tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        --no-gpu)
            GPU_ENABLED=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Build the Docker image
echo "Building SimAI Docker image: $IMAGE_NAME:$IMAGE_TAG"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

# Run the container if requested
if [ "$RUN_AFTER_BUILD" = true ]; then
    DOCKER_RUN_CMD="docker run -it"
    
    # Add GPU support if enabled
    if [ "$GPU_ENABLED" = true ]; then
        DOCKER_RUN_CMD="$DOCKER_RUN_CMD --gpus all"
    fi
    
    # Add volume mount if requested
    if [ "$MOUNT_VOLUME" = true ]; then
        DOCKER_RUN_CMD="$DOCKER_RUN_CMD -v $(pwd):/workspace/data"
    fi
    
    # Add image name
    DOCKER_RUN_CMD="$DOCKER_RUN_CMD $IMAGE_NAME:$IMAGE_TAG"
    
    echo "Running container with command: $DOCKER_RUN_CMD"
    $DOCKER_RUN_CMD
fi

echo "Build completed successfully!" 