FROM ghcr.io/linuxserver/baseimage-alpine:edge

ARG BUILD_DATE
ARG VERSION
ARG COMPOSE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="TheSpad"

RUN \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache  \
    curl && \
  if [ -z ${COMPOSE_VERSION+x} ]; then \
    COMPOSE_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:docker-cli-compose$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add -U --upgrade --no-cache  \
    docker-cli \
    docker-cli-compose==${COMPOSE_VERSION} && \
  docker compose version

COPY ./docker-compose-entrypoint.sh /usr/local/bin/docker-compose-entrypoint.sh

ENTRYPOINT ["sh", "/usr/local/bin/docker-compose-entrypoint.sh"]
