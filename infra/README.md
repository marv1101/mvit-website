# MVIT-Website Stack mit Nginx & SSL/TLS

Diese Docker Compose Konfiguration errichtet einen vollständigen Production-Ready Stack mit:
- **PostgreSQL** Database
- **Backend API** (Node.js/Express mit TypeScript)
- **Frontend** (React mit Bun)
- **Nginx** Reverse Proxy mit SSL/TLS
- **Certbot** SSL-Zertifikat Management (Let's Encrypt)
- **Drupal** CMS (optional)

## Vorbereitung

### 1. DNS-Einträge vorbereiten
Stelle sicher, dass deine Domain `mphion.de` auf die IP-Adresse des Servers zeigt:
```
A Record: mphion.de    → server_ip
A Record: www.mphion.de → server_ip
```

### 2. Umgebungsvariablen konfigurieren
```bash
cd infra
nano .env
```

### 3. Ports freigeben (Firewall)
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 4242/tcp  # PostgreSQL (nur intern!)
```

## Deployment

### Stack starten (ersten Mal mit SSL-Setup)
```bash
cd infra
docker-compose up --build -d
```

Die folgenden Schritte finden automatisch statt:
1. Nginx startet und wartet auf Zertifikat
2. Certbot generiert automatisch SSL-Zertifikate von Let's Encrypt
3. Nginx wird mit SSL-Konfiguration neu geladen
4. API und Frontend sind über die Domain erreichbar

### Status überprüfen
```bash
docker-compose ps
docker-compose logs -f nginx
docker-compose logs -f certbot
```

## Zugang nach Deployment

- **Frontend**: https://mphion.de
- **API**: https://mphion.de/api/
- **Drupal**: https://mphion.de/drupal/ (falls aktiviert)

> ⚠️ Nutze HTTP (Port 80) wird automatisch zu HTTPS (Port 443) umgeleitet

## SSL-Zertifikat Management

### Zertifikat-Status prüfen
```bash
docker-compose exec certbot certbot certificates
```

### Manuelle Zertifikat-Erneuerung
```bash
docker-compose exec certbot certbot renew --dry-run
```

Die automatische Erneuerung läuft täglich um 2 Uhr morgens.

## Nginx Konfiguration

Die Nginx-Konfiguration (`nginx/nginx.conf`) enthält:
- ✅ Automatische HTTP → HTTPS Umleitung
- ✅ Rate Limiting (Frontend: 30 r/s, API: 10 r/s)
- ✅ Gzip-Kompression
- ✅ Security Headers (HSTS, X-Frame-Options, etc.)
- ✅ Reverse Proxy für API, Frontend & Drupal

### Routes
- `/` → Frontend (React App)
- `/api/` → Backend API
- `/drupal/` → Drupal CMS

## Troubleshooting

### Certbot Fehler: "Connection refused"
```bash
# Certbot braucht Nginx zum Laufen. Stelle sicher Nginx läuft:
docker-compose logs nginx
```

### SSL Zertifikat wird nicht erstellt
```bash
# Überprüfe DNS Propagation:
nslookup mphion.de
dig mphion.de

# Schau in den Certbot Logs:
docker-compose logs certbot
```

### Nginx gibt 502 Bad Gateway
```bash
# API/Frontend nicht erreichbar
docker-compose exec nginx curl -s http://api:3000/api/ | head
docker-compose exec nginx curl -s http://frontend:3001/
```

## Sicherheit

- ✅ SSL/TLS mit modernen Cipher Suites
- ✅ HSTS aktiviert (Strict-Transport-Security)
- ✅ X-Frame-Options: SAMEORIGIN
- ✅ API & Frontend intern (nicht direkt exposed)
- ✅ PostgreSQL nur auf localhost:4242

## Volumes

| Volume | Zweck |
|--------|-------|
| `pg_volume` | PostgreSQL Datenbank |
| `letsencrypt_volume` | SSL Zertifikate & Keys |
| `certbot_www` | Certbot Validierungsverzeichnis |

## Mit Podman statt Docker

Falls du Podman nutzt:
```bash
podman-compose up --build -d
```

## Logs überwachen

```bash
# Alle Services
docker-compose logs -f

# Nur Nginx
docker-compose logs -f nginx

# Nur API
docker-compose logs -f api

# Mit Zeitstempel
docker-compose logs -f --timestamps
```

## Stack stoppen

```bash
docker-compose down

# Mit Volumes löschen (VORSICHT!)
docker-compose down -v
```

## Support

Für Fragen oder Probleme, überprüfe:
- Docker Logs: `docker-compose logs [SERVICE]`
- Zertifikat Status: `docker-compose exec certbot certbot certificates`
- Nginx Status: `docker-compose exec nginx nginx -T`
