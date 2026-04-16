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

\c "drupal"

--
-- TOC entry 2 (class 3079 OID 16565)
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- TOC entry 4651 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- TOC entry 362 (class 1255 OID 16646)
-- Name: rand(); Type: FUNCTION; Schema: public; Owner: drupal_user
--

CREATE FUNCTION public.rand() RETURNS double precision
    LANGUAGE sql
    AS $$SELECT random();$$;


ALTER FUNCTION public.rand() OWNER TO drupal_user;

--
-- TOC entry 363 (class 1255 OID 16647)
-- Name: substring_index(text, text, integer); Type: FUNCTION; Schema: public; Owner: drupal_user
--

CREATE FUNCTION public.substring_index(text, text, integer) RETURNS text
    LANGUAGE sql
    AS $_$SELECT array_to_string((string_to_array($1, $2)) [1:$3], $2);$_$;


ALTER FUNCTION public.substring_index(text, text, integer) OWNER TO drupal_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 317 (class 1259 OID 18352)
-- Name: ban_ip; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.ban_ip (
    iid integer NOT NULL,
    ip character varying(40) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT ban_ip_iid_check CHECK ((iid >= 0))
);


ALTER TABLE public.ban_ip OWNER TO drupal_user;

--
-- TOC entry 4652 (class 0 OID 0)
-- Dependencies: 317
-- Name: TABLE ban_ip; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.ban_ip IS 'Stores banned IP addresses.';


--
-- TOC entry 4653 (class 0 OID 0)
-- Dependencies: 317
-- Name: COLUMN ban_ip.iid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.ban_ip.iid IS 'Primary Key: unique ID for IP addresses.';


--
-- TOC entry 4654 (class 0 OID 0)
-- Dependencies: 317
-- Name: COLUMN ban_ip.ip; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.ban_ip.ip IS 'IP address';


--
-- TOC entry 316 (class 1259 OID 18351)
-- Name: ban_ip_iid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.ban_ip_iid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ban_ip_iid_seq OWNER TO drupal_user;

--
-- TOC entry 4655 (class 0 OID 0)
-- Dependencies: 316
-- Name: ban_ip_iid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.ban_ip_iid_seq OWNED BY public.ban_ip.iid;


--
-- TOC entry 221 (class 1259 OID 16675)
-- Name: batch; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.batch (
    bid integer NOT NULL,
    token character varying(64) NOT NULL,
    "timestamp" integer NOT NULL,
    batch bytea,
    CONSTRAINT batch_bid_check CHECK ((bid >= 0))
);


ALTER TABLE public.batch OWNER TO drupal_user;

--
-- TOC entry 4656 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE batch; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.batch IS 'Stores details about batches (processes that run in multiple HTTP requests).';


--
-- TOC entry 4657 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN batch.bid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.batch.bid IS 'Primary Key: Unique batch ID.';


--
-- TOC entry 4658 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN batch.token; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.batch.token IS 'A string token generated against the current user''s session id and the batch id, used to ensure that only the user who submitted the batch can effectively access it.';


--
-- TOC entry 4659 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN batch."timestamp"; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.batch."timestamp" IS 'A Unix timestamp indicating when this batch was submitted for processing. Stale batches are purged at cron time.';


--
-- TOC entry 4660 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN batch.batch; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.batch.batch IS 'A serialized array containing the processing data for the batch.';


--
-- TOC entry 220 (class 1259 OID 16674)
-- Name: batch_bid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.batch_bid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.batch_bid_seq OWNER TO drupal_user;

--
-- TOC entry 4661 (class 0 OID 0)
-- Dependencies: 220
-- Name: batch_bid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.batch_bid_seq OWNED BY public.batch.bid;


