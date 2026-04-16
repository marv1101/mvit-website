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

ALTER DEFAULT PRIVILEGES FOR ROLE postgres
GRANT SELECT ON TABLES TO drupal_read;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres
GRANT ALL ON TABLES TO drupal_user;