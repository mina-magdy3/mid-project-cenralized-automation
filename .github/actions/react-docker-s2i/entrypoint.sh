#!/bin/bash
set -e

dockerd --host=unix://var/usr/docker.sock &
until docker info >/dev/null 2>&1; do
  sleep 1
done

REGISTRY=$INPUT_REGISTRY
USERNAME=$INPUT_USERNAME
PASSWORD=$INPUT_PASSWORD
IMAGE_NAME=$INPUT_IMAGE_NAME
TAG=$INPUT_TAG

FINAL_IMAGE="${REGISTRY}/${USERNAME}/${IMAGE_NAME}:${TAG}"

echo "$PASSWORD" | docker login "$REGISTRY" -u "$USERNAME" --password-stdin

if [ ! -d "dist" ]; then
    echo "push_status=failed" >> "$GITHUB_OUTPUT"
    exit 1
fi

docker build -f .github/actions/react-docker-s2i/Dockerfile.react -t "$FINAL_IMAGE:$TAG" .

if docker push "$FINAL_IMAGE:$TAG"; then
    IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$FINAL_IMAGE:$TAG" | cut -d'@' -f2)
    
    echo "image_name=${FINAL_IMAGE}:${TAG}" >> "$GITHUB_OUTPUT"
    echo "image_digest=${IMAGE_DIGEST}" >> "$GITHUB_OUTPUT"
    echo "push_status=success" >> "$GITHUB_OUTPUT"
else
    echo "push_status=failed" >> "$GITHUB_OUTPUT"
    exit 1
fi
