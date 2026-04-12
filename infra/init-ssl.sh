#!/bin/bash

# Script to initialize SSL certificates for Nginx in the MVIT website stack
# This script temporarily disables SSL in nginx.conf, starts the stack,
# waits for Certbot to generate certificates, then re-enables SSL and reloads Nginx.

set -e  # Exit on any error

# Configuration
NGINX_CONF="./nginx/nginx.conf"
COMPOSE_FILE="compose.yaml"
DOMAIN="mphion.de"
CERT_PATH="./nginx/certbot/conf/live/$DOMAIN/fullchain.pem"

echo "Starting SSL certificate initialization for $DOMAIN..."

# Step 1: Temporarily disable SSL in nginx.conf
echo "Disabling SSL in nginx.conf..."
if grep -q "listen 443 ssl http2" "$NGINX_CONF"; then
    # Comment out the HTTPS server block
    sed -i '/# HTTPS Server/,/# }/ s/^/# /' "$NGINX_CONF"
    echo "SSL disabled in nginx.conf"
else
    echo "SSL already disabled or not found in nginx.conf"
fi

# Step 2: Start Docker Compose stack
echo "Starting Docker Compose stack..."
docker-compose -f "$COMPOSE_FILE" up --build -d

# Step 3: Wait for certificates to be generated
echo "Waiting for Certbot to generate certificates..."
MAX_WAIT=300  # 5 minutes
WAIT_TIME=0
while [ ! -f "$CERT_PATH" ] && [ $WAIT_TIME -lt $MAX_WAIT ]; do
    sleep 10
    WAIT_TIME=$((WAIT_TIME + 10))
    echo "Waiting... ($WAIT_TIME/$MAX_WAIT seconds)"
done

if [ ! -f "$CERT_PATH" ]; then
    echo "Error: Certificate not generated within $MAX_WAIT seconds. Check logs:"
    docker-compose -f "$COMPOSE_FILE" logs certbot
    exit 1
fi

echo "Certificate generated successfully!"

# Step 4: Re-enable SSL in nginx.conf
echo "Re-enabling SSL in nginx.conf..."
if grep -q "#     listen 443 ssl http2" "$NGINX_CONF"; then
    # Uncomment the HTTPS server block
    sed -i '/# HTTPS Server/,/# }/ s/^# //' "$NGINX_CONF"
    echo "SSL re-enabled in nginx.conf"
else
    echo "SSL block not found commented in nginx.conf"
fi

# Step 5: Reload Nginx
echo "Reloading Nginx..."
docker exec nginx nginx -s reload

echo "SSL initialization complete! Your site should now be available at https://$DOMAIN"

# Optional: Show status
echo "Checking container status..."
docker-compose -f "$COMPOSE_FILE" ps