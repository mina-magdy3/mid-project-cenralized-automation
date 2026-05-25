# Location: .github/actions/react-docker-s2i/Dockerfile
FROM docker:24.0-dind

RUN apk add --no-cache bash curl git

# 👑 FIX: Copy the React Dockerfile directly into the action container image
COPY Dockerfile.react /usr/local/bin/Dockerfile.react
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]