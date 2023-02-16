#!/bin/sh
set -e

echo '
┌────────────────────────────────────────────────────┐
│                                                    │
│                                                    │
│             This image is deprecated.              │
│      We will not offer support for this image      │
│             and it will not be updated.            │
│                                                    │
│                                                    │
└────────────────────────────────────────────────────┘

Docker Compose is now available from the docker repos:
https://docs.docker.com/engine/install/

And also for direct download:
https://github.com/docker/compose

──────────────────────────────────────────────────────'

set -- docker compose "$@"

exec "$@"
