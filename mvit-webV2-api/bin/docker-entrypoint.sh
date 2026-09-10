#!/bin/sh
set -e

echo "Running database migrations..."
npx drizzle-kit migrate

echo "Setting up admin user..."
npm run setup-admin

echo "Starting application..."
exec npm start
