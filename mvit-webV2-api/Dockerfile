# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm install
RUN npm audit fix ; exit 0

# Copy source code
COPY . .

# Production stage
FROM node:22-alpine

WORKDIR /app

# Install runtime dependencies only
COPY package*.json ./
RUN npm ci --omit=dev

# Copy application source from builder (without overwriting node_modules)
COPY --from=builder /app/bin ./bin
COPY --from=builder /app/routes ./routes
COPY --from=builder /app/services ./services
COPY --from=builder /app/models ./models
COPY --from=builder /app/validators ./validators
COPY --from=builder /app/db ./db
COPY --from=builder /app/drizzle ./drizzle
COPY --from=builder /app/public ./public
COPY --from=builder /app/app.ts ./app.ts
COPY --from=builder /app/tsconfig.json ./tsconfig.json

# Run as non-root user
USER node

# Expose port
EXPOSE 3000

# Health check (exits 0 on success, 1 on failure/error)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "const req = require('http').get('http://localhost:3000/api/health', (r) => { process.exit(r.statusCode < 400 ? 0 : 1); }); req.on('error', () => process.exit(1));"

# Start application
CMD ["npm", "start"]
