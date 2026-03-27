import { pgTable, index, bigserial, bigint, customType, varchar, text, integer, serial, smallint, real, numeric, doublePrecision } from "drizzle-orm/pg-core"
import { sql } from "drizzle-orm"

const bytea = customType<{ data: Buffer }>({
  dataType() {
    return "bytea";
  },
});

export const watchdog = pgTable("watchdog", {
	wid: bigserial({ mode: "bigint" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	uid: bigint({ mode: "number" }).notNull(),
	type: varchar({ length: 64 }).notNull(),
	message: text().notNull(),
	// TODO: failed to parse database type 'bytea'
	variables: bytea("variables").notNull(),
	severity: integer().notNull(),
	link: text(),
	location: text().notNull(),
	referer: text(),
	hostname: varchar({ length: 128 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	timestamp: bigint({ mode: "number" }).notNull(),
}, (table) => [
	index("watchdog__severity__idx").using("btree", table.severity.asc().nullsLast().op("int4_ops")),
	index("watchdog__type__idx").using("btree", table.type.asc().nullsLast().op("text_ops")),
	index("watchdog__uid__idx").using("btree", table.uid.asc().nullsLast().op("int8_ops")),
]);

export const pathAlias = pgTable("path_alias", {
	id: serial().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }),
	uuid: varchar({ length: 128 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	path: varchar({ length: 255 }),
	alias: varchar({ length: 255 }),
	status: smallint().notNull(),
}, (table) => [
	index("path_alias__path_alias__alias_langcode_id_status__idx").using("btree", table.alias.asc().nullsLast().op("int4_ops"), table.langcode.asc().nullsLast().op("int4_ops"), table.id.asc().nullsLast().op("int4_ops"), table.status.asc().nullsLast().op("int2_ops")),
	index("path_alias__path_alias__path_langcode_id_status__idx").using("btree", table.path.asc().nullsLast().op("int4_ops"), table.langcode.asc().nullsLast().op("int2_ops"), table.id.asc().nullsLast().op("int4_ops"), table.status.asc().nullsLast().op("int2_ops")),
]);

export const pathAliasRevision = pgTable("path_alias_revision", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).notNull(),
	revisionId: serial("revision_id").notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	path: varchar({ length: 255 }),
	alias: varchar({ length: 255 }),
	status: smallint().notNull(),
	revisionDefault: smallint("revision_default"),
}, (table) => [
	index("path_alias_revision__path_alias__id__idx").using("btree", table.id.asc().nullsLast().op("int8_ops")),
]);

export const helpSearchItems = pgTable("help_search_items", {
	sid: serial().notNull(),
	sectionPluginId: varchar("section_plugin_id", { length: 255 }).notNull(),
	permission: varchar({ length: 255 }).notNull(),
	topicId: varchar("topic_id", { length: 255 }).notNull(),
}, (table) => [
	index("help_search_items__section_plugin_id__idx").using("btree", table.sectionPluginId.asc().nullsLast().op("text_ops")),
	index("help_search_items__topic_id__idx").using("btree", table.topicId.asc().nullsLast().op("text_ops")),
]);

export const searchDataset = pgTable("search_dataset", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	sid: bigint({ mode: "number" }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	type: varchar({ length: 64 }).notNull(),
	data: text().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	reindex: bigint({ mode: "number" }).notNull(),
});

export const searchIndex = pgTable("search_index", {
	word: varchar({ length: 50 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	sid: bigint({ mode: "number" }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	type: varchar({ length: 64 }).notNull(),
	score: real(),
}, (table) => [
	index("search_index__sid_type__idx").using("btree", table.sid.asc().nullsLast().op("int8_ops"), table.langcode.asc().nullsLast().op("int8_ops"), table.type.asc().nullsLast().op("int8_ops")),
]);

export const searchTotal = pgTable("search_total", {
	word: varchar({ length: 50 }).notNull(),
	count: real(),
});

export const config = pgTable("config", {
	collection: varchar({ length: 255 }).notNull(),
	name: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
});

export const keyValue = pgTable("key_value", {
	collection: varchar({ length: 128 }).notNull(),
	name: varchar({ length: 128 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	value: bytea("value").notNull(),
});

export const sequences = pgTable("sequences", {
	value: serial().notNull(),
});

export const batch = pgTable("batch", {
	bid: serial().notNull(),
	token: varchar({ length: 64 }).notNull(),
	timestamp: integer().notNull(),
	// TODO: failed to parse database type 'bytea'
	batch: bytea("batch"),
}, (table) => [
	index("batch__token__idx").using("btree", table.token.asc().nullsLast().op("text_ops")),
]);

export const queue = pgTable("queue", {
	itemId: serial("item_id").notNull(),
	name: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	created: bigint({ mode: "number" }).notNull(),
}, (table) => [
	index("queue__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
	index("queue__name_created__idx").using("btree", table.name.asc().nullsLast().op("int8_ops"), table.created.asc().nullsLast().op("int8_ops")),
]);

export const node = pgTable("node", {
	nid: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	vid: bigint({ mode: "number" }),
	type: varchar({ length: 32 }).notNull(),
	uuid: varchar({ length: 128 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
}, (table) => [
	index("node__node_field__type__target_id__idx").using("btree", table.type.asc().nullsLast().op("text_ops")),
]);

export const sessions = pgTable("sessions", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	uid: bigint({ mode: "number" }).notNull(),
	sid: varchar({ length: 128 }).notNull(),
	hostname: varchar({ length: 128 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	timestamp: bigint({ mode: "number" }).notNull(),
	// TODO: failed to parse database type 'bytea'
	session: bytea("session"),
}, (table) => [
	index("sessions__timestamp__idx").using("btree", table.timestamp.asc().nullsLast().op("int8_ops")),
	index("sessions__uid__idx").using("btree", table.uid.asc().nullsLast().op("int8_ops")),
]);

export const blockContentRevisionBody = pgTable("block_content_revision__body", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	bodyValue: text("body_value").notNull(),
	bodySummary: text("body_summary"),
	bodyFormat: varchar("body_format", { length: 255 }),
}, (table) => [
	index("block_content_revision__body__body_format__idx").using("btree", table.bodyFormat.asc().nullsLast().op("text_ops")),
	index("block_content_revision__body__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("block_content_revision__body__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const nodeAccess = pgTable("node_access", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	nid: bigint({ mode: "number" }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	fallback: integer().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	gid: bigint({ mode: "number" }).notNull(),
	realm: varchar({ length: 255 }).notNull(),
	grantView: integer("grant_view").notNull(),
	grantUpdate: integer("grant_update").notNull(),
	grantDelete: integer("grant_delete").notNull(),
});

export const blockContent = pgTable("block_content", {
	id: serial().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }),
	type: varchar({ length: 32 }).notNull(),
	uuid: varchar({ length: 128 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
}, (table) => [
	index("block_content__block_content_field__type__target_id__idx").using("btree", table.type.asc().nullsLast().op("text_ops")),
]);

export const blockContentRevision = pgTable("block_content_revision", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).notNull(),
	revisionId: serial("revision_id").notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionUser: bigint("revision_user", { mode: "number" }),
	revisionCreated: integer("revision_created"),
	revisionLog: text("revision_log"),
	revisionDefault: smallint("revision_default"),
}, (table) => [
	index("block_content_revision__block_content__id__idx").using("btree", table.id.asc().nullsLast().op("int8_ops")),
	index("drupal__CipXU6qdl5f10_BuhE_ogc1jMaOmJLoMQ5Qdkccjkg_idx").using("btree", table.revisionUser.asc().nullsLast().op("int8_ops")),
]);

export const blockContentFieldData = pgTable("block_content_field_data", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	type: varchar({ length: 32 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	status: smallint().notNull(),
	info: varchar({ length: 255 }),
	changed: integer(),
	reusable: smallint(),
	defaultLangcode: smallint("default_langcode").notNull(),
	revisionTranslationAffected: smallint("revision_translation_affected"),
}, (table) => [
	index("block_content_field_data__block_content__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
	index("block_content_field_data__block_content__status_type__idx").using("btree", table.status.asc().nullsLast().op("int2_ops"), table.type.asc().nullsLast().op("text_ops"), table.id.asc().nullsLast().op("text_ops")),
	index("block_content_field_data__block_content_field__reusable__idx").using("btree", table.reusable.asc().nullsLast().op("int2_ops")),
	index("drupal_Vlz4ZHQ_d0wCuo1mttzoczYX0MIgffhtal7RzxmuKw4_idx").using("btree", table.type.asc().nullsLast().op("text_ops")),
	index("drupal_wL9rKs7CrdJVvCzBzlB7hYXDGYa3Ov_zwIcY6Ecjfeo_idx").using("btree", table.id.asc().nullsLast().op("text_ops"), table.defaultLangcode.asc().nullsLast().op("int2_ops"), table.langcode.asc().nullsLast().op("int2_ops")),
]);

export const blockContentFieldRevision = pgTable("block_content_field_revision", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	status: smallint().notNull(),
	info: varchar({ length: 255 }),
	changed: integer(),
	defaultLangcode: smallint("default_langcode").notNull(),
	revisionTranslationAffected: smallint("revision_translation_affected"),
}, (table) => [
	index("drupal_PzJThk1bhC5wux6rrih6c65UXJZ9UmNGl0Eroda5fLk_idx").using("btree", table.id.asc().nullsLast().op("int2_ops"), table.defaultLangcode.asc().nullsLast().op("int2_ops"), table.langcode.asc().nullsLast().op("int2_ops")),
]);

export const blockContentBody = pgTable("block_content__body", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	bodyValue: text("body_value").notNull(),
	bodySummary: text("body_summary"),
	bodyFormat: varchar("body_format", { length: 255 }),
}, (table) => [
	index("block_content__body__body_format__idx").using("btree", table.bodyFormat.asc().nullsLast().op("text_ops")),
	index("block_content__body__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("block_content__body__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const usersData = pgTable("users_data", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	uid: bigint({ mode: "number" }).notNull(),
	module: varchar({ length: 50 }).notNull(),
	name: varchar({ length: 128 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	value: bytea("value"),
	serialized: integer(),
}, (table) => [
	index("users_data__module__idx").using("btree", table.module.asc().nullsLast().op("text_ops")),
	index("users_data__name__idx").using("btree", table.name.asc().nullsLast().op("text_ops")),
]);

export const users = pgTable("users", {
	uid: serial().notNull(),
	uuid: varchar({ length: 128 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
});

export const usersFieldData = pgTable("users_field_data", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	uid: bigint({ mode: "number" }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	preferredLangcode: varchar("preferred_langcode", { length: 12 }),
	preferredAdminLangcode: varchar("preferred_admin_langcode", { length: 12 }),
	name: varchar({ length: 60 }).notNull(),
	pass: varchar({ length: 255 }),
	mail: varchar({ length: 254 }),
	timezone: varchar({ length: 32 }),
	status: smallint(),
	created: integer().notNull(),
	changed: integer(),
	access: integer().notNull(),
	login: integer(),
	init: varchar({ length: 254 }),
	defaultLangcode: smallint("default_langcode").notNull(),
}, (table) => [
	index("users_field_data__user__id__default_langcode__langcode__idx").using("btree", table.uid.asc().nullsLast().op("int8_ops"), table.defaultLangcode.asc().nullsLast().op("int2_ops"), table.langcode.asc().nullsLast().op("int8_ops")),
	index("users_field_data__user_field__access__idx").using("btree", table.access.asc().nullsLast().op("int4_ops")),
	index("users_field_data__user_field__created__idx").using("btree", table.created.asc().nullsLast().op("int4_ops")),
	index("users_field_data__user_field__mail__idx").using("btree", table.mail.asc().nullsLast().op("text_ops")),
]);

export const userRoles = pgTable("user__roles", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	rolesTargetId: varchar("roles_target_id", { length: 255 }).notNull(),
}, (table) => [
	index("user__roles__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("user__roles__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
	index("user__roles__roles_target_id__idx").using("btree", table.rolesTargetId.asc().nullsLast().op("text_ops")),
]);

export const nodeRevision = pgTable("node_revision", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	nid: bigint({ mode: "number" }).notNull(),
	vid: serial().notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionUid: bigint("revision_uid", { mode: "number" }),
	revisionTimestamp: integer("revision_timestamp"),
	revisionLog: text("revision_log"),
	revisionDefault: smallint("revision_default"),
}, (table) => [
	index("node_revision__node__nid__idx").using("btree", table.nid.asc().nullsLast().op("int8_ops")),
	index("node_revision__node_field__langcode__idx").using("btree", table.langcode.asc().nullsLast().op("text_ops")),
	index("node_revision__node_field__revision_uid__target_id__idx").using("btree", table.revisionUid.asc().nullsLast().op("int8_ops")),
]);

export const nodeFieldData = pgTable("node_field_data", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	nid: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	vid: bigint({ mode: "number" }).notNull(),
	type: varchar({ length: 32 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	status: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	uid: bigint({ mode: "number" }).notNull(),
	title: varchar({ length: 255 }).notNull(),
	created: integer().notNull(),
	changed: integer().notNull(),
	promote: smallint().notNull(),
	sticky: smallint().notNull(),
	defaultLangcode: smallint("default_langcode").notNull(),
	revisionTranslationAffected: smallint("revision_translation_affected"),
}, (table) => [
	index("node_field_data__node__frontpage__idx").using("btree", table.promote.asc().nullsLast().op("int2_ops"), table.status.asc().nullsLast().op("int4_ops"), table.sticky.asc().nullsLast().op("int4_ops"), table.created.asc().nullsLast().op("int2_ops")),
	index("node_field_data__node__id__default_langcode__langcode__idx").using("btree", table.nid.asc().nullsLast().op("text_ops"), table.defaultLangcode.asc().nullsLast().op("int2_ops"), table.langcode.asc().nullsLast().op("int8_ops")),
	index("node_field_data__node__status_type__idx").using("btree", table.status.asc().nullsLast().op("int2_ops"), table.type.asc().nullsLast().op("text_ops"), table.nid.asc().nullsLast().op("int2_ops")),
	index("node_field_data__node__title_type__idx").using("btree", sql`title`, sql`substr((type)::text, 1, 4)`),
	index("node_field_data__node__vid__idx").using("btree", table.vid.asc().nullsLast().op("int8_ops")),
	index("node_field_data__node_field__changed__idx").using("btree", table.changed.asc().nullsLast().op("int4_ops")),
	index("node_field_data__node_field__created__idx").using("btree", table.created.asc().nullsLast().op("int4_ops")),
	index("node_field_data__node_field__type__target_id__idx").using("btree", table.type.asc().nullsLast().op("text_ops")),
	index("node_field_data__node_field__uid__target_id__idx").using("btree", table.uid.asc().nullsLast().op("int8_ops")),
]);

export const nodeFieldRevision = pgTable("node_field_revision", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	nid: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	vid: bigint({ mode: "number" }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	status: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	uid: bigint({ mode: "number" }).notNull(),
	title: varchar({ length: 255 }),
	created: integer(),
	changed: integer(),
	promote: smallint(),
	sticky: smallint(),
	defaultLangcode: smallint("default_langcode").notNull(),
	revisionTranslationAffected: smallint("revision_translation_affected"),
}, (table) => [
	index("node_field_revision__node__id__default_langcode__langcode__idx").using("btree", table.nid.asc().nullsLast().op("int2_ops"), table.defaultLangcode.asc().nullsLast().op("int2_ops"), table.langcode.asc().nullsLast().op("int2_ops")),
	index("node_field_revision__node_field__uid__target_id__idx").using("btree", table.uid.asc().nullsLast().op("int8_ops")),
]);

export const fileUsage = pgTable("file_usage", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	fid: bigint({ mode: "number" }).notNull(),
	module: varchar({ length: 50 }).notNull(),
	type: varchar({ length: 64 }).notNull(),
	id: varchar({ length: 64 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	count: bigint({ mode: "number" }).notNull(),
}, (table) => [
	index("file_usage__fid_count__idx").using("btree", table.fid.asc().nullsLast().op("int8_ops"), table.count.asc().nullsLast().op("int8_ops")),
	index("file_usage__fid_module__idx").using("btree", table.fid.asc().nullsLast().op("text_ops"), table.module.asc().nullsLast().op("text_ops")),
	index("file_usage__type_id__idx").using("btree", table.type.asc().nullsLast().op("text_ops"), table.id.asc().nullsLast().op("text_ops")),
]);

export const nodeBody = pgTable("node__body", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	bodyValue: text("body_value").notNull(),
	bodySummary: text("body_summary"),
	bodyFormat: varchar("body_format", { length: 255 }),
}, (table) => [
	index("node__body__body_format__idx").using("btree", table.bodyFormat.asc().nullsLast().op("text_ops")),
	index("node__body__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("node__body__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const nodeRevisionBody = pgTable("node_revision__body", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	bodyValue: text("body_value").notNull(),
	bodySummary: text("body_summary"),
	bodyFormat: varchar("body_format", { length: 255 }),
}, (table) => [
	index("node_revision__body__body_format__idx").using("btree", table.bodyFormat.asc().nullsLast().op("text_ops")),
	index("node_revision__body__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("node_revision__body__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const fileManaged = pgTable("file_managed", {
	fid: serial().notNull(),
	uuid: varchar({ length: 128 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	uid: bigint({ mode: "number" }),
	filename: varchar({ length: 255 }),
	uri: varchar({ length: 255 }).notNull(),
	filemime: varchar({ length: 255 }),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	filesize: bigint({ mode: "number" }),
	status: smallint().notNull(),
	created: integer(),
	changed: integer().notNull(),
}, (table) => [
	index("file_managed__file_field__changed__idx").using("btree", table.changed.asc().nullsLast().op("int4_ops")),
	index("file_managed__file_field__status__idx").using("btree", table.status.asc().nullsLast().op("int2_ops")),
	index("file_managed__file_field__uid__target_id__idx").using("btree", table.uid.asc().nullsLast().op("int8_ops")),
	index("file_managed__file_field__uri__idx").using("btree", table.uri.asc().nullsLast().op("text_ops")),
]);

export const commentEntityStatistics = pgTable("comment_entity_statistics", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	entityType: varchar("entity_type", { length: 32 }).notNull(),
	fieldName: varchar("field_name", { length: 32 }).notNull(),
	cid: integer().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	lastCommentTimestamp: bigint("last_comment_timestamp", { mode: "number" }).notNull(),
	lastCommentName: varchar("last_comment_name", { length: 60 }),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	lastCommentUid: bigint("last_comment_uid", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	commentCount: bigint("comment_count", { mode: "number" }).notNull(),
}, (table) => [
	index("comment_entity_statistics__comment_count__idx").using("btree", table.commentCount.asc().nullsLast().op("int8_ops")),
	index("comment_entity_statistics__last_comment_timestamp__idx").using("btree", table.lastCommentTimestamp.asc().nullsLast().op("int8_ops")),
	index("comment_entity_statistics__last_comment_uid__idx").using("btree", table.lastCommentUid.asc().nullsLast().op("int8_ops")),
]);

export const comment = pgTable("comment", {
	cid: serial().notNull(),
	commentType: varchar("comment_type", { length: 32 }).notNull(),
	uuid: varchar({ length: 128 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
}, (table) => [
	index("comment__comment_field__comment_type__target_id__idx").using("btree", table.commentType.asc().nullsLast().op("text_ops")),
]);

export const commentFieldData = pgTable("comment_field_data", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	cid: bigint({ mode: "number" }).notNull(),
	commentType: varchar("comment_type", { length: 32 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	status: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	uid: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	pid: bigint({ mode: "number" }),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }),
	subject: varchar({ length: 64 }),
	name: varchar({ length: 60 }),
	mail: varchar({ length: 254 }),
	homepage: varchar({ length: 255 }),
	hostname: varchar({ length: 128 }),
	created: integer().notNull(),
	changed: integer(),
	thread: varchar({ length: 255 }).notNull(),
	entityType: varchar("entity_type", { length: 32 }).notNull(),
	fieldName: varchar("field_name", { length: 32 }).notNull(),
	defaultLangcode: smallint("default_langcode").notNull(),
}, (table) => [
	index("comment_field_data__comment__entity_langcode__idx").using("btree", table.entityId.asc().nullsLast().op("int2_ops"), table.entityType.asc().nullsLast().op("text_ops"), table.commentType.asc().nullsLast().op("text_ops"), table.defaultLangcode.asc().nullsLast().op("text_ops")),
	index("comment_field_data__comment__num_new__idx").using("btree", table.entityId.asc().nullsLast().op("int2_ops"), table.entityType.asc().nullsLast().op("int4_ops"), table.commentType.asc().nullsLast().op("int2_ops"), table.status.asc().nullsLast().op("int2_ops"), table.created.asc().nullsLast().op("int4_ops"), table.cid.asc().nullsLast().op("int4_ops"), table.thread.asc().nullsLast().op("int4_ops")),
	index("comment_field_data__comment__status_comment_type__idx").using("btree", table.status.asc().nullsLast().op("int8_ops"), table.commentType.asc().nullsLast().op("int2_ops"), table.cid.asc().nullsLast().op("int8_ops")),
	index("comment_field_data__comment__status_pid__idx").using("btree", table.pid.asc().nullsLast().op("int8_ops"), table.status.asc().nullsLast().op("int2_ops")),
	index("comment_field_data__comment_field__comment_type__target_id__idx").using("btree", table.commentType.asc().nullsLast().op("text_ops")),
	index("comment_field_data__comment_field__created__idx").using("btree", table.created.asc().nullsLast().op("int4_ops")),
	index("comment_field_data__comment_field__uid__target_id__idx").using("btree", table.uid.asc().nullsLast().op("int8_ops")),
	index("drupal_mOML8Q1mOpUaN8EQHtn4pIFZ9wK8gamkAI1iyADLZZ8_idx").using("btree", table.cid.asc().nullsLast().op("int8_ops"), table.defaultLangcode.asc().nullsLast().op("text_ops"), table.langcode.asc().nullsLast().op("int8_ops")),
]);

export const commentCommentBody = pgTable("comment__comment_body", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	commentBodyValue: text("comment_body_value").notNull(),
	commentBodyFormat: varchar("comment_body_format", { length: 255 }),
}, (table) => [
	index("comment__comment_body__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("comment__comment_body__comment_body_format__idx").using("btree", table.commentBodyFormat.asc().nullsLast().op("text_ops")),
	index("comment__comment_body__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const cacheContainer = pgTable("cache_container", {
	cid: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	created: numeric({ precision: 14, scale:  3 }).notNull(),
	serialized: smallint().notNull(),
	tags: text(),
	checksum: varchar({ length: 255 }).notNull(),
}, (table) => [
	index("cache_container__created__idx").using("btree", table.created.asc().nullsLast().op("numeric_ops")),
	index("cache_container__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
]);

export const localesSource = pgTable("locales_source", {
	lid: serial().notNull(),
	source: text().notNull(),
	context: varchar({ length: 255 }).notNull(),
	version: varchar({ length: 20 }).notNull(),
}, (table) => [
	index("locales_source__source_context__idx").using("btree", sql`substr(source, 1, 30)`, sql`context`),
]);

export const localesTarget = pgTable("locales_target", {
	lid: integer().notNull(),
	translation: text().notNull(),
	language: varchar({ length: 12 }).notNull(),
	customized: integer().notNull(),
}, (table) => [
	index("locales_target__lid__idx").using("btree", table.lid.asc().nullsLast().op("int4_ops")),
]);

export const localesLocation = pgTable("locales_location", {
	lid: serial().notNull(),
	sid: integer().notNull(),
	type: varchar({ length: 50 }).notNull(),
	name: varchar({ length: 255 }).notNull(),
	version: varchar({ length: 20 }).notNull(),
}, (table) => [
	index("locales_location__string_type__idx").using("btree", table.sid.asc().nullsLast().op("int4_ops"), table.type.asc().nullsLast().op("int4_ops")),
	index("locales_location__type_name__idx").using("btree", table.type.asc().nullsLast().op("text_ops"), table.name.asc().nullsLast().op("text_ops")),
]);

export const localeFile = pgTable("locale_file", {
	project: varchar({ length: 255 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	filename: varchar({ length: 255 }).notNull(),
	version: varchar({ length: 128 }).notNull(),
	uri: varchar({ length: 255 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	timestamp: bigint({ mode: "number" }),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	lastChecked: bigint("last_checked", { mode: "number" }),
});

export const history = pgTable("history", {
	uid: integer().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	nid: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	timestamp: bigint({ mode: "number" }).notNull(),
}, (table) => [
	index("history__nid__idx").using("btree", table.nid.asc().nullsLast().op("int8_ops")),
]);

export const taxonomyTermData = pgTable("taxonomy_term_data", {
	tid: serial().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }),
	vid: varchar({ length: 32 }).notNull(),
	uuid: varchar({ length: 128 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
}, (table) => [
	index("taxonomy_term_data__taxonomy_term_field__vid__target_id__idx").using("btree", table.vid.asc().nullsLast().op("text_ops")),
]);

export const taxonomyTermRevision = pgTable("taxonomy_term_revision", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	tid: bigint({ mode: "number" }).notNull(),
	revisionId: serial("revision_id").notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionUser: bigint("revision_user", { mode: "number" }),
	revisionCreated: integer("revision_created"),
	revisionLogMessage: text("revision_log_message"),
	revisionDefault: smallint("revision_default"),
}, (table) => [
	index("drupal_2wXmNkIidFb530o9_wbeLfe93ztt315H0_uG2d8WoFE_idx").using("btree", table.revisionUser.asc().nullsLast().op("int8_ops")),
	index("taxonomy_term_revision__taxonomy_term__tid__idx").using("btree", table.tid.asc().nullsLast().op("int8_ops")),
]);

export const taxonomyTermFieldData = pgTable("taxonomy_term_field_data", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	tid: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	vid: varchar({ length: 32 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	status: smallint().notNull(),
	name: varchar({ length: 255 }).notNull(),
	descriptionValue: text("description__value"),
	descriptionFormat: varchar("description__format", { length: 255 }),
	weight: integer().notNull(),
	changed: integer(),
	defaultLangcode: smallint("default_langcode").notNull(),
	revisionTranslationAffected: smallint("revision_translation_affected"),
}, (table) => [
	index("drupal_jVEqkc6s2d_YXyKzgPOmeuEYgeSndHxNyF_lQrsUBhg_idx").using("btree", table.tid.asc().nullsLast().op("int2_ops"), table.defaultLangcode.asc().nullsLast().op("int8_ops"), table.langcode.asc().nullsLast().op("int2_ops")),
	index("taxonomy_term_field_data__taxonomy_term__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
	index("taxonomy_term_field_data__taxonomy_term__status_vid__idx").using("btree", table.status.asc().nullsLast().op("int8_ops"), table.vid.asc().nullsLast().op("int2_ops"), table.tid.asc().nullsLast().op("text_ops")),
	index("taxonomy_term_field_data__taxonomy_term__tree__idx").using("btree", table.vid.asc().nullsLast().op("int4_ops"), table.weight.asc().nullsLast().op("int4_ops"), table.name.asc().nullsLast().op("text_ops")),
	index("taxonomy_term_field_data__taxonomy_term__vid_name__idx").using("btree", table.vid.asc().nullsLast().op("text_ops"), table.name.asc().nullsLast().op("text_ops")),
	index("taxonomy_term_field_data__taxonomy_term_field__name__idx").using("btree", table.name.asc().nullsLast().op("text_ops")),
]);

export const taxonomyTermFieldRevision = pgTable("taxonomy_term_field_revision", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	tid: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	status: smallint().notNull(),
	name: varchar({ length: 255 }),
	descriptionValue: text("description__value"),
	descriptionFormat: varchar("description__format", { length: 255 }),
	changed: integer(),
	defaultLangcode: smallint("default_langcode").notNull(),
	revisionTranslationAffected: smallint("revision_translation_affected"),
}, (table) => [
	index("drupal_M2Qup2oS2zlnKrlzxtyMPc4wpQTHO8bTW9QMuxZwsiQ_idx").using("btree", table.descriptionFormat.asc().nullsLast().op("text_ops")),
	index("drupal_zC5XUHi3lXvFlyilgI0NlNZth42DSBX5G_FjNgxVTGQ_idx").using("btree", table.tid.asc().nullsLast().op("int2_ops"), table.defaultLangcode.asc().nullsLast().op("int2_ops"), table.langcode.asc().nullsLast().op("int2_ops")),
]);

export const taxonomyIndex = pgTable("taxonomy_index", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	nid: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	tid: bigint({ mode: "number" }).notNull(),
	status: integer().notNull(),
	sticky: smallint(),
	created: integer().notNull(),
}, (table) => [
	index("taxonomy_index__term_node__idx").using("btree", table.tid.asc().nullsLast().op("int4_ops"), table.status.asc().nullsLast().op("int4_ops"), table.sticky.asc().nullsLast().op("int4_ops"), table.created.asc().nullsLast().op("int4_ops")),
]);

export const taxonomyTermParent = pgTable("taxonomy_term__parent", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	parentTargetId: bigint("parent_target_id", { mode: "number" }).notNull(),
}, (table) => [
	index("taxonomy_term__parent__bundle_delta_target_id__idx").using("btree", table.bundle.asc().nullsLast().op("int8_ops"), table.delta.asc().nullsLast().op("int8_ops"), table.parentTargetId.asc().nullsLast().op("text_ops")),
	index("taxonomy_term__parent__parent_target_id__idx").using("btree", table.parentTargetId.asc().nullsLast().op("int8_ops")),
	index("taxonomy_term__parent__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const taxonomyTermRevisionParent = pgTable("taxonomy_term_revision__parent", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	parentTargetId: bigint("parent_target_id", { mode: "number" }).notNull(),
}, (table) => [
	index("taxonomy_term_revision__parent__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("taxonomy_term_revision__parent__parent_target_id__idx").using("btree", table.parentTargetId.asc().nullsLast().op("int8_ops")),
	index("taxonomy_term_revision__parent__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const menuLinkContent = pgTable("menu_link_content", {
	id: serial().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }),
	bundle: varchar({ length: 32 }).notNull(),
	uuid: varchar({ length: 128 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
});

export const menuLinkContentRevision = pgTable("menu_link_content_revision", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).notNull(),
	revisionId: serial("revision_id").notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionUser: bigint("revision_user", { mode: "number" }),
	revisionCreated: integer("revision_created"),
	revisionLogMessage: text("revision_log_message"),
	revisionDefault: smallint("revision_default"),
}, (table) => [
	index("menu_link_content_revision__menu_link_content__ef029a1897__idx").using("btree", table.revisionUser.asc().nullsLast().op("int8_ops")),
	index("menu_link_content_revision__menu_link_content__id__idx").using("btree", table.id.asc().nullsLast().op("int8_ops")),
]);

export const menuLinkContentData = pgTable("menu_link_content_data", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	bundle: varchar({ length: 32 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	enabled: smallint().notNull(),
	title: varchar({ length: 255 }),
	description: varchar({ length: 255 }),
	menuName: varchar("menu_name", { length: 255 }),
	linkUri: varchar("link__uri", { length: 2048 }),
	linkTitle: varchar("link__title", { length: 255 }),
	// TODO: failed to parse database type 'bytea'
	linkOptions: bytea("link__options"),
	external: smallint(),
	rediscover: smallint(),
	weight: integer(),
	expanded: smallint(),
	parent: varchar({ length: 255 }),
	changed: integer(),
	defaultLangcode: smallint("default_langcode").notNull(),
	revisionTranslationAffected: smallint("revision_translation_affected"),
}, (table) => [
	index("drupal_mtiYLSRDGoU4931oeZ9cDY50TtJYeSgNur4s_gNPxF8_idx").using("btree", table.id.asc().nullsLast().op("int2_ops"), table.defaultLangcode.asc().nullsLast().op("int8_ops"), table.langcode.asc().nullsLast().op("int2_ops")),
	index("menu_link_content_data__menu_link_content__enabled_bundle__idx").using("btree", table.enabled.asc().nullsLast().op("text_ops"), table.bundle.asc().nullsLast().op("int8_ops"), table.id.asc().nullsLast().op("int8_ops")),
	index("menu_link_content_data__menu_link_content__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
	index("menu_link_content_data__menu_link_content_field__link__uri__idx").using("btree", sql`substr((link__uri)::text, 1, 30)`),
]);

export const menuLinkContentFieldRevision = pgTable("menu_link_content_field_revision", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	enabled: smallint().notNull(),
	title: varchar({ length: 255 }),
	description: varchar({ length: 255 }),
	linkUri: varchar("link__uri", { length: 2048 }),
	linkTitle: varchar("link__title", { length: 255 }),
	// TODO: failed to parse database type 'bytea'
	linkOptions: bytea("link__options"),
	external: smallint(),
	changed: integer(),
	defaultLangcode: smallint("default_langcode").notNull(),
	revisionTranslationAffected: smallint("revision_translation_affected"),
}, (table) => [
	index("drupal_L0k0k_zy6SEDoKs_R8suuvxbkHf_hZzMpkX6r42vlFg_idx").using("btree", table.id.asc().nullsLast().op("int2_ops"), table.defaultLangcode.asc().nullsLast().op("int8_ops"), table.langcode.asc().nullsLast().op("text_ops")),
	index("drupal_ui7U_4ySVsbBkDhd7CC2Cz97Yr_s3QEuF9xZI0mi1lA_idx").using("btree", sql`substr((link__uri)::text, 1, 30)`),
]);

export const shortcutSetUsers = pgTable("shortcut_set_users", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	uid: bigint({ mode: "number" }).notNull(),
	setName: varchar("set_name", { length: 32 }).notNull(),
}, (table) => [
	index("shortcut_set_users__set_name__idx").using("btree", table.setName.asc().nullsLast().op("text_ops")),
]);

export const shortcut = pgTable("shortcut", {
	id: serial().notNull(),
	shortcutSet: varchar("shortcut_set", { length: 32 }).notNull(),
	uuid: varchar({ length: 128 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
}, (table) => [
	index("shortcut__shortcut_field__shortcut_set__target_id__idx").using("btree", table.shortcutSet.asc().nullsLast().op("text_ops")),
]);

export const shortcutFieldData = pgTable("shortcut_field_data", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).notNull(),
	shortcutSet: varchar("shortcut_set", { length: 32 }).notNull(),
	langcode: varchar({ length: 12 }).notNull(),
	title: varchar({ length: 255 }),
	weight: integer(),
	linkUri: varchar("link__uri", { length: 2048 }),
	linkTitle: varchar("link__title", { length: 255 }),
	// TODO: failed to parse database type 'bytea'
	linkOptions: bytea("link__options"),
	defaultLangcode: smallint("default_langcode").notNull(),
}, (table) => [
	index("drupal_ZRb0RrR9ucQ_abrsOj5OqJZ6JHhecUX6qMxhEeLHDSA_idx").using("btree", table.shortcutSet.asc().nullsLast().op("text_ops")),
	index("drupal_yYznZkp1jjRq3ZidRMkkkawuQCmql0kdszvKsIMeEkU_idx").using("btree", table.id.asc().nullsLast().op("int2_ops"), table.defaultLangcode.asc().nullsLast().op("text_ops"), table.langcode.asc().nullsLast().op("int2_ops")),
	index("shortcut_field_data__shortcut_field__link__uri__idx").using("btree", sql`substr((link__uri)::text, 1, 30)`),
]);

export const router = pgTable("router", {
	name: varchar({ length: 255 }).notNull(),
	path: varchar({ length: 255 }).notNull(),
	patternOutline: varchar("pattern_outline", { length: 255 }).notNull(),
	fit: integer().notNull(),
	// TODO: failed to parse database type 'bytea'
	route: bytea("route"),
	numberParts: smallint("number_parts").notNull(),
}, (table) => [
	index("router__pattern_outline_parts__idx").using("btree", table.patternOutline.asc().nullsLast().op("int2_ops"), table.numberParts.asc().nullsLast().op("int2_ops")),
]);

export const menuTree = pgTable("menu_tree", {
	menuName: varchar("menu_name", { length: 32 }).notNull(),
	mlid: serial().notNull(),
	id: varchar({ length: 255 }).notNull(),
	parent: varchar({ length: 255 }).notNull(),
	routeName: varchar("route_name", { length: 255 }),
	routeParamKey: varchar("route_param_key", { length: 255 }),
	// TODO: failed to parse database type 'bytea'
	routeParameters: bytea("route_parameters"),
	url: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	title: bytea("title"),
	// TODO: failed to parse database type 'bytea'
	description: bytea("description"),
	class: text(),
	// TODO: failed to parse database type 'bytea'
	options: bytea("options"),
	provider: varchar({ length: 50 }).notNull(),
	enabled: smallint().notNull(),
	discovered: smallint().notNull(),
	expanded: smallint().notNull(),
	weight: integer().notNull(),
	// TODO: failed to parse database type 'bytea'
	metadata: bytea("metadata"),
	hasChildren: smallint("has_children").notNull(),
	depth: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	p1: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	p2: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	p3: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	p4: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	p5: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	p6: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	p7: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	p8: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	p9: bigint({ mode: "number" }).notNull(),
	formClass: varchar("form_class", { length: 255 }),
}, (table) => [
	index("menu_tree__menu_parent_expand_child__idx").using("btree", sql`menu_name`, sql`expanded`, sql`has_children`, sql`substr((parent)::text, 1, 16)`),
	index("menu_tree__menu_parents__idx").using("btree", table.menuName.asc().nullsLast().op("int8_ops"), table.p1.asc().nullsLast().op("text_ops"), table.p2.asc().nullsLast().op("int8_ops"), table.p3.asc().nullsLast().op("text_ops"), table.p4.asc().nullsLast().op("text_ops"), table.p5.asc().nullsLast().op("text_ops"), table.p6.asc().nullsLast().op("text_ops"), table.p7.asc().nullsLast().op("int8_ops"), table.p8.asc().nullsLast().op("text_ops"), table.p9.asc().nullsLast().op("text_ops")),
	index("menu_tree__route_values__idx").using("btree", sql`substr((route_name)::text, 1, 32)`, sql`substr((route_param_key)::text, 1, 16)`),
]);

export const nodeFieldImage = pgTable("node__field_image", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	fieldImageTargetId: bigint("field_image_target_id", { mode: "number" }).notNull(),
	fieldImageAlt: varchar("field_image_alt", { length: 512 }),
	fieldImageTitle: varchar("field_image_title", { length: 1024 }),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	fieldImageWidth: bigint("field_image_width", { mode: "number" }),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	fieldImageHeight: bigint("field_image_height", { mode: "number" }),
}, (table) => [
	index("node__field_image__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("node__field_image__field_image_target_id__idx").using("btree", table.fieldImageTargetId.asc().nullsLast().op("int8_ops")),
	index("node__field_image__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const nodeRevisionFieldImage = pgTable("node_revision__field_image", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	fieldImageTargetId: bigint("field_image_target_id", { mode: "number" }).notNull(),
	fieldImageAlt: varchar("field_image_alt", { length: 512 }),
	fieldImageTitle: varchar("field_image_title", { length: 1024 }),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	fieldImageWidth: bigint("field_image_width", { mode: "number" }),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	fieldImageHeight: bigint("field_image_height", { mode: "number" }),
}, (table) => [
	index("node_revision__field_image__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("node_revision__field_image__field_image_target_id__idx").using("btree", table.fieldImageTargetId.asc().nullsLast().op("int8_ops")),
	index("node_revision__field_image__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const nodeComment = pgTable("node__comment", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	commentStatus: integer("comment_status").notNull(),
}, (table) => [
	index("node__comment__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("node__comment__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const nodeRevisionComment = pgTable("node_revision__comment", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	commentStatus: integer("comment_status").notNull(),
}, (table) => [
	index("node_revision__comment__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("node_revision__comment__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const nodeFieldTags = pgTable("node__field_tags", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	fieldTagsTargetId: bigint("field_tags_target_id", { mode: "number" }).notNull(),
}, (table) => [
	index("node__field_tags__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("node__field_tags__field_tags_target_id__idx").using("btree", table.fieldTagsTargetId.asc().nullsLast().op("int8_ops")),
	index("node__field_tags__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const nodeRevisionFieldTags = pgTable("node_revision__field_tags", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	fieldTagsTargetId: bigint("field_tags_target_id", { mode: "number" }).notNull(),
}, (table) => [
	index("node_revision__field_tags__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("node_revision__field_tags__field_tags_target_id__idx").using("btree", table.fieldTagsTargetId.asc().nullsLast().op("int8_ops")),
	index("node_revision__field_tags__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
]);

export const userUserPicture = pgTable("user__user_picture", {
	bundle: varchar({ length: 128 }).notNull(),
	deleted: smallint().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	entityId: bigint("entity_id", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	revisionId: bigint("revision_id", { mode: "number" }).notNull(),
	langcode: varchar({ length: 32 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	delta: bigint({ mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	userPictureTargetId: bigint("user_picture_target_id", { mode: "number" }).notNull(),
	userPictureAlt: varchar("user_picture_alt", { length: 512 }),
	userPictureTitle: varchar("user_picture_title", { length: 1024 }),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	userPictureWidth: bigint("user_picture_width", { mode: "number" }),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	userPictureHeight: bigint("user_picture_height", { mode: "number" }),
}, (table) => [
	index("user__user_picture__bundle__idx").using("btree", table.bundle.asc().nullsLast().op("text_ops")),
	index("user__user_picture__revision_id__idx").using("btree", table.revisionId.asc().nullsLast().op("int8_ops")),
	index("user__user_picture__user_picture_target_id__idx").using("btree", table.userPictureTargetId.asc().nullsLast().op("int8_ops")),
]);

export const keyValueExpire = pgTable("key_value_expire", {
	collection: varchar({ length: 128 }).notNull(),
	name: varchar({ length: 128 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	value: bytea("value").notNull(),
	expire: integer().notNull(),
}, (table) => [
	index("key_value_expire__expire__idx").using("btree", table.expire.asc().nullsLast().op("int4_ops")),
]);

export const cacheConfig = pgTable("cache_config", {
	cid: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	created: numeric({ precision: 14, scale:  3 }).notNull(),
	serialized: smallint().notNull(),
	tags: text(),
	checksum: varchar({ length: 255 }).notNull(),
}, (table) => [
	index("cache_config__created__idx").using("btree", table.created.asc().nullsLast().op("numeric_ops")),
	index("cache_config__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
]);

export const cachetags = pgTable("cachetags", {
	tag: varchar({ length: 255 }).notNull(),
	invalidations: integer().notNull(),
});

export const cacheData = pgTable("cache_data", {
	cid: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	created: numeric({ precision: 14, scale:  3 }).notNull(),
	serialized: smallint().notNull(),
	tags: text(),
	checksum: varchar({ length: 255 }).notNull(),
}, (table) => [
	index("cache_data__created__idx").using("btree", table.created.asc().nullsLast().op("numeric_ops")),
	index("cache_data__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
]);

export const cacheBootstrap = pgTable("cache_bootstrap", {
	cid: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	created: numeric({ precision: 14, scale:  3 }).notNull(),
	serialized: smallint().notNull(),
	tags: text(),
	checksum: varchar({ length: 255 }).notNull(),
}, (table) => [
	index("cache_bootstrap__created__idx").using("btree", table.created.asc().nullsLast().op("numeric_ops")),
	index("cache_bootstrap__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
]);

export const cacheDiscovery = pgTable("cache_discovery", {
	cid: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	created: numeric({ precision: 14, scale:  3 }).notNull(),
	serialized: smallint().notNull(),
	tags: text(),
	checksum: varchar({ length: 255 }).notNull(),
}, (table) => [
	index("cache_discovery__created__idx").using("btree", table.created.asc().nullsLast().op("numeric_ops")),
	index("cache_discovery__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
]);

export const cacheAccessPolicy = pgTable("cache_access_policy", {
	cid: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	created: numeric({ precision: 14, scale:  3 }).notNull(),
	serialized: smallint().notNull(),
	tags: text(),
	checksum: varchar({ length: 255 }).notNull(),
}, (table) => [
	index("cache_access_policy__created__idx").using("btree", table.created.asc().nullsLast().op("numeric_ops")),
	index("cache_access_policy__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
]);

export const cacheDefault = pgTable("cache_default", {
	cid: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	created: numeric({ precision: 14, scale:  3 }).notNull(),
	serialized: smallint().notNull(),
	tags: text(),
	checksum: varchar({ length: 255 }).notNull(),
}, (table) => [
	index("cache_default__created__idx").using("btree", table.created.asc().nullsLast().op("numeric_ops")),
	index("cache_default__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
]);

export const semaphore = pgTable("semaphore", {
	name: varchar({ length: 255 }).notNull(),
	value: varchar({ length: 255 }).notNull(),
	expire: doublePrecision().notNull(),
}, (table) => [
	index("semaphore__expire__idx").using("btree", table.expire.asc().nullsLast().op("float8_ops")),
	index("semaphore__value__idx").using("btree", table.value.asc().nullsLast().op("text_ops")),
]);

export const cacheRender = pgTable("cache_render", {
	cid: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	created: numeric({ precision: 14, scale:  3 }).notNull(),
	serialized: smallint().notNull(),
	tags: text(),
	checksum: varchar({ length: 255 }).notNull(),
}, (table) => [
	index("cache_render__created__idx").using("btree", table.created.asc().nullsLast().op("numeric_ops")),
	index("cache_render__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
]);

export const cacheMenu = pgTable("cache_menu", {
	cid: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	created: numeric({ precision: 14, scale:  3 }).notNull(),
	serialized: smallint().notNull(),
	tags: text(),
	checksum: varchar({ length: 255 }).notNull(),
}, (table) => [
	index("cache_menu__created__idx").using("btree", table.created.asc().nullsLast().op("numeric_ops")),
	index("cache_menu__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
]);

export const cacheEntity = pgTable("cache_entity", {
	cid: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	created: numeric({ precision: 14, scale:  3 }).notNull(),
	serialized: smallint().notNull(),
	tags: text(),
	checksum: varchar({ length: 255 }).notNull(),
}, (table) => [
	index("cache_entity__created__idx").using("btree", table.created.asc().nullsLast().op("numeric_ops")),
	index("cache_entity__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
]);

export const cacheDynamicPageCache = pgTable("cache_dynamic_page_cache", {
	cid: varchar({ length: 255 }).notNull(),
	// TODO: failed to parse database type 'bytea'
	data: bytea("data"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	expire: bigint({ mode: "number" }).notNull(),
	created: numeric({ precision: 14, scale:  3 }).notNull(),
	serialized: smallint().notNull(),
	tags: text(),
	checksum: varchar({ length: 255 }).notNull(),
}, (table) => [
	index("cache_dynamic_page_cache__created__idx").using("btree", table.created.asc().nullsLast().op("numeric_ops")),
	index("cache_dynamic_page_cache__expire__idx").using("btree", table.expire.asc().nullsLast().op("int8_ops")),
]);

export const banIp = pgTable("ban_ip", {
	iid: serial().notNull(),
	ip: varchar({ length: 40 }).notNull(),
}, (table) => [
	index("ban_ip__ip__idx").using("btree", table.ip.asc().nullsLast().op("text_ops")),
]);

export const inlineBlockUsage = pgTable("inline_block_usage", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	blockContentId: bigint("block_content_id", { mode: "number" }).notNull(),
	layoutEntityType: varchar("layout_entity_type", { length: 32 }),
	layoutEntityId: varchar("layout_entity_id", { length: 128 }),
}, (table) => [
	index("inline_block_usage__type_id__idx").using("btree", table.layoutEntityType.asc().nullsLast().op("text_ops"), table.layoutEntityId.asc().nullsLast().op("text_ops")),
]);
