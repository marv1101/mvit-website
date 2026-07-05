-- Database: mvit


CREATE ROLE "mvit-dev-rw" WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  NOBYPASSRLS
  ENCRYPTED PASSWORD 'SCRAM-SHA-256$4096:dDPD6l7rq+diO0+yKMpe3Q==$xTV9ajEEbDAeWkPYu9eyoEalhZUCixMPgml/jyFHi5I=:iHuKCvvJA2L6HP5+A7QUMlxVWcddbXMww5/XDtzcLxs=';

CREATE ROLE drupal_read WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  NOBYPASSRLS
  ENCRYPTED PASSWORD 'SCRAM-SHA-256$4096:+Dtzis2R923xDU8B0O/ehg==$do8dmjzkE+JBrBbjXEgzOPjWxvHFoNcDRXvjK5vQczo=:VVxjuR6WyYSXmNUj/ygIHT32GJOec0ayU2AZdXmn1Ww=';

CREATE ROLE drupal_user WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  NOBYPASSRLS
  ENCRYPTED PASSWORD 'SCRAM-SHA-256$4096:kERb8rzdh0ZyVCMFN3pB9g==$zRD9+uT6A2PHpcNspIXrxpm7owe1/JQ8Q6hDQspQ/8s=:amEmX3ZusKp5ohEQJZ98a+Poara6qRMN946soWEqhng=';

CREATE DATABASE "mvit"
    WITH
    OWNER = "mvit-admin"
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

GRANT ALL ON DATABASE "mvit" TO "mvit-admin";

GRANT TEMPORARY, CONNECT ON DATABASE "mvit" TO "mvit-dev-rw";

ALTER DEFAULT PRIVILEGES FOR ROLE "mvit-admin"
GRANT SELECT ON SEQUENCES TO "mvit-dev-rw";

ALTER DEFAULT PRIVILEGES FOR ROLE "mvit-admin"
GRANT USAGE ON TYPES TO "mvit-dev-rw";

\c "mvit"

CREATE TABLE "contact" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "contact_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"name" varchar(255) NOT NULL,
	"email" varchar(255) NOT NULL,
	"subject" varchar(255) NOT NULL,
	"message" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "offering" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "offering_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"title" varchar(255) NOT NULL,
	"description" varchar(1024) NOT NULL,
	"description_page" text,
	"icon" text NOT NULL,
	"category" integer NOT NULL,
	"features" json,
	"price" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "offering_category" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "offering_category_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"name" varchar(255) NOT NULL,
	"description" varchar(1024)
);
--> statement-breakpoint
ALTER TABLE "offering" ADD CONSTRAINT "offering_category_offering_category_id_fk" FOREIGN KEY ("category") REFERENCES "public"."offering_category"("id") ON DELETE no action ON UPDATE no action;

ALTER TABLE public.contact OWNER TO "mvit-dev-rw";

ALTER TABLE public.offering OWNER TO "mvit-dev-rw";

ALTER TABLE public.offering_category OWNER TO "mvit-dev-rw";

INSERT INTO offering_category (name, description) VALUES ('Cloud', 'Die Cloud bietet Unternehmen die Möglichkeit enorme Leistung von globaler IT-Infrastruktur zu nutzen.');
INSERT INTO offering_category (name, description) VALUES ('Software', 'Eigene und Drittanbieter-Softwareprodukte, die wir anbieten und betreuen.');

