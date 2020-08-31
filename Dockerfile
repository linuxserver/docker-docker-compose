ARG DOCKER_VERSION=19.03.8

FROM docker:${DOCKER_VERSION} AS docker-cli

FROM lsiobase/ubuntu:bionic AS build

ARG COMPOSE_VERSION

RUN apt-get update && apt-get install --no-install-recommends -y \
    curl \
    gcc \
    git \
    libc-dev \
    libffi-dev \
    libgcc-6-dev \
    libssl-dev \
    make \
    openssl \
    python3-dev \
    python3-pip \
    zlib1g-dev

COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker

RUN \
 mkdir -p /compose && \
 if [ -z ${COMPOSE_VERSION+x} ]; then \
    COMPOSE_VERSION=$(curl -sX GET "https://api.github.com/repos/docker/compose/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 git clone https://github.com/docker/compose.git && \
 cd /compose && \
 git checkout "${COMPOSE_VERSION}" && \
 pip3 install virtualenv==20.0.30 && \
 pip3 install tox==3.19.0 && \
 PY_ARG=$(printf "$(python3 -V)" | awk '{print $2}' | awk 'BEGIN{FS=OFS="."} NF--' | sed 's|\.||g' | sed 's|^|py|g') && \
 sed -i "s|envlist = .*|envlist = ${PY_ARG},pre-commit|g" tox.ini && \
 tox --notest && \
 mkdir -p dist && \
 chmod 777 dist && \
 /compose/.tox/${PY_ARG}/bin/pip3 install -q -r requirements-build.txt && \
 echo "$(script/build/write-git-sha)" > compose/GITSHA && \
 export PATH="/compose/pyinstaller:${PATH}" && \
 /compose/.tox/${PY_ARG}/bin/pyinstaller --exclude-module pycrypto --exclude-module PyInstaller docker-compose.spec && \
 ls -la dist/ && \
 ldd dist/docker-compose && \
 mv dist/docker-compose /usr/local/bin && \
 docker-compose version

############## runtime stage ##############
FROM lsiobase/ubuntu:bionic

ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

COPY --from=build /compose/docker-compose-entrypoint.sh /usr/local/bin/docker-compose-entrypoint.sh
COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=build /usr/local/bin/docker-compose /usr/local/bin/docker-compose
ENTRYPOINT ["sh", "/usr/local/bin/docker-compose-entrypoint.sh"]
