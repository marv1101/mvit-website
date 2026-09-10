CREATE TABLE "admin_user" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "admin_user_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"username" varchar(100) NOT NULL,
	"password_hash" varchar(255) NOT NULL,
	"force_password_change" boolean DEFAULT false NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "admin_user_username_unique" UNIQUE("username")
);
--> statement-breakpoint
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
CREATE TABLE "page_visit" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "page_visit_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"visited_at" timestamp DEFAULT now() NOT NULL,
	"path" varchar(2048) NOT NULL,
	"ip_hash" varchar(64) NOT NULL,
	"user_agent" text,
	"referrer" varchar(2048),
	"device_type" varchar(50)
);
--> statement-breakpoint
ALTER TABLE "offering" ADD CONSTRAINT "offering_category_offering_category_id_fk" FOREIGN KEY ("category") REFERENCES "public"."offering_category"("id") ON DELETE no action ON UPDATE no action;