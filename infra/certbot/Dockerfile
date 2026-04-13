FROM certbot/certbot:latest

# Install additional tools
RUN apk add --no-cache wget curl bash
RUN apk add --no-cache docker-cli

# Copy entrypoint script
COPY entrypoint.sh /

# Make script executable
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /etc/letsencrypt

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
