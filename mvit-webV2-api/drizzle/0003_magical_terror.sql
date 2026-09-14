CREATE TABLE "reference" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "reference_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"company" varchar(255) NOT NULL,
	"company_url" varchar(2048),
	"logo_url" text,
	"summary" varchar(1024) NOT NULL,
	"story" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
