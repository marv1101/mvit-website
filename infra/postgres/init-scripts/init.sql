-- Database: dev-mvit


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
  ENCRYPTED PASSWORD 'SCRAM-SHA-256$4096:WyHsFiYPrm4qma0ucRx1EA==$osnIivQlLh4kO+3711XGg4MZxDBkFgVIGAFCxZrc6Qc=:e5zOhyEHE3ci1ncMhXNz1I+JAyLt+7lNBaU6jov/8QM=';

CREATE DATABASE "dev-mvit"
    WITH
    OWNER = "mvit-admin"
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

GRANT ALL ON DATABASE "dev-mvit" TO "mvit-admin";

GRANT TEMPORARY, CONNECT ON DATABASE "dev-mvit" TO "mvit-dev-rw";

ALTER DEFAULT PRIVILEGES FOR ROLE "mvit-admin"
GRANT SELECT ON SEQUENCES TO "mvit-dev-rw";

ALTER DEFAULT PRIVILEGES FOR ROLE "mvit-admin"
GRANT USAGE ON TYPES TO "mvit-dev-rw";

\c "dev-mvit"

CREATE TABLE public.contact (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    message text NOT NULL
);


ALTER TABLE public.contact OWNER TO "mvit-dev-rw";

ALTER TABLE public.contact ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.contact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.offering (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    description character varying(1024) NOT NULL,
    description_page text,
    icon text NOT NULL,
    category integer NOT NULL,
    features json,
    price integer NOT NULL
);


ALTER TABLE public.offering OWNER TO "mvit-dev-rw";

CREATE TABLE public.offering_category (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(1024)
);

ALTER TABLE public.offering_category OWNER TO "mvit-dev-rw";

ALTER TABLE public.offering_category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.offering_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.offering ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.offering_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- TOC entry 3281 (class 2606 OID 16523)
-- Name: contact contact_pkey; Type: CONSTRAINT; Schema: public; Owner: mvit-dev-rw
--

ALTER TABLE ONLY public.contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (id);


--
-- TOC entry 3283 (class 2606 OID 16539)
-- Name: offering_category offering_category_pkey; Type: CONSTRAINT; Schema: public; Owner: mvit-dev-rw
--

ALTER TABLE ONLY public.offering_category
    ADD CONSTRAINT offering_category_pkey PRIMARY KEY (id);


--
-- TOC entry 3285 (class 2606 OID 18676)
-- Name: offering offering_pkey; Type: CONSTRAINT; Schema: public; Owner: mvit-dev-rw
--

ALTER TABLE ONLY public.offering
    ADD CONSTRAINT offering_pkey PRIMARY KEY (id);


--
-- TOC entry 3286 (class 2606 OID 18677)
-- Name: offering offering_category_offering_category_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: mvit-dev-rw
--

ALTER TABLE ONLY public.offering
    ADD CONSTRAINT offering_category_offering_category_id_fk FOREIGN KEY (category) REFERENCES public.offering_category(id);


--
-- TOC entry 3441 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: mvit-web-admin
--

GRANT ALL ON SCHEMA public TO "mvit-dev-rw";


--
-- TOC entry 2049 (class 826 OID 18943)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT SELECT ON SEQUENCES TO "mvit-dev-rw";


--
-- TOC entry 2050 (class 826 OID 18944)
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TYPES TO "mvit-dev-rw";


--
-- TOC entry 2048 (class 826 OID 18942)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT SELECT,INSERT,UPDATE ON TABLES TO "mvit-dev-rw";


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