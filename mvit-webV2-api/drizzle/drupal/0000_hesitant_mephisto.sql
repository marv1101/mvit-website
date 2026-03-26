-- Current sql file was generated after introspecting the database
-- If you want to run this migration please uncomment this code before executing migrations
/*
CREATE TABLE "watchdog" (
	"wid" bigserial NOT NULL,
	"uid" bigint NOT NULL,
	"type" varchar(64) NOT NULL,
	"message" text NOT NULL,
	"variables" "bytea" NOT NULL,
	"severity" integer NOT NULL,
	"link" text,
	"location" text NOT NULL,
	"referer" text,
	"hostname" varchar(128) NOT NULL,
	"timestamp" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "path_alias" (
	"id" serial NOT NULL,
	"revision_id" bigint,
	"uuid" varchar(128) NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"path" varchar(255),
	"alias" varchar(255),
	"status" smallint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "path_alias_revision" (
	"id" bigint NOT NULL,
	"revision_id" serial NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"path" varchar(255),
	"alias" varchar(255),
	"status" smallint NOT NULL,
	"revision_default" smallint
);
--> statement-breakpoint
CREATE TABLE "help_search_items" (
	"sid" serial NOT NULL,
	"section_plugin_id" varchar(255) NOT NULL,
	"permission" varchar(255) NOT NULL,
	"topic_id" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "search_dataset" (
	"sid" bigint NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"type" varchar(64) NOT NULL,
	"data" text NOT NULL,
	"reindex" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "search_index" (
	"word" varchar(50) NOT NULL,
	"sid" bigint NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"type" varchar(64) NOT NULL,
	"score" real
);
--> statement-breakpoint
CREATE TABLE "search_total" (
	"word" varchar(50) NOT NULL,
	"count" real
);
--> statement-breakpoint
CREATE TABLE "config" (
	"collection" varchar(255) NOT NULL,
	"name" varchar(255) NOT NULL,
	"data" "bytea"
);
--> statement-breakpoint
CREATE TABLE "key_value" (
	"collection" varchar(128) NOT NULL,
	"name" varchar(128) NOT NULL,
	"value" "bytea" NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sequences" (
	"value" serial NOT NULL
);
--> statement-breakpoint
CREATE TABLE "batch" (
	"bid" serial NOT NULL,
	"token" varchar(64) NOT NULL,
	"timestamp" integer NOT NULL,
	"batch" "bytea"
);
--> statement-breakpoint
CREATE TABLE "queue" (
	"item_id" serial NOT NULL,
	"name" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "node" (
	"nid" serial NOT NULL,
	"vid" bigint,
	"type" varchar(32) NOT NULL,
	"uuid" varchar(128) NOT NULL,
	"langcode" varchar(12) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sessions" (
	"uid" bigint NOT NULL,
	"sid" varchar(128) NOT NULL,
	"hostname" varchar(128) NOT NULL,
	"timestamp" bigint NOT NULL,
	"session" "bytea"
);
--> statement-breakpoint
CREATE TABLE "block_content_revision__body" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"body_value" text NOT NULL,
	"body_summary" text,
	"body_format" varchar(255)
);
--> statement-breakpoint
CREATE TABLE "node_access" (
	"nid" bigint NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"fallback" integer NOT NULL,
	"gid" bigint NOT NULL,
	"realm" varchar(255) NOT NULL,
	"grant_view" integer NOT NULL,
	"grant_update" integer NOT NULL,
	"grant_delete" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "block_content" (
	"id" serial NOT NULL,
	"revision_id" bigint,
	"type" varchar(32) NOT NULL,
	"uuid" varchar(128) NOT NULL,
	"langcode" varchar(12) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "block_content_revision" (
	"id" bigint NOT NULL,
	"revision_id" serial NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"revision_user" bigint,
	"revision_created" integer,
	"revision_log" text,
	"revision_default" smallint
);
--> statement-breakpoint
CREATE TABLE "block_content_field_data" (
	"id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"type" varchar(32) NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"status" smallint NOT NULL,
	"info" varchar(255),
	"changed" integer,
	"reusable" smallint,
	"default_langcode" smallint NOT NULL,
	"revision_translation_affected" smallint
);
--> statement-breakpoint
CREATE TABLE "block_content_field_revision" (
	"id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"status" smallint NOT NULL,
	"info" varchar(255),
	"changed" integer,
	"default_langcode" smallint NOT NULL,
	"revision_translation_affected" smallint
);
--> statement-breakpoint
CREATE TABLE "block_content__body" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"body_value" text NOT NULL,
	"body_summary" text,
	"body_format" varchar(255)
);
--> statement-breakpoint
CREATE TABLE "users_data" (
	"uid" bigint NOT NULL,
	"module" varchar(50) NOT NULL,
	"name" varchar(128) NOT NULL,
	"value" "bytea",
	"serialized" integer
);
--> statement-breakpoint
CREATE TABLE "users" (
	"uid" serial NOT NULL,
	"uuid" varchar(128) NOT NULL,
	"langcode" varchar(12) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users_field_data" (
	"uid" bigint NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"preferred_langcode" varchar(12),
	"preferred_admin_langcode" varchar(12),
	"name" varchar(60) NOT NULL,
	"pass" varchar(255),
	"mail" varchar(254),
	"timezone" varchar(32),
	"status" smallint,
	"created" integer NOT NULL,
	"changed" integer,
	"access" integer NOT NULL,
	"login" integer,
	"init" varchar(254),
	"default_langcode" smallint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "user__roles" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"roles_target_id" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "node_revision" (
	"nid" bigint NOT NULL,
	"vid" serial NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"revision_uid" bigint,
	"revision_timestamp" integer,
	"revision_log" text,
	"revision_default" smallint
);
--> statement-breakpoint
CREATE TABLE "node_field_data" (
	"nid" bigint NOT NULL,
	"vid" bigint NOT NULL,
	"type" varchar(32) NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"status" smallint NOT NULL,
	"uid" bigint NOT NULL,
	"title" varchar(255) NOT NULL,
	"created" integer NOT NULL,
	"changed" integer NOT NULL,
	"promote" smallint NOT NULL,
	"sticky" smallint NOT NULL,
	"default_langcode" smallint NOT NULL,
	"revision_translation_affected" smallint
);
--> statement-breakpoint
CREATE TABLE "node_field_revision" (
	"nid" bigint NOT NULL,
	"vid" bigint NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"status" smallint NOT NULL,
	"uid" bigint NOT NULL,
	"title" varchar(255),
	"created" integer,
	"changed" integer,
	"promote" smallint,
	"sticky" smallint,
	"default_langcode" smallint NOT NULL,
	"revision_translation_affected" smallint
);
--> statement-breakpoint
CREATE TABLE "file_usage" (
	"fid" bigint NOT NULL,
	"module" varchar(50) NOT NULL,
	"type" varchar(64) NOT NULL,
	"id" varchar(64) NOT NULL,
	"count" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "node__body" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"body_value" text NOT NULL,
	"body_summary" text,
	"body_format" varchar(255)
);
--> statement-breakpoint
CREATE TABLE "node_revision__body" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"body_value" text NOT NULL,
	"body_summary" text,
	"body_format" varchar(255)
);
--> statement-breakpoint
CREATE TABLE "file_managed" (
	"fid" serial NOT NULL,
	"uuid" varchar(128) NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"uid" bigint,
	"filename" varchar(255),
	"uri" varchar(255) NOT NULL,
	"filemime" varchar(255),
	"filesize" bigint,
	"status" smallint NOT NULL,
	"created" integer,
	"changed" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "comment_entity_statistics" (
	"entity_id" bigint NOT NULL,
	"entity_type" varchar(32) NOT NULL,
	"field_name" varchar(32) NOT NULL,
	"cid" integer NOT NULL,
	"last_comment_timestamp" bigint NOT NULL,
	"last_comment_name" varchar(60),
	"last_comment_uid" bigint NOT NULL,
	"comment_count" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "comment" (
	"cid" serial NOT NULL,
	"comment_type" varchar(32) NOT NULL,
	"uuid" varchar(128) NOT NULL,
	"langcode" varchar(12) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "comment_field_data" (
	"cid" bigint NOT NULL,
	"comment_type" varchar(32) NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"status" smallint NOT NULL,
	"uid" bigint NOT NULL,
	"pid" bigint,
	"entity_id" bigint,
	"subject" varchar(64),
	"name" varchar(60),
	"mail" varchar(254),
	"homepage" varchar(255),
	"hostname" varchar(128),
	"created" integer NOT NULL,
	"changed" integer,
	"thread" varchar(255) NOT NULL,
	"entity_type" varchar(32) NOT NULL,
	"field_name" varchar(32) NOT NULL,
	"default_langcode" smallint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "comment__comment_body" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"comment_body_value" text NOT NULL,
	"comment_body_format" varchar(255)
);
--> statement-breakpoint
CREATE TABLE "cache_container" (
	"cid" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" numeric(14, 3) NOT NULL,
	"serialized" smallint NOT NULL,
	"tags" text,
	"checksum" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "locales_source" (
	"lid" serial NOT NULL,
	"source" text NOT NULL,
	"context" varchar(255) NOT NULL,
	"version" varchar(20) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "locales_target" (
	"lid" integer NOT NULL,
	"translation" text NOT NULL,
	"language" varchar(12) NOT NULL,
	"customized" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "locales_location" (
	"lid" serial NOT NULL,
	"sid" integer NOT NULL,
	"type" varchar(50) NOT NULL,
	"name" varchar(255) NOT NULL,
	"version" varchar(20) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "locale_file" (
	"project" varchar(255) NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"filename" varchar(255) NOT NULL,
	"version" varchar(128) NOT NULL,
	"uri" varchar(255) NOT NULL,
	"timestamp" bigint,
	"last_checked" bigint
);
--> statement-breakpoint
CREATE TABLE "history" (
	"uid" integer NOT NULL,
	"nid" bigint NOT NULL,
	"timestamp" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "taxonomy_term_data" (
	"tid" serial NOT NULL,
	"revision_id" bigint,
	"vid" varchar(32) NOT NULL,
	"uuid" varchar(128) NOT NULL,
	"langcode" varchar(12) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "taxonomy_term_revision" (
	"tid" bigint NOT NULL,
	"revision_id" serial NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"revision_user" bigint,
	"revision_created" integer,
	"revision_log_message" text,
	"revision_default" smallint
);
--> statement-breakpoint
CREATE TABLE "taxonomy_term_field_data" (
	"tid" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"vid" varchar(32) NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"status" smallint NOT NULL,
	"name" varchar(255) NOT NULL,
	"description__value" text,
	"description__format" varchar(255),
	"weight" integer NOT NULL,
	"changed" integer,
	"default_langcode" smallint NOT NULL,
	"revision_translation_affected" smallint
);
--> statement-breakpoint
CREATE TABLE "taxonomy_term_field_revision" (
	"tid" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"status" smallint NOT NULL,
	"name" varchar(255),
	"description__value" text,
	"description__format" varchar(255),
	"changed" integer,
	"default_langcode" smallint NOT NULL,
	"revision_translation_affected" smallint
);
--> statement-breakpoint
CREATE TABLE "taxonomy_index" (
	"nid" bigint NOT NULL,
	"tid" bigint NOT NULL,
	"status" integer NOT NULL,
	"sticky" smallint,
	"created" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "taxonomy_term__parent" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"parent_target_id" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "taxonomy_term_revision__parent" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"parent_target_id" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "menu_link_content" (
	"id" serial NOT NULL,
	"revision_id" bigint,
	"bundle" varchar(32) NOT NULL,
	"uuid" varchar(128) NOT NULL,
	"langcode" varchar(12) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "menu_link_content_revision" (
	"id" bigint NOT NULL,
	"revision_id" serial NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"revision_user" bigint,
	"revision_created" integer,
	"revision_log_message" text,
	"revision_default" smallint
);
--> statement-breakpoint
CREATE TABLE "menu_link_content_data" (
	"id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"bundle" varchar(32) NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"enabled" smallint NOT NULL,
	"title" varchar(255),
	"description" varchar(255),
	"menu_name" varchar(255),
	"link__uri" varchar(2048),
	"link__title" varchar(255),
	"link__options" "bytea",
	"external" smallint,
	"rediscover" smallint,
	"weight" integer,
	"expanded" smallint,
	"parent" varchar(255),
	"changed" integer,
	"default_langcode" smallint NOT NULL,
	"revision_translation_affected" smallint
);
--> statement-breakpoint
CREATE TABLE "menu_link_content_field_revision" (
	"id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"enabled" smallint NOT NULL,
	"title" varchar(255),
	"description" varchar(255),
	"link__uri" varchar(2048),
	"link__title" varchar(255),
	"link__options" "bytea",
	"external" smallint,
	"changed" integer,
	"default_langcode" smallint NOT NULL,
	"revision_translation_affected" smallint
);
--> statement-breakpoint
CREATE TABLE "shortcut_set_users" (
	"uid" bigint NOT NULL,
	"set_name" varchar(32) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "shortcut" (
	"id" serial NOT NULL,
	"shortcut_set" varchar(32) NOT NULL,
	"uuid" varchar(128) NOT NULL,
	"langcode" varchar(12) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "shortcut_field_data" (
	"id" bigint NOT NULL,
	"shortcut_set" varchar(32) NOT NULL,
	"langcode" varchar(12) NOT NULL,
	"title" varchar(255),
	"weight" integer,
	"link__uri" varchar(2048),
	"link__title" varchar(255),
	"link__options" "bytea",
	"default_langcode" smallint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "router" (
	"name" varchar(255) NOT NULL,
	"path" varchar(255) NOT NULL,
	"pattern_outline" varchar(255) NOT NULL,
	"fit" integer NOT NULL,
	"route" "bytea",
	"number_parts" smallint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "menu_tree" (
	"menu_name" varchar(32) NOT NULL,
	"mlid" serial NOT NULL,
	"id" varchar(255) NOT NULL,
	"parent" varchar(255) NOT NULL,
	"route_name" varchar(255),
	"route_param_key" varchar(255),
	"route_parameters" "bytea",
	"url" varchar(255) NOT NULL,
	"title" "bytea",
	"description" "bytea",
	"class" text,
	"options" "bytea",
	"provider" varchar(50) NOT NULL,
	"enabled" smallint NOT NULL,
	"discovered" smallint NOT NULL,
	"expanded" smallint NOT NULL,
	"weight" integer NOT NULL,
	"metadata" "bytea",
	"has_children" smallint NOT NULL,
	"depth" smallint NOT NULL,
	"p1" bigint NOT NULL,
	"p2" bigint NOT NULL,
	"p3" bigint NOT NULL,
	"p4" bigint NOT NULL,
	"p5" bigint NOT NULL,
	"p6" bigint NOT NULL,
	"p7" bigint NOT NULL,
	"p8" bigint NOT NULL,
	"p9" bigint NOT NULL,
	"form_class" varchar(255)
);
--> statement-breakpoint
CREATE TABLE "node__field_image" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"field_image_target_id" bigint NOT NULL,
	"field_image_alt" varchar(512),
	"field_image_title" varchar(1024),
	"field_image_width" bigint,
	"field_image_height" bigint
);
--> statement-breakpoint
CREATE TABLE "node_revision__field_image" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"field_image_target_id" bigint NOT NULL,
	"field_image_alt" varchar(512),
	"field_image_title" varchar(1024),
	"field_image_width" bigint,
	"field_image_height" bigint
);
--> statement-breakpoint
CREATE TABLE "node__comment" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"comment_status" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "node_revision__comment" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"comment_status" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "node__field_tags" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"field_tags_target_id" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "node_revision__field_tags" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"field_tags_target_id" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "user__user_picture" (
	"bundle" varchar(128) NOT NULL,
	"deleted" smallint NOT NULL,
	"entity_id" bigint NOT NULL,
	"revision_id" bigint NOT NULL,
	"langcode" varchar(32) NOT NULL,
	"delta" bigint NOT NULL,
	"user_picture_target_id" bigint NOT NULL,
	"user_picture_alt" varchar(512),
	"user_picture_title" varchar(1024),
	"user_picture_width" bigint,
	"user_picture_height" bigint
);
--> statement-breakpoint
CREATE TABLE "key_value_expire" (
	"collection" varchar(128) NOT NULL,
	"name" varchar(128) NOT NULL,
	"value" "bytea" NOT NULL,
	"expire" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cache_config" (
	"cid" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" numeric(14, 3) NOT NULL,
	"serialized" smallint NOT NULL,
	"tags" text,
	"checksum" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cachetags" (
	"tag" varchar(255) NOT NULL,
	"invalidations" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cache_data" (
	"cid" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" numeric(14, 3) NOT NULL,
	"serialized" smallint NOT NULL,
	"tags" text,
	"checksum" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cache_bootstrap" (
	"cid" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" numeric(14, 3) NOT NULL,
	"serialized" smallint NOT NULL,
	"tags" text,
	"checksum" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cache_discovery" (
	"cid" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" numeric(14, 3) NOT NULL,
	"serialized" smallint NOT NULL,
	"tags" text,
	"checksum" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cache_access_policy" (
	"cid" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" numeric(14, 3) NOT NULL,
	"serialized" smallint NOT NULL,
	"tags" text,
	"checksum" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cache_default" (
	"cid" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" numeric(14, 3) NOT NULL,
	"serialized" smallint NOT NULL,
	"tags" text,
	"checksum" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "semaphore" (
	"name" varchar(255) NOT NULL,
	"value" varchar(255) NOT NULL,
	"expire" double precision NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cache_render" (
	"cid" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" numeric(14, 3) NOT NULL,
	"serialized" smallint NOT NULL,
	"tags" text,
	"checksum" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cache_menu" (
	"cid" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" numeric(14, 3) NOT NULL,
	"serialized" smallint NOT NULL,
	"tags" text,
	"checksum" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cache_entity" (
	"cid" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" numeric(14, 3) NOT NULL,
	"serialized" smallint NOT NULL,
	"tags" text,
	"checksum" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cache_dynamic_page_cache" (
	"cid" varchar(255) NOT NULL,
	"data" "bytea",
	"expire" bigint NOT NULL,
	"created" numeric(14, 3) NOT NULL,
	"serialized" smallint NOT NULL,
	"tags" text,
	"checksum" varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "ban_ip" (
	"iid" serial NOT NULL,
	"ip" varchar(40) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "inline_block_usage" (
	"block_content_id" bigint NOT NULL,
	"layout_entity_type" varchar(32),
	"layout_entity_id" varchar(128)
);
--> statement-breakpoint
CREATE INDEX "watchdog__severity__idx" ON "watchdog" USING btree ("severity" int4_ops);--> statement-breakpoint
CREATE INDEX "watchdog__type__idx" ON "watchdog" USING btree ("type" text_ops);--> statement-breakpoint
CREATE INDEX "watchdog__uid__idx" ON "watchdog" USING btree ("uid" int8_ops);--> statement-breakpoint
CREATE INDEX "path_alias__path_alias__alias_langcode_id_status__idx" ON "path_alias" USING btree ("alias" int4_ops,"langcode" int4_ops,"id" int4_ops,"status" int2_ops);--> statement-breakpoint
CREATE INDEX "path_alias__path_alias__path_langcode_id_status__idx" ON "path_alias" USING btree ("path" int4_ops,"langcode" int2_ops,"id" int4_ops,"status" int2_ops);--> statement-breakpoint
CREATE INDEX "path_alias_revision__path_alias__id__idx" ON "path_alias_revision" USING btree ("id" int8_ops);--> statement-breakpoint
CREATE INDEX "help_search_items__section_plugin_id__idx" ON "help_search_items" USING btree ("section_plugin_id" text_ops);--> statement-breakpoint
CREATE INDEX "help_search_items__topic_id__idx" ON "help_search_items" USING btree ("topic_id" text_ops);--> statement-breakpoint
CREATE INDEX "search_index__sid_type__idx" ON "search_index" USING btree ("sid" int8_ops,"langcode" int8_ops,"type" int8_ops);--> statement-breakpoint
CREATE INDEX "batch__token__idx" ON "batch" USING btree ("token" text_ops);--> statement-breakpoint
CREATE INDEX "queue__expire__idx" ON "queue" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "queue__name_created__idx" ON "queue" USING btree ("name" int8_ops,"created" int8_ops);--> statement-breakpoint
CREATE INDEX "node__node_field__type__target_id__idx" ON "node" USING btree ("type" text_ops);--> statement-breakpoint
CREATE INDEX "sessions__timestamp__idx" ON "sessions" USING btree ("timestamp" int8_ops);--> statement-breakpoint
CREATE INDEX "sessions__uid__idx" ON "sessions" USING btree ("uid" int8_ops);--> statement-breakpoint
CREATE INDEX "block_content_revision__body__body_format__idx" ON "block_content_revision__body" USING btree ("body_format" text_ops);--> statement-breakpoint
CREATE INDEX "block_content_revision__body__bundle__idx" ON "block_content_revision__body" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "block_content_revision__body__revision_id__idx" ON "block_content_revision__body" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "block_content__block_content_field__type__target_id__idx" ON "block_content" USING btree ("type" text_ops);--> statement-breakpoint
CREATE INDEX "block_content_revision__block_content__id__idx" ON "block_content_revision" USING btree ("id" int8_ops);--> statement-breakpoint
CREATE INDEX "drupal__CipXU6qdl5f10_BuhE_ogc1jMaOmJLoMQ5Qdkccjkg_idx" ON "block_content_revision" USING btree ("revision_user" int8_ops);--> statement-breakpoint
CREATE INDEX "block_content_field_data__block_content__revision_id__idx" ON "block_content_field_data" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "block_content_field_data__block_content__status_type__idx" ON "block_content_field_data" USING btree ("status" int2_ops,"type" text_ops,"id" text_ops);--> statement-breakpoint
CREATE INDEX "block_content_field_data__block_content_field__reusable__idx" ON "block_content_field_data" USING btree ("reusable" int2_ops);--> statement-breakpoint
CREATE INDEX "drupal_Vlz4ZHQ_d0wCuo1mttzoczYX0MIgffhtal7RzxmuKw4_idx" ON "block_content_field_data" USING btree ("type" text_ops);--> statement-breakpoint
CREATE INDEX "drupal_wL9rKs7CrdJVvCzBzlB7hYXDGYa3Ov_zwIcY6Ecjfeo_idx" ON "block_content_field_data" USING btree ("id" text_ops,"default_langcode" int2_ops,"langcode" int2_ops);--> statement-breakpoint
CREATE INDEX "drupal_PzJThk1bhC5wux6rrih6c65UXJZ9UmNGl0Eroda5fLk_idx" ON "block_content_field_revision" USING btree ("id" int2_ops,"default_langcode" int2_ops,"langcode" int2_ops);--> statement-breakpoint
CREATE INDEX "block_content__body__body_format__idx" ON "block_content__body" USING btree ("body_format" text_ops);--> statement-breakpoint
CREATE INDEX "block_content__body__bundle__idx" ON "block_content__body" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "block_content__body__revision_id__idx" ON "block_content__body" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "users_data__module__idx" ON "users_data" USING btree ("module" text_ops);--> statement-breakpoint
CREATE INDEX "users_data__name__idx" ON "users_data" USING btree ("name" text_ops);--> statement-breakpoint
CREATE INDEX "users_field_data__user__id__default_langcode__langcode__idx" ON "users_field_data" USING btree ("uid" int8_ops,"default_langcode" int2_ops,"langcode" int8_ops);--> statement-breakpoint
CREATE INDEX "users_field_data__user_field__access__idx" ON "users_field_data" USING btree ("access" int4_ops);--> statement-breakpoint
CREATE INDEX "users_field_data__user_field__created__idx" ON "users_field_data" USING btree ("created" int4_ops);--> statement-breakpoint
CREATE INDEX "users_field_data__user_field__mail__idx" ON "users_field_data" USING btree ("mail" text_ops);--> statement-breakpoint
CREATE INDEX "user__roles__bundle__idx" ON "user__roles" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "user__roles__revision_id__idx" ON "user__roles" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "user__roles__roles_target_id__idx" ON "user__roles" USING btree ("roles_target_id" text_ops);--> statement-breakpoint
CREATE INDEX "node_revision__node__nid__idx" ON "node_revision" USING btree ("nid" int8_ops);--> statement-breakpoint
CREATE INDEX "node_revision__node_field__langcode__idx" ON "node_revision" USING btree ("langcode" text_ops);--> statement-breakpoint
CREATE INDEX "node_revision__node_field__revision_uid__target_id__idx" ON "node_revision" USING btree ("revision_uid" int8_ops);--> statement-breakpoint
CREATE INDEX "node_field_data__node__frontpage__idx" ON "node_field_data" USING btree ("promote" int2_ops,"status" int4_ops,"sticky" int4_ops,"created" int2_ops);--> statement-breakpoint
CREATE INDEX "node_field_data__node__id__default_langcode__langcode__idx" ON "node_field_data" USING btree ("nid" text_ops,"default_langcode" int2_ops,"langcode" int8_ops);--> statement-breakpoint
CREATE INDEX "node_field_data__node__status_type__idx" ON "node_field_data" USING btree ("status" int2_ops,"type" text_ops,"nid" int2_ops);--> statement-breakpoint
CREATE INDEX "node_field_data__node__title_type__idx" ON "node_field_data" USING btree (title text_ops,substr((type)::text, 1, 4) text_ops);--> statement-breakpoint
CREATE INDEX "node_field_data__node__vid__idx" ON "node_field_data" USING btree ("vid" int8_ops);--> statement-breakpoint
CREATE INDEX "node_field_data__node_field__changed__idx" ON "node_field_data" USING btree ("changed" int4_ops);--> statement-breakpoint
CREATE INDEX "node_field_data__node_field__created__idx" ON "node_field_data" USING btree ("created" int4_ops);--> statement-breakpoint
CREATE INDEX "node_field_data__node_field__type__target_id__idx" ON "node_field_data" USING btree ("type" text_ops);--> statement-breakpoint
CREATE INDEX "node_field_data__node_field__uid__target_id__idx" ON "node_field_data" USING btree ("uid" int8_ops);--> statement-breakpoint
CREATE INDEX "node_field_revision__node__id__default_langcode__langcode__idx" ON "node_field_revision" USING btree ("nid" int2_ops,"default_langcode" int2_ops,"langcode" int2_ops);--> statement-breakpoint
CREATE INDEX "node_field_revision__node_field__uid__target_id__idx" ON "node_field_revision" USING btree ("uid" int8_ops);--> statement-breakpoint
CREATE INDEX "file_usage__fid_count__idx" ON "file_usage" USING btree ("fid" int8_ops,"count" int8_ops);--> statement-breakpoint
CREATE INDEX "file_usage__fid_module__idx" ON "file_usage" USING btree ("fid" text_ops,"module" text_ops);--> statement-breakpoint
CREATE INDEX "file_usage__type_id__idx" ON "file_usage" USING btree ("type" text_ops,"id" text_ops);--> statement-breakpoint
CREATE INDEX "node__body__body_format__idx" ON "node__body" USING btree ("body_format" text_ops);--> statement-breakpoint
CREATE INDEX "node__body__bundle__idx" ON "node__body" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "node__body__revision_id__idx" ON "node__body" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "node_revision__body__body_format__idx" ON "node_revision__body" USING btree ("body_format" text_ops);--> statement-breakpoint
CREATE INDEX "node_revision__body__bundle__idx" ON "node_revision__body" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "node_revision__body__revision_id__idx" ON "node_revision__body" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "file_managed__file_field__changed__idx" ON "file_managed" USING btree ("changed" int4_ops);--> statement-breakpoint
CREATE INDEX "file_managed__file_field__status__idx" ON "file_managed" USING btree ("status" int2_ops);--> statement-breakpoint
CREATE INDEX "file_managed__file_field__uid__target_id__idx" ON "file_managed" USING btree ("uid" int8_ops);--> statement-breakpoint
CREATE INDEX "file_managed__file_field__uri__idx" ON "file_managed" USING btree ("uri" text_ops);--> statement-breakpoint
CREATE INDEX "comment_entity_statistics__comment_count__idx" ON "comment_entity_statistics" USING btree ("comment_count" int8_ops);--> statement-breakpoint
CREATE INDEX "comment_entity_statistics__last_comment_timestamp__idx" ON "comment_entity_statistics" USING btree ("last_comment_timestamp" int8_ops);--> statement-breakpoint
CREATE INDEX "comment_entity_statistics__last_comment_uid__idx" ON "comment_entity_statistics" USING btree ("last_comment_uid" int8_ops);--> statement-breakpoint
CREATE INDEX "comment__comment_field__comment_type__target_id__idx" ON "comment" USING btree ("comment_type" text_ops);--> statement-breakpoint
CREATE INDEX "comment_field_data__comment__entity_langcode__idx" ON "comment_field_data" USING btree ("entity_id" int2_ops,"entity_type" text_ops,"comment_type" text_ops,"default_langcode" text_ops);--> statement-breakpoint
CREATE INDEX "comment_field_data__comment__num_new__idx" ON "comment_field_data" USING btree ("entity_id" int2_ops,"entity_type" int4_ops,"comment_type" int2_ops,"status" int2_ops,"created" int4_ops,"cid" int4_ops,"thread" int4_ops);--> statement-breakpoint
CREATE INDEX "comment_field_data__comment__status_comment_type__idx" ON "comment_field_data" USING btree ("status" int8_ops,"comment_type" int2_ops,"cid" int8_ops);--> statement-breakpoint
CREATE INDEX "comment_field_data__comment__status_pid__idx" ON "comment_field_data" USING btree ("pid" int8_ops,"status" int2_ops);--> statement-breakpoint
CREATE INDEX "comment_field_data__comment_field__comment_type__target_id__idx" ON "comment_field_data" USING btree ("comment_type" text_ops);--> statement-breakpoint
CREATE INDEX "comment_field_data__comment_field__created__idx" ON "comment_field_data" USING btree ("created" int4_ops);--> statement-breakpoint
CREATE INDEX "comment_field_data__comment_field__uid__target_id__idx" ON "comment_field_data" USING btree ("uid" int8_ops);--> statement-breakpoint
CREATE INDEX "drupal_mOML8Q1mOpUaN8EQHtn4pIFZ9wK8gamkAI1iyADLZZ8_idx" ON "comment_field_data" USING btree ("cid" int8_ops,"default_langcode" text_ops,"langcode" int8_ops);--> statement-breakpoint
CREATE INDEX "comment__comment_body__bundle__idx" ON "comment__comment_body" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "comment__comment_body__comment_body_format__idx" ON "comment__comment_body" USING btree ("comment_body_format" text_ops);--> statement-breakpoint
CREATE INDEX "comment__comment_body__revision_id__idx" ON "comment__comment_body" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "cache_container__created__idx" ON "cache_container" USING btree ("created" numeric_ops);--> statement-breakpoint
CREATE INDEX "cache_container__expire__idx" ON "cache_container" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "locales_source__source_context__idx" ON "locales_source" USING btree (substr(source, 1, 30) text_ops,context text_ops);--> statement-breakpoint
CREATE INDEX "locales_target__lid__idx" ON "locales_target" USING btree ("lid" int4_ops);--> statement-breakpoint
CREATE INDEX "locales_location__string_type__idx" ON "locales_location" USING btree ("sid" int4_ops,"type" int4_ops);--> statement-breakpoint
CREATE INDEX "locales_location__type_name__idx" ON "locales_location" USING btree ("type" text_ops,"name" text_ops);--> statement-breakpoint
CREATE INDEX "history__nid__idx" ON "history" USING btree ("nid" int8_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term_data__taxonomy_term_field__vid__target_id__idx" ON "taxonomy_term_data" USING btree ("vid" text_ops);--> statement-breakpoint
CREATE INDEX "drupal_2wXmNkIidFb530o9_wbeLfe93ztt315H0_uG2d8WoFE_idx" ON "taxonomy_term_revision" USING btree ("revision_user" int8_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term_revision__taxonomy_term__tid__idx" ON "taxonomy_term_revision" USING btree ("tid" int8_ops);--> statement-breakpoint
CREATE INDEX "drupal_jVEqkc6s2d_YXyKzgPOmeuEYgeSndHxNyF_lQrsUBhg_idx" ON "taxonomy_term_field_data" USING btree ("tid" int2_ops,"default_langcode" int8_ops,"langcode" int2_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term_field_data__taxonomy_term__revision_id__idx" ON "taxonomy_term_field_data" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term_field_data__taxonomy_term__status_vid__idx" ON "taxonomy_term_field_data" USING btree ("status" int8_ops,"vid" int2_ops,"tid" text_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term_field_data__taxonomy_term__tree__idx" ON "taxonomy_term_field_data" USING btree ("vid" int4_ops,"weight" int4_ops,"name" text_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term_field_data__taxonomy_term__vid_name__idx" ON "taxonomy_term_field_data" USING btree ("vid" text_ops,"name" text_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term_field_data__taxonomy_term_field__name__idx" ON "taxonomy_term_field_data" USING btree ("name" text_ops);--> statement-breakpoint
CREATE INDEX "drupal_M2Qup2oS2zlnKrlzxtyMPc4wpQTHO8bTW9QMuxZwsiQ_idx" ON "taxonomy_term_field_revision" USING btree ("description__format" text_ops);--> statement-breakpoint
CREATE INDEX "drupal_zC5XUHi3lXvFlyilgI0NlNZth42DSBX5G_FjNgxVTGQ_idx" ON "taxonomy_term_field_revision" USING btree ("tid" int2_ops,"default_langcode" int2_ops,"langcode" int2_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_index__term_node__idx" ON "taxonomy_index" USING btree ("tid" int4_ops,"status" int4_ops,"sticky" int4_ops,"created" int4_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term__parent__bundle_delta_target_id__idx" ON "taxonomy_term__parent" USING btree ("bundle" int8_ops,"delta" int8_ops,"parent_target_id" text_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term__parent__parent_target_id__idx" ON "taxonomy_term__parent" USING btree ("parent_target_id" int8_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term__parent__revision_id__idx" ON "taxonomy_term__parent" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term_revision__parent__bundle__idx" ON "taxonomy_term_revision__parent" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term_revision__parent__parent_target_id__idx" ON "taxonomy_term_revision__parent" USING btree ("parent_target_id" int8_ops);--> statement-breakpoint
CREATE INDEX "taxonomy_term_revision__parent__revision_id__idx" ON "taxonomy_term_revision__parent" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "menu_link_content_revision__menu_link_content__ef029a1897__idx" ON "menu_link_content_revision" USING btree ("revision_user" int8_ops);--> statement-breakpoint
CREATE INDEX "menu_link_content_revision__menu_link_content__id__idx" ON "menu_link_content_revision" USING btree ("id" int8_ops);--> statement-breakpoint
CREATE INDEX "drupal_mtiYLSRDGoU4931oeZ9cDY50TtJYeSgNur4s_gNPxF8_idx" ON "menu_link_content_data" USING btree ("id" int2_ops,"default_langcode" int8_ops,"langcode" int2_ops);--> statement-breakpoint
CREATE INDEX "menu_link_content_data__menu_link_content__enabled_bundle__idx" ON "menu_link_content_data" USING btree ("enabled" text_ops,"bundle" int8_ops,"id" int8_ops);--> statement-breakpoint
CREATE INDEX "menu_link_content_data__menu_link_content__revision_id__idx" ON "menu_link_content_data" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "menu_link_content_data__menu_link_content_field__link__uri__idx" ON "menu_link_content_data" USING btree (substr((link__uri)::text, 1, 30) text_ops);--> statement-breakpoint
CREATE INDEX "drupal_L0k0k_zy6SEDoKs_R8suuvxbkHf_hZzMpkX6r42vlFg_idx" ON "menu_link_content_field_revision" USING btree ("id" int2_ops,"default_langcode" int8_ops,"langcode" text_ops);--> statement-breakpoint
CREATE INDEX "drupal_ui7U_4ySVsbBkDhd7CC2Cz97Yr_s3QEuF9xZI0mi1lA_idx" ON "menu_link_content_field_revision" USING btree (substr((link__uri)::text, 1, 30) text_ops);--> statement-breakpoint
CREATE INDEX "shortcut_set_users__set_name__idx" ON "shortcut_set_users" USING btree ("set_name" text_ops);--> statement-breakpoint
CREATE INDEX "shortcut__shortcut_field__shortcut_set__target_id__idx" ON "shortcut" USING btree ("shortcut_set" text_ops);--> statement-breakpoint
CREATE INDEX "drupal_ZRb0RrR9ucQ_abrsOj5OqJZ6JHhecUX6qMxhEeLHDSA_idx" ON "shortcut_field_data" USING btree ("shortcut_set" text_ops);--> statement-breakpoint
CREATE INDEX "drupal_yYznZkp1jjRq3ZidRMkkkawuQCmql0kdszvKsIMeEkU_idx" ON "shortcut_field_data" USING btree ("id" int2_ops,"default_langcode" text_ops,"langcode" int2_ops);--> statement-breakpoint
CREATE INDEX "shortcut_field_data__shortcut_field__link__uri__idx" ON "shortcut_field_data" USING btree (substr((link__uri)::text, 1, 30) text_ops);--> statement-breakpoint
CREATE INDEX "router__pattern_outline_parts__idx" ON "router" USING btree ("pattern_outline" int2_ops,"number_parts" int2_ops);--> statement-breakpoint
CREATE INDEX "menu_tree__menu_parent_expand_child__idx" ON "menu_tree" USING btree (menu_name text_ops,expanded int2_ops,has_children int2_ops,substr((parent)::text, 1, 16) text_ops);--> statement-breakpoint
CREATE INDEX "menu_tree__menu_parents__idx" ON "menu_tree" USING btree ("menu_name" int8_ops,"p1" text_ops,"p2" int8_ops,"p3" text_ops,"p4" text_ops,"p5" text_ops,"p6" text_ops,"p7" int8_ops,"p8" text_ops,"p9" text_ops);--> statement-breakpoint
CREATE INDEX "menu_tree__route_values__idx" ON "menu_tree" USING btree (substr((route_name)::text, 1, 32) text_ops,substr((route_param_key)::text, 1, 16) text_ops);--> statement-breakpoint
CREATE INDEX "node__field_image__bundle__idx" ON "node__field_image" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "node__field_image__field_image_target_id__idx" ON "node__field_image" USING btree ("field_image_target_id" int8_ops);--> statement-breakpoint
CREATE INDEX "node__field_image__revision_id__idx" ON "node__field_image" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "node_revision__field_image__bundle__idx" ON "node_revision__field_image" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "node_revision__field_image__field_image_target_id__idx" ON "node_revision__field_image" USING btree ("field_image_target_id" int8_ops);--> statement-breakpoint
CREATE INDEX "node_revision__field_image__revision_id__idx" ON "node_revision__field_image" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "node__comment__bundle__idx" ON "node__comment" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "node__comment__revision_id__idx" ON "node__comment" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "node_revision__comment__bundle__idx" ON "node_revision__comment" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "node_revision__comment__revision_id__idx" ON "node_revision__comment" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "node__field_tags__bundle__idx" ON "node__field_tags" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "node__field_tags__field_tags_target_id__idx" ON "node__field_tags" USING btree ("field_tags_target_id" int8_ops);--> statement-breakpoint
CREATE INDEX "node__field_tags__revision_id__idx" ON "node__field_tags" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "node_revision__field_tags__bundle__idx" ON "node_revision__field_tags" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "node_revision__field_tags__field_tags_target_id__idx" ON "node_revision__field_tags" USING btree ("field_tags_target_id" int8_ops);--> statement-breakpoint
CREATE INDEX "node_revision__field_tags__revision_id__idx" ON "node_revision__field_tags" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "user__user_picture__bundle__idx" ON "user__user_picture" USING btree ("bundle" text_ops);--> statement-breakpoint
CREATE INDEX "user__user_picture__revision_id__idx" ON "user__user_picture" USING btree ("revision_id" int8_ops);--> statement-breakpoint
CREATE INDEX "user__user_picture__user_picture_target_id__idx" ON "user__user_picture" USING btree ("user_picture_target_id" int8_ops);--> statement-breakpoint
CREATE INDEX "key_value_expire__expire__idx" ON "key_value_expire" USING btree ("expire" int4_ops);--> statement-breakpoint
CREATE INDEX "cache_config__created__idx" ON "cache_config" USING btree ("created" numeric_ops);--> statement-breakpoint
CREATE INDEX "cache_config__expire__idx" ON "cache_config" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "cache_data__created__idx" ON "cache_data" USING btree ("created" numeric_ops);--> statement-breakpoint
CREATE INDEX "cache_data__expire__idx" ON "cache_data" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "cache_bootstrap__created__idx" ON "cache_bootstrap" USING btree ("created" numeric_ops);--> statement-breakpoint
CREATE INDEX "cache_bootstrap__expire__idx" ON "cache_bootstrap" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "cache_discovery__created__idx" ON "cache_discovery" USING btree ("created" numeric_ops);--> statement-breakpoint
CREATE INDEX "cache_discovery__expire__idx" ON "cache_discovery" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "cache_access_policy__created__idx" ON "cache_access_policy" USING btree ("created" numeric_ops);--> statement-breakpoint
CREATE INDEX "cache_access_policy__expire__idx" ON "cache_access_policy" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "cache_default__created__idx" ON "cache_default" USING btree ("created" numeric_ops);--> statement-breakpoint
CREATE INDEX "cache_default__expire__idx" ON "cache_default" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "semaphore__expire__idx" ON "semaphore" USING btree ("expire" float8_ops);--> statement-breakpoint
CREATE INDEX "semaphore__value__idx" ON "semaphore" USING btree ("value" text_ops);--> statement-breakpoint
CREATE INDEX "cache_render__created__idx" ON "cache_render" USING btree ("created" numeric_ops);--> statement-breakpoint
CREATE INDEX "cache_render__expire__idx" ON "cache_render" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "cache_menu__created__idx" ON "cache_menu" USING btree ("created" numeric_ops);--> statement-breakpoint
CREATE INDEX "cache_menu__expire__idx" ON "cache_menu" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "cache_entity__created__idx" ON "cache_entity" USING btree ("created" numeric_ops);--> statement-breakpoint
CREATE INDEX "cache_entity__expire__idx" ON "cache_entity" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "cache_dynamic_page_cache__created__idx" ON "cache_dynamic_page_cache" USING btree ("created" numeric_ops);--> statement-breakpoint
CREATE INDEX "cache_dynamic_page_cache__expire__idx" ON "cache_dynamic_page_cache" USING btree ("expire" int8_ops);--> statement-breakpoint
CREATE INDEX "ban_ip__ip__idx" ON "ban_ip" USING btree ("ip" text_ops);--> statement-breakpoint
CREATE INDEX "inline_block_usage__type_id__idx" ON "inline_block_usage" USING btree ("layout_entity_type" text_ops,"layout_entity_id" text_ops);
*/