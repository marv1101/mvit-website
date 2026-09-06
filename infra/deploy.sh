#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════════
# MVIT-Website – Update-Skript (VPS)
# ────────────────────────────────────────────────────────────────────────────
# Bringt den Stack auf den aktuellen Stand: git pull → migrations → pull/build →
# rolling restart. Soll nach bereits erfolgtem setup.sh-periodisch genutzt werden.
# ════════════════════════════════════════════════════════════════════════════
set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/website/mvit-website}"
BRANCH="${BRANCH:-main}"
INFRA="$REPO_DIR/infra"
COMPOSE="docker compose -f $INFRA/compose-prod.yaml"

# Farben (nur bei Terminal)
if [ -t 1 ]; then
  C_GREEN='\033[0;32m'; C_YELLOW='\033[1;33m'; C_RED='\033[0;31m'; C_NC='\033[0m'
else
  C_GREEN=''; C_YELLOW=''; C_RED=''; C_NC=''
fi
info()  { printf "${C_GREEN}✓${C_NC} %s\n"  "$*"; }
warn()  { printf "${C_YELLOW}!${C_NC} %s\n" "$*"; }
err()   { printf "${C_RED}✗${C_NC} %s\n" "$*" >&2; }
step()  { printf "\n${C_YELLOW}── %s ──${C_NC}\n" "$*"; }

[ -d "$REPO_DIR/.git" ] || { err "Repo nicht gefunden: $REPO_DIR"; exit 1; }

# ── 1. Aktuellen Stand holen ─────────────────────────────────────────────────
step "Repo aktualisieren"
git -C "$REPO_DIR" fetch --quiet origin "$BRANCH"
git -C "$REPO_DIR" checkout "$BRANCH"
git -C "$REPO_DIR" reset --hard "origin/$BRANCH"
info "Repo auf Stand origin/$BRANCH."

# ── 2. DB-Migrationen anwenden ───────────────────────────────────────────────
# Wird NUR ausgeführt, wenn der migrations-Service in der CI/CD nicht bereits vorher
# dran war. Fehlertolerant: falls keine ausstehenden Migrations vorhanden sind.
step "Datenbank-Migrationen"
if $COMPOSE run --rm --no-deps api npx drizzle-kit migrate --config drizzle.config.ts 2>/dev/null; then
  info "Migrationen angewendet."
else
  warn "Migrationen übersprungen oder nicht konfiguriert – bitte manuell prüfen."
fi

# ── 3. Images aktualisieren ──────────────────────────────────────────────────
step "Images aktualisieren"
# Strategie: bei CI/CD-Push mit TAG in .env -> pull; sonst lokal bauen.
if grep -qE '^TAG=[^l].*' "$INFRA/.env" 2>/dev/null; then
  $COMPOSE pull
  info "Images aktualisiert via Pull."
else
  $COMPOSE build --pull
  info "Images lokal neu gebaut."
fi

# ── 4. Stack neu starten (kein Down – kurzfristiger Rolling-Neustart) ─────────
step "Stack aktualisieren"
$COMPOSE up -d --wait
info "Stack läuft mit aktualisiertem Stand."

# ── 5. Dangling-Images aufräumen ──────────────────────────────────────────────
step "Aufräumen"
docker image prune -f >/dev/null 2>&1 || true
info "Verwaiste Images entfernt."

step "Update abgeschlossen"
$COMPOSE ps