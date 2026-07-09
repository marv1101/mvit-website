# MVIT-Website – Production Stack mit Caddy

Vollständiger Production-Ready Stack auf dem VPS (`mphion.de`):

- **Caddy** Reverse Proxy mit automatischem HTTPS (Let's Encrypt) – ersetzt Nginx + Certbot
- **PostgreSQL 16** Datenbank
- **Backend API** (Node.js/Express + Drizzle, TypeScript)
- **Frontend** (React + Bun)
- **Drupal 10** CMS (optional)

## One-Liner-Deployment auf dem VPS

> Der VPS muss über die Domain `mphion.de` erreichbar sein (A-Record auf die Server-IP).

```bash
curl -fsSL https://raw.githubusercontent.com/marv1101/mvit-website/main/infra/setup.sh | bash
```

Das Skript erledigt:
1. Docker & Compose-Plugin installieren (falls nicht vorhanden)
2. Repo nach `~/mvit-website` klonen
3. `.env` aus Vorlage anlegen (interaktiv auszufüllen)
4. UFW-Firewall freigeben (22, 80, 443 TCP + UDP)
5. Images bauen & Stack starten (Caddy bezieht Zertifikat automatisch)

Alternativ Schritt-für-Schritt:

```bash
git clone https://github.com/marv1101/mvit-website.git ~/mvit-website
cd ~/mvit-website/infra
cp .env.example .env
$EDITOR .env           # Secrets eintragen!
docker compose -f compose-prod.yaml up -d --build --wait
```

## Update (nach Änderungen auf main)

```bash
bash ~/mvit-website/infra/deploy.sh
```

Oder via CI/CD: bei Push auf `main` baut GitHub Actions die Images und pusht
sie in GHCR; das `deploy.yml`-Workflow SSHt auf den VPS und führt ein
`docker compose pull && up -d` aus.

## Zugang nach Deployment

| Service  | URL                              |
|----------|----------------------------------|
|Frontend  | https://mphion.de                |
| API      | https://mphion.de/api/           |
| Health   | https://mphion.de/api/health     |
| Drupal   | https://mphion.de/drupal/        |

HTTP → HTTPS-Umleitung übernimmt Caddy automatisch.

## CI/CD-Pipeline

| Workflow                  | Datei                          | Zweck                         |
|---------------------------|--------------------------------|------------------------------|
| CI – Tests                | `.github/workflows/test.yml`   | Lint, vitest, Frontend build, compose/caddy validate |
| Build & Publish           | `.github/workflows/build.yml`  | Docker-Images nach GHCR pushen (api, frontend) |
| Deploy                    | `.github/workflows/deploy.yml` | SSH auf VPS → pull & up        |

Benötigte Repository Secrets (unter Settings → Secrets and variables → Actions):

- `SSH_HOST` – VPS-Host (`mphion.de`)
- `SSH_USER` – Benutzer (`mvit-deploy` bzw. root)
- `SSH_PRIVATE_KEY` – privater Key ohne Passphrase
- `SSH_PORT` *(optional, default 22)*

## Ansible – Server wiederholbar provisionieren

```bash
cd ansible
# inventory.yml anpassen (VPS-IP/Domain, Repo-Dir)
ansible-playbook -i inventory.yml playbooks/setup-server.yml
```

Installiert Docker, UFW, fail2ban, logrotate, richtet den `mvit-deploy`-User ein.

## Monitoring (optional)

```bash
docker compose -f compose-prod.yaml -f compose.monitoring.yaml up -d
```

Startet kilometerweit: Prometheus, cAdvisor, Node-Exporter, Loki, Promtail, Grafana.
Grafana ist nur im internen Netzwerk erreichbar – via SSH-Tunnel zugreifen:

```bash
ssh -L 3000:grafana:3000 user@mphion.de
# dann http://localhost:3000 (admin / Passwort aus GRAFANA_ADMIN_PASSWORD in .env)
```

## Kommando-Übersicht

```bash
# Status
docker compose -f compose-prod.yaml ps
docker compose -f compose-prod.yaml logs -f caddy

# Stack stoppen
docker compose -f compose-prod.yaml down

# Stack komplett löschen (VORSICHT – inkl. DB-Daten!)
docker compose -f compose-prod.yaml down -v

# Update via CI/CD images
docker compose -f compose-prod.yaml pull && docker compose -f compose-prod.yaml up -d --wait

# Erzwinge Caddy-Zertifikat-Renewal
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

## Sicherheit

- ✅ Automatisches HTTPS via Caddy / Let's Encrypt
- ✅ HTTP/3 (QUIC) über Port 443/udp
- ✅ HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy via Caddy
- ✅ Container laufen als `no-new-privileges`
- ✅ API/Frontend/Drupal intern (nicht direkt exposed – nur über Caddy)
- ✅ PostgreSQL nur im internen Network
- ✅ Realy-Limiting pro IP in Caddy (optional über Plugin)

## Kompatibilität

`compose.yaml` (mit Nginx + Certbot) ist weiterhin verfügbar, wird aber nicht mehr
aktiv empfohlen – `compose-prod.yaml` (Caddy) ist der neue Production-Standard.