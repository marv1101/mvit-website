-- ============================================================================
-- PlanBar Produktbeschreibung für MVIT Website
-- ============================================================================
-- Beschreibung: Fügt die HTML-Produktbeschreibung für PlanBar in die
--              description_page Spalte der offering Tabelle ein.
-- Voraussetzung: PlanBar muss bereits als Eintrag in der offering Tabelle
--                 existieren (id = 2).
-- ============================================================================

-- Option 1: Update bestehender Eintrag (PlanBar hat id = 2)
UPDATE offering
SET description_page = '<div class="space-y-8">

  <!-- Hero Section -->
  <div class="bg-gradient-to-br from-primary/10 via-secondary/30 to-accent/10 rounded-xl p-8 md:p-10 border border-border">
    <h2 class="text-2xl md:text-3xl font-bold text-foreground mb-3">
      Intelligente Schichtplanung für KMU
    </h2>
    <p class="text-lg text-muted-foreground leading-relaxed max-w-3xl">
      PlanBar ist eine webbasierte Dienstplanungsapplikation, die Erstellung, Verwaltung und automatische Optimierung von Schichtplänen unter Berücksichtigung des deutschen Arbeitszeitgesetzes (ArbZG) in einer intuitiven Oberfläche vereint.
    </p>
  </div>

  <!-- Key Features -->
  <div>
    <h3 class="text-xl font-semibold text-foreground mb-5">Hauptfunktionen</h3>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
      <div class="bg-card rounded-lg border border-border p-5 hover:shadow-md transition-shadow">
        <div class="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center mb-3">
          <span class="text-primary text-lg font-bold">📊</span>
        </div>
        <h4 class="font-semibold text-foreground mb-2">Dashboard</h4>
        <p class="text-sm text-muted-foreground">Übersicht über Mitarbeiter, heutige Schichten, offene Wünsche und aktuelle Dienstpläne auf einen Blick.</p>
      </div>
      <div class="bg-card rounded-lg border border-border p-5 hover:shadow-md transition-shadow">
        <div class="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center mb-3">
          <span class="text-primary text-lg font-bold">🤖</span>
        </div>
        <h4 class="font-semibold text-foreground mb-2">KI-Optimierung</h4>
        <p class="text-sm text-muted-foreground">Automatische Schichtverteilung mit Google OR-Tools CP-SAT-Solver unter Einhaltung aller gesetzlichen Vorgaben.</p>
      </div>
      <div class="bg-card rounded-lg border border-border p-5 hover:shadow-md transition-shadow">
        <div class="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center mb-3">
          <span class="text-primary text-lg font-bold">⚖️</span>
        </div>
        <h4 class="font-semibold text-foreground mb-2">ArbZG-konform</h4>
        <p class="text-sm text-muted-foreground">Automatische Prüfung von 11h Ruhezeit, max. 10h Arbeitstag, Sonntagsruhe und weiteren Vorgaben.</p>
      </div>
      <div class="bg-card rounded-lg border border-border p-5 hover:shadow-md transition-shadow">
        <div class="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center mb-3">
          <span class="text-primary text-lg font-bold">🖱️</span>
        </div>
        <h4 class="font-semibold text-foreground mb-2">Drag & Drop</h4>
        <p class="text-sm text-muted-foreground">Interaktiver Kalender für manuelle Schichtzuweisungen mit intuitiver Drag-and-Drop-Bedienung.</p>
      </div>
      <div class="bg-card rounded-lg border border-border p-5 hover:shadow-md transition-shadow">
        <div class="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center mb-3">
          <span class="text-primary text-lg font-bold">👥</span>
        </div>
        <h4 class="font-semibold text-foreground mb-2">Mitarbeiter-Selbstbedienung</h4>
        <p class="text-sm text-muted-foreground">Mitarbeiter können Urlaubsanträge, Wünsche und Nicht-Verfügbarkeiten direkt im System einreichen.</p>
      </div>
      <div class="bg-card rounded-lg border border-border p-5 hover:shadow-md transition-shadow">
        <div class="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center mb-3">
          <span class="text-primary text-lg font-bold">🌙</span>
        </div>
        <h4 class="font-semibold text-foreground mb-2">Dark Mode</h4>
        <p class="text-sm text-muted-foreground">Unterstützung für helles und dunkles Thema für angenehmes Arbeiten zu jeder Tageszeit.</p>
      </div>
    </div>
  </div>

  <!-- So funktioniert es -->
  <div>
    <h3 class="text-xl font-semibold text-foreground mb-5">In 3 Schritten zum optimalen Dienstplan</h3>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="relative">
        <div class="bg-primary text-primary-foreground w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm mb-4">1</div>
        <h4 class="font-semibold text-foreground mb-2">Definieren</h4>
        <p class="text-sm text-muted-foreground">Legen Sie den Zeitraum und die benötigten Rollen (Früh-/Spät-/Nachtschicht) fest. Mitarbeiter können ihre Wünsche und Abwesenheiten eintragen.</p>
      </div>
      <div class="relative">
        <div class="bg-primary text-primary-foreground w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm mb-4">2</div>
        <h4 class="font-semibold text-foreground mb-2">Optimieren</h4>
        <p class="text-sm text-muted-foreground">Der TiTO-Optimierer erstellt automatisch einen fairen und gesetzeskonformen Plan – oder passen Sie Schichten manuell per Drag & Drop an.</p>
      </div>
      <div class="relative">
        <div class="bg-primary text-primary-foreground w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm mb-4">3</div>
        <h4 class="font-semibold text-foreground mb-2">Veröffentlichen</h4>
        <p class="text-sm text-muted-foreground">Reichen Sie den Plan ein. Mitarbeiter werden informiert und können ihre Schichten einsehen. Bei Bedarf kann der Plan jederzeit wiederholt werden.</p>
      </div>
    </div>
  </div>

  <!-- Technologie-Highlights -->
  <div class="bg-muted/30 rounded-xl p-6 md:p-8">
    <h3 class="text-xl font-semibold text-foreground mb-5">Technologie</h3>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
      <div class="bg-card rounded-lg p-5 border border-border">
        <h4 class="font-semibold text-foreground mb-2 text-primary">Backend</h4>
        <ul class="text-sm text-muted-foreground space-y-1">
          <li>• Python 3.11+ & FastAPI</li>
          <li>• SQLAlchemy + Alembic</li>
          <li>• JWT-Authentifizierung</li>
          <li>• PostgreSQL</li>
        </ul>
      </div>
      <div class="bg-card rounded-lg p-5 border border-border">
        <h4 class="font-semibold text-foreground mb-2 text-primary">Optimierer (TiTO)</h4>
        <ul class="text-sm text-muted-foreground space-y-1">
          <li>• Google OR-Tools CP-SAT</li>
          <li>• Warteschlangen-basiert</li>
          <li>• Horbare Worker-Prozesse</li>
          <li>• Automatisches Retry</li>
        </ul>
      </div>
      <div class="bg-card rounded-lg p-5 border border-border">
        <h4 class="font-semibold text-foreground mb-2 text-primary">Frontend</h4>
        <ul class="text-sm text-muted-foreground space-y-1">
          <li>• React 18 + TypeScript</li>
          <li>• Tailwind CSS + shadcn/ui</li>
          <li>• Drag & Drop Kalender</li>
          <li>• Echtzeit-Status</li>
        </ul>
      </div>
    </div>
  </div>

  <!-- ArbZG Compliance -->
  <div>
    <h3 class="text-xl font-semibold text-foreground mb-5">Arbeitsrechtliche Konformität</h3>
    <p class="text-muted-foreground mb-5">PlanBar automatisiert die Einhaltung der wichtigsten Vorgaben des Arbeitszeitgesetzes:</p>
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <div class="flex items-start gap-3 bg-card rounded-lg p-4 border border-border">
        <span class="text-green-500 font-bold text-lg">✓</span>
        <div>
          <span class="font-medium text-foreground">11 Stunden Ruhezeit</span>
          <p class="text-sm text-muted-foreground">Zwischen zwei Schichten werden automatisch 11 Stunden Ruhezeit eingehalten.</p>
        </div>
      </div>
      <div class="flex items-start gap-3 bg-card rounded-lg p-4 border border-border">
        <span class="text-green-500 font-bold text-lg">✓</span>
        <div>
          <span class="font-medium text-foreground">Max. 10 Stunden pro Tag</span>
          <p class="text-sm text-muted-foreground">Die tägliche Arbeitszeit überschreitet nicht die erlaubten 10 Stunden.</p>
        </div>
      </div>
      <div class="flex items-start gap-3 bg-card rounded-lg p-4 border border-border">
        <span class="text-green-500 font-bold text-lg">✓</span>
        <div>
          <span class="font-medium text-foreground">Sonntagsruhe</span>
          <p class="text-sm text-muted-foreground">Automatische Beachtung der arbeitsfreien Sonntage gemäß ArbZG.</p>
        </div>
      </div>
      <div class="flex items-start gap-3 bg-card rounded-lg p-4 border border-border">
        <span class="text-green-500 font-bold text-lg">✓</span>
        <div>
          <span class="font-medium text-foreground">Faire Verteilung</span>
          <p class="text-sm text-muted-foreground">Ungleiche Schichten werden automatisch unter Mitarbeitern ausgeglichen.</p>
        </div>
      </div>
    </div>
  </div>

  <!-- Multi-Tenancy & Sicherheit -->
  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <div class="bg-card rounded-lg border border-border p-6">
      <h3 class="text-lg font-semibold text-foreground mb-3">Multi-Tenancy</h3>
      <p class="text-sm text-muted-foreground mb-3">Jeder Kunde läuft in einer vollständig isolierten Umgebung mit eigener Datenbank und eigenem Anwendungs-Stack.</p>
      <ul class="text-sm text-muted-foreground space-y-1">
        <li>• Database-per-Tenant</li>
        <li>• Eigene Subdomain pro Kunde</li>
        <li>• Getrennte Ressourcen-Limits</li>
        <li>• Einfaches Backup & Restore</li>
      </ul>
    </div>
    <div class="bg-card rounded-lg border border-border p-6">
      <h3 class="text-lg font-semibold text-foreground mb-3">Sicherheit</h3>
      <p class="text-sm text-muted-foreground mb-3">Enterprise-Grade Sicherheit für Ihre sensiblen Personaldaten.</p>
      <ul class="text-sm text-muted-foreground space-y-1">
        <li>• JWT mit HttpOnly-Cookies</li>
        <li>• bcrypt-Passwort-Hashing</li>
        <li>• Rollen-basierte Zugriffskontrolle</li>
        <li>• SSL/TLS Verschlüsselung</li>
      </ul>
    </div>
  </div>

  <!-- CTA -->
  <div class="bg-gradient-to-r from-primary to-accent rounded-xl p-8 md:p-10 text-center text-primary-foreground">
    <h3 class="text-2xl font-bold mb-3">Bereit für effizientere Schichtplanung?</h3>
    <p class="text-lg opacity-90 mb-6 max-w-2xl mx-auto">
      Vereinbaren Sie eine unverbindliche Demo und erleben Sie, wie PlanBar Ihre Dienstplanung automatisiert und vereinfacht.
    </p>
    <div class="flex flex-col sm:flex-row gap-4 justify-center">
      <a href="#contact" class="inline-block px-8 py-3 bg-card text-foreground font-semibold rounded-lg hover:shadow-xl transition-all">
        Demo anfordern
      </a>
      <a href="mailto:admin@mphion.de" class="inline-block px-8 py-3 border-2 border-primary-foreground text-primary-foreground font-semibold rounded-lg hover:bg-primary-foreground/10 transition-all">
        Kontakt aufnehmen
      </a>
    </div>
  </div>

</div>'
WHERE id = 2;

-- ============================================================================
-- Alternative: Neuen Eintrag erstellen (falls PlanBar noch nicht existiert)
-- ============================================================================
-- INSERT INTO offering (title, description, description_page, icon, category, features, price)
-- VALUES (
--   'PlanBar',
--   'Intelligente Dienstplanung für Apotheken und KMI. Optimieren Sie Ihre Schichtpläne mit KI-gestützter Automatisierung unter Einhaltung des Arbeitszeitgesetzes.',
--   '<div class="space-y-8">...</div>',  -- HTML von oben hier einfügen
--   'CalendarDays',
--   1,
--   '["Mitarbeiterverwaltung mit Arbeitszeiten & Pausen", "KI-gestützte Schichtoptimierung", "Mitarbeiterwunsch-Verwaltung", "Dashboard mit Echtzeit-Statistiken", "ArbZG-konforme Planung", "Dark Mode"]',
--   0
-- );

-- ============================================================================
-- Verifikation: Prüfe ob der Update erfolgreich war
-- ============================================================================
-- SELECT id, title, length(description_page) AS description_length
-- FROM offering
-- WHERE id = 2;
