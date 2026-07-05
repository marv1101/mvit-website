--
-- PostgreSQL database dump
--

\restrict BPpwpEZ4qWUo9fhNfXERKPM67TViNljKzV22EmOcG2hPSr95Om09Q3igJC3gAZk

-- Dumped from database version 16.12 (Debian 16.12-1.pgdg13+1)
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-06 19:10:17 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: mvit-web-admin
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO "mvit-web-admin";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 216 (class 1259 OID 16517)
-- Name: contact; Type: TABLE; Schema: public; Owner: mvit-dev-rw
--

CREATE TABLE public.contact (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    message text NOT NULL
);


ALTER TABLE public.contact OWNER TO "mvit-dev-rw";

--
-- TOC entry 215 (class 1259 OID 16516)
-- Name: contact_id_seq; Type: SEQUENCE; Schema: public; Owner: mvit-dev-rw
--

ALTER TABLE public.contact ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.contact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 18670)
-- Name: offering; Type: TABLE; Schema: public; Owner: mvit-dev-rw
--

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

--
-- TOC entry 218 (class 1259 OID 16533)
-- Name: offering_category; Type: TABLE; Schema: public; Owner: mvit-dev-rw
--

CREATE TABLE public.offering_category (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(1024)
);


ALTER TABLE public.offering_category OWNER TO "mvit-dev-rw";

--
-- TOC entry 217 (class 1259 OID 16532)
-- Name: offering_category_id_seq; Type: SEQUENCE; Schema: public; Owner: mvit-dev-rw
--

ALTER TABLE public.offering_category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.offering_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 219 (class 1259 OID 18669)
-- Name: offering_id_seq; Type: SEQUENCE; Schema: public; Owner: mvit-dev-rw
--

ALTER TABLE public.offering ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.offering_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 3431 (class 0 OID 16517)
-- Dependencies: 216
-- Data for Name: contact; Type: TABLE DATA; Schema: public; Owner: mvit-dev-rw
--

COPY public.contact (id, name, email, subject, message) FROM stdin;
1	Marian	Marian@example.de	Test	Testmessage
2	Marian Voigtländer	marian11.01.2003@gmail.com	Test	test
\.


--
-- TOC entry 3435 (class 0 OID 18670)
-- Dependencies: 220
-- Data for Name: offering; Type: TABLE DATA; Schema: public; Owner: mvit-dev-rw
--

COPY public.offering (id, title, description, description_page, icon, category, features, price) FROM stdin;
1	Test	Gute Leistung	<p> Testtext aus der <b>Datenbank</b> für meine Seite </p>	Cloud	1	["test", "123", "und noch was"]	0
2	PlanBar	Intelligente Dienstplanung für Apotheken. Optimieren Sie Ihre Schichtpläne mit KI-gestützter Automatisierung.	<div class="space-y-12"><div class="bg-gradient-to-br from-primary/10 to-accent/10 rounded-2xl p-8 md:p-12"><h2 class="text-3xl font-bold mb-4">Dienstplanung neu gedacht</h2><p class="text-lg text-muted-foreground max-w-3xl">PlanBar ist die moderne Cloud-Lösung für Ihre Apotheke.</p></div><div><h2 class="text-2xl font-bold mb-8">Alle Funktionen im Überblick</h2><div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"><div class="bg-card border border-border rounded-xl p-6"><h3 class="font-semibold text-lg mb-2">Mitarbeiterverwaltung</h3><p class="text-muted-foreground">Verwalten Sie Stammdaten, Arbeitszeiten und Pausenregelungen.</p></div><div class="bg-card border border-border rounded-xl p-6"><h3 class="font-semibold text-lg mb-2">KI-gestützte Optimierung</h3><p class="text-muted-foreground">Intelligenter Algorithmus für optimale Schichtpläne.</p></div></div></div></div>	CalendarDays	2	["Mitarbeiterverwaltung","KI-gestützte Schichtoptimierung","Mitarbeiterwunsch-Verwaltung","Dashboard"]	0
\.


--
-- TOC entry 3433 (class 0 OID 16533)
-- Dependencies: 218
-- Data for Name: offering_category; Type: TABLE DATA; Schema: public; Owner: mvit-dev-rw
--

COPY public.offering_category (id, name, description) FROM stdin;
1	Cloud	Die Cloud bietet Unternehmen die Möglichkeit enorme Leistung von globaler IT-Infrastruktur zu nutzen.
2	Software	Eigene und Drittanbieter-Softwareprodukte.
\.


--
-- TOC entry 3442 (class 0 OID 0)
-- Dependencies: 215
-- Name: contact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mvit-dev-rw
--

SELECT pg_catalog.setval('public.contact_id_seq', 2, true);


--
-- TOC entry 3443 (class 0 OID 0)
-- Dependencies: 217
-- Name: offering_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mvit-dev-rw
--

SELECT pg_catalog.setval('public.offering_category_id_seq', 2, true);


--
-- TOC entry 3444 (class 0 OID 0)
-- Dependencies: 219
-- Name: offering_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mvit-dev-rw
--

SELECT pg_catalog.setval('public.offering_id_seq', 2, true);


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


-- Completed on 2026-04-06 19:10:17 CEST

--
-- PostgreSQL database dump complete
--

\unrestrict BPpwpEZ4qWUo9fhNfXERKPM67TViNljKzV22EmOcG2hPSr95Om09Q3igJC3gAZk

