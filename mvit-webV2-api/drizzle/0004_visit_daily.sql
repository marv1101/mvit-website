CREATE TABLE "visit_daily" (
	"day" date NOT NULL,
	"path" varchar(2048) NOT NULL,
	"referrer" varchar(2048) NOT NULL,
	"device_type" varchar(50) NOT NULL,
	"count" integer DEFAULT 0 NOT NULL,
	CONSTRAINT "visit_daily_day_path_referrer_device_type_pk" PRIMARY KEY ("day", "path", "referrer", "device_type")
);
--> statement-breakpoint
CREATE INDEX "idx_page_visit_visited_at" ON "page_visit" USING btree ("visited_at");
