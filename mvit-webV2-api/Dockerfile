# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm install
RUN npm audit fix --force

# Copy source code
COPY . .

# Production stage
FROM node:22-alpine

WORKDIR /app

# Install runtime dependencies only
COPY package*.json ./
RUN npm ci --only=production

# Copy built files from builder stage
COPY --from=builder /app /app

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/', (r) => {if (r.statusCode !== 404) throw new Error(r.statusCode)})"

# Start application
CMD ["npm", "start"]
