#!/bin/bash
set -e

# 1. Start the internal Docker daemon binary process directly in the background
echo "Starting isolated Docker-in-Docker engine..."
dockerd --host=unix:///var/run/docker.sock &

# Wait until the engine responds to health commands
echo "Waiting for Docker daemon to initialize..."
until docker info >/dev/null 2>&1; do
    sleep 1
done
echo "Docker Daemon is live and active!"

# 2. Map tracking parameters out of GitHub Action inputs
REGISTRY=$INPUT_REGISTRY
USERNAME=$INPUT_USERNAME
PASSWORD=$INPUT_PASSWORD
IMAGE_NAME=$INPUT_IMAGE_NAME
TAG=$INPUT_TAG

FINAL_IMAGE="${REGISTRY}/${IMAGE_NAME}"

# 3. Log in to your container registry
echo "$PASSWORD" | docker login "$REGISTRY" -u "$USERNAME" --password-stdin

# 4. Build your production container from the true repository root context
docker build -f .github/actions/react-docker-s2i/Dockerfile.react -t "$FINAL_IMAGE:$TAG" .

# 5. Push to GHCR and export metrics securely to the pipeline output file
if docker push "$FINAL_IMAGE:$TAG"; then
    IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$FINAL_IMAGE:$TAG" | cut -d'@' -f2)
    echo "image_name=${FINAL_IMAGE}:${TAG}" >> "$GITHUB_OUTPUT"
    echo "image_digest=${IMAGE_DIGEST}" >> "$GITHUB_OUTPUT"
    echo "push_status=push_success" >> "$GITHUB_OUTPUT"
else
    echo "push_status=failed" >> "$GITHUB_OUTPUT"
    exit 1
fi
