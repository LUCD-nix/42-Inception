#!/bin/sh
set -eu

SSL_DIR="/etc/nginx/ssl"
SSL_CERT="$SSL_DIR/nginx.crt"
SSL_KEY="$SSL_DIR/nginx.key"
SSL_SUBJECT="${SSL_SUBJECT:-/C=FR/ST=IDF/L=Paris/O=42/OU=Inception/CN=localhost}"

mkdir -p "$SSL_DIR"

if [ ! -f "$SSL_CERT" ] || [ ! -f "$SSL_KEY" ]; then
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$SSL_KEY" \
    -out "$SSL_CERT" \
    -subj "$SSL_SUBJECT"
fi

chmod 600 "$SSL_KEY"
chmod 644 "$SSL_CERT"

# tests the current configuration
nginx -t

exec "$@"
