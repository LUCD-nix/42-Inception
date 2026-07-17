#!/bin/sh
set -eu

# tests the current configuration
nginx -t

exec "$@"
