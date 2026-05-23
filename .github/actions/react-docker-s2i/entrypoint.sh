#!/bin/sh

set -e
REGISTRY=$1
USERNAME=$2
PASSWORD=$3
IMAGE_NAME=$4
TAG=${5:-latest}

SHA_TAG=$(git rev-parse --short HEAD)

FULL_IMAGE="$REGISTRY/$USERNAME/$IMAGE_NAME"

echo "$PASSWORD" | docker login $REGISTRY \
-u $USERNAME \
--password-stdin

npm install
npm run build

docker build \
-f Dockerfile \
-t $FULL_IMAGE:latest \
-t $FULL_IMAGE:$SHA_TAG .

echo "Pushing images..."

docker push $FULL_IMAGE:latest
docker push $FULL_IMAGE:$SHA_TAG

DIGEST=$(docker inspect \
--format='{{index .RepoDigests 0}}' \
$FULL_IMAGE:$SHA_TAG)

echo "image_name=$FULL_IMAGE:$SHA_TAG" >> $GITHUB_OUTPUT
echo "image_digest=$DIGEST" >> $GITHUB_OUTPUT
echo "push_status=success" >> $GITHUB_OUTPUT
