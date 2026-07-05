#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INFRA="$ROOT/infra"

echo "=== MVIT Development Environment ==="
echo ""

# ── 1. Docker-Services starten ──────────────────────────────────────────
echo ">>> Starte Docker-Services (Postgres, Drupal, pgAdmin) ..."
docker compose -f "$INFRA/compose.dev.yaml" up -d --build --wait
echo "    ✅ Docker-Services laufen"
echo ""

# ── 2. Abhängigkeiten prüfen ────────────────────────────────────────────
if [ ! -d "$ROOT/mvit-webV2-api/node_modules" ]; then
  echo ">>> Installiere API-Abhängigkeiten ..."
  (cd "$ROOT/mvit-webV2-api" && npm install)
fi

if [ ! -d "$ROOT/mvits-webV2/mvits-webV2/node_modules" ]; then
  echo ">>> Installiere Frontend-Abhängigkeiten ..."
  (cd "$ROOT/mvits-webV2/mvits-webV2" && bun install)
fi

# ── 3. Dev-Server starten ────────────────────────────────────────────────
echo ">>> Starte API (Port 3000) ..."
(cd "$ROOT/mvit-webV2-api" && npm run dev) &
API_PID=$!

echo ">>> Starte Frontend (Port 3001) ..."
(cd "$ROOT/mvits-webV2/mvits-webV2" && bun dev) &
FRONTEND_PID=$!

echo ""
echo "=== Übersicht ============================================="
echo "  Frontend : http://localhost:3001"
echo "  API      : http://localhost:3000"
echo "  Postgres : localhost:4242"
echo "  Drupal   : http://localhost:8081"
echo "  pgAdmin  : http://localhost:5050 (dev@localhost / dev)"
echo "==========================================================="
echo ""

# ── 4. Cleanup bei Strg+C ────────────────────────────────────────────────
cleanup() {
  echo ""
  echo ">>> Stoppe Dev-Server ..."
  kill $API_PID $FRONTEND_PID 2>/dev/null || true
  wait $API_PID $FRONTEND_PID 2>/dev/null || true
  echo "    ✅ Dev-Server gestoppt"
  echo ""
  echo "Docker-Services laufen weiter."
  echo "Zum Stoppen:  docker compose -f infra/compose.dev.yaml down"
}

trap cleanup EXIT INT TERM

wait
