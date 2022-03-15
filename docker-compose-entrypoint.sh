#!/bin/sh
set -e

set -- docker compose "$@"

exec "$@"