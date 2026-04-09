FROM certbot/certbot:latest

# Install additional tools
RUN apk add --no-cache wget curl bash

# Copy entrypoint script
COPY entrypoint.sh /

# Make script executable
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /etc/letsencrypt

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
