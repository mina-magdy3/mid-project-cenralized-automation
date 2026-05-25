#!/bin/bash
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

FINAL_IMAGE="${REGISTRY}/${USERNAME}/${IMAGE_NAME}:${TAG}"

echo "$PASSWORD" | docker login "$REGISTRY" -u "$USERNAME" --password-stdin

docker build -f /usr/local/bin/Dockerfile.react -t "$FINAL_IMAGE" .

if docker push "$FINAL_IMAGE"; then
    IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$FINAL_IMAGE" | cut -d'@' -f2)
    echo "image_name=${FINAL_IMAGE}" >> "$GITHUB_OUTPUT"
    echo "image_digest=${IMAGE_DIGEST}" >> "$GITHUB_OUTPUT"
    echo "push_status=push_success" >> "$GITHUB_OUTPUT"
else
    echo "push_status=failed" >> "$GITHUB_OUTPUT"
    exit 1
fi
