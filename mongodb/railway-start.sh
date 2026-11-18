#!/bin/sh
# Railway wrapper for MongoDB. The official entrypoint creates the root user
# only when the data directory is empty, and without these variables it would
# start with access control off. Refuse to start rather than do that.
set -e
if [ -z "$MONGO_INITDB_ROOT_USERNAME" ] || [ -z "$MONGO_INITDB_ROOT_PASSWORD" ]; then
  echo "railway-start: MONGO_INITDB_ROOT_USERNAME and MONGO_INITDB_ROOT_PASSWORD must be set" >&2
  exit 1
fi
exec docker-entrypoint.sh "$@"