INSERT INTO offering (title, description, description_page, icon, category, features, price) VALUES
  ('Test', 'Gute Leistung', '<p> Testtext aus der <b>Datenbank</b> für meine Seite </p>', 'Cloud', 1, '["test", "123", "und noch was"]', 0),
  ('PlanBar', 'Intelligente Dienstplanung für Apotheken. Optimieren Sie Ihre Schichtpläne mit KI-gestützter Automatisierung und berücksichtigen Sie Mitarbeiterwünsche, Qualifikationen und gesetzliche Vorgaben.',
   '<div class="space-y-12"><div class="bg-gradient-to-br from-primary/10 to-accent/10 rounded-2xl p-8 md:p-12"><h2 class="text-3xl font-bold mb-4">Dienstplanung neu gedacht</h2><p class="text-lg text-muted-foreground max-w-3xl">PlanBar ist die moderne Cloud-Lösung für Ihre Apotheke. Erstellen Sie in Minuten optimierte Dienstpläne, die Mitarbeiterwünsche berücksichtigen, Qualifikationen beachten und gesetzliche Vorgaben einhalten.</p></div><div><h2 class="text-2xl font-bold mb-8">Alle Funktionen im Überblick</h2><div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"><div class="bg-card border border-border rounded-xl p-6"><h3 class="font-semibold text-lg mb-2">Mitarbeiterverwaltung</h3><p class="text-muted-foreground">Verwalten Sie Stammdaten, Arbeitszeiten, Pausenregelungen und farbliche Markierungen aller Mitarbeiter.</p></div><div class="bg-card border border-border rounded-xl p-6"><h3 class="font-semibold text-lg mb-2">KI-gestützte Optimierung</h3><p class="text-muted-foreground">Unser intelligenter Algorithmus erstellt optimale Schichtpläne unter Berücksichtigung aller Randbedingungen und Wünsche.</p></div><div class="bg-card border border-border rounded-xl p-6"><h3 class="font-semibold text-lg mb-2">Wunschverwaltung</h3><p class="text-muted-foreground">Mitarbeiter können Urlaubs- und Schichtwünsche einreichen, die automatisch in die Planung einfließen.</p></div><div class="bg-card border border-border rounded-xl p-6"><h3 class="font-semibold text-lg mb-2">Rollen & Berechtigungen</h3><p class="text-muted-foreground">Definieren Sie Rollen wie Apotheker oder PKA mit individuellen Berechtigungen.</p></div><div class="bg-card border border-border rounded-xl p-6"><h3 class="font-semibold text-lg mb-2">Dashboard & Statistiken</h3><p class="text-muted-foreground">Auf einen Blick: Offene Wünsche, anstehende Schichten, Mitarbeiterauslastung und mehr.</p></div><div class="bg-card border border-border rounded-xl p-6"><h3 class="font-semibold text-lg mb-2">Pinboard</h3><p class="text-muted-foreground">Interne Kommunikation und Aushänge direkt in der Anwendung für Ihr Team.</p></div><div class="bg-card border border-border rounded-xl p-6"><h3 class="font-semibold text-lg mb-2">Zeitkonten</h3><p class="text-muted-foreground">Erfassen Sie Arbeitszeiten und führen Sie Zeitkonten für Ihre Mitarbeiter nach.</p></div><div class="bg-card border border-border rounded-xl p-6"><h3 class="font-semibold text-lg mb-2">Schichtvorlagen</h3><p class="text-muted-foreground">Hinterlegen Sie wiederkehrende Schichtmodelle (Früh-/Spätschicht) mit Rollenanforderungen.</p></div><div class="bg-card border border-border rounded-xl p-6"><h3 class="font-semibold text-lg mb-2">Automatische Planung</h3><p class="text-muted-foreground">Mit einem Klick wird der optimale Dienstplan erstellt – schnell und zuverlässig.</p></div></div></div><div class="bg-muted/50 rounded-2xl p-8 md:p-12"><h2 class="text-2xl font-bold mb-6">So funktioniert PlanBar</h2><div class="space-y-4"><div class="flex gap-4"><div class="flex-shrink-0 w-10 h-10 rounded-full bg-primary text-primary-foreground flex items-center justify-center font-bold">1</div><div><h3 class="font-semibold">Mitarbeiter anlegen</h3><p class="text-muted-foreground">Erfassen Sie Ihre Mitarbeiter mit Arbeitszeiten, Rollen und individuellen Einstellungen.</p></div></div><div class="flex gap-4"><div class="flex-shrink-0 w-10 h-10 rounded-full bg-primary text-primary-foreground flex items-center justify-center font-bold">2</div><div><h3 class="font-semibold">Schichtmodell definieren</h3><p class="text-muted-foreground">Legen Sie Schichtvorlagen mit benötigten Rollen und Zeiten fest.</p></div></div><div class="flex gap-4"><div class="flex-shrink-0 w-10 h-10 rounded-full bg-primary text-primary-foreground flex items-center justify-center font-bold">3</div><div><h3 class="font-semibold">Wünsche sammeln</h3><p class="text-muted-foreground">Ihre Mitarbeiter teilen ihre Verfügbarkeiten und Wünsche mit.</p></div></div><div class="flex gap-4"><div class="flex-shrink-0 w-10 h-10 rounded-full bg-primary text-primary-foreground flex items-center justify-center font-bold">4</div><div><h3 class="font-semibold">Optimierten Plan erstellen</h3><p class="text-muted-foreground">Mit einem Klick erstellt PlanBar den optimalen Dienstplan.</p></div></div></div></div><div class="text-center bg-gradient-to-r from-primary to-accent rounded-2xl p-8 md:p-12"><h2 class="text-2xl font-bold text-primary-foreground mb-4">Bereit für die moderne Dienstplanung?</h2><p class="text-primary-foreground/80 mb-6 max-w-2xl mx-auto">Testen Sie PlanBar kostenlos und überzeugen Sie sich selbst von der intelligenten Schichtplanung.</p><div class="flex flex-col sm:flex-row gap-4 justify-center"><a href="https://planbar-demo.mphion.de" target="_blank" class="px-8 py-3 bg-card text-foreground rounded-lg font-semibold hover:shadow-lg transition-all">Demo starten</a><a href="#contact" class="px-8 py-3 bg-primary-foreground/10 text-primary-foreground border-2 border-primary-foreground/30 rounded-lg font-semibold hover:bg-primary-foreground/20 transition-all">Kontakt aufnehmen</a></div></div></div>',
   'CalendarDays', 2, '["Mitarbeiterverwaltung mit Arbeitszeiten & Pausen","KI-gestützte Schichtoptimierung","Mitarbeiterwunsch-Verwaltung","Rollenbasiertes Berechtigungssystem","Dashboard mit Echtzeit-Statistiken","Pinboard für Team-Kommunikation","Zeitkonten & Arbeitszeiterfassung","Wiederkehrende Schichtvorlagen","Automatische Dienstplanerstellung"]', 0);

