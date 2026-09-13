ALTER TABLE "contact" ADD COLUMN "created_at" timestamp with time zone DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "contact" ADD COLUMN "status" varchar(20) DEFAULT 'open' NOT NULL;