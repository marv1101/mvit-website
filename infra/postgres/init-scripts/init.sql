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
-- ── Rechte für drizzle-Migrationen ──────────────────────────────────────────
-- drizzle-kit führt beim Migrieren `CREATE SCHEMA IF NOT EXISTS "drizzle"`
-- aus (für sein Journal __drizzle_migrations). PostgreSQL prüft das
-- CREATE-Privileg auf DB-Ebene dabei AUCH wenn das Schema schon existiert –
-- daher braucht der App-User zwingend CREATE auf der Datenbank.
-- Das Tabellen-Schema wird ausschließlich über Migrationen erzeugt
-- (mvit-webV2-api/drizzle), NICHT hier. Seed-Daten: postgres/seed.sql
-- (nach der ersten Migration einspielen).
GRANT CREATE ON DATABASE "mvit" TO "mvit-dev-rw";
GRANT ALL ON SCHEMA public TO "mvit-dev-rw";


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