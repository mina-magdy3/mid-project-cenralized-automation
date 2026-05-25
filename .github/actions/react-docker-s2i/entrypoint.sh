#!/bin/bash
# Location: .github/actions/react-docker-s2i/entrypoint.sh
set -e

echo "Starting isolated Docker-in-Docker engine..."
dockerd --host=unix:///var/run/docker.sock &

echo "Waiting for Docker daemon to initialize..."
until docker info >/dev/null 2>&1; do
    sleep 1
done
echo "Docker Daemon is live and active!"

REGISTRY=$INPUT_REGISTRY
USERNAME=$INPUT_USERNAME
PASSWORD=$INPUT_PASSWORD
IMAGE_NAME=$INPUT_IMAGE_NAME
TAG=$INPUT_TAG

FINAL_IMAGE="${REGISTRY}/${IMAGE_NAME}"

# Log in to registry
echo "$PASSWORD" | docker login "$REGISTRY" -u "$USERNAME" --password-stdin

# 👑 FIX: Point the build flag directly to the internal image path we baked in
docker build -f /usr/local/bin/Dockerfile.react -t "$FINAL_IMAGE:$TAG" .

# Push to GHCR
if docker push "$FINAL_IMAGE:$TAG"; then
    IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$FINAL_IMAGE:$TAG" | cut -d'@' -f2)
    echo "image_name=${FINAL_IMAGE}:${TAG}" >> "$GITHUB_OUTPUT"
    echo "image_digest=${IMAGE_DIGEST}" >> "$GITHUB_OUTPUT"
    echo "push_status=push_success" >> "$GITHUB_OUTPUT"
else
    echo "push_status=failed" >> "$GITHUB_OUTPUT"
    exit 1
fi
