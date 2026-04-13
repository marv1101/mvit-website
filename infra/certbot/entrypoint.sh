#!/bin/bash

set -e

DOMAIN="mphion.de"
EMAIL="marvphoto@web.de"
CERTBOT_DIR="/etc/letsencrypt"
CERTBOT_LIVE="$CERTBOT_DIR/live/$DOMAIN"
CERTBOT_ARCHIVE="$CERTBOT_DIR/archive/$DOMAIN"

echo "Waiting for nginx to be ready..."
sleep 5

# Check if certificate already exists
if [ -d "$CERTBOT_LIVE" ] && [ -f "$CERTBOT_LIVE/fullchain.pem" ]; then
    echo "Certificate for $DOMAIN already exists. Attempting renewal..."
    certbot renew --quiet --no-eff-email || echo "Renewal check complete"
else
    echo "Requesting new certificate for $DOMAIN..."
    certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email $EMAIL \
        --agree-tos \
        --no-eff-email \
        --non-interactive \
        -d $DOMAIN \
        -d www.$DOMAIN
fi

echo "Starting renewal daemon..."
# Renewal daemon: check twice daily

certbot renew --quiet --no-eff-email --post-hook "docker exec nginx nginx -s reload"
