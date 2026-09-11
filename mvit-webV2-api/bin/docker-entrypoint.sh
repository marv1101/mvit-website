#!/bin/sh
set -e

# Bei explizitem Kommando (z. B. `docker compose run api npx drizzle-kit ...`)
# nur dieses ausführen, statt Migration + Admin-Setup + App-Start.
if [ "$#" -gt 0 ]; then
  exec "$@"
fi

echo "Running database migrations..."
npx drizzle-kit migrate

echo "Setting up admin user..."
npm run setup-admin

echo "Starting application..."
exec npm start