--
-- TOC entry 242 (class 1259 OID 16873)
-- Name: block_content; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.block_content (
    id integer NOT NULL,
    revision_id bigint,
    type character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT block_content_id_check CHECK ((id >= 0)),
    CONSTRAINT block_content_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.block_content OWNER TO drupal_user;

--
-- TOC entry 4662 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE block_content; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.block_content IS 'The base table for block_content entities.';


--
-- TOC entry 4663 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN block_content.type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content.type IS 'The ID of the target entity.';


--
-- TOC entry 247 (class 1259 OID 16921)
-- Name: block_content__body; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.block_content__body (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    body_value text NOT NULL,
    body_summary text,
    body_format character varying(255),
    CONSTRAINT block_content__body_delta_check CHECK ((delta >= 0)),
    CONSTRAINT block_content__body_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT block_content__body_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.block_content__body OWNER TO drupal_user;

--
-- TOC entry 4664 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE block_content__body; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.block_content__body IS 'Data storage for block_content field body.';


--
-- TOC entry 4665 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN block_content__body.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content__body.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 4666 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN block_content__body.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content__body.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 4667 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN block_content__body.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content__body.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 4668 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN block_content__body.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content__body.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 4669 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN block_content__body.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content__body.langcode IS 'The language code for this data item.';


--
-- TOC entry 4670 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN block_content__body.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content__body.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 245 (class 1259 OID 16900)
-- Name: block_content_field_data; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.block_content_field_data (
    id bigint NOT NULL,
    revision_id bigint NOT NULL,
    type character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    info character varying(255),
    changed integer,
    reusable smallint,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT block_content_field_data_id_check CHECK ((id >= 0)),
    CONSTRAINT block_content_field_data_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.block_content_field_data OWNER TO drupal_user;

--
-- TOC entry 4671 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE block_content_field_data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.block_content_field_data IS 'The data table for block_content entities.';


--
-- TOC entry 4672 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN block_content_field_data.type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content_field_data.type IS 'The ID of the target entity.';


--
-- TOC entry 246 (class 1259 OID 16912)
-- Name: block_content_field_revision; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.block_content_field_revision (
    id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    info character varying(255),
    changed integer,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT block_content_field_revision_id_check CHECK ((id >= 0)),
    CONSTRAINT block_content_field_revision_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.block_content_field_revision OWNER TO drupal_user;

--
-- TOC entry 4673 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE block_content_field_revision; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.block_content_field_revision IS 'The revision data table for block_content entities.';


--
-- TOC entry 241 (class 1259 OID 16872)
-- Name: block_content_id_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.block_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.block_content_id_seq OWNER TO drupal_user;

--
-- TOC entry 4674 (class 0 OID 0)
-- Dependencies: 241
-- Name: block_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.block_content_id_seq OWNED BY public.block_content.id;


--
-- TOC entry 244 (class 1259 OID 16887)
-- Name: block_content_revision; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.block_content_revision (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    langcode character varying(12) NOT NULL,
    revision_user bigint,
    revision_created integer,
    revision_log text,
    revision_default smallint,
    CONSTRAINT block_content_revision_id_check1 CHECK ((id >= 0)),
    CONSTRAINT block_content_revision_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT block_content_revision_revision_user_check CHECK ((revision_user >= 0))
);


ALTER TABLE public.block_content_revision OWNER TO drupal_user;

--
-- TOC entry 4675 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE block_content_revision; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.block_content_revision IS 'The revision table for block_content entities.';


--
-- TOC entry 4676 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN block_content_revision.revision_user; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content_revision.revision_user IS 'The ID of the target entity.';


--
-- TOC entry 248 (class 1259 OID 16937)
-- Name: block_content_revision__body; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.block_content_revision__body (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    body_value text NOT NULL,
    body_summary text,
    body_format character varying(255),
    CONSTRAINT block_content_revision__body_delta_check CHECK ((delta >= 0)),
    CONSTRAINT block_content_revision__body_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT block_content_revision__body_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.block_content_revision__body OWNER TO drupal_user;

--
-- TOC entry 4677 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE block_content_revision__body; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.block_content_revision__body IS 'Revision archive storage for block_content field body.';


--
-- TOC entry 4678 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN block_content_revision__body.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content_revision__body.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 4679 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN block_content_revision__body.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content_revision__body.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 4680 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN block_content_revision__body.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content_revision__body.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 4681 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN block_content_revision__body.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content_revision__body.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 4682 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN block_content_revision__body.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content_revision__body.langcode IS 'The language code for this data item.';


--
-- TOC entry 4683 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN block_content_revision__body.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.block_content_revision__body.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 243 (class 1259 OID 16886)
-- Name: block_content_revision_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.block_content_revision_revision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.block_content_revision_revision_id_seq OWNER TO drupal_user;

--
-- TOC entry 4684 (class 0 OID 0)
-- Dependencies: 243
-- Name: block_content_revision_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.block_content_revision_revision_id_seq OWNED BY public.block_content_revision.revision_id;


--
-- TOC entry 309 (class 1259 OID 17984)
-- Name: cache_access_policy; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_access_policy (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_access_policy OWNER TO drupal_user;

--
-- TOC entry 4685 (class 0 OID 0)
-- Dependencies: 309
-- Name: TABLE cache_access_policy; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_access_policy IS 'Storage for the cache API.';


--
-- TOC entry 4686 (class 0 OID 0)
-- Dependencies: 309
-- Name: COLUMN cache_access_policy.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_access_policy.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4687 (class 0 OID 0)
-- Dependencies: 309
-- Name: COLUMN cache_access_policy.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_access_policy.data IS 'A collection of data to cache.';


--
-- TOC entry 4688 (class 0 OID 0)
-- Dependencies: 309
-- Name: COLUMN cache_access_policy.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_access_policy.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4689 (class 0 OID 0)
-- Dependencies: 309
-- Name: COLUMN cache_access_policy.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_access_policy.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4690 (class 0 OID 0)
-- Dependencies: 309
-- Name: COLUMN cache_access_policy.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_access_policy.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4691 (class 0 OID 0)
-- Dependencies: 309
-- Name: COLUMN cache_access_policy.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_access_policy.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4692 (class 0 OID 0)
-- Dependencies: 309
-- Name: COLUMN cache_access_policy.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_access_policy.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 307 (class 1259 OID 17957)
-- Name: cache_bootstrap; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_bootstrap (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_bootstrap OWNER TO drupal_user;

--
-- TOC entry 4693 (class 0 OID 0)
-- Dependencies: 307
-- Name: TABLE cache_bootstrap; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_bootstrap IS 'Storage for the cache API.';


--
-- TOC entry 4694 (class 0 OID 0)
-- Dependencies: 307
-- Name: COLUMN cache_bootstrap.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_bootstrap.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4695 (class 0 OID 0)
-- Dependencies: 307
-- Name: COLUMN cache_bootstrap.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_bootstrap.data IS 'A collection of data to cache.';


--
-- TOC entry 4696 (class 0 OID 0)
-- Dependencies: 307
-- Name: COLUMN cache_bootstrap.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_bootstrap.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4697 (class 0 OID 0)
-- Dependencies: 307
-- Name: COLUMN cache_bootstrap.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_bootstrap.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4698 (class 0 OID 0)
-- Dependencies: 307
-- Name: COLUMN cache_bootstrap.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_bootstrap.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4699 (class 0 OID 0)
-- Dependencies: 307
-- Name: COLUMN cache_bootstrap.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_bootstrap.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4700 (class 0 OID 0)
-- Dependencies: 307
-- Name: COLUMN cache_bootstrap.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_bootstrap.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 304 (class 1259 OID 17924)
-- Name: cache_config; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_config (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_config OWNER TO drupal_user;

--
-- TOC entry 4701 (class 0 OID 0)
-- Dependencies: 304
-- Name: TABLE cache_config; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_config IS 'Storage for the cache API.';


--
-- TOC entry 4702 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN cache_config.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_config.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4703 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN cache_config.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_config.data IS 'A collection of data to cache.';


--
-- TOC entry 4704 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN cache_config.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_config.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4705 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN cache_config.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_config.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4706 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN cache_config.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_config.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4707 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN cache_config.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_config.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4708 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN cache_config.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_config.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 266 (class 1259 OID 17174)
-- Name: cache_container; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_container (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_container OWNER TO drupal_user;

--
-- TOC entry 4709 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE cache_container; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_container IS 'Storage for the cache API.';


--
-- TOC entry 4710 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN cache_container.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_container.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4711 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN cache_container.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_container.data IS 'A collection of data to cache.';


--
-- TOC entry 4712 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN cache_container.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_container.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4713 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN cache_container.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_container.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4714 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN cache_container.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_container.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4715 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN cache_container.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_container.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4716 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN cache_container.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_container.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 306 (class 1259 OID 17944)
-- Name: cache_data; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_data (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_data OWNER TO drupal_user;

--
-- TOC entry 4717 (class 0 OID 0)
-- Dependencies: 306
-- Name: TABLE cache_data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_data IS 'Storage for the cache API.';


--
-- TOC entry 4718 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN cache_data.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_data.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4719 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN cache_data.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_data.data IS 'A collection of data to cache.';


--
-- TOC entry 4720 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN cache_data.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_data.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4721 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN cache_data.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_data.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4722 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN cache_data.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_data.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4723 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN cache_data.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_data.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4724 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN cache_data.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_data.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 310 (class 1259 OID 17999)
-- Name: cache_default; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_default (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_default OWNER TO drupal_user;

--
-- TOC entry 4725 (class 0 OID 0)
-- Dependencies: 310
-- Name: TABLE cache_default; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_default IS 'Storage for the cache API.';


--
-- TOC entry 4726 (class 0 OID 0)
-- Dependencies: 310
-- Name: COLUMN cache_default.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_default.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4727 (class 0 OID 0)
-- Dependencies: 310
-- Name: COLUMN cache_default.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_default.data IS 'A collection of data to cache.';


--
-- TOC entry 4728 (class 0 OID 0)
-- Dependencies: 310
-- Name: COLUMN cache_default.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_default.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4729 (class 0 OID 0)
-- Dependencies: 310
-- Name: COLUMN cache_default.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_default.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4730 (class 0 OID 0)
-- Dependencies: 310
-- Name: COLUMN cache_default.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_default.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4731 (class 0 OID 0)
-- Dependencies: 310
-- Name: COLUMN cache_default.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_default.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4732 (class 0 OID 0)
-- Dependencies: 310
-- Name: COLUMN cache_default.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_default.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 308 (class 1259 OID 17970)
-- Name: cache_discovery; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_discovery (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_discovery OWNER TO drupal_user;

--
-- TOC entry 4733 (class 0 OID 0)
-- Dependencies: 308
-- Name: TABLE cache_discovery; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_discovery IS 'Storage for the cache API.';


--
-- TOC entry 4734 (class 0 OID 0)
-- Dependencies: 308
-- Name: COLUMN cache_discovery.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_discovery.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4735 (class 0 OID 0)
-- Dependencies: 308
-- Name: COLUMN cache_discovery.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_discovery.data IS 'A collection of data to cache.';


--
-- TOC entry 4736 (class 0 OID 0)
-- Dependencies: 308
-- Name: COLUMN cache_discovery.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_discovery.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4737 (class 0 OID 0)
-- Dependencies: 308
-- Name: COLUMN cache_discovery.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_discovery.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4738 (class 0 OID 0)
-- Dependencies: 308
-- Name: COLUMN cache_discovery.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_discovery.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4739 (class 0 OID 0)
-- Dependencies: 308
-- Name: COLUMN cache_discovery.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_discovery.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4740 (class 0 OID 0)
-- Dependencies: 308
-- Name: COLUMN cache_discovery.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_discovery.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 315 (class 1259 OID 18129)
-- Name: cache_dynamic_page_cache; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_dynamic_page_cache (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_dynamic_page_cache OWNER TO drupal_user;

--
-- TOC entry 4741 (class 0 OID 0)
-- Dependencies: 315
-- Name: TABLE cache_dynamic_page_cache; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_dynamic_page_cache IS 'Storage for the cache API.';


--
-- TOC entry 4742 (class 0 OID 0)
-- Dependencies: 315
-- Name: COLUMN cache_dynamic_page_cache.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_dynamic_page_cache.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4743 (class 0 OID 0)
-- Dependencies: 315
-- Name: COLUMN cache_dynamic_page_cache.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_dynamic_page_cache.data IS 'A collection of data to cache.';


--
-- TOC entry 4744 (class 0 OID 0)
-- Dependencies: 315
-- Name: COLUMN cache_dynamic_page_cache.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_dynamic_page_cache.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4745 (class 0 OID 0)
-- Dependencies: 315
-- Name: COLUMN cache_dynamic_page_cache.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_dynamic_page_cache.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4746 (class 0 OID 0)
-- Dependencies: 315
-- Name: COLUMN cache_dynamic_page_cache.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_dynamic_page_cache.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4747 (class 0 OID 0)
-- Dependencies: 315
-- Name: COLUMN cache_dynamic_page_cache.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_dynamic_page_cache.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4748 (class 0 OID 0)
-- Dependencies: 315
-- Name: COLUMN cache_dynamic_page_cache.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_dynamic_page_cache.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 314 (class 1259 OID 18115)
-- Name: cache_entity; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_entity (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_entity OWNER TO drupal_user;

--
-- TOC entry 4749 (class 0 OID 0)
-- Dependencies: 314
-- Name: TABLE cache_entity; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_entity IS 'Storage for the cache API.';


--
-- TOC entry 4750 (class 0 OID 0)
-- Dependencies: 314
-- Name: COLUMN cache_entity.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_entity.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4751 (class 0 OID 0)
-- Dependencies: 314
-- Name: COLUMN cache_entity.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_entity.data IS 'A collection of data to cache.';


--
-- TOC entry 4752 (class 0 OID 0)
-- Dependencies: 314
-- Name: COLUMN cache_entity.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_entity.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4753 (class 0 OID 0)
-- Dependencies: 314
-- Name: COLUMN cache_entity.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_entity.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4754 (class 0 OID 0)
-- Dependencies: 314
-- Name: COLUMN cache_entity.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_entity.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4755 (class 0 OID 0)
-- Dependencies: 314
-- Name: COLUMN cache_entity.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_entity.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4756 (class 0 OID 0)
-- Dependencies: 314
-- Name: COLUMN cache_entity.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_entity.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 313 (class 1259 OID 18093)
-- Name: cache_menu; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_menu (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_menu OWNER TO drupal_user;

--
-- TOC entry 4757 (class 0 OID 0)
-- Dependencies: 313
-- Name: TABLE cache_menu; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_menu IS 'Storage for the cache API.';


--
-- TOC entry 4758 (class 0 OID 0)
-- Dependencies: 313
-- Name: COLUMN cache_menu.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_menu.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4759 (class 0 OID 0)
-- Dependencies: 313
-- Name: COLUMN cache_menu.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_menu.data IS 'A collection of data to cache.';


--
-- TOC entry 4760 (class 0 OID 0)
-- Dependencies: 313
-- Name: COLUMN cache_menu.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_menu.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4761 (class 0 OID 0)
-- Dependencies: 313
-- Name: COLUMN cache_menu.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_menu.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4762 (class 0 OID 0)
-- Dependencies: 313
-- Name: COLUMN cache_menu.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_menu.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4763 (class 0 OID 0)
-- Dependencies: 313
-- Name: COLUMN cache_menu.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_menu.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4764 (class 0 OID 0)
-- Dependencies: 313
-- Name: COLUMN cache_menu.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_menu.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 319 (class 1259 OID 18918)
-- Name: cache_page; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_page (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_page OWNER TO drupal_user;

--
-- TOC entry 4765 (class 0 OID 0)
-- Dependencies: 319
-- Name: TABLE cache_page; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_page IS 'Storage for the cache API.';


--
-- TOC entry 4766 (class 0 OID 0)
-- Dependencies: 319
-- Name: COLUMN cache_page.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_page.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4767 (class 0 OID 0)
-- Dependencies: 319
-- Name: COLUMN cache_page.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_page.data IS 'A collection of data to cache.';


--
-- TOC entry 4768 (class 0 OID 0)
-- Dependencies: 319
-- Name: COLUMN cache_page.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_page.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4769 (class 0 OID 0)
-- Dependencies: 319
-- Name: COLUMN cache_page.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_page.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4770 (class 0 OID 0)
-- Dependencies: 319
-- Name: COLUMN cache_page.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_page.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4771 (class 0 OID 0)
-- Dependencies: 319
-- Name: COLUMN cache_page.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_page.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4772 (class 0 OID 0)
-- Dependencies: 319
-- Name: COLUMN cache_page.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_page.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 312 (class 1259 OID 18050)
-- Name: cache_render; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cache_render (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


ALTER TABLE public.cache_render OWNER TO drupal_user;

--
-- TOC entry 4773 (class 0 OID 0)
-- Dependencies: 312
-- Name: TABLE cache_render; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cache_render IS 'Storage for the cache API.';


--
-- TOC entry 4774 (class 0 OID 0)
-- Dependencies: 312
-- Name: COLUMN cache_render.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_render.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4775 (class 0 OID 0)
-- Dependencies: 312
-- Name: COLUMN cache_render.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_render.data IS 'A collection of data to cache.';


--
-- TOC entry 4776 (class 0 OID 0)
-- Dependencies: 312
-- Name: COLUMN cache_render.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_render.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- TOC entry 4777 (class 0 OID 0)
-- Dependencies: 312
-- Name: COLUMN cache_render.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_render.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- TOC entry 4778 (class 0 OID 0)
-- Dependencies: 312
-- Name: COLUMN cache_render.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_render.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 4779 (class 0 OID 0)
-- Dependencies: 312
-- Name: COLUMN cache_render.tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_render.tags IS 'Space-separated list of cache tags for this entry.';


--
-- TOC entry 4780 (class 0 OID 0)
-- Dependencies: 312
-- Name: COLUMN cache_render.checksum; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cache_render.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- TOC entry 305 (class 1259 OID 17937)
-- Name: cachetags; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.cachetags (
    tag character varying(255) DEFAULT ''::character varying NOT NULL,
    invalidations integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.cachetags OWNER TO drupal_user;

--
-- TOC entry 4781 (class 0 OID 0)
-- Dependencies: 305
-- Name: TABLE cachetags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.cachetags IS 'Cache table for tracking cache tag invalidations.';


--
-- TOC entry 4782 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN cachetags.tag; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cachetags.tag IS 'Namespace-prefixed tag string.';


--
-- TOC entry 4783 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN cachetags.invalidations; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.cachetags.invalidations IS 'Number incremented when the tag is invalidated.';


--
-- TOC entry 263 (class 1259 OID 17121)
-- Name: comment; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.comment (
    cid integer NOT NULL,
    comment_type character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT comment_cid_check CHECK ((cid >= 0))
);


ALTER TABLE public.comment OWNER TO drupal_user;

--
-- TOC entry 4784 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE comment; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.comment IS 'The base table for comment entities.';


--
-- TOC entry 4785 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN comment.comment_type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment.comment_type IS 'The ID of the target entity.';


--
-- TOC entry 265 (class 1259 OID 17151)
-- Name: comment__comment_body; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.comment__comment_body (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    comment_body_value text NOT NULL,
    comment_body_format character varying(255),
    CONSTRAINT comment__comment_body_delta_check CHECK ((delta >= 0)),
    CONSTRAINT comment__comment_body_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT comment__comment_body_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.comment__comment_body OWNER TO drupal_user;

--
-- TOC entry 4786 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE comment__comment_body; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.comment__comment_body IS 'Data storage for comment field comment_body.';


--
-- TOC entry 4787 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN comment__comment_body.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment__comment_body.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 4788 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN comment__comment_body.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment__comment_body.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 4789 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN comment__comment_body.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment__comment_body.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 4790 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN comment__comment_body.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment__comment_body.revision_id IS 'The entity revision id this data is attached to, which for an unversioned entity type is the same as the entity id';


--
-- TOC entry 4791 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN comment__comment_body.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment__comment_body.langcode IS 'The language code for this data item.';


--
-- TOC entry 4792 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN comment__comment_body.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment__comment_body.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 262 (class 1259 OID 17120)
-- Name: comment_cid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.comment_cid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comment_cid_seq OWNER TO drupal_user;

--
-- TOC entry 4793 (class 0 OID 0)
-- Dependencies: 262
-- Name: comment_cid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.comment_cid_seq OWNED BY public.comment.cid;


--
-- TOC entry 261 (class 1259 OID 17102)
-- Name: comment_entity_statistics; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.comment_entity_statistics (
    entity_id bigint DEFAULT 0 NOT NULL,
    entity_type character varying(32) DEFAULT 'node'::character varying NOT NULL,
    field_name character varying(32) DEFAULT ''::character varying NOT NULL,
    cid integer DEFAULT 0 NOT NULL,
    last_comment_timestamp bigint DEFAULT 0 NOT NULL,
    last_comment_name character varying(60),
    last_comment_uid bigint DEFAULT 0 NOT NULL,
    comment_count bigint DEFAULT 0 NOT NULL,
    CONSTRAINT comment_entity_statistics_comment_count_check CHECK ((comment_count >= 0)),
    CONSTRAINT comment_entity_statistics_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT comment_entity_statistics_last_comment_uid_check CHECK ((last_comment_uid >= 0))
);


ALTER TABLE public.comment_entity_statistics OWNER TO drupal_user;

--
-- TOC entry 4794 (class 0 OID 0)
-- Dependencies: 261
-- Name: TABLE comment_entity_statistics; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.comment_entity_statistics IS 'Maintains statistics of entity and comments posts to show "new" and "updated" flags.';


--
-- TOC entry 4795 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN comment_entity_statistics.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_entity_statistics.entity_id IS 'The entity_id of the entity for which the statistics are compiled.';


--
-- TOC entry 4796 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN comment_entity_statistics.entity_type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_entity_statistics.entity_type IS 'The entity_type of the entity to which this comment is a reply.';


--
-- TOC entry 4797 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN comment_entity_statistics.field_name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_entity_statistics.field_name IS 'The field_name of the field that was used to add this comment.';


--
-- TOC entry 4798 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN comment_entity_statistics.cid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_entity_statistics.cid IS 'The "comment".cid of the last comment.';


--
-- TOC entry 4799 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN comment_entity_statistics.last_comment_timestamp; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_entity_statistics.last_comment_timestamp IS 'The Unix timestamp of the last comment that was posted within this node, from "comment".changed.';


--
-- TOC entry 4800 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN comment_entity_statistics.last_comment_name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_entity_statistics.last_comment_name IS 'The name of the latest author to post a comment on this node, from "comment".name.';


--
-- TOC entry 4801 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN comment_entity_statistics.last_comment_uid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_entity_statistics.last_comment_uid IS 'The user ID of the latest author to post a comment on this node, from "comment".uid.';


--
-- TOC entry 4802 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN comment_entity_statistics.comment_count; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_entity_statistics.comment_count IS 'The total number of comments on this entity.';


--
-- TOC entry 264 (class 1259 OID 17131)
-- Name: comment_field_data; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.comment_field_data (
    cid bigint NOT NULL,
    comment_type character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    uid bigint NOT NULL,
    pid bigint,
    entity_id bigint,
    subject character varying(64),
    name character varying(60),
    mail character varying(254),
    homepage character varying(255),
    hostname character varying(128),
    created integer NOT NULL,
    changed integer,
    thread character varying(255) NOT NULL,
    entity_type character varying(32) NOT NULL,
    field_name character varying(32) NOT NULL,
    default_langcode smallint NOT NULL,
    CONSTRAINT comment_field_data_cid_check CHECK ((cid >= 0)),
    CONSTRAINT comment_field_data_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT comment_field_data_pid_check CHECK ((pid >= 0)),
    CONSTRAINT comment_field_data_uid_check CHECK ((uid >= 0))
);


ALTER TABLE public.comment_field_data OWNER TO drupal_user;

--
-- TOC entry 4803 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE comment_field_data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.comment_field_data IS 'The data table for comment entities.';


--
-- TOC entry 4804 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN comment_field_data.comment_type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_field_data.comment_type IS 'The ID of the target entity.';


--
-- TOC entry 4805 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN comment_field_data.uid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_field_data.uid IS 'The ID of the target entity.';


--
-- TOC entry 4806 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN comment_field_data.pid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_field_data.pid IS 'The ID of the target entity.';


--
-- TOC entry 4807 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN comment_field_data.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.comment_field_data.entity_id IS 'The ID of the target entity.';


--
-- TOC entry 216 (class 1259 OID 16648)
-- Name: config; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.config (
    collection character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea
);


ALTER TABLE public.config OWNER TO drupal_user;

--
-- TOC entry 4808 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE config; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.config IS 'The base table for configuration data.';


--
-- TOC entry 4809 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN config.collection; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.config.collection IS 'Primary Key: Config object collection.';


--
-- TOC entry 4810 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN config.name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.config.name IS 'Primary Key: Config object name.';


--
-- TOC entry 4811 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN config.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.config.data IS 'A serialized configuration object data.';


--
-- TOC entry 260 (class 1259 OID 17081)
-- Name: file_managed; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.file_managed (
    fid integer NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    uid bigint,
    filename character varying(255),
    uri character varying(255) NOT NULL,
    filemime character varying(255),
    filesize bigint,
    status smallint NOT NULL,
    created integer,
    changed integer NOT NULL,
    CONSTRAINT file_managed_fid_check CHECK ((fid >= 0)),
    CONSTRAINT file_managed_filesize_check CHECK ((filesize >= 0)),
    CONSTRAINT file_managed_uid_check CHECK ((uid >= 0))
);


ALTER TABLE public.file_managed OWNER TO drupal_user;

--
-- TOC entry 4812 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE file_managed; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.file_managed IS 'The base table for file entities.';


--
-- TOC entry 4813 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN file_managed.uid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.file_managed.uid IS 'The ID of the target entity.';


--
-- TOC entry 259 (class 1259 OID 17080)
-- Name: file_managed_fid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.file_managed_fid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.file_managed_fid_seq OWNER TO drupal_user;

--
-- TOC entry 4814 (class 0 OID 0)
-- Dependencies: 259
-- Name: file_managed_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.file_managed_fid_seq OWNED BY public.file_managed.fid;


--
-- TOC entry 258 (class 1259 OID 17066)
-- Name: file_usage; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.file_usage (
    fid bigint NOT NULL,
    module character varying(50) DEFAULT ''::character varying NOT NULL,
    type character varying(64) DEFAULT ''::character varying NOT NULL,
    id character varying(64) DEFAULT 0 NOT NULL,
    count bigint DEFAULT 0 NOT NULL,
    CONSTRAINT file_usage_count_check CHECK ((count >= 0)),
    CONSTRAINT file_usage_fid_check CHECK ((fid >= 0))
);


ALTER TABLE public.file_usage OWNER TO drupal_user;

--
-- TOC entry 4815 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE file_usage; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.file_usage IS 'Track where a file is used.';


--
-- TOC entry 4816 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN file_usage.fid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.file_usage.fid IS 'File ID.';


--
-- TOC entry 4817 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN file_usage.module; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.file_usage.module IS 'The name of the module that is using the file.';


--
-- TOC entry 4818 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN file_usage.type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.file_usage.type IS 'The name of the object type in which the file is used.';


--
-- TOC entry 4819 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN file_usage.id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.file_usage.id IS 'The primary key of the object using the file.';


--
-- TOC entry 4820 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN file_usage.count; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.file_usage.count IS 'The number of times this file is used by this object.';


--
-- TOC entry 235 (class 1259 OID 16806)
-- Name: help_search_items; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.help_search_items (
    sid integer NOT NULL,
    section_plugin_id character varying(255) DEFAULT ''::character varying NOT NULL,
    permission character varying(255) DEFAULT ''::character varying NOT NULL,
    topic_id character varying(255) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT help_search_items_sid_check CHECK ((sid >= 0))
);


ALTER TABLE public.help_search_items OWNER TO drupal_user;

--
-- TOC entry 4821 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE help_search_items; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.help_search_items IS 'Stores information about indexed help search items';


--
-- TOC entry 4822 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN help_search_items.sid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.help_search_items.sid IS 'Numeric index of this item in the search index';


--
-- TOC entry 4823 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN help_search_items.section_plugin_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.help_search_items.section_plugin_id IS 'The help section the item comes from';


--
-- TOC entry 4824 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN help_search_items.permission; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.help_search_items.permission IS 'The permission needed to view this item';


--
-- TOC entry 4825 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN help_search_items.topic_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.help_search_items.topic_id IS 'The topic ID of the item';


--
-- TOC entry 234 (class 1259 OID 16805)
-- Name: help_search_items_sid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.help_search_items_sid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.help_search_items_sid_seq OWNER TO drupal_user;

--
-- TOC entry 4826 (class 0 OID 0)
-- Dependencies: 234
-- Name: help_search_items_sid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.help_search_items_sid_seq OWNED BY public.help_search_items.sid;


--
-- TOC entry 273 (class 1259 OID 17241)
-- Name: history; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.history (
    uid integer DEFAULT 0 NOT NULL,
    nid bigint DEFAULT 0 NOT NULL,
    "timestamp" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT history_nid_check CHECK ((nid >= 0))
);


ALTER TABLE public.history OWNER TO drupal_user;

--
-- TOC entry 4827 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE history; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.history IS 'A record of which "users" have read which "node"s.';


--
-- TOC entry 4828 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN history.uid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.history.uid IS 'The "users".uid that read the "node" nid.';


--
-- TOC entry 4829 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN history.nid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.history.nid IS 'The "node".nid that was read.';


--
-- TOC entry 4830 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN history."timestamp"; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.history."timestamp" IS 'The Unix timestamp at which the read occurred.';


--
-- TOC entry 318 (class 1259 OID 18390)
-- Name: inline_block_usage; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.inline_block_usage (
    block_content_id bigint NOT NULL,
    layout_entity_type character varying(32) DEFAULT ''::character varying,
    layout_entity_id character varying(128) DEFAULT 0,
    CONSTRAINT inline_block_usage_block_content_id_check CHECK ((block_content_id >= 0))
);


ALTER TABLE public.inline_block_usage OWNER TO drupal_user;

--
-- TOC entry 4831 (class 0 OID 0)
-- Dependencies: 318
-- Name: TABLE inline_block_usage; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.inline_block_usage IS 'Track where a block_content entity is used.';


--
-- TOC entry 4832 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN inline_block_usage.block_content_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.inline_block_usage.block_content_id IS 'The block_content entity ID.';


--
-- TOC entry 4833 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN inline_block_usage.layout_entity_type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.inline_block_usage.layout_entity_type IS 'The entity type of the parent entity.';


--
-- TOC entry 4834 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN inline_block_usage.layout_entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.inline_block_usage.layout_entity_id IS 'The ID of the parent entity.';


--
-- TOC entry 217 (class 1259 OID 16657)
-- Name: key_value; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.key_value (
    collection character varying(128) DEFAULT ''::character varying NOT NULL,
    name character varying(128) DEFAULT ''::character varying NOT NULL,
    value bytea NOT NULL
);


ALTER TABLE public.key_value OWNER TO drupal_user;

--
-- TOC entry 4835 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE key_value; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.key_value IS 'Generic key-value storage table. See the state system for an example.';


--
-- TOC entry 4836 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN key_value.collection; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.key_value.collection IS 'A named collection of key and value pairs.';


--
-- TOC entry 4837 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN key_value.name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.key_value.name IS 'The key of the key-value pair. As KEY is a SQL reserved keyword, name was chosen instead.';


--
-- TOC entry 4838 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN key_value.value; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.key_value.value IS 'The value.';


--
-- TOC entry 303 (class 1259 OID 17907)
-- Name: key_value_expire; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.key_value_expire (
    collection character varying(128) DEFAULT ''::character varying NOT NULL,
    name character varying(128) DEFAULT ''::character varying NOT NULL,
    value bytea NOT NULL,
    expire integer DEFAULT 2147483647 NOT NULL
);


ALTER TABLE public.key_value_expire OWNER TO drupal_user;

--
-- TOC entry 4839 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE key_value_expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.key_value_expire IS 'Generic key/value storage table with an expiration.';


--
-- TOC entry 4840 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN key_value_expire.collection; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.key_value_expire.collection IS 'A named collection of key and value pairs.';


--
-- TOC entry 4841 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN key_value_expire.name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.key_value_expire.name IS 'The key of the key/value pair.';


--
-- TOC entry 4842 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN key_value_expire.value; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.key_value_expire.value IS 'The value of the key/value pair.';


--
-- TOC entry 4843 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN key_value_expire.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.key_value_expire.expire IS 'The time since Unix epoch in seconds when this item expires. Defaults to the maximum possible time.';


--
-- TOC entry 272 (class 1259 OID 17223)
-- Name: locale_file; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.locale_file (
    project character varying(255) DEFAULT ''::character varying NOT NULL,
    langcode character varying(12) DEFAULT ''::character varying NOT NULL,
    filename character varying(255) DEFAULT ''::character varying NOT NULL,
    version character varying(128) DEFAULT ''::character varying NOT NULL,
    uri character varying(255) DEFAULT ''::character varying NOT NULL,
    "timestamp" bigint DEFAULT 0,
    last_checked bigint DEFAULT 0
);


ALTER TABLE public.locale_file OWNER TO drupal_user;

--
-- TOC entry 4844 (class 0 OID 0)
-- Dependencies: 272
-- Name: TABLE locale_file; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.locale_file IS 'File import status information for interface translation files.';


--
-- TOC entry 4845 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN locale_file.project; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locale_file.project IS 'A unique short name to identify the project the file belongs to.';


--
-- TOC entry 4846 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN locale_file.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locale_file.langcode IS 'Language code of this translation. References "language".langcode.';


--
-- TOC entry 4847 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN locale_file.filename; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locale_file.filename IS 'Filename of the imported file.';


--
-- TOC entry 4848 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN locale_file.version; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locale_file.version IS 'Version tag of the imported file.';


--
-- TOC entry 4849 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN locale_file.uri; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locale_file.uri IS 'URI of the remote file, the resulting local file or the locally imported file.';


--
-- TOC entry 4850 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN locale_file."timestamp"; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locale_file."timestamp" IS 'Unix timestamp of the imported file.';


--
-- TOC entry 4851 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN locale_file.last_checked; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locale_file.last_checked IS 'Unix timestamp of the last time this translation was confirmed to be the most recent release available.';


--
-- TOC entry 271 (class 1259 OID 17212)
-- Name: locales_location; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.locales_location (
    lid integer NOT NULL,
    sid integer NOT NULL,
    type character varying(50) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    version character varying(20) DEFAULT 'none'::character varying NOT NULL
);


ALTER TABLE public.locales_location OWNER TO drupal_user;

--
-- TOC entry 4852 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE locales_location; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.locales_location IS 'Location information for source strings.';


--
-- TOC entry 4853 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN locales_location.lid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_location.lid IS 'Unique identifier of this location.';


--
-- TOC entry 4854 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN locales_location.sid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_location.sid IS 'Unique identifier of this string.';


--
-- TOC entry 4855 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN locales_location.type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_location.type IS 'The location type (file, config, path, etc).';


--
-- TOC entry 4856 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN locales_location.name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_location.name IS 'Type dependent location information (file name, path, etc).';


--
-- TOC entry 4857 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN locales_location.version; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_location.version IS 'Version of Drupal where the location was found.';


--
-- TOC entry 270 (class 1259 OID 17211)
-- Name: locales_location_lid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.locales_location_lid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.locales_location_lid_seq OWNER TO drupal_user;

--
-- TOC entry 4858 (class 0 OID 0)
-- Dependencies: 270
-- Name: locales_location_lid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.locales_location_lid_seq OWNED BY public.locales_location.lid;


--
-- TOC entry 268 (class 1259 OID 17189)
-- Name: locales_source; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.locales_source (
    lid integer NOT NULL,
    source text NOT NULL,
    context character varying(255) DEFAULT ''::character varying NOT NULL,
    version character varying(20) DEFAULT 'none'::character varying NOT NULL
);


ALTER TABLE public.locales_source OWNER TO drupal_user;

--
-- TOC entry 4859 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE locales_source; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.locales_source IS 'List of English source strings.';


--
-- TOC entry 4860 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN locales_source.lid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_source.lid IS 'Unique identifier of this string.';


--
-- TOC entry 4861 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN locales_source.source; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_source.source IS 'The original string in English.';


--
-- TOC entry 4862 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN locales_source.context; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_source.context IS 'The context this string applies to.';


--
-- TOC entry 4863 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN locales_source.version; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_source.version IS 'Version of Drupal where the string was last used (for locales optimization).';


--
-- TOC entry 267 (class 1259 OID 17188)
-- Name: locales_source_lid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.locales_source_lid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.locales_source_lid_seq OWNER TO drupal_user;

--
-- TOC entry 4864 (class 0 OID 0)
-- Dependencies: 267
-- Name: locales_source_lid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.locales_source_lid_seq OWNED BY public.locales_source.lid;


--
-- TOC entry 269 (class 1259 OID 17200)
-- Name: locales_target; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.locales_target (
    lid integer DEFAULT 0 NOT NULL,
    translation text NOT NULL,
    language character varying(12) DEFAULT ''::character varying NOT NULL,
    customized integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.locales_target OWNER TO drupal_user;

--
-- TOC entry 4865 (class 0 OID 0)
-- Dependencies: 269
-- Name: TABLE locales_target; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.locales_target IS 'Stores translated versions of strings.';


--
-- TOC entry 4866 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN locales_target.lid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_target.lid IS 'Source string ID. References "locales_source".lid.';


--
-- TOC entry 4867 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN locales_target.translation; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_target.translation IS 'Translation string value in this language.';


--
-- TOC entry 4868 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN locales_target.language; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_target.language IS 'Language code. References "language".langcode.';


--
-- TOC entry 4869 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN locales_target.customized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.locales_target.customized IS 'Boolean indicating whether the translation is custom to this site.';


--
-- TOC entry 284 (class 1259 OID 17361)
-- Name: menu_link_content; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.menu_link_content (
    id integer NOT NULL,
    revision_id bigint,
    bundle character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT menu_link_content_id_check CHECK ((id >= 0)),
    CONSTRAINT menu_link_content_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.menu_link_content OWNER TO drupal_user;

--
-- TOC entry 4870 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE menu_link_content; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.menu_link_content IS 'The base table for menu_link_content entities.';


--
-- TOC entry 287 (class 1259 OID 17387)
-- Name: menu_link_content_data; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.menu_link_content_data (
    id bigint NOT NULL,
    revision_id bigint NOT NULL,
    bundle character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    enabled smallint NOT NULL,
    title character varying(255),
    description character varying(255),
    menu_name character varying(255),
    link__uri character varying(2048),
    link__title character varying(255),
    link__options bytea,
    external smallint,
    rediscover smallint,
    weight integer,
    expanded smallint,
    parent character varying(255),
    changed integer,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT menu_link_content_data_id_check CHECK ((id >= 0)),
    CONSTRAINT menu_link_content_data_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.menu_link_content_data OWNER TO drupal_user;

--
-- TOC entry 4871 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE menu_link_content_data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.menu_link_content_data IS 'The data table for menu_link_content entities.';


--
-- TOC entry 4872 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN menu_link_content_data.link__uri; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_link_content_data.link__uri IS 'The URI of the link.';


--
-- TOC entry 4873 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN menu_link_content_data.link__title; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_link_content_data.link__title IS 'The link text.';


--
-- TOC entry 4874 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN menu_link_content_data.link__options; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_link_content_data.link__options IS 'Serialized array of options for the link.';


--
-- TOC entry 288 (class 1259 OID 17400)
-- Name: menu_link_content_field_revision; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.menu_link_content_field_revision (
    id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(12) NOT NULL,
    enabled smallint NOT NULL,
    title character varying(255),
    description character varying(255),
    link__uri character varying(2048),
    link__title character varying(255),
    link__options bytea,
    external smallint,
    changed integer,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT menu_link_content_field_revision_id_check CHECK ((id >= 0)),
    CONSTRAINT menu_link_content_field_revision_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.menu_link_content_field_revision OWNER TO drupal_user;

--
-- TOC entry 4875 (class 0 OID 0)
-- Dependencies: 288
-- Name: TABLE menu_link_content_field_revision; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.menu_link_content_field_revision IS 'The revision data table for menu_link_content entities.';


--
-- TOC entry 4876 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN menu_link_content_field_revision.link__uri; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_link_content_field_revision.link__uri IS 'The URI of the link.';


--
-- TOC entry 4877 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN menu_link_content_field_revision.link__title; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_link_content_field_revision.link__title IS 'The link text.';


--
-- TOC entry 4878 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN menu_link_content_field_revision.link__options; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_link_content_field_revision.link__options IS 'Serialized array of options for the link.';


--
-- TOC entry 283 (class 1259 OID 17360)
-- Name: menu_link_content_id_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.menu_link_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.menu_link_content_id_seq OWNER TO drupal_user;

--
-- TOC entry 4879 (class 0 OID 0)
-- Dependencies: 283
-- Name: menu_link_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.menu_link_content_id_seq OWNED BY public.menu_link_content.id;


--
-- TOC entry 286 (class 1259 OID 17374)
-- Name: menu_link_content_revision; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.menu_link_content_revision (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    langcode character varying(12) NOT NULL,
    revision_user bigint,
    revision_created integer,
    revision_log_message text,
    revision_default smallint,
    CONSTRAINT menu_link_content_revision_id_check1 CHECK ((id >= 0)),
    CONSTRAINT menu_link_content_revision_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT menu_link_content_revision_revision_user_check CHECK ((revision_user >= 0))
);


ALTER TABLE public.menu_link_content_revision OWNER TO drupal_user;

--
-- TOC entry 4880 (class 0 OID 0)
-- Dependencies: 286
-- Name: TABLE menu_link_content_revision; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.menu_link_content_revision IS 'The revision table for menu_link_content entities.';


--
-- TOC entry 4881 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN menu_link_content_revision.revision_user; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_link_content_revision.revision_user IS 'The ID of the target entity.';


--
-- TOC entry 285 (class 1259 OID 17373)
-- Name: menu_link_content_revision_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.menu_link_content_revision_revision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.menu_link_content_revision_revision_id_seq OWNER TO drupal_user;

--
-- TOC entry 4882 (class 0 OID 0)
-- Dependencies: 285
-- Name: menu_link_content_revision_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.menu_link_content_revision_revision_id_seq OWNED BY public.menu_link_content_revision.revision_id;


--
-- TOC entry 295 (class 1259 OID 17489)
-- Name: menu_tree; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.menu_tree (
    menu_name character varying(32) DEFAULT ''::character varying NOT NULL,
    mlid integer NOT NULL,
    id character varying(255) NOT NULL,
    parent character varying(255) DEFAULT ''::character varying NOT NULL,
    route_name character varying(255),
    route_param_key character varying(255),
    route_parameters bytea,
    url character varying(255) DEFAULT ''::character varying NOT NULL,
    title bytea,
    description bytea,
    class text,
    options bytea,
    provider character varying(50) DEFAULT 'system'::character varying NOT NULL,
    enabled smallint DEFAULT 1 NOT NULL,
    discovered smallint DEFAULT 0 NOT NULL,
    expanded smallint DEFAULT 0 NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    metadata bytea,
    has_children smallint DEFAULT 0 NOT NULL,
    depth smallint DEFAULT 0 NOT NULL,
    p1 bigint DEFAULT 0 NOT NULL,
    p2 bigint DEFAULT 0 NOT NULL,
    p3 bigint DEFAULT 0 NOT NULL,
    p4 bigint DEFAULT 0 NOT NULL,
    p5 bigint DEFAULT 0 NOT NULL,
    p6 bigint DEFAULT 0 NOT NULL,
    p7 bigint DEFAULT 0 NOT NULL,
    p8 bigint DEFAULT 0 NOT NULL,
    p9 bigint DEFAULT 0 NOT NULL,
    form_class character varying(255),
    CONSTRAINT menu_tree_mlid_check CHECK ((mlid >= 0)),
    CONSTRAINT menu_tree_p1_check CHECK ((p1 >= 0)),
    CONSTRAINT menu_tree_p2_check CHECK ((p2 >= 0)),
    CONSTRAINT menu_tree_p3_check CHECK ((p3 >= 0)),
    CONSTRAINT menu_tree_p4_check CHECK ((p4 >= 0)),
    CONSTRAINT menu_tree_p5_check CHECK ((p5 >= 0)),
    CONSTRAINT menu_tree_p6_check CHECK ((p6 >= 0)),
    CONSTRAINT menu_tree_p7_check CHECK ((p7 >= 0)),
    CONSTRAINT menu_tree_p8_check CHECK ((p8 >= 0)),
    CONSTRAINT menu_tree_p9_check CHECK ((p9 >= 0))
);


ALTER TABLE public.menu_tree OWNER TO drupal_user;

--
-- TOC entry 4883 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE menu_tree; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.menu_tree IS 'Contains the menu tree hierarchy.';


--
-- TOC entry 4884 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.menu_name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.menu_name IS 'The menu name. All links with the same menu name (such as ''tools'') are part of the same menu.';


--
-- TOC entry 4885 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.mlid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.mlid IS 'The menu link ID (mlid) is the integer primary key.';


--
-- TOC entry 4886 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.id IS 'Unique machine name: the plugin ID.';


--
-- TOC entry 4887 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.parent; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.parent IS 'The plugin ID for the parent of this link.';


--
-- TOC entry 4888 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.route_name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.route_name IS 'The machine name of a defined Symfony Route this menu link represents.';


--
-- TOC entry 4889 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.route_param_key; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.route_param_key IS 'An encoded string of route parameters for loading by route.';


--
-- TOC entry 4890 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.route_parameters; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.route_parameters IS 'Serialized array of route parameters of this menu link.';


--
-- TOC entry 4891 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.url; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.url IS 'The external path this link points to (when not using a route).';


--
-- TOC entry 4892 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.title; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.title IS 'The serialized title for the link. May be a TranslatableMarkup.';


--
-- TOC entry 4893 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.description; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.description IS 'The serialized description of this link - used for admin pages and title attribute. May be a TranslatableMarkup.';


--
-- TOC entry 4894 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.class; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.class IS 'The class for this link plugin.';


--
-- TOC entry 4895 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.options; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.options IS 'A serialized array of URL options, such as a query string or HTML attributes.';


--
-- TOC entry 4896 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.provider; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.provider IS 'The name of the module that generated this link.';


--
-- TOC entry 4897 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.enabled; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.enabled IS 'A flag for whether the link should be rendered in menus. (0 = a disabled menu link that may be shown on admin screens, 1 = a normal, visible link)';


--
-- TOC entry 4898 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.discovered; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.discovered IS 'A flag for whether the link was discovered, so can be purged on rebuild';


--
-- TOC entry 4899 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.expanded; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.expanded IS 'Flag for whether this link should be rendered as expanded in menus - expanded links always have their child links displayed, instead of only when the link is in the active trail (1 = expanded, 0 = not expanded)';


--
-- TOC entry 4900 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.weight; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.weight IS 'Link weight among links in the same menu at the same depth.';


--
-- TOC entry 4901 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.metadata; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.metadata IS 'A serialized array of data that may be used by the plugin instance.';


--
-- TOC entry 4902 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.has_children; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.has_children IS 'Flag indicating whether any enabled links have this link as a parent (1 = enabled children exist, 0 = no enabled children).';


--
-- TOC entry 4903 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.depth; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.depth IS 'The depth relative to the top level. A link with empty parent will have depth == 1.';


--
-- TOC entry 4904 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.p1; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.p1 IS 'The first mlid in the materialized path. If N = depth, then pN must equal the mlid. If depth > 1 then p(N-1) must equal the parent link mlid. All pX where X > depth must equal zero. The columns p1 .. p9 are also called the parents.';


--
-- TOC entry 4905 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.p2; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.p2 IS 'The second mlid in the materialized path. See p1.';


--
-- TOC entry 4906 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.p3; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.p3 IS 'The third mlid in the materialized path. See p1.';


--
-- TOC entry 4907 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.p4; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.p4 IS 'The fourth mlid in the materialized path. See p1.';


--
-- TOC entry 4908 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.p5; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.p5 IS 'The fifth mlid in the materialized path. See p1.';


--
-- TOC entry 4909 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.p6; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.p6 IS 'The sixth mlid in the materialized path. See p1.';


--
-- TOC entry 4910 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.p7; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.p7 IS 'The seventh mlid in the materialized path. See p1.';


--
-- TOC entry 4911 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.p8; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.p8 IS 'The eighth mlid in the materialized path. See p1.';


--
-- TOC entry 4912 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.p9; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.p9 IS 'The ninth mlid in the materialized path. See p1.';


--
-- TOC entry 4913 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN menu_tree.form_class; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.menu_tree.form_class IS 'meh';


--
-- TOC entry 294 (class 1259 OID 17488)
-- Name: menu_tree_mlid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.menu_tree_mlid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.menu_tree_mlid_seq OWNER TO drupal_user;

--
-- TOC entry 4914 (class 0 OID 0)
-- Dependencies: 294
-- Name: menu_tree_mlid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.menu_tree_mlid_seq OWNED BY public.menu_tree.mlid;


--
-- TOC entry 251 (class 1259 OID 16975)
-- Name: node; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node (
    nid integer NOT NULL,
    vid bigint,
    type character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT node_nid_check CHECK ((nid >= 0)),
    CONSTRAINT node_vid_check CHECK ((vid >= 0))
);


ALTER TABLE public.node OWNER TO drupal_user;

--
-- TOC entry 4915 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE node; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node IS 'The base table for node entities.';


--
-- TOC entry 4916 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN node.type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node.type IS 'The ID of the target entity.';


--
-- TOC entry 256 (class 1259 OID 17031)
-- Name: node__body; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node__body (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    body_value text NOT NULL,
    body_summary text,
    body_format character varying(255),
    CONSTRAINT node__body_delta_check CHECK ((delta >= 0)),
    CONSTRAINT node__body_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT node__body_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.node__body OWNER TO drupal_user;

--
-- TOC entry 4918 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE node__body; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node__body IS 'Data storage for node field body.';


--
-- TOC entry 4919 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node__body.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__body.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 4920 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node__body.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__body.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 4921 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node__body.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__body.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 4922 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node__body.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__body.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 4923 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node__body.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__body.langcode IS 'The language code for this data item.';


--
-- TOC entry 4924 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node__body.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__body.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 298 (class 1259 OID 17570)
-- Name: node__comment; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node__comment (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    comment_status integer DEFAULT 0 NOT NULL,
    CONSTRAINT node__comment_delta_check CHECK ((delta >= 0)),
    CONSTRAINT node__comment_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT node__comment_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.node__comment OWNER TO drupal_user;

--
-- TOC entry 4926 (class 0 OID 0)
-- Dependencies: 298
-- Name: TABLE node__comment; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node__comment IS 'Data storage for node field comment.';


--
-- TOC entry 4927 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN node__comment.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__comment.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 4928 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN node__comment.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__comment.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 4929 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN node__comment.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__comment.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 4930 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN node__comment.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__comment.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 4931 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN node__comment.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__comment.langcode IS 'The language code for this data item.';


--
-- TOC entry 4932 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN node__comment.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__comment.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 4933 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN node__comment.comment_status; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__comment.comment_status IS 'Whether comments are allowed on this entity: 0 = no, 1 = closed (read only), 2 = open (read/write).';


--
-- TOC entry 296 (class 1259 OID 17531)
-- Name: node__field_image; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node__field_image (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    field_image_target_id bigint NOT NULL,
    field_image_alt character varying(512),
    field_image_title character varying(1024),
    field_image_width bigint,
    field_image_height bigint,
    CONSTRAINT node__field_image_delta_check CHECK ((delta >= 0)),
    CONSTRAINT node__field_image_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT node__field_image_field_image_height_check CHECK ((field_image_height >= 0)),
    CONSTRAINT node__field_image_field_image_target_id_check CHECK ((field_image_target_id >= 0)),
    CONSTRAINT node__field_image_field_image_width_check CHECK ((field_image_width >= 0)),
    CONSTRAINT node__field_image_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.node__field_image OWNER TO drupal_user;

--
-- TOC entry 4934 (class 0 OID 0)
-- Dependencies: 296
-- Name: TABLE node__field_image; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node__field_image IS 'Data storage for node field field_image.';


--
-- TOC entry 4935 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN node__field_image.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_image.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 4936 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN node__field_image.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_image.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 4937 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN node__field_image.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_image.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 4938 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN node__field_image.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_image.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 4939 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN node__field_image.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_image.langcode IS 'The language code for this data item.';


--
-- TOC entry 4940 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN node__field_image.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_image.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 4941 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN node__field_image.field_image_target_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_image.field_image_target_id IS 'The ID of the file entity.';


--
-- TOC entry 4942 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN node__field_image.field_image_alt; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_image.field_image_alt IS 'Alternative image text, for the image''s ''alt'' attribute.';


--
-- TOC entry 4943 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN node__field_image.field_image_title; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_image.field_image_title IS 'Image title text, for the image''s ''title'' attribute.';


--
-- TOC entry 4944 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN node__field_image.field_image_width; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_image.field_image_width IS 'The width of the image in pixels.';


--
-- TOC entry 4945 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN node__field_image.field_image_height; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_image.field_image_height IS 'The height of the image in pixels.';


--
-- TOC entry 300 (class 1259 OID 17599)
-- Name: node__field_tags; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node__field_tags (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    field_tags_target_id bigint NOT NULL,
    CONSTRAINT node__field_tags_delta_check CHECK ((delta >= 0)),
    CONSTRAINT node__field_tags_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT node__field_tags_field_tags_target_id_check CHECK ((field_tags_target_id >= 0)),
    CONSTRAINT node__field_tags_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.node__field_tags OWNER TO drupal_user;

--
-- TOC entry 4946 (class 0 OID 0)
-- Dependencies: 300
-- Name: TABLE node__field_tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node__field_tags IS 'Data storage for node field field_tags.';


--
-- TOC entry 4947 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN node__field_tags.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_tags.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 4948 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN node__field_tags.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_tags.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 4949 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN node__field_tags.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_tags.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 4950 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN node__field_tags.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_tags.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 4951 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN node__field_tags.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_tags.langcode IS 'The language code for this data item.';


--
-- TOC entry 4952 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN node__field_tags.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_tags.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 4953 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN node__field_tags.field_tags_target_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node__field_tags.field_tags_target_id IS 'The ID of the target entity.';


--
-- TOC entry 249 (class 1259 OID 16955)
-- Name: node_access; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node_access (
    nid bigint DEFAULT 0 NOT NULL,
    langcode character varying(12) DEFAULT ''::character varying NOT NULL,
    fallback integer DEFAULT 1 NOT NULL,
    gid bigint DEFAULT 0 NOT NULL,
    realm character varying(255) DEFAULT ''::character varying NOT NULL,
    grant_view integer DEFAULT 0 NOT NULL,
    grant_update integer DEFAULT 0 NOT NULL,
    grant_delete integer DEFAULT 0 NOT NULL,
    CONSTRAINT node_access_fallback_check CHECK ((fallback >= 0)),
    CONSTRAINT node_access_gid_check CHECK ((gid >= 0)),
    CONSTRAINT node_access_grant_delete_check CHECK ((grant_delete >= 0)),
    CONSTRAINT node_access_grant_update_check CHECK ((grant_update >= 0)),
    CONSTRAINT node_access_grant_view_check CHECK ((grant_view >= 0)),
    CONSTRAINT node_access_nid_check CHECK ((nid >= 0))
);


ALTER TABLE public.node_access OWNER TO drupal_user;

--
-- TOC entry 4954 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE node_access; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node_access IS 'Identifies which realm/grant pairs a user must possess in order to view, update, or delete specific nodes.';


--
-- TOC entry 4955 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN node_access.nid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_access.nid IS 'The "node".nid this record affects.';


--
-- TOC entry 4956 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN node_access.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_access.langcode IS 'The "language".langcode of this node.';


--
-- TOC entry 4957 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN node_access.fallback; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_access.fallback IS 'Boolean indicating whether this record should be used as a fallback if a language condition is not provided.';


--
-- TOC entry 4958 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN node_access.gid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_access.gid IS 'The grant ID a user must possess in the specified realm to gain this row''s privileges on the node.';


--
-- TOC entry 4959 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN node_access.realm; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_access.realm IS 'The realm in which the user must possess the grant ID. Modules can define one or more realms by implementing hook_node_grants().';


--
-- TOC entry 4960 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN node_access.grant_view; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_access.grant_view IS 'Boolean indicating whether a user with the realm/grant pair can view this node.';


--
-- TOC entry 4961 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN node_access.grant_update; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_access.grant_update IS 'Boolean indicating whether a user with the realm/grant pair can edit this node.';


--
-- TOC entry 4962 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN node_access.grant_delete; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_access.grant_delete IS 'Boolean indicating whether a user with the realm/grant pair can delete this node.';


--
-- TOC entry 254 (class 1259 OID 17003)
-- Name: node_field_data; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node_field_data (
    nid bigint NOT NULL,
    vid bigint NOT NULL,
    type character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    uid bigint NOT NULL,
    title character varying(255) NOT NULL,
    created integer NOT NULL,
    changed integer NOT NULL,
    promote smallint NOT NULL,
    sticky smallint NOT NULL,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT node_field_data_nid_check CHECK ((nid >= 0)),
    CONSTRAINT node_field_data_uid_check CHECK ((uid >= 0)),
    CONSTRAINT node_field_data_vid_check CHECK ((vid >= 0))
);


ALTER TABLE public.node_field_data OWNER TO drupal_user;

--
-- TOC entry 4963 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE node_field_data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node_field_data IS 'The data table for node entities.';


--
-- TOC entry 4964 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN node_field_data.type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_field_data.type IS 'The ID of the target entity.';


--
-- TOC entry 4965 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN node_field_data.uid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_field_data.uid IS 'The ID of the target entity.';


--
-- TOC entry 255 (class 1259 OID 17020)
-- Name: node_field_revision; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node_field_revision (
    nid bigint NOT NULL,
    vid bigint NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    uid bigint NOT NULL,
    title character varying(255),
    created integer,
    changed integer,
    promote smallint,
    sticky smallint,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT node_field_revision_nid_check CHECK ((nid >= 0)),
    CONSTRAINT node_field_revision_uid_check CHECK ((uid >= 0)),
    CONSTRAINT node_field_revision_vid_check CHECK ((vid >= 0))
);


ALTER TABLE public.node_field_revision OWNER TO drupal_user;

--
-- TOC entry 4967 (class 0 OID 0)
-- Dependencies: 255
-- Name: TABLE node_field_revision; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node_field_revision IS 'The revision data table for node entities.';


--
-- TOC entry 4968 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN node_field_revision.uid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_field_revision.uid IS 'The ID of the target entity.';


--
-- TOC entry 250 (class 1259 OID 16974)
-- Name: node_nid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.node_nid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.node_nid_seq OWNER TO drupal_user;

--
-- TOC entry 4969 (class 0 OID 0)
-- Dependencies: 250
-- Name: node_nid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.node_nid_seq OWNED BY public.node.nid;


--
-- TOC entry 253 (class 1259 OID 16989)
-- Name: node_revision; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node_revision (
    nid bigint NOT NULL,
    vid integer NOT NULL,
    langcode character varying(12) NOT NULL,
    revision_uid bigint,
    revision_timestamp integer,
    revision_log text,
    revision_default smallint,
    CONSTRAINT node_revision_nid_check CHECK ((nid >= 0)),
    CONSTRAINT node_revision_revision_uid_check CHECK ((revision_uid >= 0)),
    CONSTRAINT node_revision_vid_check CHECK ((vid >= 0))
);


ALTER TABLE public.node_revision OWNER TO drupal_user;

--
-- TOC entry 4970 (class 0 OID 0)
-- Dependencies: 253
-- Name: TABLE node_revision; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node_revision IS 'The revision table for node entities.';


--
-- TOC entry 4971 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN node_revision.revision_uid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision.revision_uid IS 'The ID of the target entity.';


--
-- TOC entry 257 (class 1259 OID 17047)
-- Name: node_revision__body; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node_revision__body (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    body_value text NOT NULL,
    body_summary text,
    body_format character varying(255),
    CONSTRAINT node_revision__body_delta_check CHECK ((delta >= 0)),
    CONSTRAINT node_revision__body_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT node_revision__body_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.node_revision__body OWNER TO drupal_user;

--
-- TOC entry 4972 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE node_revision__body; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node_revision__body IS 'Revision archive storage for node field body.';


--
-- TOC entry 4973 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_revision__body.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__body.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 4974 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_revision__body.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__body.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 4975 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_revision__body.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__body.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 4976 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_revision__body.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__body.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 4977 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_revision__body.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__body.langcode IS 'The language code for this data item.';


--
-- TOC entry 4978 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_revision__body.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__body.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 299 (class 1259 OID 17584)
-- Name: node_revision__comment; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node_revision__comment (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    comment_status integer DEFAULT 0 NOT NULL,
    CONSTRAINT node_revision__comment_delta_check CHECK ((delta >= 0)),
    CONSTRAINT node_revision__comment_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT node_revision__comment_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.node_revision__comment OWNER TO drupal_user;

--
-- TOC entry 4979 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE node_revision__comment; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node_revision__comment IS 'Revision archive storage for node field comment.';


--
-- TOC entry 4980 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN node_revision__comment.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__comment.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 4981 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN node_revision__comment.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__comment.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 4982 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN node_revision__comment.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__comment.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 4983 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN node_revision__comment.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__comment.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 4984 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN node_revision__comment.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__comment.langcode IS 'The language code for this data item.';


--
-- TOC entry 4985 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN node_revision__comment.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__comment.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 4986 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN node_revision__comment.comment_status; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__comment.comment_status IS 'Whether comments are allowed on this entity: 0 = no, 1 = closed (read only), 2 = open (read/write).';


--
-- TOC entry 297 (class 1259 OID 17550)
-- Name: node_revision__field_image; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node_revision__field_image (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    field_image_target_id bigint NOT NULL,
    field_image_alt character varying(512),
    field_image_title character varying(1024),
    field_image_width bigint,
    field_image_height bigint,
    CONSTRAINT node_revision__field_image_delta_check CHECK ((delta >= 0)),
    CONSTRAINT node_revision__field_image_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT node_revision__field_image_field_image_height_check CHECK ((field_image_height >= 0)),
    CONSTRAINT node_revision__field_image_field_image_target_id_check CHECK ((field_image_target_id >= 0)),
    CONSTRAINT node_revision__field_image_field_image_width_check CHECK ((field_image_width >= 0)),
    CONSTRAINT node_revision__field_image_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.node_revision__field_image OWNER TO drupal_user;

--
-- TOC entry 4987 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE node_revision__field_image; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node_revision__field_image IS 'Revision archive storage for node field field_image.';


--
-- TOC entry 4988 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN node_revision__field_image.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_image.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 4989 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN node_revision__field_image.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_image.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 4990 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN node_revision__field_image.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_image.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 4991 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN node_revision__field_image.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_image.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 4992 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN node_revision__field_image.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_image.langcode IS 'The language code for this data item.';


--
-- TOC entry 4993 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN node_revision__field_image.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_image.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 4994 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN node_revision__field_image.field_image_target_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_image.field_image_target_id IS 'The ID of the file entity.';


--
-- TOC entry 4995 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN node_revision__field_image.field_image_alt; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_image.field_image_alt IS 'Alternative image text, for the image''s ''alt'' attribute.';


--
-- TOC entry 4996 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN node_revision__field_image.field_image_title; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_image.field_image_title IS 'Image title text, for the image''s ''title'' attribute.';


--
-- TOC entry 4997 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN node_revision__field_image.field_image_width; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_image.field_image_width IS 'The width of the image in pixels.';


--
-- TOC entry 4998 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN node_revision__field_image.field_image_height; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_image.field_image_height IS 'The height of the image in pixels.';


--
-- TOC entry 301 (class 1259 OID 17614)
-- Name: node_revision__field_tags; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.node_revision__field_tags (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    field_tags_target_id bigint NOT NULL,
    CONSTRAINT node_revision__field_tags_delta_check CHECK ((delta >= 0)),
    CONSTRAINT node_revision__field_tags_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT node_revision__field_tags_field_tags_target_id_check CHECK ((field_tags_target_id >= 0)),
    CONSTRAINT node_revision__field_tags_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.node_revision__field_tags OWNER TO drupal_user;

--
-- TOC entry 4999 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE node_revision__field_tags; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.node_revision__field_tags IS 'Revision archive storage for node field field_tags.';


--
-- TOC entry 5000 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN node_revision__field_tags.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_tags.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 5001 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN node_revision__field_tags.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_tags.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 5002 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN node_revision__field_tags.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_tags.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 5003 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN node_revision__field_tags.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_tags.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 5004 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN node_revision__field_tags.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_tags.langcode IS 'The language code for this data item.';


--
-- TOC entry 5005 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN node_revision__field_tags.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_tags.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 5006 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN node_revision__field_tags.field_tags_target_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.node_revision__field_tags.field_tags_target_id IS 'The ID of the target entity.';


--
-- TOC entry 252 (class 1259 OID 16988)
-- Name: node_revision_vid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.node_revision_vid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.node_revision_vid_seq OWNER TO drupal_user;

--
-- TOC entry 5007 (class 0 OID 0)
-- Dependencies: 252
-- Name: node_revision_vid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.node_revision_vid_seq OWNED BY public.node_revision.vid;


--
-- TOC entry 231 (class 1259 OID 16777)
-- Name: path_alias; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.path_alias (
    id integer NOT NULL,
    revision_id bigint,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    path character varying(255),
    alias character varying(255),
    status smallint NOT NULL,
    CONSTRAINT path_alias_id_check CHECK ((id >= 0)),
    CONSTRAINT path_alias_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.path_alias OWNER TO drupal_user;

--
-- TOC entry 5008 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE path_alias; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.path_alias IS 'The base table for path_alias entities.';


--
-- TOC entry 230 (class 1259 OID 16776)
-- Name: path_alias_id_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.path_alias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.path_alias_id_seq OWNER TO drupal_user;

--
-- TOC entry 5009 (class 0 OID 0)
-- Dependencies: 230
-- Name: path_alias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.path_alias_id_seq OWNED BY public.path_alias.id;


--
-- TOC entry 233 (class 1259 OID 16794)
-- Name: path_alias_revision; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.path_alias_revision (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    langcode character varying(12) NOT NULL,
    path character varying(255),
    alias character varying(255),
    status smallint NOT NULL,
    revision_default smallint,
    CONSTRAINT path_alias_revision_id_check1 CHECK ((id >= 0)),
    CONSTRAINT path_alias_revision_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.path_alias_revision OWNER TO drupal_user;

--
-- TOC entry 5010 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE path_alias_revision; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.path_alias_revision IS 'The revision table for path_alias entities.';


--
-- TOC entry 232 (class 1259 OID 16793)
-- Name: path_alias_revision_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.path_alias_revision_revision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.path_alias_revision_revision_id_seq OWNER TO drupal_user;

--
-- TOC entry 5011 (class 0 OID 0)
-- Dependencies: 232
-- Name: path_alias_revision_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.path_alias_revision_revision_id_seq OWNED BY public.path_alias_revision.revision_id;


--
-- TOC entry 223 (class 1259 OID 16686)
-- Name: queue; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.queue (
    item_id integer NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire bigint DEFAULT 0 NOT NULL,
    created bigint DEFAULT 0 NOT NULL,
    CONSTRAINT queue_item_id_check CHECK ((item_id >= 0))
);


ALTER TABLE public.queue OWNER TO drupal_user;

--
-- TOC entry 5012 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE queue; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.queue IS 'Stores items in queues.';


--
-- TOC entry 5013 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN queue.item_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.queue.item_id IS 'Primary Key: Unique item ID.';


--
-- TOC entry 5014 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN queue.name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.queue.name IS 'The queue name.';


--
-- TOC entry 5015 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN queue.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.queue.data IS 'The arbitrary data for the item.';


--
-- TOC entry 5016 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN queue.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.queue.expire IS 'Timestamp when the claim lease expires on the item.';


--
-- TOC entry 5017 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN queue.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.queue.created IS 'Timestamp when the item was created.';


--
-- TOC entry 222 (class 1259 OID 16685)
-- Name: queue_item_id_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.queue_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.queue_item_id_seq OWNER TO drupal_user;

--
-- TOC entry 5018 (class 0 OID 0)
-- Dependencies: 222
-- Name: queue_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.queue_item_id_seq OWNED BY public.queue.item_id;


--
-- TOC entry 293 (class 1259 OID 17475)
-- Name: router; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.router (
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    path character varying(255) DEFAULT ''::character varying NOT NULL,
    pattern_outline character varying(255) DEFAULT ''::character varying NOT NULL,
    fit integer DEFAULT 0 NOT NULL,
    route bytea,
    number_parts smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.router OWNER TO drupal_user;

--
-- TOC entry 5019 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE router; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.router IS 'Maps paths to various callbacks (access, page and title)';


--
-- TOC entry 5020 (class 0 OID 0)
-- Dependencies: 293
-- Name: COLUMN router.name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.router.name IS 'Primary Key: Machine name of this route';


--
-- TOC entry 5021 (class 0 OID 0)
-- Dependencies: 293
-- Name: COLUMN router.path; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.router.path IS 'The path for this URI';


--
-- TOC entry 5022 (class 0 OID 0)
-- Dependencies: 293
-- Name: COLUMN router.pattern_outline; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.router.pattern_outline IS 'The pattern';


--
-- TOC entry 5023 (class 0 OID 0)
-- Dependencies: 293
-- Name: COLUMN router.fit; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.router.fit IS 'A numeric representation of how specific the path is.';


--
-- TOC entry 5024 (class 0 OID 0)
-- Dependencies: 293
-- Name: COLUMN router.route; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.router.route IS 'A serialized Route object';


--
-- TOC entry 5025 (class 0 OID 0)
-- Dependencies: 293
-- Name: COLUMN router.number_parts; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.router.number_parts IS 'Number of parts in this router path.';


--
-- TOC entry 238 (class 1259 OID 16839)
-- Name: search_dataset; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.search_dataset (
    sid bigint DEFAULT 0 NOT NULL,
    langcode character varying(12) DEFAULT ''::character varying NOT NULL,
    type character varying(64) NOT NULL,
    data text NOT NULL,
    reindex bigint DEFAULT 0 NOT NULL,
    CONSTRAINT search_dataset_reindex_check CHECK ((reindex >= 0)),
    CONSTRAINT search_dataset_sid_check CHECK ((sid >= 0))
);


ALTER TABLE public.search_dataset OWNER TO drupal_user;

--
-- TOC entry 5026 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE search_dataset; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.search_dataset IS 'Stores items that will be searched.';


--
-- TOC entry 5027 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN search_dataset.sid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_dataset.sid IS 'Search item ID, e.g. node ID for nodes.';


--
-- TOC entry 5028 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN search_dataset.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_dataset.langcode IS 'The "languages".langcode of the item variant.';


--
-- TOC entry 5029 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN search_dataset.type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_dataset.type IS 'Type of item, e.g. node.';


--
-- TOC entry 5030 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN search_dataset.data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_dataset.data IS 'List of space-separated words from the item.';


--
-- TOC entry 5031 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN search_dataset.reindex; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_dataset.reindex IS 'Set to force node reindexing.';


--
-- TOC entry 239 (class 1259 OID 16851)
-- Name: search_index; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.search_index (
    word character varying(50) DEFAULT ''::character varying NOT NULL,
    sid bigint DEFAULT 0 NOT NULL,
    langcode character varying(12) DEFAULT ''::character varying NOT NULL,
    type character varying(64) NOT NULL,
    score real,
    CONSTRAINT search_index_sid_check CHECK ((sid >= 0))
);


ALTER TABLE public.search_index OWNER TO drupal_user;

--
-- TOC entry 5032 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE search_index; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.search_index IS 'Stores the search index, associating words, items and scores.';


--
-- TOC entry 5033 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN search_index.word; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_index.word IS 'The "search_total".word that is associated with the search item.';


--
-- TOC entry 5034 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN search_index.sid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_index.sid IS 'The "search_dataset".sid of the searchable item to which the word belongs.';


--
-- TOC entry 5035 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN search_index.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_index.langcode IS 'The "languages".langcode of the item variant.';


--
-- TOC entry 5036 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN search_index.type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_index.type IS 'The "search_dataset".type of the searchable item to which the word belongs.';


--
-- TOC entry 5037 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN search_index.score; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_index.score IS 'The numeric score of the word, higher being more important.';


--
-- TOC entry 240 (class 1259 OID 16861)
-- Name: search_total; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.search_total (
    word character varying(50) DEFAULT ''::character varying NOT NULL,
    count real
);


ALTER TABLE public.search_total OWNER TO drupal_user;

--
-- TOC entry 5038 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE search_total; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.search_total IS 'Stores search totals for words.';


--
-- TOC entry 5039 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN search_total.word; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_total.word IS 'Primary Key: Unique word in the search index.';


--
-- TOC entry 5040 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN search_total.count; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.search_total.count IS 'The count of the word in the index using Zipf''s law to equalize the probability distribution.';


--
-- TOC entry 311 (class 1259 OID 18038)
-- Name: semaphore; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.semaphore (
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value character varying(255) DEFAULT ''::character varying NOT NULL,
    expire double precision NOT NULL
);


ALTER TABLE public.semaphore OWNER TO drupal_user;

--
-- TOC entry 5041 (class 0 OID 0)
-- Dependencies: 311
-- Name: TABLE semaphore; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.semaphore IS 'Table for holding semaphores, locks, flags, etc. that cannot be stored as state since they must not be cached.';


--
-- TOC entry 5042 (class 0 OID 0)
-- Dependencies: 311
-- Name: COLUMN semaphore.name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.semaphore.name IS 'Primary Key: Unique name.';


--
-- TOC entry 5043 (class 0 OID 0)
-- Dependencies: 311
-- Name: COLUMN semaphore.value; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.semaphore.value IS 'A value for the semaphore.';


--
-- TOC entry 5044 (class 0 OID 0)
-- Dependencies: 311
-- Name: COLUMN semaphore.expire; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.semaphore.expire IS 'A Unix timestamp with microseconds indicating when the semaphore should expire.';


--
-- TOC entry 219 (class 1259 OID 16667)
-- Name: sequences; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.sequences (
    value integer NOT NULL,
    CONSTRAINT sequences_value_check CHECK ((value >= 0))
);


ALTER TABLE public.sequences OWNER TO drupal_user;

--
-- TOC entry 5045 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE sequences; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.sequences IS 'Stores IDs.';


--
-- TOC entry 5046 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN sequences.value; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.sequences.value IS 'The value of the sequence.';


--
-- TOC entry 218 (class 1259 OID 16666)
-- Name: sequences_value_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.sequences_value_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sequences_value_seq OWNER TO drupal_user;

--
-- TOC entry 5047 (class 0 OID 0)
-- Dependencies: 218
-- Name: sequences_value_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.sequences_value_seq OWNED BY public.sequences.value;


--
-- TOC entry 224 (class 1259 OID 16700)
-- Name: sessions; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.sessions (
    uid bigint NOT NULL,
    sid character varying(128) NOT NULL,
    hostname character varying(128) DEFAULT ''::character varying NOT NULL,
    "timestamp" bigint DEFAULT 0 NOT NULL,
    session bytea,
    CONSTRAINT sessions_uid_check CHECK ((uid >= 0))
);


ALTER TABLE public.sessions OWNER TO drupal_user;

--
-- TOC entry 5048 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE sessions; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.sessions IS 'Drupal''s session handlers read and write into the sessions table. Each record represents a user session, either anonymous or authenticated.';


--
-- TOC entry 5049 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN sessions.uid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.sessions.uid IS 'The "users".uid corresponding to a session, or 0 for anonymous user.';


--
-- TOC entry 5050 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN sessions.sid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.sessions.sid IS 'A session ID (hashed). The value is generated by Drupal''s session handlers.';


--
-- TOC entry 5051 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN sessions.hostname; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.sessions.hostname IS 'The IP address that last used this session ID (sid).';


--
-- TOC entry 5052 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN sessions."timestamp"; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.sessions."timestamp" IS 'The Unix timestamp when this session last requested a page. Old records are purged by PHP automatically.';


--
-- TOC entry 5053 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN sessions.session; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.sessions.session IS 'The serialized contents of the user''s session, an array of name/value pairs that persists across page requests by this session ID. Drupal loads the user''s session from here   at the start of each request and saves it at the end.';


--
-- TOC entry 291 (class 1259 OID 17426)
-- Name: shortcut; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.shortcut (
    id integer NOT NULL,
    shortcut_set character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT shortcut_id_check CHECK ((id >= 0))
);


ALTER TABLE public.shortcut OWNER TO drupal_user;

--
-- TOC entry 5054 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE shortcut; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.shortcut IS 'The base table for shortcut entities.';


--
-- TOC entry 5055 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN shortcut.shortcut_set; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.shortcut.shortcut_set IS 'The ID of the target entity.';


--
-- TOC entry 292 (class 1259 OID 17436)
-- Name: shortcut_field_data; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.shortcut_field_data (
    id bigint NOT NULL,
    shortcut_set character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    title character varying(255),
    weight integer,
    link__uri character varying(2048),
    link__title character varying(255),
    link__options bytea,
    default_langcode smallint NOT NULL,
    CONSTRAINT shortcut_field_data_id_check CHECK ((id >= 0))
);


ALTER TABLE public.shortcut_field_data OWNER TO drupal_user;

--
-- TOC entry 5056 (class 0 OID 0)
-- Dependencies: 292
-- Name: TABLE shortcut_field_data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.shortcut_field_data IS 'The data table for shortcut entities.';


--
-- TOC entry 5057 (class 0 OID 0)
-- Dependencies: 292
-- Name: COLUMN shortcut_field_data.shortcut_set; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.shortcut_field_data.shortcut_set IS 'The ID of the target entity.';


--
-- TOC entry 5058 (class 0 OID 0)
-- Dependencies: 292
-- Name: COLUMN shortcut_field_data.link__uri; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.shortcut_field_data.link__uri IS 'The URI of the link.';


--
-- TOC entry 5059 (class 0 OID 0)
-- Dependencies: 292
-- Name: COLUMN shortcut_field_data.link__title; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.shortcut_field_data.link__title IS 'The link text.';


--
-- TOC entry 5060 (class 0 OID 0)
-- Dependencies: 292
-- Name: COLUMN shortcut_field_data.link__options; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.shortcut_field_data.link__options IS 'Serialized array of options for the link.';


--
-- TOC entry 290 (class 1259 OID 17425)
-- Name: shortcut_id_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.shortcut_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shortcut_id_seq OWNER TO drupal_user;

--
-- TOC entry 5061 (class 0 OID 0)
-- Dependencies: 290
-- Name: shortcut_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.shortcut_id_seq OWNED BY public.shortcut.id;


--
-- TOC entry 289 (class 1259 OID 17416)
-- Name: shortcut_set_users; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.shortcut_set_users (
    uid bigint DEFAULT 0 NOT NULL,
    set_name character varying(32) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT shortcut_set_users_uid_check CHECK ((uid >= 0))
);


ALTER TABLE public.shortcut_set_users OWNER TO drupal_user;

--
-- TOC entry 5062 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE shortcut_set_users; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.shortcut_set_users IS 'Maps users to shortcut sets.';


--
-- TOC entry 5063 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN shortcut_set_users.uid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.shortcut_set_users.uid IS 'The "users".uid for this set.';


--
-- TOC entry 5064 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN shortcut_set_users.set_name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.shortcut_set_users.set_name IS 'The "shortcut_set".set_name that will be displayed for this user.';


--
-- TOC entry 280 (class 1259 OID 17306)
-- Name: taxonomy_index; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.taxonomy_index (
    nid bigint DEFAULT 0 NOT NULL,
    tid bigint DEFAULT 0 NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    sticky smallint DEFAULT 0,
    created integer DEFAULT 0 NOT NULL,
    CONSTRAINT taxonomy_index_nid_check CHECK ((nid >= 0)),
    CONSTRAINT taxonomy_index_tid_check CHECK ((tid >= 0))
);


ALTER TABLE public.taxonomy_index OWNER TO drupal_user;

--
-- TOC entry 5065 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE taxonomy_index; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.taxonomy_index IS 'Maintains denormalized information about node/term relationships.';


--
-- TOC entry 5066 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN taxonomy_index.nid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_index.nid IS 'The "node".nid this record tracks.';


--
-- TOC entry 5067 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN taxonomy_index.tid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_index.tid IS 'The term ID.';


--
-- TOC entry 5068 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN taxonomy_index.status; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_index.status IS 'Boolean indicating whether the node is published (visible to non-administrators).';


--
-- TOC entry 5069 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN taxonomy_index.sticky; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_index.sticky IS 'Boolean indicating whether the node is sticky.';


--
-- TOC entry 5070 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN taxonomy_index.created; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_index.created IS 'The Unix timestamp when the node was created.';


--
-- TOC entry 281 (class 1259 OID 17319)
-- Name: taxonomy_term__parent; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.taxonomy_term__parent (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    parent_target_id bigint NOT NULL,
    CONSTRAINT taxonomy_term__parent_delta_check CHECK ((delta >= 0)),
    CONSTRAINT taxonomy_term__parent_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT taxonomy_term__parent_parent_target_id_check CHECK ((parent_target_id >= 0)),
    CONSTRAINT taxonomy_term__parent_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.taxonomy_term__parent OWNER TO drupal_user;

--
-- TOC entry 5071 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE taxonomy_term__parent; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.taxonomy_term__parent IS 'Data storage for taxonomy_term field parent.';


--
-- TOC entry 5072 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN taxonomy_term__parent.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term__parent.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 5073 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN taxonomy_term__parent.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term__parent.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 5074 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN taxonomy_term__parent.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term__parent.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 5075 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN taxonomy_term__parent.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term__parent.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 5076 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN taxonomy_term__parent.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term__parent.langcode IS 'The language code for this data item.';


--
-- TOC entry 5077 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN taxonomy_term__parent.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term__parent.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN taxonomy_term__parent.parent_target_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term__parent.parent_target_id IS 'The ID of the target entity.';


--
-- TOC entry 275 (class 1259 OID 17253)
-- Name: taxonomy_term_data; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.taxonomy_term_data (
    tid integer NOT NULL,
    revision_id bigint,
    vid character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT taxonomy_term_data_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT taxonomy_term_data_tid_check CHECK ((tid >= 0))
);


ALTER TABLE public.taxonomy_term_data OWNER TO drupal_user;

--
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE taxonomy_term_data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.taxonomy_term_data IS 'The base table for taxonomy_term entities.';


--
-- TOC entry 5080 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN taxonomy_term_data.vid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term_data.vid IS 'The ID of the target entity.';


--
-- TOC entry 274 (class 1259 OID 17252)
-- Name: taxonomy_term_data_tid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.taxonomy_term_data_tid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.taxonomy_term_data_tid_seq OWNER TO drupal_user;

--
-- TOC entry 5081 (class 0 OID 0)
-- Dependencies: 274
-- Name: taxonomy_term_data_tid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.taxonomy_term_data_tid_seq OWNED BY public.taxonomy_term_data.tid;


--
-- TOC entry 278 (class 1259 OID 17280)
-- Name: taxonomy_term_field_data; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.taxonomy_term_field_data (
    tid bigint NOT NULL,
    revision_id bigint NOT NULL,
    vid character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    name character varying(255) NOT NULL,
    description__value text,
    description__format character varying(255),
    weight integer NOT NULL,
    changed integer,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT taxonomy_term_field_data_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT taxonomy_term_field_data_tid_check CHECK ((tid >= 0))
);


ALTER TABLE public.taxonomy_term_field_data OWNER TO drupal_user;

--
-- TOC entry 5082 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE taxonomy_term_field_data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.taxonomy_term_field_data IS 'The data table for taxonomy_term entities.';


--
-- TOC entry 5083 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN taxonomy_term_field_data.vid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term_field_data.vid IS 'The ID of the target entity.';


--
-- TOC entry 279 (class 1259 OID 17295)
-- Name: taxonomy_term_field_revision; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.taxonomy_term_field_revision (
    tid bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    name character varying(255),
    description__value text,
    description__format character varying(255),
    changed integer,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT taxonomy_term_field_revision_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT taxonomy_term_field_revision_tid_check CHECK ((tid >= 0))
);


ALTER TABLE public.taxonomy_term_field_revision OWNER TO drupal_user;

--
-- TOC entry 5084 (class 0 OID 0)
-- Dependencies: 279
-- Name: TABLE taxonomy_term_field_revision; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.taxonomy_term_field_revision IS 'The revision data table for taxonomy_term entities.';


--
-- TOC entry 277 (class 1259 OID 17267)
-- Name: taxonomy_term_revision; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.taxonomy_term_revision (
    tid bigint NOT NULL,
    revision_id integer NOT NULL,
    langcode character varying(12) NOT NULL,
    revision_user bigint,
    revision_created integer,
    revision_log_message text,
    revision_default smallint,
    CONSTRAINT taxonomy_term_revision_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT taxonomy_term_revision_revision_user_check CHECK ((revision_user >= 0)),
    CONSTRAINT taxonomy_term_revision_tid_check CHECK ((tid >= 0))
);


ALTER TABLE public.taxonomy_term_revision OWNER TO drupal_user;

--
-- TOC entry 5085 (class 0 OID 0)
-- Dependencies: 277
-- Name: TABLE taxonomy_term_revision; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.taxonomy_term_revision IS 'The revision table for taxonomy_term entities.';


--
-- TOC entry 5086 (class 0 OID 0)
-- Dependencies: 277
-- Name: COLUMN taxonomy_term_revision.revision_user; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term_revision.revision_user IS 'The ID of the target entity.';


--
-- TOC entry 282 (class 1259 OID 17334)
-- Name: taxonomy_term_revision__parent; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.taxonomy_term_revision__parent (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    parent_target_id bigint NOT NULL,
    CONSTRAINT taxonomy_term_revision__parent_delta_check CHECK ((delta >= 0)),
    CONSTRAINT taxonomy_term_revision__parent_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT taxonomy_term_revision__parent_parent_target_id_check CHECK ((parent_target_id >= 0)),
    CONSTRAINT taxonomy_term_revision__parent_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.taxonomy_term_revision__parent OWNER TO drupal_user;

--
-- TOC entry 5087 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE taxonomy_term_revision__parent; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.taxonomy_term_revision__parent IS 'Revision archive storage for taxonomy_term field parent.';


--
-- TOC entry 5088 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN taxonomy_term_revision__parent.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term_revision__parent.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 5089 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN taxonomy_term_revision__parent.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term_revision__parent.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN taxonomy_term_revision__parent.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term_revision__parent.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN taxonomy_term_revision__parent.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term_revision__parent.revision_id IS 'The entity revision id this data is attached to';


--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN taxonomy_term_revision__parent.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term_revision__parent.langcode IS 'The language code for this data item.';


--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN taxonomy_term_revision__parent.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term_revision__parent.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN taxonomy_term_revision__parent.parent_target_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.taxonomy_term_revision__parent.parent_target_id IS 'The ID of the target entity.';


--
-- TOC entry 276 (class 1259 OID 17266)
-- Name: taxonomy_term_revision_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.taxonomy_term_revision_revision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.taxonomy_term_revision_revision_id_seq OWNER TO drupal_user;

--
-- TOC entry 5095 (class 0 OID 0)
-- Dependencies: 276
-- Name: taxonomy_term_revision_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.taxonomy_term_revision_revision_id_seq OWNED BY public.taxonomy_term_revision.revision_id;


--
-- TOC entry 229 (class 1259 OID 16761)
-- Name: user__roles; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.user__roles (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    roles_target_id character varying(255) NOT NULL,
    CONSTRAINT user__roles_delta_check CHECK ((delta >= 0)),
    CONSTRAINT user__roles_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT user__roles_revision_id_check CHECK ((revision_id >= 0))
);


ALTER TABLE public.user__roles OWNER TO drupal_user;

--
-- TOC entry 5096 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE user__roles; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.user__roles IS 'Data storage for user field roles.';


--
-- TOC entry 5097 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN user__roles.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__roles.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 5098 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN user__roles.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__roles.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 5099 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN user__roles.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__roles.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 5100 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN user__roles.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__roles.revision_id IS 'The entity revision id this data is attached to, which for an unversioned entity type is the same as the entity id';


--
-- TOC entry 5101 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN user__roles.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__roles.langcode IS 'The language code for this data item.';


--
-- TOC entry 5102 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN user__roles.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__roles.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 5103 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN user__roles.roles_target_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__roles.roles_target_id IS 'The ID of the target entity.';


--
-- TOC entry 302 (class 1259 OID 17630)
-- Name: user__user_picture; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.user__user_picture (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    user_picture_target_id bigint NOT NULL,
    user_picture_alt character varying(512),
    user_picture_title character varying(1024),
    user_picture_width bigint,
    user_picture_height bigint,
    CONSTRAINT user__user_picture_delta_check CHECK ((delta >= 0)),
    CONSTRAINT user__user_picture_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT user__user_picture_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT user__user_picture_user_picture_height_check CHECK ((user_picture_height >= 0)),
    CONSTRAINT user__user_picture_user_picture_target_id_check CHECK ((user_picture_target_id >= 0)),
    CONSTRAINT user__user_picture_user_picture_width_check CHECK ((user_picture_width >= 0))
);


ALTER TABLE public.user__user_picture OWNER TO drupal_user;

--
-- TOC entry 5104 (class 0 OID 0)
-- Dependencies: 302
-- Name: TABLE user__user_picture; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.user__user_picture IS 'Data storage for user field user_picture.';


--
-- TOC entry 5105 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN user__user_picture.bundle; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__user_picture.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- TOC entry 5106 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN user__user_picture.deleted; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__user_picture.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN user__user_picture.entity_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__user_picture.entity_id IS 'The entity id this data is attached to';


--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN user__user_picture.revision_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__user_picture.revision_id IS 'The entity revision id this data is attached to, which for an unversioned entity type is the same as the entity id';


--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN user__user_picture.langcode; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__user_picture.langcode IS 'The language code for this data item.';


--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN user__user_picture.delta; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__user_picture.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN user__user_picture.user_picture_target_id; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__user_picture.user_picture_target_id IS 'The ID of the file entity.';


--
-- TOC entry 5112 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN user__user_picture.user_picture_alt; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__user_picture.user_picture_alt IS 'Alternative image text, for the image''s ''alt'' attribute.';


--
-- TOC entry 5113 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN user__user_picture.user_picture_title; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__user_picture.user_picture_title IS 'Image title text, for the image''s ''title'' attribute.';


--
-- TOC entry 5114 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN user__user_picture.user_picture_width; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__user_picture.user_picture_width IS 'The width of the image in pixels.';


--
-- TOC entry 5115 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN user__user_picture.user_picture_height; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.user__user_picture.user_picture_height IS 'The height of the image in pixels.';


--
-- TOC entry 227 (class 1259 OID 16738)
-- Name: users; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.users (
    uid integer NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT users_uid_check CHECK ((uid >= 0))
);


ALTER TABLE public.users OWNER TO drupal_user;

--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.users IS 'The base table for user entities.';


--
-- TOC entry 225 (class 1259 OID 16722)
-- Name: users_data; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.users_data (
    uid bigint DEFAULT 0 NOT NULL,
    module character varying(50) DEFAULT ''::character varying NOT NULL,
    name character varying(128) DEFAULT ''::character varying NOT NULL,
    value bytea,
    serialized integer DEFAULT 0,
    CONSTRAINT users_data_serialized_check CHECK ((serialized >= 0)),
    CONSTRAINT users_data_uid_check CHECK ((uid >= 0))
);


ALTER TABLE public.users_data OWNER TO drupal_user;

--
-- TOC entry 5117 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE users_data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.users_data IS 'Stores module data as key/value pairs per user.';


--
-- TOC entry 5118 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN users_data.uid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.users_data.uid IS 'The "users".uid this record affects.';


--
-- TOC entry 5119 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN users_data.module; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.users_data.module IS 'The name of the module declaring the variable.';


--
-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN users_data.name; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.users_data.name IS 'The identifier of the data.';


--
-- TOC entry 5121 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN users_data.value; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.users_data.value IS 'The value.';


--
-- TOC entry 5122 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN users_data.serialized; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.users_data.serialized IS 'Whether value is serialized.';


--
-- TOC entry 228 (class 1259 OID 16747)
-- Name: users_field_data; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.users_field_data (
    uid bigint NOT NULL,
    langcode character varying(12) NOT NULL,
    preferred_langcode character varying(12),
    preferred_admin_langcode character varying(12),
    name character varying(60) NOT NULL,
    pass character varying(255),
    mail character varying(254),
    timezone character varying(32),
    status smallint,
    created integer NOT NULL,
    changed integer,
    access integer NOT NULL,
    login integer,
    init character varying(254),
    default_langcode smallint NOT NULL,
    CONSTRAINT users_field_data_uid_check CHECK ((uid >= 0))
);


ALTER TABLE public.users_field_data OWNER TO drupal_user;

--
-- TOC entry 5123 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE users_field_data; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.users_field_data IS 'The data table for user entities.';


--
-- TOC entry 226 (class 1259 OID 16737)
-- Name: users_uid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.users_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_uid_seq OWNER TO drupal_user;

--
-- TOC entry 5124 (class 0 OID 0)
-- Dependencies: 226
-- Name: users_uid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.users_uid_seq OWNED BY public.users.uid;


--
-- TOC entry 237 (class 1259 OID 16821)
-- Name: watchdog; Type: TABLE; Schema: public; Owner: drupal_user
--

CREATE TABLE public.watchdog (
    wid bigint NOT NULL,
    uid bigint DEFAULT 0 NOT NULL,
    type character varying(64) DEFAULT ''::character varying NOT NULL,
    message text NOT NULL,
    variables bytea NOT NULL,
    severity integer DEFAULT 0 NOT NULL,
    link text,
    location text NOT NULL,
    referer text,
    hostname character varying(128) DEFAULT ''::character varying NOT NULL,
    "timestamp" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT watchdog_severity_check CHECK ((severity >= 0)),
    CONSTRAINT watchdog_uid_check CHECK ((uid >= 0))
);


ALTER TABLE public.watchdog OWNER TO drupal_user;

--
-- TOC entry 5125 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE watchdog; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON TABLE public.watchdog IS 'Table that contains logs of all system events.';


--
-- TOC entry 5126 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN watchdog.wid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.watchdog.wid IS 'Primary Key: Unique watchdog event ID.';


--
-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN watchdog.uid; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.watchdog.uid IS 'The "users".uid of the user who triggered the event.';


--
-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN watchdog.type; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.watchdog.type IS 'Type of log message, for example "user" or "page not found."';


--
-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN watchdog.message; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.watchdog.message IS 'Text of log message to be passed into the t() function.';


--
-- TOC entry 5130 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN watchdog.variables; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.watchdog.variables IS 'Serialized array of variables that match the message string and that is passed into the t() function.';


--
-- TOC entry 5131 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN watchdog.severity; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.watchdog.severity IS 'The severity level of the event. ranges from 0 (Emergency) to 7 (Debug)';


--
-- TOC entry 5132 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN watchdog.link; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.watchdog.link IS 'Link to view the result of the event.';


--
-- TOC entry 5133 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN watchdog.location; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.watchdog.location IS 'URL of the origin of the event.';


--
-- TOC entry 5134 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN watchdog.referer; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.watchdog.referer IS 'URL of referring page.';


--
-- TOC entry 5135 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN watchdog.hostname; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.watchdog.hostname IS 'Hostname of the user who triggered the event.';


--
-- TOC entry 5136 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN watchdog."timestamp"; Type: COMMENT; Schema: public; Owner: drupal_user
--

COMMENT ON COLUMN public.watchdog."timestamp" IS 'Unix timestamp of when event occurred.';


--
-- TOC entry 236 (class 1259 OID 16820)
-- Name: watchdog_wid_seq; Type: SEQUENCE; Schema: public; Owner: drupal_user
--

CREATE SEQUENCE public.watchdog_wid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.watchdog_wid_seq OWNER TO drupal_user;

--
-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 236
-- Name: watchdog_wid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drupal_user
--

ALTER SEQUENCE public.watchdog_wid_seq OWNED BY public.watchdog.wid;


--
-- TOC entry 3876 (class 2604 OID 18355)
-- Name: ban_ip iid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.ban_ip ALTER COLUMN iid SET DEFAULT nextval('public.ban_ip_iid_seq'::regclass);


--
-- TOC entry 3665 (class 2604 OID 16678)
-- Name: batch bid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.batch ALTER COLUMN bid SET DEFAULT nextval('public.batch_bid_seq'::regclass);


--
-- TOC entry 3699 (class 2604 OID 16876)
-- Name: block_content id; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.block_content ALTER COLUMN id SET DEFAULT nextval('public.block_content_id_seq'::regclass);


--
-- TOC entry 3700 (class 2604 OID 16890)
-- Name: block_content_revision revision_id; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.block_content_revision ALTER COLUMN revision_id SET DEFAULT nextval('public.block_content_revision_revision_id_seq'::regclass);


--
-- TOC entry 3735 (class 2604 OID 17124)
-- Name: comment cid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.comment ALTER COLUMN cid SET DEFAULT nextval('public.comment_cid_seq'::regclass);


--
-- TOC entry 3727 (class 2604 OID 17084)
-- Name: file_managed fid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.file_managed ALTER COLUMN fid SET DEFAULT nextval('public.file_managed_fid_seq'::regclass);


--
-- TOC entry 3682 (class 2604 OID 16809)
-- Name: help_search_items sid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.help_search_items ALTER COLUMN sid SET DEFAULT nextval('public.help_search_items_sid_seq'::regclass);


--
-- TOC entry 3749 (class 2604 OID 17215)
-- Name: locales_location lid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.locales_location ALTER COLUMN lid SET DEFAULT nextval('public.locales_location_lid_seq'::regclass);


--
-- TOC entry 3743 (class 2604 OID 17192)
-- Name: locales_source lid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.locales_source ALTER COLUMN lid SET DEFAULT nextval('public.locales_source_lid_seq'::regclass);


--
-- TOC entry 3776 (class 2604 OID 17364)
-- Name: menu_link_content id; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.menu_link_content ALTER COLUMN id SET DEFAULT nextval('public.menu_link_content_id_seq'::regclass);


--
-- TOC entry 3777 (class 2604 OID 17377)
-- Name: menu_link_content_revision revision_id; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.menu_link_content_revision ALTER COLUMN revision_id SET DEFAULT nextval('public.menu_link_content_revision_revision_id_seq'::regclass);


--
-- TOC entry 3787 (class 2604 OID 17493)
-- Name: menu_tree mlid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.menu_tree ALTER COLUMN mlid SET DEFAULT nextval('public.menu_tree_mlid_seq'::regclass);


--
-- TOC entry 3715 (class 2604 OID 16978)
-- Name: node nid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node ALTER COLUMN nid SET DEFAULT nextval('public.node_nid_seq'::regclass);


--
-- TOC entry 3716 (class 2604 OID 16992)
-- Name: node_revision vid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node_revision ALTER COLUMN vid SET DEFAULT nextval('public.node_revision_vid_seq'::regclass);


--
-- TOC entry 3680 (class 2604 OID 16780)
-- Name: path_alias id; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.path_alias ALTER COLUMN id SET DEFAULT nextval('public.path_alias_id_seq'::regclass);


--
-- TOC entry 3681 (class 2604 OID 16797)
-- Name: path_alias_revision revision_id; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.path_alias_revision ALTER COLUMN revision_id SET DEFAULT nextval('public.path_alias_revision_revision_id_seq'::regclass);


--
-- TOC entry 3666 (class 2604 OID 16689)
-- Name: queue item_id; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.queue ALTER COLUMN item_id SET DEFAULT nextval('public.queue_item_id_seq'::regclass);


--
-- TOC entry 3664 (class 2604 OID 16670)
-- Name: sequences value; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.sequences ALTER COLUMN value SET DEFAULT nextval('public.sequences_value_seq'::regclass);


--
-- TOC entry 3780 (class 2604 OID 17429)
-- Name: shortcut id; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.shortcut ALTER COLUMN id SET DEFAULT nextval('public.shortcut_id_seq'::regclass);


--
-- TOC entry 3763 (class 2604 OID 17256)
-- Name: taxonomy_term_data tid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.taxonomy_term_data ALTER COLUMN tid SET DEFAULT nextval('public.taxonomy_term_data_tid_seq'::regclass);


--
-- TOC entry 3764 (class 2604 OID 17270)
-- Name: taxonomy_term_revision revision_id; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.taxonomy_term_revision ALTER COLUMN revision_id SET DEFAULT nextval('public.taxonomy_term_revision_revision_id_seq'::regclass);


--
-- TOC entry 3676 (class 2604 OID 16741)
-- Name: users uid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.users ALTER COLUMN uid SET DEFAULT nextval('public.users_uid_seq'::regclass);


--
-- TOC entry 3686 (class 2604 OID 16824)
-- Name: watchdog wid; Type: DEFAULT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.watchdog ALTER COLUMN wid SET DEFAULT nextval('public.watchdog_wid_seq'::regclass);

-- Dependencies: 316
-- Name: ban_ip_iid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.ban_ip_iid_seq', 1, false);


--
-- TOC entry 5139 (class 0 OID 0)
-- Dependencies: 220
-- Name: batch_bid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.batch_bid_seq', 4, true);


--
-- TOC entry 5140 (class 0 OID 0)
-- Dependencies: 241
-- Name: block_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.block_content_id_seq', 1, false);


--
-- TOC entry 5141 (class 0 OID 0)
-- Dependencies: 243
-- Name: block_content_revision_revision_id_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.block_content_revision_revision_id_seq', 1, false);


--
-- TOC entry 5142 (class 0 OID 0)
-- Dependencies: 262
-- Name: comment_cid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.comment_cid_seq', 1, false);


--
-- TOC entry 5143 (class 0 OID 0)
-- Dependencies: 259
-- Name: file_managed_fid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.file_managed_fid_seq', 2, true);


--
-- TOC entry 5144 (class 0 OID 0)
-- Dependencies: 234
-- Name: help_search_items_sid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.help_search_items_sid_seq', 92, true);


--
-- TOC entry 5145 (class 0 OID 0)
-- Dependencies: 270
-- Name: locales_location_lid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.locales_location_lid_seq', 1046, true);


--
-- TOC entry 5146 (class 0 OID 0)
-- Dependencies: 267
-- Name: locales_source_lid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.locales_source_lid_seq', 11347, true);


--
-- TOC entry 5147 (class 0 OID 0)
-- Dependencies: 283
-- Name: menu_link_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.menu_link_content_id_seq', 1, false);


--
-- TOC entry 5148 (class 0 OID 0)
-- Dependencies: 285
-- Name: menu_link_content_revision_revision_id_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.menu_link_content_revision_revision_id_seq', 1, false);


--
-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 294
-- Name: menu_tree_mlid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.menu_tree_mlid_seq', 71, true);


--
-- TOC entry 5150 (class 0 OID 0)
-- Dependencies: 250
-- Name: node_nid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.node_nid_seq', 3, true);


--
-- TOC entry 5151 (class 0 OID 0)
-- Dependencies: 252
-- Name: node_revision_vid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.node_revision_vid_seq', 4, true);


--
-- TOC entry 5152 (class 0 OID 0)
-- Dependencies: 230
-- Name: path_alias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.path_alias_id_seq', 1, false);


--
-- TOC entry 5153 (class 0 OID 0)
-- Dependencies: 232
-- Name: path_alias_revision_revision_id_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.path_alias_revision_revision_id_seq', 1, false);


--
-- TOC entry 5154 (class 0 OID 0)
-- Dependencies: 222
-- Name: queue_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.queue_item_id_seq', 74, true);


--
-- TOC entry 5155 (class 0 OID 0)
-- Dependencies: 218
-- Name: sequences_value_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.sequences_value_seq', 1, false);


--
-- TOC entry 5156 (class 0 OID 0)
-- Dependencies: 290
-- Name: shortcut_id_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.shortcut_id_seq', 2, true);


--
-- TOC entry 5157 (class 0 OID 0)
-- Dependencies: 274
-- Name: taxonomy_term_data_tid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.taxonomy_term_data_tid_seq', 3, true);


--
-- TOC entry 5158 (class 0 OID 0)
-- Dependencies: 276
-- Name: taxonomy_term_revision_revision_id_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.taxonomy_term_revision_revision_id_seq', 3, true);


--
-- TOC entry 5159 (class 0 OID 0)
-- Dependencies: 226
-- Name: users_uid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.users_uid_seq', 1, true);


--
-- TOC entry 5160 (class 0 OID 0)
-- Dependencies: 236
-- Name: watchdog_wid_seq; Type: SEQUENCE SET; Schema: public; Owner: drupal_user
--

SELECT pg_catalog.setval('public.watchdog_wid_seq', 160, true);


--
-- TOC entry 4389 (class 2606 OID 18359)
-- Name: ban_ip ban_ip____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.ban_ip
    ADD CONSTRAINT ban_ip____pkey PRIMARY KEY (iid);


--
-- TOC entry 4042 (class 2606 OID 16683)
-- Name: batch batch____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.batch
    ADD CONSTRAINT batch____pkey PRIMARY KEY (bid);


--
-- TOC entry 4101 (class 2606 OID 16880)
-- Name: block_content block_content____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.block_content
    ADD CONSTRAINT block_content____pkey PRIMARY KEY (id);


--
-- TOC entry 4103 (class 2606 OID 16882)
-- Name: block_content block_content__block_content__revision_id__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.block_content
    ADD CONSTRAINT block_content__block_content__revision_id__key UNIQUE (revision_id);


--
-- TOC entry 4106 (class 2606 OID 16884)
-- Name: block_content block_content__block_content_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.block_content
    ADD CONSTRAINT block_content__block_content_field__uuid__value__key UNIQUE (uuid);


--
-- TOC entry 4122 (class 2606 OID 16933)
-- Name: block_content__body block_content__body____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.block_content__body
    ADD CONSTRAINT block_content__body____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- TOC entry 4112 (class 2606 OID 16906)
-- Name: block_content_field_data block_content_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.block_content_field_data
    ADD CONSTRAINT block_content_field_data____pkey PRIMARY KEY (id, langcode);


--
-- TOC entry 4119 (class 2606 OID 16918)
-- Name: block_content_field_revision block_content_field_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.block_content_field_revision
    ADD CONSTRAINT block_content_field_revision____pkey PRIMARY KEY (revision_id, langcode);


--
-- TOC entry 4108 (class 2606 OID 16897)
-- Name: block_content_revision block_content_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.block_content_revision
    ADD CONSTRAINT block_content_revision____pkey PRIMARY KEY (revision_id);


--
-- TOC entry 4127 (class 2606 OID 16949)
-- Name: block_content_revision__body block_content_revision__body____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.block_content_revision__body
    ADD CONSTRAINT block_content_revision__body____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- TOC entry 4361 (class 2606 OID 17994)
-- Name: cache_access_policy cache_access_policy____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_access_policy
    ADD CONSTRAINT cache_access_policy____pkey PRIMARY KEY (cid);


--
-- TOC entry 4353 (class 2606 OID 17967)
-- Name: cache_bootstrap cache_bootstrap____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_bootstrap
    ADD CONSTRAINT cache_bootstrap____pkey PRIMARY KEY (cid);


--
-- TOC entry 4343 (class 2606 OID 17934)
-- Name: cache_config cache_config____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_config
    ADD CONSTRAINT cache_config____pkey PRIMARY KEY (cid);


--
-- TOC entry 4209 (class 2606 OID 17184)
-- Name: cache_container cache_container____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_container
    ADD CONSTRAINT cache_container____pkey PRIMARY KEY (cid);


--
-- TOC entry 4349 (class 2606 OID 17954)
-- Name: cache_data cache_data____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_data
    ADD CONSTRAINT cache_data____pkey PRIMARY KEY (cid);


--
-- TOC entry 4365 (class 2606 OID 18009)
-- Name: cache_default cache_default____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_default
    ADD CONSTRAINT cache_default____pkey PRIMARY KEY (cid);


--
-- TOC entry 4357 (class 2606 OID 17980)
-- Name: cache_discovery cache_discovery____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_discovery
    ADD CONSTRAINT cache_discovery____pkey PRIMARY KEY (cid);


--
-- TOC entry 4385 (class 2606 OID 18139)
-- Name: cache_dynamic_page_cache cache_dynamic_page_cache____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_dynamic_page_cache
    ADD CONSTRAINT cache_dynamic_page_cache____pkey PRIMARY KEY (cid);


--
-- TOC entry 4381 (class 2606 OID 18125)
-- Name: cache_entity cache_entity____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_entity
    ADD CONSTRAINT cache_entity____pkey PRIMARY KEY (cid);


--
-- TOC entry 4377 (class 2606 OID 18103)
-- Name: cache_menu cache_menu____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_menu
    ADD CONSTRAINT cache_menu____pkey PRIMARY KEY (cid);


--
-- TOC entry 4395 (class 2606 OID 18928)
-- Name: cache_page cache_page____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_page
    ADD CONSTRAINT cache_page____pkey PRIMARY KEY (cid);


--
-- TOC entry 4373 (class 2606 OID 18060)
-- Name: cache_render cache_render____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cache_render
    ADD CONSTRAINT cache_render____pkey PRIMARY KEY (cid);


--
-- TOC entry 4347 (class 2606 OID 17943)
-- Name: cachetags cachetags____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.cachetags
    ADD CONSTRAINT cachetags____pkey PRIMARY KEY (tag);


--
-- TOC entry 4189 (class 2606 OID 17127)
-- Name: comment comment____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment____pkey PRIMARY KEY (cid);


--
-- TOC entry 4204 (class 2606 OID 17163)
-- Name: comment__comment_body comment__comment_body____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.comment__comment_body
    ADD CONSTRAINT comment__comment_body____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- TOC entry 4192 (class 2606 OID 17129)
-- Name: comment comment__comment_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment__comment_field__uuid__value__key UNIQUE (uuid);


--
-- TOC entry 4184 (class 2606 OID 17116)
-- Name: comment_entity_statistics comment_entity_statistics____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.comment_entity_statistics
    ADD CONSTRAINT comment_entity_statistics____pkey PRIMARY KEY (entity_id, entity_type, field_name);


--
-- TOC entry 4194 (class 2606 OID 17141)
-- Name: comment_field_data comment_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.comment_field_data
    ADD CONSTRAINT comment_field_data____pkey PRIMARY KEY (cid, langcode);


--
-- TOC entry 4036 (class 2606 OID 16656)
-- Name: config config____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.config
    ADD CONSTRAINT config____pkey PRIMARY KEY (collection, name);


--
-- TOC entry 4176 (class 2606 OID 17091)
-- Name: file_managed file_managed____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.file_managed
    ADD CONSTRAINT file_managed____pkey PRIMARY KEY (fid);


--
-- TOC entry 4182 (class 2606 OID 17093)
-- Name: file_managed file_managed__file_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.file_managed
    ADD CONSTRAINT file_managed__file_field__uuid__value__key UNIQUE (uuid);


--
-- TOC entry 4171 (class 2606 OID 17076)
-- Name: file_usage file_usage____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.file_usage
    ADD CONSTRAINT file_usage____pkey PRIMARY KEY (fid, type, id, module);


--
-- TOC entry 4085 (class 2606 OID 16817)
-- Name: help_search_items help_search_items____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.help_search_items
    ADD CONSTRAINT help_search_items____pkey PRIMARY KEY (sid);


--
-- TOC entry 4225 (class 2606 OID 17249)
-- Name: history history____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.history
    ADD CONSTRAINT history____pkey PRIMARY KEY (uid, nid);


--
-- TOC entry 4392 (class 2606 OID 18397)
-- Name: inline_block_usage inline_block_usage____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.inline_block_usage
    ADD CONSTRAINT inline_block_usage____pkey PRIMARY KEY (block_content_id);


--
-- TOC entry 4038 (class 2606 OID 16665)
-- Name: key_value key_value____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.key_value
    ADD CONSTRAINT key_value____pkey PRIMARY KEY (collection, name);


--
-- TOC entry 4340 (class 2606 OID 17916)
-- Name: key_value_expire key_value_expire____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.key_value_expire
    ADD CONSTRAINT key_value_expire____pkey PRIMARY KEY (collection, name);


--
-- TOC entry 4223 (class 2606 OID 17236)
-- Name: locale_file locale_file____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.locale_file
    ADD CONSTRAINT locale_file____pkey PRIMARY KEY (project, langcode);


--
-- TOC entry 4219 (class 2606 OID 17220)
-- Name: locales_location locales_location____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.locales_location
    ADD CONSTRAINT locales_location____pkey PRIMARY KEY (lid);


--
-- TOC entry 4213 (class 2606 OID 17198)
-- Name: locales_source locales_source____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.locales_source
    ADD CONSTRAINT locales_source____pkey PRIMARY KEY (lid);


--
-- TOC entry 4216 (class 2606 OID 17209)
-- Name: locales_target locales_target____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.locales_target
    ADD CONSTRAINT locales_target____pkey PRIMARY KEY (language, lid);


--
-- TOC entry 4264 (class 2606 OID 17368)
-- Name: menu_link_content menu_link_content____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.menu_link_content
    ADD CONSTRAINT menu_link_content____pkey PRIMARY KEY (id);


--
-- TOC entry 4266 (class 2606 OID 17370)
-- Name: menu_link_content menu_link_content__menu_link_content__revision_id__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.menu_link_content
    ADD CONSTRAINT menu_link_content__menu_link_content__revision_id__key UNIQUE (revision_id);


--
-- TOC entry 4268 (class 2606 OID 17372)
-- Name: menu_link_content menu_link_content__menu_link_content_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.menu_link_content
    ADD CONSTRAINT menu_link_content__menu_link_content_field__uuid__value__key UNIQUE (uuid);


--
-- TOC entry 4275 (class 2606 OID 17395)
-- Name: menu_link_content_data menu_link_content_data____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.menu_link_content_data
    ADD CONSTRAINT menu_link_content_data____pkey PRIMARY KEY (id, langcode);


--
-- TOC entry 4282 (class 2606 OID 17408)
-- Name: menu_link_content_field_revision menu_link_content_field_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.menu_link_content_field_revision
    ADD CONSTRAINT menu_link_content_field_revision____pkey PRIMARY KEY (revision_id, langcode);


--
-- TOC entry 4270 (class 2606 OID 17384)
-- Name: menu_link_content_revision menu_link_content_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.menu_link_content_revision
    ADD CONSTRAINT menu_link_content_revision____pkey PRIMARY KEY (revision_id);


--
-- TOC entry 4300 (class 2606 OID 17525)
-- Name: menu_tree menu_tree____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.menu_tree
    ADD CONSTRAINT menu_tree____pkey PRIMARY KEY (mlid);


--
-- TOC entry 4302 (class 2606 OID 17527)
-- Name: menu_tree menu_tree__id__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.menu_tree
    ADD CONSTRAINT menu_tree__id__key UNIQUE (id);


--
-- TOC entry 4134 (class 2606 OID 16982)
-- Name: node node____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node
    ADD CONSTRAINT node____pkey PRIMARY KEY (nid);


--
-- TOC entry 4161 (class 2606 OID 17043)
-- Name: node__body node__body____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node__body
    ADD CONSTRAINT node__body____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- TOC entry 4317 (class 2606 OID 17581)
-- Name: node__comment node__comment____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node__comment
    ADD CONSTRAINT node__comment____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- TOC entry 4307 (class 2606 OID 17546)
-- Name: node__field_image node__field_image____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node__field_image
    ADD CONSTRAINT node__field_image____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- TOC entry 4325 (class 2606 OID 17610)
-- Name: node__field_tags node__field_tags____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node__field_tags
    ADD CONSTRAINT node__field_tags____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- TOC entry 4136 (class 2606 OID 16984)
-- Name: node node__node__vid__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node
    ADD CONSTRAINT node__node__vid__key UNIQUE (vid);


--
-- TOC entry 4139 (class 2606 OID 16986)
-- Name: node node__node_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node
    ADD CONSTRAINT node__node_field__uuid__value__key UNIQUE (uuid);


--
-- TOC entry 4132 (class 2606 OID 16973)
-- Name: node_access node_access____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node_access
    ADD CONSTRAINT node_access____pkey PRIMARY KEY (nid, gid, realm, langcode);


--
-- TOC entry 4146 (class 2606 OID 17010)
-- Name: node_field_data node_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node_field_data
    ADD CONSTRAINT node_field_data____pkey PRIMARY KEY (nid, langcode);


--
-- TOC entry 4157 (class 2606 OID 17027)
-- Name: node_field_revision node_field_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node_field_revision
    ADD CONSTRAINT node_field_revision____pkey PRIMARY KEY (vid, langcode);


--
-- TOC entry 4141 (class 2606 OID 16999)
-- Name: node_revision node_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node_revision
    ADD CONSTRAINT node_revision____pkey PRIMARY KEY (vid);


--
-- TOC entry 4166 (class 2606 OID 17059)
-- Name: node_revision__body node_revision__body____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node_revision__body
    ADD CONSTRAINT node_revision__body____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- TOC entry 4321 (class 2606 OID 17595)
-- Name: node_revision__comment node_revision__comment____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node_revision__comment
    ADD CONSTRAINT node_revision__comment____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- TOC entry 4312 (class 2606 OID 17565)
-- Name: node_revision__field_image node_revision__field_image____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node_revision__field_image
    ADD CONSTRAINT node_revision__field_image____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- TOC entry 4330 (class 2606 OID 17625)
-- Name: node_revision__field_tags node_revision__field_tags____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.node_revision__field_tags
    ADD CONSTRAINT node_revision__field_tags____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- TOC entry 4074 (class 2606 OID 16786)
-- Name: path_alias path_alias____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.path_alias
    ADD CONSTRAINT path_alias____pkey PRIMARY KEY (id);


--
-- TOC entry 4078 (class 2606 OID 16788)
-- Name: path_alias path_alias__path_alias__revision_id__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.path_alias
    ADD CONSTRAINT path_alias__path_alias__revision_id__key UNIQUE (revision_id);


--
-- TOC entry 4080 (class 2606 OID 16790)
-- Name: path_alias path_alias__path_alias_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.path_alias
    ADD CONSTRAINT path_alias__path_alias_field__uuid__value__key UNIQUE (uuid);


--
-- TOC entry 4082 (class 2606 OID 16803)
-- Name: path_alias_revision path_alias_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.path_alias_revision
    ADD CONSTRAINT path_alias_revision____pkey PRIMARY KEY (revision_id);


--
-- TOC entry 4045 (class 2606 OID 16697)
-- Name: queue queue____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.queue
    ADD CONSTRAINT queue____pkey PRIMARY KEY (item_id);


--
-- TOC entry 4297 (class 2606 OID 17486)
-- Name: router router____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.router
    ADD CONSTRAINT router____pkey PRIMARY KEY (name);


--
-- TOC entry 4094 (class 2606 OID 16850)
-- Name: search_dataset search_dataset____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.search_dataset
    ADD CONSTRAINT search_dataset____pkey PRIMARY KEY (sid, langcode, type);


--
-- TOC entry 4096 (class 2606 OID 16859)
-- Name: search_index search_index____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.search_index
    ADD CONSTRAINT search_index____pkey PRIMARY KEY (word, sid, langcode, type);


--
-- TOC entry 4099 (class 2606 OID 16866)
-- Name: search_total search_total____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.search_total
    ADD CONSTRAINT search_total____pkey PRIMARY KEY (word);


--
-- TOC entry 4369 (class 2606 OID 18046)
-- Name: semaphore semaphore____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.semaphore
    ADD CONSTRAINT semaphore____pkey PRIMARY KEY (name);


--
-- TOC entry 4040 (class 2606 OID 16673)
-- Name: sequences sequences____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.sequences
    ADD CONSTRAINT sequences____pkey PRIMARY KEY (value);


--
-- TOC entry 4049 (class 2606 OID 16709)
-- Name: sessions sessions____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions____pkey PRIMARY KEY (sid);


--
-- TOC entry 4287 (class 2606 OID 17432)
-- Name: shortcut shortcut____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.shortcut
    ADD CONSTRAINT shortcut____pkey PRIMARY KEY (id);


--
-- TOC entry 4290 (class 2606 OID 17434)
-- Name: shortcut shortcut__shortcut_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.shortcut
    ADD CONSTRAINT shortcut__shortcut_field__uuid__value__key UNIQUE (uuid);


--
-- TOC entry 4294 (class 2606 OID 17443)
-- Name: shortcut_field_data shortcut_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.shortcut_field_data
    ADD CONSTRAINT shortcut_field_data____pkey PRIMARY KEY (id, langcode);


--
-- TOC entry 4284 (class 2606 OID 17423)
-- Name: shortcut_set_users shortcut_set_users____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.shortcut_set_users
    ADD CONSTRAINT shortcut_set_users____pkey PRIMARY KEY (uid);


--
-- TOC entry 4251 (class 2606 OID 17317)
-- Name: taxonomy_index taxonomy_index____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.taxonomy_index
    ADD CONSTRAINT taxonomy_index____pkey PRIMARY KEY (nid, tid);


--
-- TOC entry 4254 (class 2606 OID 17330)
-- Name: taxonomy_term__parent taxonomy_term__parent____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.taxonomy_term__parent
    ADD CONSTRAINT taxonomy_term__parent____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- TOC entry 4228 (class 2606 OID 17260)
-- Name: taxonomy_term_data taxonomy_term_data____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.taxonomy_term_data
    ADD CONSTRAINT taxonomy_term_data____pkey PRIMARY KEY (tid);


--
-- TOC entry 4230 (class 2606 OID 17262)
-- Name: taxonomy_term_data taxonomy_term_data__taxonomy_term__revision_id__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.taxonomy_term_data
    ADD CONSTRAINT taxonomy_term_data__taxonomy_term__revision_id__key UNIQUE (revision_id);


--
-- TOC entry 4232 (class 2606 OID 17264)
-- Name: taxonomy_term_data taxonomy_term_data__taxonomy_term_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.taxonomy_term_data
    ADD CONSTRAINT taxonomy_term_data__taxonomy_term_field__uuid__value__key UNIQUE (uuid);


--
-- TOC entry 4240 (class 2606 OID 17288)
-- Name: taxonomy_term_field_data taxonomy_term_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.taxonomy_term_field_data
    ADD CONSTRAINT taxonomy_term_field_data____pkey PRIMARY KEY (tid, langcode);


--
-- TOC entry 4249 (class 2606 OID 17303)
-- Name: taxonomy_term_field_revision taxonomy_term_field_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.taxonomy_term_field_revision
    ADD CONSTRAINT taxonomy_term_field_revision____pkey PRIMARY KEY (revision_id, langcode);


--
-- TOC entry 4236 (class 2606 OID 17277)
-- Name: taxonomy_term_revision taxonomy_term_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.taxonomy_term_revision
    ADD CONSTRAINT taxonomy_term_revision____pkey PRIMARY KEY (revision_id);


--
-- TOC entry 4259 (class 2606 OID 17345)
-- Name: taxonomy_term_revision__parent taxonomy_term_revision__parent____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.taxonomy_term_revision__parent
    ADD CONSTRAINT taxonomy_term_revision__parent____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- TOC entry 4069 (class 2606 OID 16771)
-- Name: user__roles user__roles____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.user__roles
    ADD CONSTRAINT user__roles____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- TOC entry 4335 (class 2606 OID 17645)
-- Name: user__user_picture user__user_picture____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.user__user_picture
    ADD CONSTRAINT user__user_picture____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- TOC entry 4057 (class 2606 OID 16744)
-- Name: users users____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users____pkey PRIMARY KEY (uid);


--
-- TOC entry 4059 (class 2606 OID 16746)
-- Name: users users__user_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users__user_field__uuid__value__key UNIQUE (uuid);


--
-- TOC entry 4053 (class 2606 OID 16734)
-- Name: users_data users_data____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.users_data
    ADD CONSTRAINT users_data____pkey PRIMARY KEY (uid, module, name);


--
-- TOC entry 4061 (class 2606 OID 16754)
-- Name: users_field_data users_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.users_field_data
    ADD CONSTRAINT users_field_data____pkey PRIMARY KEY (uid, langcode);


--
-- TOC entry 4064 (class 2606 OID 16756)
-- Name: users_field_data users_field_data__user__name__key; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.users_field_data
    ADD CONSTRAINT users_field_data__user__name__key UNIQUE (name, langcode);


--
-- TOC entry 4089 (class 2606 OID 16835)
-- Name: watchdog watchdog____pkey; Type: CONSTRAINT; Schema: public; Owner: drupal_user
--

ALTER TABLE ONLY public.watchdog
    ADD CONSTRAINT watchdog____pkey PRIMARY KEY (wid);


--
-- TOC entry 4390 (class 1259 OID 18360)
-- Name: ban_ip__ip__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX ban_ip__ip__idx ON public.ban_ip USING btree (ip);


--
-- TOC entry 4043 (class 1259 OID 16684)
-- Name: batch__token__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX batch__token__idx ON public.batch USING btree (token);


--
-- TOC entry 4104 (class 1259 OID 16885)
-- Name: block_content__block_content_field__type__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX block_content__block_content_field__type__target_id__idx ON public.block_content USING btree (type);


--
-- TOC entry 4123 (class 1259 OID 16936)
-- Name: block_content__body__body_format__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX block_content__body__body_format__idx ON public.block_content__body USING btree (body_format);


--
-- TOC entry 4124 (class 1259 OID 16934)
-- Name: block_content__body__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX block_content__body__bundle__idx ON public.block_content__body USING btree (bundle);


--
-- TOC entry 4125 (class 1259 OID 16935)
-- Name: block_content__body__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX block_content__body__revision_id__idx ON public.block_content__body USING btree (revision_id);


--
-- TOC entry 4113 (class 1259 OID 16908)
-- Name: block_content_field_data__block_content__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX block_content_field_data__block_content__revision_id__idx ON public.block_content_field_data USING btree (revision_id);


--
-- TOC entry 4114 (class 1259 OID 16911)
-- Name: block_content_field_data__block_content__status_type__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX block_content_field_data__block_content__status_type__idx ON public.block_content_field_data USING btree (status, type, id);


--
-- TOC entry 4115 (class 1259 OID 16910)
-- Name: block_content_field_data__block_content_field__reusable__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX block_content_field_data__block_content_field__reusable__idx ON public.block_content_field_data USING btree (reusable);


--
-- TOC entry 4109 (class 1259 OID 16898)
-- Name: block_content_revision__block_content__id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX block_content_revision__block_content__id__idx ON public.block_content_revision USING btree (id);


--
-- TOC entry 4128 (class 1259 OID 16952)
-- Name: block_content_revision__body__body_format__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX block_content_revision__body__body_format__idx ON public.block_content_revision__body USING btree (body_format);


--
-- TOC entry 4129 (class 1259 OID 16950)
-- Name: block_content_revision__body__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX block_content_revision__body__bundle__idx ON public.block_content_revision__body USING btree (bundle);


--
-- TOC entry 4130 (class 1259 OID 16951)
-- Name: block_content_revision__body__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX block_content_revision__body__revision_id__idx ON public.block_content_revision__body USING btree (revision_id);


--
-- TOC entry 4362 (class 1259 OID 17996)
-- Name: cache_access_policy__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_access_policy__created__idx ON public.cache_access_policy USING btree (created);


--
-- TOC entry 4363 (class 1259 OID 17995)
-- Name: cache_access_policy__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_access_policy__expire__idx ON public.cache_access_policy USING btree (expire);


--
-- TOC entry 4354 (class 1259 OID 17969)
-- Name: cache_bootstrap__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_bootstrap__created__idx ON public.cache_bootstrap USING btree (created);


--
-- TOC entry 4355 (class 1259 OID 17968)
-- Name: cache_bootstrap__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_bootstrap__expire__idx ON public.cache_bootstrap USING btree (expire);


--
-- TOC entry 4344 (class 1259 OID 17936)
-- Name: cache_config__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_config__created__idx ON public.cache_config USING btree (created);


--
-- TOC entry 4345 (class 1259 OID 17935)
-- Name: cache_config__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_config__expire__idx ON public.cache_config USING btree (expire);


--
-- TOC entry 4210 (class 1259 OID 17186)
-- Name: cache_container__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_container__created__idx ON public.cache_container USING btree (created);


--
-- TOC entry 4211 (class 1259 OID 17185)
-- Name: cache_container__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_container__expire__idx ON public.cache_container USING btree (expire);


--
-- TOC entry 4350 (class 1259 OID 17956)
-- Name: cache_data__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_data__created__idx ON public.cache_data USING btree (created);


--
-- TOC entry 4351 (class 1259 OID 17955)
-- Name: cache_data__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_data__expire__idx ON public.cache_data USING btree (expire);


--
-- TOC entry 4366 (class 1259 OID 18011)
-- Name: cache_default__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_default__created__idx ON public.cache_default USING btree (created);


--
-- TOC entry 4367 (class 1259 OID 18010)
-- Name: cache_default__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_default__expire__idx ON public.cache_default USING btree (expire);


--
-- TOC entry 4358 (class 1259 OID 17982)
-- Name: cache_discovery__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_discovery__created__idx ON public.cache_discovery USING btree (created);


--
-- TOC entry 4359 (class 1259 OID 17981)
-- Name: cache_discovery__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_discovery__expire__idx ON public.cache_discovery USING btree (expire);


--
-- TOC entry 4386 (class 1259 OID 18141)
-- Name: cache_dynamic_page_cache__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_dynamic_page_cache__created__idx ON public.cache_dynamic_page_cache USING btree (created);


--
-- TOC entry 4387 (class 1259 OID 18140)
-- Name: cache_dynamic_page_cache__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_dynamic_page_cache__expire__idx ON public.cache_dynamic_page_cache USING btree (expire);


--
-- TOC entry 4382 (class 1259 OID 18127)
-- Name: cache_entity__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_entity__created__idx ON public.cache_entity USING btree (created);


--
-- TOC entry 4383 (class 1259 OID 18126)
-- Name: cache_entity__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_entity__expire__idx ON public.cache_entity USING btree (expire);


--
-- TOC entry 4378 (class 1259 OID 18105)
-- Name: cache_menu__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_menu__created__idx ON public.cache_menu USING btree (created);


--
-- TOC entry 4379 (class 1259 OID 18104)
-- Name: cache_menu__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_menu__expire__idx ON public.cache_menu USING btree (expire);


--
-- TOC entry 4396 (class 1259 OID 18930)
-- Name: cache_page__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_page__created__idx ON public.cache_page USING btree (created);


--
-- TOC entry 4397 (class 1259 OID 18929)
-- Name: cache_page__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_page__expire__idx ON public.cache_page USING btree (expire);


--
-- TOC entry 4374 (class 1259 OID 18062)
-- Name: cache_render__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_render__created__idx ON public.cache_render USING btree (created);


--
-- TOC entry 4375 (class 1259 OID 18061)
-- Name: cache_render__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX cache_render__expire__idx ON public.cache_render USING btree (expire);


--
-- TOC entry 4205 (class 1259 OID 17164)
-- Name: comment__comment_body__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment__comment_body__bundle__idx ON public.comment__comment_body USING btree (bundle);


--
-- TOC entry 4206 (class 1259 OID 17166)
-- Name: comment__comment_body__comment_body_format__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment__comment_body__comment_body_format__idx ON public.comment__comment_body USING btree (comment_body_format);


--
-- TOC entry 4207 (class 1259 OID 17165)
-- Name: comment__comment_body__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment__comment_body__revision_id__idx ON public.comment__comment_body USING btree (revision_id);


--
-- TOC entry 4190 (class 1259 OID 17130)
-- Name: comment__comment_field__comment_type__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment__comment_field__comment_type__target_id__idx ON public.comment USING btree (comment_type);


--
-- TOC entry 4185 (class 1259 OID 17118)
-- Name: comment_entity_statistics__comment_count__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment_entity_statistics__comment_count__idx ON public.comment_entity_statistics USING btree (comment_count);


--
-- TOC entry 4186 (class 1259 OID 17117)
-- Name: comment_entity_statistics__last_comment_timestamp__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment_entity_statistics__last_comment_timestamp__idx ON public.comment_entity_statistics USING btree (last_comment_timestamp);


--
-- TOC entry 4187 (class 1259 OID 17119)
-- Name: comment_entity_statistics__last_comment_uid__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment_entity_statistics__last_comment_uid__idx ON public.comment_entity_statistics USING btree (last_comment_uid);


--
-- TOC entry 4195 (class 1259 OID 17149)
-- Name: comment_field_data__comment__entity_langcode__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment_field_data__comment__entity_langcode__idx ON public.comment_field_data USING btree (entity_id, entity_type, comment_type, default_langcode);


--
-- TOC entry 4196 (class 1259 OID 17148)
-- Name: comment_field_data__comment__num_new__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment_field_data__comment__num_new__idx ON public.comment_field_data USING btree (entity_id, entity_type, comment_type, status, created, cid, thread);


--
-- TOC entry 4197 (class 1259 OID 17146)
-- Name: comment_field_data__comment__status_comment_type__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment_field_data__comment__status_comment_type__idx ON public.comment_field_data USING btree (status, comment_type, cid);


--
-- TOC entry 4198 (class 1259 OID 17147)
-- Name: comment_field_data__comment__status_pid__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment_field_data__comment__status_pid__idx ON public.comment_field_data USING btree (pid, status);


--
-- TOC entry 4199 (class 1259 OID 17143)
-- Name: comment_field_data__comment_field__comment_type__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment_field_data__comment_field__comment_type__target_id__idx ON public.comment_field_data USING btree (comment_type);


--
-- TOC entry 4200 (class 1259 OID 17145)
-- Name: comment_field_data__comment_field__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment_field_data__comment_field__created__idx ON public.comment_field_data USING btree (created);


--
-- TOC entry 4201 (class 1259 OID 17144)
-- Name: comment_field_data__comment_field__uid__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX comment_field_data__comment_field__uid__target_id__idx ON public.comment_field_data USING btree (uid);


--
-- TOC entry 4234 (class 1259 OID 17279)
-- Name: drupal_2wXmNkIidFb530o9_wbeLfe93ztt315H0_uG2d8WoFE_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_2wXmNkIidFb530o9_wbeLfe93ztt315H0_uG2d8WoFE_idx" ON public.taxonomy_term_revision USING btree (revision_user);


--
-- TOC entry 4279 (class 1259 OID 17409)
-- Name: drupal_L0k0k_zy6SEDoKs_R8suuvxbkHf_hZzMpkX6r42vlFg_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_L0k0k_zy6SEDoKs_R8suuvxbkHf_hZzMpkX6r42vlFg_idx" ON public.menu_link_content_field_revision USING btree (id, default_langcode, langcode);


--
-- TOC entry 4246 (class 1259 OID 17305)
-- Name: drupal_M2Qup2oS2zlnKrlzxtyMPc4wpQTHO8bTW9QMuxZwsiQ_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_M2Qup2oS2zlnKrlzxtyMPc4wpQTHO8bTW9QMuxZwsiQ_idx" ON public.taxonomy_term_field_revision USING btree (description__format);


--
-- TOC entry 4120 (class 1259 OID 16919)
-- Name: drupal_PzJThk1bhC5wux6rrih6c65UXJZ9UmNGl0Eroda5fLk_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_PzJThk1bhC5wux6rrih6c65UXJZ9UmNGl0Eroda5fLk_idx" ON public.block_content_field_revision USING btree (id, default_langcode, langcode);


--
-- TOC entry 4116 (class 1259 OID 16909)
-- Name: drupal_Vlz4ZHQ_d0wCuo1mttzoczYX0MIgffhtal7RzxmuKw4_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_Vlz4ZHQ_d0wCuo1mttzoczYX0MIgffhtal7RzxmuKw4_idx" ON public.block_content_field_data USING btree (type);


--
-- TOC entry 4291 (class 1259 OID 17445)
-- Name: drupal_ZRb0RrR9ucQ_abrsOj5OqJZ6JHhecUX6qMxhEeLHDSA_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_ZRb0RrR9ucQ_abrsOj5OqJZ6JHhecUX6qMxhEeLHDSA_idx" ON public.shortcut_field_data USING btree (shortcut_set);


--
-- TOC entry 4110 (class 1259 OID 16899)
-- Name: drupal__CipXU6qdl5f10_BuhE_ogc1jMaOmJLoMQ5Qdkccjkg_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal__CipXU6qdl5f10_BuhE_ogc1jMaOmJLoMQ5Qdkccjkg_idx" ON public.block_content_revision USING btree (revision_user);


--
-- TOC entry 4238 (class 1259 OID 17289)
-- Name: drupal_jVEqkc6s2d_YXyKzgPOmeuEYgeSndHxNyF_lQrsUBhg_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_jVEqkc6s2d_YXyKzgPOmeuEYgeSndHxNyF_lQrsUBhg_idx" ON public.taxonomy_term_field_data USING btree (tid, default_langcode, langcode);


--
-- TOC entry 4202 (class 1259 OID 17142)
-- Name: drupal_mOML8Q1mOpUaN8EQHtn4pIFZ9wK8gamkAI1iyADLZZ8_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_mOML8Q1mOpUaN8EQHtn4pIFZ9wK8gamkAI1iyADLZZ8_idx" ON public.comment_field_data USING btree (cid, default_langcode, langcode);


--
-- TOC entry 4273 (class 1259 OID 17396)
-- Name: drupal_mtiYLSRDGoU4931oeZ9cDY50TtJYeSgNur4s_gNPxF8_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_mtiYLSRDGoU4931oeZ9cDY50TtJYeSgNur4s_gNPxF8_idx" ON public.menu_link_content_data USING btree (id, default_langcode, langcode);


--
-- TOC entry 4280 (class 1259 OID 17410)
-- Name: drupal_ui7U_4ySVsbBkDhd7CC2Cz97Yr_s3QEuF9xZI0mi1lA_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_ui7U_4ySVsbBkDhd7CC2Cz97Yr_s3QEuF9xZI0mi1lA_idx" ON public.menu_link_content_field_revision USING btree (substr((link__uri)::text, 1, 30));


--
-- TOC entry 4117 (class 1259 OID 16907)
-- Name: drupal_wL9rKs7CrdJVvCzBzlB7hYXDGYa3Ov_zwIcY6Ecjfeo_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_wL9rKs7CrdJVvCzBzlB7hYXDGYa3Ov_zwIcY6Ecjfeo_idx" ON public.block_content_field_data USING btree (id, default_langcode, langcode);


--
-- TOC entry 4292 (class 1259 OID 17444)
-- Name: drupal_yYznZkp1jjRq3ZidRMkkkawuQCmql0kdszvKsIMeEkU_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_yYznZkp1jjRq3ZidRMkkkawuQCmql0kdszvKsIMeEkU_idx" ON public.shortcut_field_data USING btree (id, default_langcode, langcode);


--
-- TOC entry 4247 (class 1259 OID 17304)
-- Name: drupal_zC5XUHi3lXvFlyilgI0NlNZth42DSBX5G_FjNgxVTGQ_idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX "drupal_zC5XUHi3lXvFlyilgI0NlNZth42DSBX5G_FjNgxVTGQ_idx" ON public.taxonomy_term_field_revision USING btree (tid, default_langcode, langcode);


--
-- TOC entry 4177 (class 1259 OID 17097)
-- Name: file_managed__file_field__changed__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX file_managed__file_field__changed__idx ON public.file_managed USING btree (changed);


--
-- TOC entry 4178 (class 1259 OID 17096)
-- Name: file_managed__file_field__status__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX file_managed__file_field__status__idx ON public.file_managed USING btree (status);


--
-- TOC entry 4179 (class 1259 OID 17094)
-- Name: file_managed__file_field__uid__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX file_managed__file_field__uid__target_id__idx ON public.file_managed USING btree (uid);


--
-- TOC entry 4180 (class 1259 OID 17095)
-- Name: file_managed__file_field__uri__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX file_managed__file_field__uri__idx ON public.file_managed USING btree (uri);


--
-- TOC entry 4172 (class 1259 OID 17078)
-- Name: file_usage__fid_count__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX file_usage__fid_count__idx ON public.file_usage USING btree (fid, count);


--
-- TOC entry 4173 (class 1259 OID 17079)
-- Name: file_usage__fid_module__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX file_usage__fid_module__idx ON public.file_usage USING btree (fid, module);


--
-- TOC entry 4174 (class 1259 OID 17077)
-- Name: file_usage__type_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX file_usage__type_id__idx ON public.file_usage USING btree (type, id);


--
-- TOC entry 4086 (class 1259 OID 16818)
-- Name: help_search_items__section_plugin_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX help_search_items__section_plugin_id__idx ON public.help_search_items USING btree (section_plugin_id);


--
-- TOC entry 4087 (class 1259 OID 16819)
-- Name: help_search_items__topic_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX help_search_items__topic_id__idx ON public.help_search_items USING btree (topic_id);


--
-- TOC entry 4226 (class 1259 OID 17250)
-- Name: history__nid__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX history__nid__idx ON public.history USING btree (nid);


--
-- TOC entry 4393 (class 1259 OID 18398)
-- Name: inline_block_usage__type_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX inline_block_usage__type_id__idx ON public.inline_block_usage USING btree (layout_entity_type, layout_entity_id);


--
-- TOC entry 4341 (class 1259 OID 17917)
-- Name: key_value_expire__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX key_value_expire__expire__idx ON public.key_value_expire USING btree (expire);


--
-- TOC entry 4220 (class 1259 OID 17221)
-- Name: locales_location__string_type__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX locales_location__string_type__idx ON public.locales_location USING btree (sid, type);


--
-- TOC entry 4221 (class 1259 OID 17222)
-- Name: locales_location__type_name__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX locales_location__type_name__idx ON public.locales_location USING btree (type, name);


--
-- TOC entry 4214 (class 1259 OID 17199)
-- Name: locales_source__source_context__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX locales_source__source_context__idx ON public.locales_source USING btree (substr(source, 1, 30), context);


--
-- TOC entry 4217 (class 1259 OID 17210)
-- Name: locales_target__lid__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX locales_target__lid__idx ON public.locales_target USING btree (lid);


--
-- TOC entry 4276 (class 1259 OID 17399)
-- Name: menu_link_content_data__menu_link_content__enabled_bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX menu_link_content_data__menu_link_content__enabled_bundle__idx ON public.menu_link_content_data USING btree (enabled, bundle, id);


--
-- TOC entry 4277 (class 1259 OID 17397)
-- Name: menu_link_content_data__menu_link_content__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX menu_link_content_data__menu_link_content__revision_id__idx ON public.menu_link_content_data USING btree (revision_id);


--
-- TOC entry 4278 (class 1259 OID 17398)
-- Name: menu_link_content_data__menu_link_content_field__link__uri__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX menu_link_content_data__menu_link_content_field__link__uri__idx ON public.menu_link_content_data USING btree (substr((link__uri)::text, 1, 30));


--
-- TOC entry 4271 (class 1259 OID 17386)
-- Name: menu_link_content_revision__menu_link_content__ef029a1897__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX menu_link_content_revision__menu_link_content__ef029a1897__idx ON public.menu_link_content_revision USING btree (revision_user);


--
-- TOC entry 4272 (class 1259 OID 17385)
-- Name: menu_link_content_revision__menu_link_content__id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX menu_link_content_revision__menu_link_content__id__idx ON public.menu_link_content_revision USING btree (id);


--
-- TOC entry 4303 (class 1259 OID 17529)
-- Name: menu_tree__menu_parent_expand_child__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX menu_tree__menu_parent_expand_child__idx ON public.menu_tree USING btree (menu_name, expanded, has_children, substr((parent)::text, 1, 16));


--
-- TOC entry 4304 (class 1259 OID 17528)
-- Name: menu_tree__menu_parents__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX menu_tree__menu_parents__idx ON public.menu_tree USING btree (menu_name, p1, p2, p3, p4, p5, p6, p7, p8, p9);


--
-- TOC entry 4305 (class 1259 OID 17530)
-- Name: menu_tree__route_values__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX menu_tree__route_values__idx ON public.menu_tree USING btree (substr((route_name)::text, 1, 32), substr((route_param_key)::text, 1, 16));


--
-- TOC entry 4162 (class 1259 OID 17046)
-- Name: node__body__body_format__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__body__body_format__idx ON public.node__body USING btree (body_format);


--
-- TOC entry 4163 (class 1259 OID 17044)
-- Name: node__body__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__body__bundle__idx ON public.node__body USING btree (bundle);


--
-- TOC entry 4164 (class 1259 OID 17045)
-- Name: node__body__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__body__revision_id__idx ON public.node__body USING btree (revision_id);


--
-- TOC entry 4318 (class 1259 OID 17582)
-- Name: node__comment__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__comment__bundle__idx ON public.node__comment USING btree (bundle);


--
-- TOC entry 4319 (class 1259 OID 17583)
-- Name: node__comment__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__comment__revision_id__idx ON public.node__comment USING btree (revision_id);


--
-- TOC entry 4308 (class 1259 OID 17547)
-- Name: node__field_image__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__field_image__bundle__idx ON public.node__field_image USING btree (bundle);


--
-- TOC entry 4309 (class 1259 OID 17549)
-- Name: node__field_image__field_image_target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__field_image__field_image_target_id__idx ON public.node__field_image USING btree (field_image_target_id);


--
-- TOC entry 4310 (class 1259 OID 17548)
-- Name: node__field_image__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__field_image__revision_id__idx ON public.node__field_image USING btree (revision_id);


--
-- TOC entry 4326 (class 1259 OID 17611)
-- Name: node__field_tags__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__field_tags__bundle__idx ON public.node__field_tags USING btree (bundle);


--
-- TOC entry 4327 (class 1259 OID 17613)
-- Name: node__field_tags__field_tags_target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__field_tags__field_tags_target_id__idx ON public.node__field_tags USING btree (field_tags_target_id);


--
-- TOC entry 4328 (class 1259 OID 17612)
-- Name: node__field_tags__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__field_tags__revision_id__idx ON public.node__field_tags USING btree (revision_id);


--
-- TOC entry 4137 (class 1259 OID 16987)
-- Name: node__node_field__type__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node__node_field__type__target_id__idx ON public.node USING btree (type);


--
-- TOC entry 4147 (class 1259 OID 17018)
-- Name: node_field_data__node__frontpage__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_field_data__node__frontpage__idx ON public.node_field_data USING btree (promote, status, sticky, created);


--
-- TOC entry 4148 (class 1259 OID 17011)
-- Name: node_field_data__node__id__default_langcode__langcode__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_field_data__node__id__default_langcode__langcode__idx ON public.node_field_data USING btree (nid, default_langcode, langcode);


--
-- TOC entry 4149 (class 1259 OID 17017)
-- Name: node_field_data__node__status_type__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_field_data__node__status_type__idx ON public.node_field_data USING btree (status, type, nid);


--
-- TOC entry 4150 (class 1259 OID 17019)
-- Name: node_field_data__node__title_type__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_field_data__node__title_type__idx ON public.node_field_data USING btree (title, substr((type)::text, 1, 4));


--
-- TOC entry 4151 (class 1259 OID 17012)
-- Name: node_field_data__node__vid__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_field_data__node__vid__idx ON public.node_field_data USING btree (vid);


--
-- TOC entry 4152 (class 1259 OID 17016)
-- Name: node_field_data__node_field__changed__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_field_data__node_field__changed__idx ON public.node_field_data USING btree (changed);


--
-- TOC entry 4153 (class 1259 OID 17015)
-- Name: node_field_data__node_field__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_field_data__node_field__created__idx ON public.node_field_data USING btree (created);


--
-- TOC entry 4154 (class 1259 OID 17013)
-- Name: node_field_data__node_field__type__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_field_data__node_field__type__target_id__idx ON public.node_field_data USING btree (type);


--
-- TOC entry 4155 (class 1259 OID 17014)
-- Name: node_field_data__node_field__uid__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_field_data__node_field__uid__target_id__idx ON public.node_field_data USING btree (uid);


--
-- TOC entry 4158 (class 1259 OID 17028)
-- Name: node_field_revision__node__id__default_langcode__langcode__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_field_revision__node__id__default_langcode__langcode__idx ON public.node_field_revision USING btree (nid, default_langcode, langcode);


--
-- TOC entry 4159 (class 1259 OID 17029)
-- Name: node_field_revision__node_field__uid__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_field_revision__node_field__uid__target_id__idx ON public.node_field_revision USING btree (uid);


--
-- TOC entry 4167 (class 1259 OID 17062)
-- Name: node_revision__body__body_format__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__body__body_format__idx ON public.node_revision__body USING btree (body_format);


--
-- TOC entry 4168 (class 1259 OID 17060)
-- Name: node_revision__body__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__body__bundle__idx ON public.node_revision__body USING btree (bundle);


--
-- TOC entry 4169 (class 1259 OID 17061)
-- Name: node_revision__body__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__body__revision_id__idx ON public.node_revision__body USING btree (revision_id);


--
-- TOC entry 4322 (class 1259 OID 17596)
-- Name: node_revision__comment__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__comment__bundle__idx ON public.node_revision__comment USING btree (bundle);


--
-- TOC entry 4323 (class 1259 OID 17597)
-- Name: node_revision__comment__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__comment__revision_id__idx ON public.node_revision__comment USING btree (revision_id);


--
-- TOC entry 4313 (class 1259 OID 17566)
-- Name: node_revision__field_image__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__field_image__bundle__idx ON public.node_revision__field_image USING btree (bundle);


--
-- TOC entry 4314 (class 1259 OID 17568)
-- Name: node_revision__field_image__field_image_target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__field_image__field_image_target_id__idx ON public.node_revision__field_image USING btree (field_image_target_id);


--
-- TOC entry 4315 (class 1259 OID 17567)
-- Name: node_revision__field_image__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__field_image__revision_id__idx ON public.node_revision__field_image USING btree (revision_id);


--
-- TOC entry 4331 (class 1259 OID 17626)
-- Name: node_revision__field_tags__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__field_tags__bundle__idx ON public.node_revision__field_tags USING btree (bundle);


--
-- TOC entry 4332 (class 1259 OID 17628)
-- Name: node_revision__field_tags__field_tags_target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__field_tags__field_tags_target_id__idx ON public.node_revision__field_tags USING btree (field_tags_target_id);


--
-- TOC entry 4333 (class 1259 OID 17627)
-- Name: node_revision__field_tags__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__field_tags__revision_id__idx ON public.node_revision__field_tags USING btree (revision_id);


--
-- TOC entry 4142 (class 1259 OID 17000)
-- Name: node_revision__node__nid__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__node__nid__idx ON public.node_revision USING btree (nid);


--
-- TOC entry 4143 (class 1259 OID 17001)
-- Name: node_revision__node_field__langcode__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__node_field__langcode__idx ON public.node_revision USING btree (langcode);


--
-- TOC entry 4144 (class 1259 OID 17002)
-- Name: node_revision__node_field__revision_uid__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX node_revision__node_field__revision_uid__target_id__idx ON public.node_revision USING btree (revision_uid);


--
-- TOC entry 4075 (class 1259 OID 16791)
-- Name: path_alias__path_alias__alias_langcode_id_status__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX path_alias__path_alias__alias_langcode_id_status__idx ON public.path_alias USING btree (alias, langcode, id, status);


--
-- TOC entry 4076 (class 1259 OID 16792)
-- Name: path_alias__path_alias__path_langcode_id_status__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX path_alias__path_alias__path_langcode_id_status__idx ON public.path_alias USING btree (path, langcode, id, status);


--
-- TOC entry 4083 (class 1259 OID 16804)
-- Name: path_alias_revision__path_alias__id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX path_alias_revision__path_alias__id__idx ON public.path_alias_revision USING btree (id);


--
-- TOC entry 4046 (class 1259 OID 16699)
-- Name: queue__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX queue__expire__idx ON public.queue USING btree (expire);


--
-- TOC entry 4047 (class 1259 OID 16698)
-- Name: queue__name_created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX queue__name_created__idx ON public.queue USING btree (name, created);


--
-- TOC entry 4298 (class 1259 OID 17487)
-- Name: router__pattern_outline_parts__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX router__pattern_outline_parts__idx ON public.router USING btree (pattern_outline, number_parts);


--
-- TOC entry 4097 (class 1259 OID 16860)
-- Name: search_index__sid_type__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX search_index__sid_type__idx ON public.search_index USING btree (sid, langcode, type);


--
-- TOC entry 4370 (class 1259 OID 18048)
-- Name: semaphore__expire__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX semaphore__expire__idx ON public.semaphore USING btree (expire);


--
-- TOC entry 4371 (class 1259 OID 18047)
-- Name: semaphore__value__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX semaphore__value__idx ON public.semaphore USING btree (value);


--
-- TOC entry 4050 (class 1259 OID 16710)
-- Name: sessions__timestamp__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX sessions__timestamp__idx ON public.sessions USING btree ("timestamp");


--
-- TOC entry 4051 (class 1259 OID 16711)
-- Name: sessions__uid__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX sessions__uid__idx ON public.sessions USING btree (uid);


--
-- TOC entry 4288 (class 1259 OID 17435)
-- Name: shortcut__shortcut_field__shortcut_set__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX shortcut__shortcut_field__shortcut_set__target_id__idx ON public.shortcut USING btree (shortcut_set);


--
-- TOC entry 4295 (class 1259 OID 17446)
-- Name: shortcut_field_data__shortcut_field__link__uri__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX shortcut_field_data__shortcut_field__link__uri__idx ON public.shortcut_field_data USING btree (substr((link__uri)::text, 1, 30));


--
-- TOC entry 4285 (class 1259 OID 17424)
-- Name: shortcut_set_users__set_name__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX shortcut_set_users__set_name__idx ON public.shortcut_set_users USING btree (set_name);


--
-- TOC entry 4252 (class 1259 OID 17318)
-- Name: taxonomy_index__term_node__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_index__term_node__idx ON public.taxonomy_index USING btree (tid, status, sticky, created);


--
-- TOC entry 4255 (class 1259 OID 17333)
-- Name: taxonomy_term__parent__bundle_delta_target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term__parent__bundle_delta_target_id__idx ON public.taxonomy_term__parent USING btree (bundle, delta, parent_target_id);


--
-- TOC entry 4256 (class 1259 OID 17332)
-- Name: taxonomy_term__parent__parent_target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term__parent__parent_target_id__idx ON public.taxonomy_term__parent USING btree (parent_target_id);


--
-- TOC entry 4257 (class 1259 OID 17331)
-- Name: taxonomy_term__parent__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term__parent__revision_id__idx ON public.taxonomy_term__parent USING btree (revision_id);


--
-- TOC entry 4233 (class 1259 OID 17265)
-- Name: taxonomy_term_data__taxonomy_term_field__vid__target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term_data__taxonomy_term_field__vid__target_id__idx ON public.taxonomy_term_data USING btree (vid);


--
-- TOC entry 4241 (class 1259 OID 17290)
-- Name: taxonomy_term_field_data__taxonomy_term__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term_field_data__taxonomy_term__revision_id__idx ON public.taxonomy_term_field_data USING btree (revision_id);


--
-- TOC entry 4242 (class 1259 OID 17292)
-- Name: taxonomy_term_field_data__taxonomy_term__status_vid__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term_field_data__taxonomy_term__status_vid__idx ON public.taxonomy_term_field_data USING btree (status, vid, tid);


--
-- TOC entry 4243 (class 1259 OID 17293)
-- Name: taxonomy_term_field_data__taxonomy_term__tree__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term_field_data__taxonomy_term__tree__idx ON public.taxonomy_term_field_data USING btree (vid, weight, name);


--
-- TOC entry 4244 (class 1259 OID 17294)
-- Name: taxonomy_term_field_data__taxonomy_term__vid_name__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term_field_data__taxonomy_term__vid_name__idx ON public.taxonomy_term_field_data USING btree (vid, name);


--
-- TOC entry 4245 (class 1259 OID 17291)
-- Name: taxonomy_term_field_data__taxonomy_term_field__name__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term_field_data__taxonomy_term_field__name__idx ON public.taxonomy_term_field_data USING btree (name);


--
-- TOC entry 4260 (class 1259 OID 17346)
-- Name: taxonomy_term_revision__parent__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term_revision__parent__bundle__idx ON public.taxonomy_term_revision__parent USING btree (bundle);


--
-- TOC entry 4261 (class 1259 OID 17348)
-- Name: taxonomy_term_revision__parent__parent_target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term_revision__parent__parent_target_id__idx ON public.taxonomy_term_revision__parent USING btree (parent_target_id);


--
-- TOC entry 4262 (class 1259 OID 17347)
-- Name: taxonomy_term_revision__parent__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term_revision__parent__revision_id__idx ON public.taxonomy_term_revision__parent USING btree (revision_id);


--
-- TOC entry 4237 (class 1259 OID 17278)
-- Name: taxonomy_term_revision__taxonomy_term__tid__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX taxonomy_term_revision__taxonomy_term__tid__idx ON public.taxonomy_term_revision USING btree (tid);


--
-- TOC entry 4070 (class 1259 OID 16772)
-- Name: user__roles__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX user__roles__bundle__idx ON public.user__roles USING btree (bundle);


--
-- TOC entry 4071 (class 1259 OID 16773)
-- Name: user__roles__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX user__roles__revision_id__idx ON public.user__roles USING btree (revision_id);


--
-- TOC entry 4072 (class 1259 OID 16774)
-- Name: user__roles__roles_target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX user__roles__roles_target_id__idx ON public.user__roles USING btree (roles_target_id);


--
-- TOC entry 4336 (class 1259 OID 17646)
-- Name: user__user_picture__bundle__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX user__user_picture__bundle__idx ON public.user__user_picture USING btree (bundle);


--
-- TOC entry 4337 (class 1259 OID 17647)
-- Name: user__user_picture__revision_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX user__user_picture__revision_id__idx ON public.user__user_picture USING btree (revision_id);


--
-- TOC entry 4338 (class 1259 OID 17648)
-- Name: user__user_picture__user_picture_target_id__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX user__user_picture__user_picture_target_id__idx ON public.user__user_picture USING btree (user_picture_target_id);


--
-- TOC entry 4054 (class 1259 OID 16735)
-- Name: users_data__module__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX users_data__module__idx ON public.users_data USING btree (module);


--
-- TOC entry 4055 (class 1259 OID 16736)
-- Name: users_data__name__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX users_data__name__idx ON public.users_data USING btree (name);


--
-- TOC entry 4062 (class 1259 OID 16757)
-- Name: users_field_data__user__id__default_langcode__langcode__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX users_field_data__user__id__default_langcode__langcode__idx ON public.users_field_data USING btree (uid, default_langcode, langcode);


--
-- TOC entry 4065 (class 1259 OID 16760)
-- Name: users_field_data__user_field__access__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX users_field_data__user_field__access__idx ON public.users_field_data USING btree (access);


--
-- TOC entry 4066 (class 1259 OID 16759)
-- Name: users_field_data__user_field__created__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX users_field_data__user_field__created__idx ON public.users_field_data USING btree (created);


--
-- TOC entry 4067 (class 1259 OID 16758)
-- Name: users_field_data__user_field__mail__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX users_field_data__user_field__mail__idx ON public.users_field_data USING btree (mail);


--
-- TOC entry 4090 (class 1259 OID 16838)
-- Name: watchdog__severity__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX watchdog__severity__idx ON public.watchdog USING btree (severity);


--
-- TOC entry 4091 (class 1259 OID 16836)
-- Name: watchdog__type__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX watchdog__type__idx ON public.watchdog USING btree (type);


--
-- TOC entry 4092 (class 1259 OID 16837)
-- Name: watchdog__uid__idx; Type: INDEX; Schema: public; Owner: drupal_user
--

CREATE INDEX watchdog__uid__idx ON public.watchdog USING btree (uid);


--
-- TOC entry 4650 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO drupal_read;


--
-- TOC entry 4917 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE node; Type: ACL; Schema: public; Owner: drupal_user
--

GRANT SELECT ON TABLE public.node TO drupal_read;


--
-- TOC entry 4925 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE node__body; Type: ACL; Schema: public; Owner: drupal_user
--

GRANT SELECT ON TABLE public.node__body TO drupal_read;


--
-- TOC entry 4966 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE node_field_data; Type: ACL; Schema: public; Owner: drupal_user
--

GRANT SELECT ON TABLE public.node_field_data TO drupal_read;

GRANT ALL ON TABLE public.ban_ip TO drupal_user;

GRANT SELECT ON TABLE public.ban_ip TO drupal_read;

GRANT ALL ON TABLE public.batch TO drupal_user;

GRANT SELECT ON TABLE public.batch TO drupal_read;

GRANT ALL ON TABLE public.block_content TO drupal_user;

GRANT SELECT ON TABLE public.block_content TO drupal_read;

GRANT ALL ON TABLE public.block_content__body TO drupal_user;

GRANT SELECT ON TABLE public.block_content__body TO drupal_read;

GRANT ALL ON TABLE public.block_content_field_data TO drupal_user;

GRANT SELECT ON TABLE public.block_content_field_data TO drupal_read;

GRANT ALL ON TABLE public.block_content_field_revision TO drupal_user;

GRANT SELECT ON TABLE public.block_content_field_revision TO drupal_read;

GRANT ALL ON TABLE public.block_content_revision TO drupal_user;

GRANT SELECT ON TABLE public.block_content_revision TO drupal_read;

GRANT ALL ON TABLE public.block_content_revision__body TO drupal_user;

GRANT SELECT ON TABLE public.block_content_revision__body TO drupal_read;

GRANT ALL ON TABLE public.cache_access_policy TO drupal_user;

GRANT SELECT ON TABLE public.cache_access_policy TO drupal_read;

GRANT ALL ON TABLE public.cache_bootstrap TO drupal_user;

GRANT SELECT ON TABLE public.cache_bootstrap TO drupal_read;

GRANT ALL ON TABLE public.cache_config TO drupal_user;

GRANT SELECT ON TABLE public.cache_config TO drupal_read;

GRANT ALL ON TABLE public.cache_container TO drupal_user;

GRANT SELECT ON TABLE public.cache_container TO drupal_read;

GRANT ALL ON TABLE public.cache_data TO drupal_user;

GRANT SELECT ON TABLE public.cache_data TO drupal_read;

GRANT ALL ON TABLE public.cache_default TO drupal_user;

GRANT SELECT ON TABLE public.cache_default TO drupal_read;

GRANT ALL ON TABLE public.cache_discovery TO drupal_user;

GRANT SELECT ON TABLE public.cache_discovery TO drupal_read;

GRANT ALL ON TABLE public.cache_dynamic_page_cache TO drupal_user;

GRANT SELECT ON TABLE public.cache_dynamic_page_cache TO drupal_read;

GRANT ALL ON TABLE public.cache_entity TO drupal_user;

GRANT SELECT ON TABLE public.cache_entity TO drupal_read;

GRANT ALL ON TABLE public.cache_menu TO drupal_user;

GRANT SELECT ON TABLE public.cache_menu TO drupal_read;

GRANT ALL ON TABLE public.cache_page TO drupal_user;

GRANT SELECT ON TABLE public.cache_page TO drupal_read;

GRANT ALL ON TABLE public.cache_render TO drupal_user;

GRANT SELECT ON TABLE public.cache_render TO drupal_read;

GRANT ALL ON TABLE public.cachetags TO drupal_user;

GRANT SELECT ON TABLE public.cachetags TO drupal_read;

GRANT ALL ON TABLE public.comment TO drupal_user;

GRANT SELECT ON TABLE public.comment TO drupal_read;

GRANT ALL ON TABLE public.comment__comment_body TO drupal_user;

GRANT SELECT ON TABLE public.comment__comment_body TO drupal_read;

GRANT ALL ON TABLE public.comment_entity_statistics TO drupal_user;

GRANT SELECT ON TABLE public.comment_entity_statistics TO drupal_read;

GRANT ALL ON TABLE public.comment_field_data TO drupal_user;

GRANT SELECT ON TABLE public.comment_field_data TO drupal_read;

GRANT ALL ON TABLE public.config TO drupal_user;

GRANT SELECT ON TABLE public.config TO drupal_read;

GRANT ALL ON TABLE public.file_managed TO drupal_user;

GRANT SELECT ON TABLE public.file_managed TO drupal_read;

GRANT ALL ON TABLE public.file_usage TO drupal_user;

GRANT SELECT ON TABLE public.file_usage TO drupal_read;

GRANT ALL ON TABLE public.help_search_items TO drupal_user;

GRANT SELECT ON TABLE public.help_search_items TO drupal_read;

GRANT ALL ON TABLE public.history TO drupal_user;

GRANT SELECT ON TABLE public.history TO drupal_read;

GRANT ALL ON TABLE public.inline_block_usage TO drupal_user;

GRANT SELECT ON TABLE public.inline_block_usage TO drupal_read;

GRANT ALL ON TABLE public.key_value TO drupal_user;

GRANT SELECT ON TABLE public.key_value TO drupal_read;

GRANT ALL ON TABLE public.key_value_expire TO drupal_user;

GRANT SELECT ON TABLE public.key_value_expire TO drupal_read;

GRANT ALL ON TABLE public.locale_file TO drupal_user;

GRANT SELECT ON TABLE public.locale_file TO drupal_read;

GRANT ALL ON TABLE public.locales_location TO drupal_user;

GRANT SELECT ON TABLE public.locales_location TO drupal_read;

GRANT ALL ON TABLE public.locales_source TO drupal_user;

GRANT SELECT ON TABLE public.locales_source TO drupal_read;

GRANT ALL ON TABLE public.locales_target TO drupal_user;

GRANT SELECT ON TABLE public.locales_target TO drupal_read;

GRANT ALL ON TABLE public.menu_link_content TO drupal_user;

GRANT SELECT ON TABLE public.menu_link_content TO drupal_read;

GRANT ALL ON TABLE public.menu_link_content_data TO drupal_user;

GRANT SELECT ON TABLE public.menu_link_content_data TO drupal_read;

GRANT ALL ON TABLE public.menu_link_content_field_revision TO drupal_user;

GRANT SELECT ON TABLE public.menu_link_content_field_revision TO drupal_read;

GRANT ALL ON TABLE public.menu_link_content_revision TO drupal_user;

GRANT SELECT ON TABLE public.menu_link_content_revision TO drupal_read;

GRANT ALL ON TABLE public.menu_tree TO drupal_user;

GRANT SELECT ON TABLE public.menu_tree TO drupal_read;

GRANT ALL ON TABLE public.node TO drupal_user;

GRANT SELECT ON TABLE public.node TO drupal_read;

GRANT ALL ON TABLE public.node__body TO drupal_user;

GRANT SELECT ON TABLE public.node__body TO drupal_read;

GRANT ALL ON TABLE public.node__comment TO drupal_user;

GRANT SELECT ON TABLE public.node__comment TO drupal_read;

GRANT ALL ON TABLE public.node__field_image TO drupal_user;

GRANT SELECT ON TABLE public.node__field_image TO drupal_read;

GRANT ALL ON TABLE public.node__field_tags TO drupal_user;

GRANT SELECT ON TABLE public.node__field_tags TO drupal_read;

GRANT ALL ON TABLE public.node_access TO drupal_user;

GRANT SELECT ON TABLE public.node_access TO drupal_read;

GRANT ALL ON TABLE public.node_field_data TO drupal_user;

GRANT SELECT ON TABLE public.node_field_data TO drupal_read;

GRANT ALL ON TABLE public.node_field_revision TO drupal_user;

GRANT SELECT ON TABLE public.node_field_revision TO drupal_read;

GRANT ALL ON TABLE public.node_revision TO drupal_user;

GRANT SELECT ON TABLE public.node_revision TO drupal_read;

GRANT ALL ON TABLE public.node_revision__body TO drupal_user;

GRANT SELECT ON TABLE public.node_revision__body TO drupal_read;

GRANT ALL ON TABLE public.node_revision__comment TO drupal_user;

GRANT SELECT ON TABLE public.node_revision__comment TO drupal_read;

GRANT ALL ON TABLE public.node_revision__field_image TO drupal_user;

GRANT SELECT ON TABLE public.node_revision__field_image TO drupal_read;

GRANT ALL ON TABLE public.node_revision__field_tags TO drupal_user;

GRANT SELECT ON TABLE public.node_revision__field_tags TO drupal_read;

GRANT ALL ON TABLE public.path_alias TO drupal_user;

GRANT SELECT ON TABLE public.path_alias TO drupal_read;

GRANT ALL ON TABLE public.path_alias_revision TO drupal_user;

GRANT SELECT ON TABLE public.path_alias_revision TO drupal_read;

GRANT ALL ON TABLE public.queue TO drupal_user;

GRANT SELECT ON TABLE public.queue TO drupal_read;

GRANT ALL ON TABLE public.router TO drupal_user;

GRANT SELECT ON TABLE public.router TO drupal_read;

GRANT ALL ON TABLE public.search_dataset TO drupal_user;

GRANT SELECT ON TABLE public.search_dataset TO drupal_read;

GRANT ALL ON TABLE public.search_index TO drupal_user;

GRANT SELECT ON TABLE public.search_index TO drupal_read;

GRANT ALL ON TABLE public.search_total TO drupal_user;

GRANT SELECT ON TABLE public.search_total TO drupal_read;

GRANT ALL ON TABLE public.semaphore TO drupal_user;

GRANT SELECT ON TABLE public.semaphore TO drupal_read;

GRANT ALL ON TABLE public.sequences TO drupal_user;

GRANT SELECT ON TABLE public.sequences TO drupal_read;

GRANT ALL ON TABLE public.sessions TO drupal_user;

GRANT SELECT ON TABLE public.sessions TO drupal_read;

GRANT ALL ON TABLE public.shortcut TO drupal_user;

GRANT SELECT ON TABLE public.shortcut TO drupal_read;

GRANT ALL ON TABLE public.shortcut_field_data TO drupal_user;

GRANT SELECT ON TABLE public.shortcut_field_data TO drupal_read;

GRANT ALL ON TABLE public.shortcut_set_users TO drupal_user;

GRANT SELECT ON TABLE public.shortcut_set_users TO drupal_read;

GRANT ALL ON TABLE public.taxonomy_index TO drupal_user;

GRANT SELECT ON TABLE public.taxonomy_index TO drupal_read;

GRANT ALL ON TABLE public.taxonomy_term__parent TO drupal_user;

GRANT SELECT ON TABLE public.taxonomy_term__parent TO drupal_read;

GRANT ALL ON TABLE public.taxonomy_term_data TO drupal_user;

GRANT SELECT ON TABLE public.taxonomy_term_data TO drupal_read;

GRANT ALL ON TABLE public.taxonomy_term_field_data TO drupal_user;

GRANT SELECT ON TABLE public.taxonomy_term_field_data TO drupal_read;

GRANT ALL ON TABLE public.taxonomy_term_field_revision TO drupal_user;

GRANT SELECT ON TABLE public.taxonomy_term_field_revision TO drupal_read;

GRANT ALL ON TABLE public.taxonomy_term_revision TO drupal_user;

GRANT SELECT ON TABLE public.taxonomy_term_revision TO drupal_read;

GRANT ALL ON TABLE public.taxonomy_term_revision__parent TO drupal_user;

GRANT SELECT ON TABLE public.taxonomy_term_revision__parent TO drupal_read;

GRANT ALL ON TABLE public.user__roles TO drupal_user;

GRANT SELECT ON TABLE public.user__roles TO drupal_read;

GRANT ALL ON TABLE public.user__user_picture TO drupal_user;

GRANT SELECT ON TABLE public.user__user_picture TO drupal_read;

GRANT ALL ON TABLE public.users TO drupal_user;

GRANT SELECT ON TABLE public.users TO drupal_read;

GRANT ALL ON TABLE public.users_data TO drupal_user;

GRANT SELECT ON TABLE public.users_data TO drupal_read;

GRANT ALL ON TABLE public.users_field_data TO drupal_user;

GRANT SELECT ON TABLE public.users_field_data TO drupal_read;

GRANT ALL ON TABLE public.watchdog TO drupal_user;

GRANT SELECT ON TABLE public.watchdog TO drupal_read;