GRANT ALL ON SCHEMA public TO "mvit-dev-rw";


--
-- TOC entry 2049 (class 826 OID 18943)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: -; Owner: mvit-admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "mvit-admin" GRANT SELECT ON SEQUENCES TO "mvit-dev-rw";


--
-- TOC entry 2050 (class 826 OID 18944)
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: -; Owner: mvit-admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "mvit-admin" GRANT ALL ON TYPES TO "mvit-dev-rw";


--
-- TOC entry 2048 (class 826 OID 18942)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: mvit-admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "mvit-admin" GRANT SELECT,INSERT,UPDATE ON TABLES TO "mvit-dev-rw";


GRANT SELECT, UPDATE ON SEQUENCE public.contact_id_seq TO "mvit-dev-rw";

GRANT SELECT, UPDATE ON SEQUENCE public.offering_category_id_seq TO "mvit-dev-rw";

GRANT SELECT, UPDATE ON SEQUENCE public.offering_id_seq TO "mvit-dev-rw";

GRANT SELECT, UPDATE, INSERT ON TABLE public.contact TO "mvit-dev-rw";

GRANT SELECT, UPDATE, INSERT ON TABLE public.offering TO "mvit-dev-rw";

GRANT SELECT, UPDATE, INSERT ON TABLE public.offering_category TO "mvit-dev-rw";



-- Database: drupal

CREATE DATABASE drupal
    WITH
    OWNER = drupal_user
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

ALTER DATABASE drupal
    SET bytea_output TO 'escape';

ALTER DEFAULT PRIVILEGES FOR ROLE "mvit-admin"
GRANT SELECT ON TABLES TO drupal_read;

ALTER DEFAULT PRIVILEGES FOR ROLE "mvit-admin"
GRANT ALL ON TABLES TO drupal_user;