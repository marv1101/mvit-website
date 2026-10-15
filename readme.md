# MVIT Website

Persönliche Website, gestaltet im Stil einer modernen Unternehmenswebsite, mit
integriertem Admin-Backend, CMS-gestütztem Content-Workflow und produktivem
Deployment auf einem einzelnen VPS.

---

## Inhaltsverzeichnis

1. [Überblick](#überblick)
2. [Features](#features)
3. [Tech-Stack](#tech-stack)
4. [Architektur](#architektur)
5. [Projektstruktur](#projektstruktur)
6. [Lokale Entwicklung](#lokale-entwicklung)
7. [Deployment](#deployment)
8. [Konfiguration (Environment)](#konfiguration-environment)
9. [Sicherheit](#sicherheit)
10. [Monitoring](#monitoring)
11. [Nützliche Links](#nützliche-links)

---

## Überblick

MVIT Website ist die persönliche Website des Maintainers, technisch und
optisch aber wie ein kleines Produkt umgesetzt: eigene API, separates Frontend
mit server-side rendering (SSR), content managment system (CMS) für redaktionellen Content, automatisierte CI/CD-Pipeline und einem
gehärteten Production-Deployment hinter einem Reverse-Proxy.

Das Repository ist ein Monorepo und enthält drei logische Einheiten:

| Pfad                     | Rolle                                                             |
| ------------------------ | ----------------------------------------------------------------- |
| `mvit-webV2-api/`        | REST-API (Node.js + Express + TypeScript + Drizzle/PostgreSQL)   |
| `mvits-webV2/`           | Frontend (Bun + React 19 + SSR + Tailwind v4)                    |
| `infra/`, `ansible/`     | Infrastruktur, Docker-Compose, Server-Provisionierung            |
| `.github/`               | GitHub-Actions: Tests, Container-Build, Deploy                   |

---

## Features

- **Marketing-Site** mit öffentlichen Seiten (Home, Blog, Produkte, Referenzen,
  Impressum, Datenschutz).
- **Admin-Bereich** mit Login, Dashboard und CRUD-UIs für Angebote,
  Kategorien, Referenzen und Kontaktanfragen.
- **Server-Side Rendering** (SSR) durch Bun.serve für SEO-kritische Routen
  (`/`, `/product/:id`, `/blog/:id`, `/reference/:id`, `/impressum`,
  `/datenschutz`) inkl. dynamisch generierter `sitemap.xml` und `robots.txt`.
- **CMS-Integration**: Blogposts werden aus einer Drupal-11-Instanz bezogen,
  ohne dass das Backend Drupal nach außen exposed.
- **Besuchsstatistik** mit Datenschutzfreundlichem IP-Hashing
  (SHA-256 + Pepper), Retention-Cron und Tages-Aggregaten.
- **CI/CD**: Tests -> Container-Build -> GHCR
- **TLS-Termination** und HTTP/3 durch Caddy.
- **Optional**: Monitoring-Stack (Prometheus, Grafana, Loki, cAdvisor,
  node-exporter) als Overlay-Compose-Datei.

---

## Tech-Stack

### Backend – `mvit-webV2-api/`

| Kategorie         | Technologie                                          |
| ----------------- | ---------------------------------------------------- |
| Runtime           | Node.js 22 (Alpine im Container)                     |
| Sprache           | TypeScript 7 (strict, `nodenext`, ESM)               |
| HTTP-Framework    | Express 5                                            |
| ORM               | Drizzle ORM + Drizzle Kit (Migrationen)             |
| Datenbank-Treiber | `pg` (PostgreSQL-Client)                             |
| Auth              | JWT (HS256) im HttpOnly-Cookie + Bcrypt (12 Rounds)  |
| Sicherheit        | Helmet, CORS, `express-rate-limit`, `isomorphic-dompurify` |
| Logging           | morgan                                               |
| Scheduling        | node-cron (Visit-Retention, Cleanup)                 |
| Tests             | Vitest + Supertest, Coverage ≥ 90 % (v8)            |
| Linting           | ESLint                                               |

### Frontend – `mvits-webV2/`

| Kategorie        | Technologie                                       |
| ---------------- | ------------------------------------------------- |
| Runtime          | Bun (Hot-Reload Dev, SSR Prod)                    |
| Sprache          | TypeScript                                        |
| UI-Framework     | React 19 + React Router 7                         |
| Styling          | Tailwind CSS v4 (über `bun-plugin-tailwind`)      |
| UI-Primitives    | shadcn/ui (49 Komponenten) auf Basis von Radix UI  |
| Icons            | lucide-react                                      |
| Formulare        | react-hook-form                                   |
| Charts           | recharts (Admin-Dashboard)                        |
| Editor           | Toast UI Editor + CodeMirror (HTML-Modus)         |
| Notifications    | sonner, react-hot-toast                           |
| Sanitization     | DOMPurify (SSR-safe)                              |
| Theme            | light/dark/system via `next-themes`               |
| SSR              | `Bun.serve` + React-SSR, dynamische `sitemap.xml` |

### CMS

| Kategorie  | Technologie                                |
| ---------- | ----------------------------------------- |
| CMS        | Drupal 11 (Apache, trixie)                |
| Inhalt     | Blogartikel (Body, Image, Field-Data)     |
| Anbindung  | Read-only Zugriff auf Drupal-DB (`drupal_read`) für Frontend |

### Datenbank

| Kategorie       | Technologie                             |
| --------------- | ---------------------------------------- |
| Engine          | PostgreSQL 16                            |
| Datenbanken     | `mvit` (App) + `drupal` (CMS)            |
| Rollen          | `mvit-admin`, `mvit-dev-rw`, `drupal_user`, `drupal_read` |
| Tuning          | 512 MB shared_buffers, WAL-Kompression, Connection-Limit 200 |

### Infrastruktur

| Kategorie         | Technologie                                     |
| ----------------- | ----------------------------------------------- |
| Container         | Docker + Docker Compose (Multi-Stage Builds)    |
| Reverse-Proxy     | **Caddy 2** (Prod) – TLS, HTTP/3, Security-Header |
| Legacy-Proxy      | Nginx + Certbot (nicht mehr empfohlen)          |
| Server-Setup      | Ansible (Roles: `docker`, `security`, `deploy_user`) |

### CI/CD

| Workflow          | Trigger                                | Aufgabe                                |
| ----------------- | --------------------------------------- | -------------------------------------- |
| `test.yml`        | push `main`, PR                         | Vitest, Bun-Build, Compose-Config-Check |
| `build.yml`       | push `main`, Tag `v*`                   | Matrix-Build & Push zu `ghcr.io`        |
---

## Architektur

### Komponentenübersicht

```
┌─────────────────────────────────────────────────────────────────────┐
│                              Internet                               │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Caddy 2  (Reverse Proxy / TLS-Terminator)                          │
│  - HTTPS (Let's Encrypt), HTTP/3 (QUIC)                              │
│  - Security-Header (HSTS, X-Frame-Options, CSP …)                   │
│  - Routing:                                                         │
│      /api/*    →  mvit-api:3000                                      │
│      /drupal/* →  drupal:80                                          │
│      *         →  mvit-frontend:3001                                 │
└─────────────────────────────────────────────────────────────────────┘
        │                     │                        │
        ▼                     ▼                        ▼
┌──────────────────┐  ┌─────────────────┐    ┌──────────────────────┐
│   mvit-api       │  │     drupal      │    │   mvit-frontend      │
│  (Node 22 +      │  │   (Drupal 11    │    │  (Bun + React 19 +   │
│   Express 5 +    │  │    Apache,      │    │   Tailwind v4 + SSR) │
│   Drizzle ORM)   │  │    trixie)      │    │                      │
│  Port 3000       │  │  Port 80        │    │  Port 3001           │
└──────────────────┘  └─────────────────┘    └──────────────────────┘
        │                     │
        └──────────┬──────────┘
                   ▼
        ┌────────────────────┐
        │   PostgreSQL 16    │
        │   DBs: mvit, drupal│
        └────────────────────┘
```

### Datenflüsse

- **Öffentliche Seiten** – Browser ↔ Caddy ↔ Frontend (SSR via Bun.serve).
  Das Frontend ruft SSR-seitig die API über das interne Docker-Netz
  (`INTERNAL_API_BASE_URL=http://mvit-api:3000/api`) auf.
- **Admin-CRUD** – Browser ↔ Caddy ↔ Frontend ↔ API ↔ Postgres.
- **Blogposts** – API liest Read-only aus `drupal`-DB -> gibt eine normalisierte
  JSON-Struktur zurück; das Frontend rendert die Artikel.
- **Kontaktformular** – POST `/api/contacts` (Rate-Limit 5/15 min) →
  `contact`-Tabelle in der App-DB.
- **Statistik** – `POST /api/visits` (öffentlich, Rate-Limit 120/15 min) →
  `page_visit` (gepuffert, 5-s-Flush) → Cron-Aggregation in `visit_daily`
  und Retention-TTL (`VISIT_RETENTION_DAYS`, Default 90).

### Auth-Modell

- Login per `POST /api/auth/login` (Rate-Limit 5/15 min) → JWT (HS256,
  24-h-TTL) wird als `HttpOnly`-Cookie `admin_token` (in Prod `Secure`,
  `SameSite=Lax`) zurückgegeben.
- Token ist **invalid**, sobald `admin_user.password_changed_at > iat` – so
  wird ein serverseitiges Session-Invalidate nach Passwortwechsel erreicht.
- `force_password_change`-Flag im `admin_user`-Datensatz erzwingt den ersten
  Passwortwechsel.
- Geschützte Routen im Frontend (`/admin/*`) werden über `<ProtectedRoute />`
  abgefangen, das `GET /api/auth/me` prüft und ggf. weiterleitet.

### Verzeichnis-Layout (Top-Level)

```
mvit website/
├── mvit-webV2-api/         # Backend (Express + Drizzle)
├── mvits-webV2/            # Frontend (Bun + React 19)
│   └── mvits-webV2/        #   ↑ redundante Verschachtelung (siehe STYLEGUIDE)
├── infra/                  # Compose-Files, Caddyfile, Postgres, Drupal, Monitoring
├── ansible/                # Server-Provisionierung
├── product-descriptions/   # Marketing-/Inhaltsmaterialien
├── .github/                # Workflows + Dependabot
├── STYLEGUIDE.md           # Naming & Folder Conventions
└── readme.md               # dieses Dokument
```

---

## Lokale Entwicklung

### Voraussetzungen

- Node.js 22
- Bun (für das Frontend)
- Docker + Docker Compose

### Einstieg in einem Schritt

```bash
# Repo klonen
git clone https://github.com/marv1101/mvit-website mvit-website
cd mvit-website

# Dev-Stack (Postgres, Drupal, pgAdmin) starten
bash infra/dev.sh
```

`infra/dev.sh` startet die Docker-Services (`compose.dev.yaml`), dann parallel
API (`npm run dev`) und Frontend (`bun dev`).

### Backend manuell starten

```bash
cd mvit-webV2-api
cp .env.example .env       # siehe Konfiguration unten
npm install
npm run dev                # tsx --watch ./bin/www.ts
npm test                   # Vitest
npm run test:coverage      # Coverage-Report (≥ 90 % Schwellwert)
npm run migrate            # drizzle-kit migrate
```

Der Container-Entrypoint führt nacheinander aus:

1. `npx drizzle-kit migrate`
2. `npm run setup-admin`
3. `exec npm start`

### Frontend manuell starten

```bash
cd mvits-webV2/mvits-webV2
bun install
bun dev                    # Bun-Serve mit HMR auf :3001
bun test
bun run build              # Tailwind-Compile + Bun.build (statisches Bundle)
```

Wichtige Env-Variablen siehe [Konfiguration](#konfiguration-environment).

### Drupal lokal

Drupal wird durch `infra/compose.dev.yaml` mit Port `8081` freigegeben. Der
initiale Login erfolgt mit dem Standard-`admin`-User (Passwort wird beim
Setup ausgegeben); das Backend greift über den internen Hostnamen `drupal`
darauf zu.

---

## Deployment

Das Produktiv-Deployment läuft auf einem einzelnen VPS hinter Caddy. Es gibt
**Docker Compose** (Runtime) und **GitHub Actions** (Build).

### 1. Produktiv-Stack starten

```bash
cd /root/mvit-website/infra
cp .env.example .env       # Werte anpassen (siehe Konfiguration)
TAG=main docker compose -f compose-prod.yaml up -d --wait
```

Stack-Bestandteile (`compose-prod.yaml`):

| Service     | Image / Build                                           | Bemerkung                                  |
| ----------- | -------------------------------------------------------- | ----------------------------------------- |
| `db`        | `postgres:16`                                            | internes Netzwerk, keine Host-Ports       |
| `api`       | `ghcr.io/marv1101/mvit-api:${TAG}`                        | Healthcheck `/api/health`                 |
| `frontend`  | `ghcr.io/marv1101/mvit-frontend:${TAG}`                   | Healthcheck `/`                           |
| `drupal`    | Build aus `./drupal/Dockerfile`                           | wird über `/drupal/*` von Caddy exponiert  |

> Hinweis: Caddy selbst wird aktuell über einen separaten Container mit
> `caddy:2-alpine` und dem mitgelieferten `Caddyfile` betrieben – die
> `Caddyfile` terminiert TLS, setzt Security-Header und verteilt den Traffic
> auf die drei Services. `{$SSL_EMAIL}` wird aus der `.env` gezogen.

### 2. Update / Rollout

`infra/deploy.sh` macht im Wesentlichen:

```bash
git fetch origin
git reset --hard origin/main
TAG="${TAG:-main}" docker compose -f compose-prod.yaml pull
TAG="${TAG:-main}" docker compose -f compose-prod.yaml up -d --wait
docker image prune -f
```

In der CI/CD-Pipeline wird genau dieses Skript via SSH aus dem `deploy.yml`
ausgeführt.

### 3. CI/CD – GitHub Actions

Voraussetzungen (Repository-Secrets):

| Secret            | Beschreibung                                |
| ----------------- | ------------------------------------------- |
| `SSH_HOST`        | VPS-Host (z. B. `mphion.de`)                |
| `SSH_USER`        | Deploy-User (`mvit-deploy` oder `root`)     |
| `SSH_PRIVATE_KEY` | privater SSH-Key                            |
| `SSH_PORT`        | optional, Default `22`                      |

Ablauf:

1. **Tests** (`test.yml`): Vitest im API-Repo, Bun-Build im Frontend,
   `docker compose config` und `caddy validate` für `infra/`.
2. **Build** (`build.yml`): Matrix-Build der beiden Images, Push zu
   `ghcr.io/marv1101/{mvit-api,mvit-frontend}` mit Tags `branch`,
   `semver`, `sha`, `latest`. GHA-Build-Cache aktiv.
3. **Deploy** (`deploy.yml`): Wartet auf den erfolgreichen Build, SSH auf
   den VPS, setzt `TAG` in `.env`, führt `drizzle-kit migrate` aus, dann
   `deploy.sh`, abschließend `curl https://${HOST}/api/health`.

### 4. Staging

Für Staging gibt es einen Override:

```bash
TAG=main docker compose \
  -f compose-prod.yaml \
  -f compose.staging.yaml \
  up -d --wait
```

Ergebnis: Hostname `stage.mphion.de`, **Let's Encrypt Staging-CA** (kein
Rate-Limit-Risiko beim Zertifikats-Test), Ports `8080` und `8443`.

### 5. Monitoring-Overlay (optional)

```bash
TAG=main docker compose \
  -f compose-prod.yaml \
  -f compose.monitoring.yaml \
  up -d --wait
```

Liefert Prometheus, cAdvisor, node-exporter, Loki, Promtail und Grafana.
Grafana-Zugriff wird über `GRAFANA_ADMIN_PASSWORD` aus der `.env`
abgesichert.

---

## Konfiguration (Environment)

### Backend (`mvit-webV2-api/.env`)

| Variable                  | Default / Beispiel                                            |
| ------------------------- | -------------------------------------------------------------- |
| `PORT`                    | `3000`                                                         |
| `DATABASE_URL`            | `postgres://mvit-dev-rw:mvit-dev-password@localhost:4242/mvit` |
| `DRUPAL_DB_URL`           | `postgres://drupal_user:drupal-password@localhost:4242/drupal` |
| `CORS_ORIGIN`             | `http://localhost:3001`                                       |
| `JWT_SECRET`              | **Pflicht**, ≥ 32 Zeichen                                     |
| `PEPPER`                  | Secret für IP-Hashing                                         |
| `TRUST_PROXY_HOPS`        | `0` (Dev) / `1` (Prod, hinter Caddy)                           |
| `VISIT_RETENTION_DAYS`    | `90`                                                           |
| `ADMIN_DEFAULT_USERNAME`  | `admin`                                                        |
| `ADMIN_INITIAL_PASSWORD`  | optional, sonst wird eins generiert und ins Log geschrieben    |

### Frontend (`mvits-webV2/mvits-webV2/.env`)

| Variable                       | Default                                          |
| ------------------------------ | ------------------------------------------------- |
| `PORT`                         | `3001`                                            |
| `BUN_PUBLIC_API_BASE_URL`      | `http://localhost:3000/api` (Prod: `…/api`)       |
| `BUN_PUBLIC_DRUPAL_BASE_URL`   | `http://localhost:8081/drupal`                    |
| `BUN_PUBLIC_SITE_URL`          | `https://mphion.de`                               |
| `INTERNAL_API_BASE_URL`        | `http://mvit-api:3000/api` (Container-intern)     |

> `BUN_PUBLIC_*` werden zur Serve- und Build-Zeit in den Client-Bundle
> inlined.

### Infra (`infra/.env`)

Wird sowohl vom Compose-File als auch vom Caddy-Setup gelesen
(`SSL_EMAIL`, `TAG`, ggf. `GRAFANA_ADMIN_PASSWORD`).

---

## Sicherheit

- **TLS** ausschließlich über Caddy (Let's Encrypt, automatisches Renewal),
  HTTP/3 wird unterstützt.
- **Security-Header** (Caddy + Nginx-Legacy identisch): HSTS, X-Frame-Options
  `SAMEORIGIN`, X-Content-Type-Options `nosniff`, Referrer-Policy,
  X-XSS-Protection.
- **JWT-Cookie** `admin_token`: `HttpOnly`, in Prod `Secure`,
  `SameSite=Lax`, signiert mit HS256, 24 h TTL.
- **Passwort-Hashing**: Bcrypt mit 12 Rounds; Passwortwechsel invalidiert
  offene Tokens sofort.
- **Rate-Limits**: Login 5/15 min, Contact 5/15 min, Visits 120/15 min.
- **IP-Anonymisierung** in `page_visit`: SHA-256(IP + PEPPER) → nur Hash in
  der DB, kein Klartext.
- **Input-Sanitization**: DOMPurify (Server + Client) für alle HTML-Felder,
  Validatoren für Strings (Regex, Längen).
- **Container-Hardening**: `security_opt: no-new-privileges`,
  `read_only`/`tmpfs: /tmp` wo möglich, API läuft als Non-Root-User `node`.
- **Reverse-Proxy-Config** für Drupal: `reverse_proxy=true`,
  `trusted_host_patterns` auf eigene Domains beschränkt, verhindert
  HTTP→HTTPS-Redirect-Loop mit HSTS.
- **Firewall**: UFW erlaubt nur 22, 80, 443; fail2ban gegen SSH-Brute-Force.

---

## Monitoring

Im optionalen `compose.monitoring.yaml`:

| Komponente    | Aufgabe                                              |
| ------------- | ---------------------------------------------------- |
| Prometheus    | Scraping alle 15 s                                   |
| cAdvisor      | Container-Metriken                                   |
| node-exporter | Host-Metriken (CPU, RAM, Disk, Network)              |
| Loki          | Log-Aggregation                                      |
| Promtail      | Log-Shipping (Filter: `com.docker.compose.project=infra`) |
| Grafana       | Dashboards (Login via `GRAFANA_ADMIN_PASSWORD`)      |

Container-Logs sind auf 50–100 MB pro File mit 5 Files Rotation begrenzt
(`json-file` Driver).

---

## Nützliche Links

- [`STYLEGUIDE.md`](./STYLEGUIDE.md) – Naming-Konventionen und
  Refactoring-Hinweise (insb. die redundante Verschachtelung
  `mvits-webV2/mvits-webV2/`).
- [`ansible/README.md`](./ansible/README.md) – Server-Setup im Detail.
- [`infra/README.md`](./infra/README.md) – Compose-Stacks, Caddy, Drupal,
  Postgres.
- API-Endpoints und Datenbankschema siehe jeweilige Sub-README in
  `mvit-webV2-api/` und `mvits-webV2/`.