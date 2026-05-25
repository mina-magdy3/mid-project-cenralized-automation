FROM docker:24.0-dind

RUN apk add --no-cache bash curl git

COPY Dockerfile.react /usr/local/bin/Dockerfile.react

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]