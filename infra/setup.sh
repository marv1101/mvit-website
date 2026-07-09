#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════════
# MVIT-Website – Bootstrap-Skript für den VPS (mphion.de)
# ────────────────────────────────────────────────────────────────────────────
# Setzt den gesamten Stack in einem Lauf auf:
#   1. Docker-Engine + Compose-Plugin installieren (falls nicht vorhanden)
#   2. Repo klonen (falls nicht vorhanden) / git pull (falls vorhanden)
#   3. .env aus Vorlage erzeugen (interaktiv, falls noch nicht vorhanden)
#   4. Images bauen und Stack starten (Caddy übernimmt HTTPS automatisch)
#
# Aufruf auf dem VPS:
#   curl -fsSL https://raw.githubusercontent.com/marv1101/mvit-website/main/infra/setup.sh | bash
#
# Oder nach manuellem Klon:
#   bash infra/setup.sh
# ════════════════════════════════════════════════════════════════════════════
set -euo pipefail

REPO_URL="https://github.com/marv1101/mvit-website.git"
REPO_DIR="${REPO_DIR:-$HOME/mvit-website}"
BRANCH="${BRANCH:-main}"

# Farben (nur wenn Terminal)
if [ -t 1 ]; then
  C_GREEN='\033[0;32m'; C_YELLOW='\033[1;33m'; C_RED='\033[0;31m'; C_NC='\033[0m'
else
  C_GREEN=''; C_YELLOW=''; C_RED=''; C_NC=''
fi
info()  { printf "${C_GREEN}✓${C_NC} %s\n"  "$*"; }
warn()  { printf "${C_YELLOW}!${C_NC} %s\n" "$*"; }
err()   { printf "${C_RED}✗${C_NC} %s\n" "$*" >&2; }
step()  { printf "\n${C_YELLOW}── %s ──${C_NC}\n" "$*"; }

need_root() {
  if [ "$(id -u)" -ne 0 ]; then
    warn "Skript benötigt Root-Rechte für die Docker-Installation. Re-Run mit sudo."
    exec sudo -E bash "$0" "$@"
  fi
}

# ── 1. Docker installieren (falls fehlt) ──────────────────────────────────────
step "Docker-Engine prüfen"
if ! command -v docker >/dev/null 2>&1; then
  info "Docker nicht vorhanden – Installation wird vorbereitet."
  need_root "$@"
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg lsb-release ufw
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
$(. /etc/os-release; echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
  info "Docker installiert."
else
  info "Docker ist bereits installiert ($(docker --version))."
fi

# ── 2. Repo klonen / aktualisieren ────────────────────────────────────────────
step "Repository vorbereiten ($REPO_DIR)"
if [ ! -d "$REPO_DIR/.git" ]; then
  git clone --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
  info "Repo geklont nach $REPO_DIR"
else
  warn "Repo existiert – versuche Pull."
  git -C "$REPO_DIR" fetch --quiet origin "$BRANCH"
  git -C "$REPO_DIR" checkout "$BRANCH"
  git -C "$REPO_DIR" reset --hard "origin/$BRANCH"
  info "Repo auf Stand origin/$BRANCH gebracht."
fi

INFRA="$REPO_DIR/infra"
cd "$INFRA"

# ── 3. .env erzeugen (interaktiv, falls nicht vorhanden) ─────────────────────
step "Umgebungsvariablen (.env)"
if [ ! -f "$INFRA/.env" ]; then
  cp "$INFRA/.env.example" "$INFRA/.env"
  warn ".env wurde aus Vorlage erzeugt. Bitte Secrets anpassen:"
  warn "  nano $INFRA/.env"
  echo
  if [ -t 0 ]; then
    read -r -p "Drücke ENTER nach dem Editieren, um fortzufahren …" _
  else
    err ".env existiert noch nicht und stdin ist nicht interaktiv (curl|bash)."
    err "Bitte erst manuell anlegen: cp $INFRA/.env.example $INFRA/.env"
    exit 1
  fi
else
  info ".env vorhanden – wird verwendet."
fi

# ── 4. Firewall (nur 80/443/22) ───────────────────────────────────────────────
step "Firewall (ufw)"
if command -v ufw >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
  ufw allow 22/tcp  || true
  ufw allow 80/tcp  || true
  ufw allow 443/tcp || true
  ufw allow 443/udp || true  # HTTP/3 (QUIC)
  echo "y" | ufw enable || true
  info "ufw konfiguriert (22, 80, 443/tcp+udp offen)."
else
  warn "ufw nicht verfügbar – Firewall-Schritt übersprungen."
fi

# ── 5. Stack bauen & starten ──────────────────────────────────────────────────
step "Stack bauen & starten"
docker compose -f "$INFRA/compose-prod.yaml" build --pull
docker compose -f "$INFRA/compose-prod.yaml" up -d --wait
info "Stack läuft."

# ── 6. Status & Hinweise ──────────────────────────────────────────────────────
step "Fertig"
echo
echo "  Frontend : https://mphion.de"
echo "  API      : https://mphion.de/api/"
echo "  Health   : https://mphion.de/api/health"
echo "  Drupal   : https://mphion.de/drupal/"
echo
echo "  Logs     : docker compose -f $INFRA/compose-prod.yaml logs -f"
echo "  Stop     : docker compose -f $INFRA/compose-prod.yaml down"
echo "  Update   : bash $INFRA/deploy.sh"
echo
info "Deployment abgeschlossen. Caddy bezieht das Zertifikat beim ersten Start automatisch."
warn "Erster Start braucht ~30-60s bis das HTTPS-Zertifikat ausgestellt ist."