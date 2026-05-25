#!/bin/bash
set -e

REGISTRY=$INPUT_REGISTRY
USERNAME=$INPUT_USERNAME
PASSWORD=$INPUT_PASSWORD
IMAGE_NAME=$INPUT_IMAGE_NAME
TAG=$INPUT_TAG

FINAL_IMAGE="${REGISTRY}/${USERNAME}/${IMAGE_NAME}:${TAG}"

echo "$PASSWORD" | docker login "$REGISTRY" -u "$USERNAME" --password-stdin

pwd
ls -la
cd React-Frontend
ls -la
ls -la dist || echo "dist is missing"

# if [ ! -d "dist" ]; then
#     echo "push_status=failed" >> "$GITHUB_OUTPUT"
#     exit 1
# fi

docker build -f .github/actions/react-docker-s2i/Dockerfile.react -t "$FINAL_IMAGE" .

if docker push "$FINAL_IMAGE"; then
    IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$FINAL_IMAGE" | cut -d'@' -f2)
    
    echo "image_name=${FINAL_IMAGE}" >> "$GITHUB_OUTPUT"
    echo "image_digest=${IMAGE_DIGEST}" >> "$GITHUB_OUTPUT"
    echo "push_status=success" >> "$GITHUB_OUTPUT"
else
    echo "push_status=failed" >> "$GITHUB_OUTPUT"
    exit 1
fi
