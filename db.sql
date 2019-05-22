DROP TABLE IF EXISTS core_users CASCADE;
DROP TABLE IF EXISTS core_usr_notifications CASCADE;
DROP TABLE IF EXISTS core_trees CASCADE;
DROP TABLE IF EXISTS core_tre_levels CASCADE;
DROP TABLE IF EXISTS core_tre_units CASCADE;
DROP TABLE IF EXISTS core_currencies CASCADE;
DROP TABLE IF EXISTS core_cry_rates CASCADE;
DROP TABLE IF EXISTS core_config_languages CASCADE;
DROP TABLE IF EXISTS core_groups CASCADE;
DROP TABLE IF EXISTS core_grp_permissions CASCADE;
DROP TABLE IF EXISTS core_groups_users CASCADE;
DROP TABLE IF EXISTS core_schemas CASCADE;
DROP TABLE IF EXISTS core_sch_followers CASCADE;
DROP TABLE IF EXISTS core_schemas_modules CASCADE;
DROP TABLE IF EXISTS core_lookups CASCADE;
DROP TABLE IF EXISTS core_lkp_options CASCADE;
DROP TABLE IF EXISTS core_sch_fields CASCADE;
DROP TABLE IF EXISTS core_sch_fld_validations CASCADE;
DROP TABLE IF EXISTS core_widgets CASCADE;
DROP TABLE IF EXISTS core_sch_pages CASCADE;
DROP TABLE IF EXISTS core_sch_views CASCADE;
DROP TABLE IF EXISTS core_views_pages CASCADE;
DROP TABLE IF EXISTS core_sch_pag_sections CASCADE;
DROP TABLE IF EXISTS core_sch_pag_sec_tabs CASCADE;
DROP TABLE IF EXISTS core_sch_pag_cnt_structures CASCADE;
DROP TABLE IF EXISTS core_translations CASCADE;
DROP TABLE IF EXISTS core_jobs CASCADE;
DROP TABLE IF EXISTS core_jobs_followers CASCADE;
DROP TABLE IF EXISTS core_job_tasks CASCADE;
DROP TABLE IF EXISTS core_job_instances CASCADE;
DROP TABLE IF EXISTS core_job_task_instances CASCADE;
DROP TABLE IF EXISTS core_services CASCADE;
DROP TABLE IF EXISTS core_system_params CASCADE;
DROP VIEW IF EXISTS core_v_user_groups CASCADE;
DROP VIEW IF EXISTS core_v_group_users CASCADE;
DROP VIEW IF EXISTS core_v_users_and_groups CASCADE;
DROP VIEW IF EXISTS core_v_sch_modules CASCADE;
DROP VIEW IF EXISTS core_v_job_followers CASCADE;
DROP VIEW IF EXISTS core_v_job_instance CASCADE;
DROP VIEW IF EXISTS core_v_job_task_instance CASCADE;
DROP VIEW IF EXISTS core_v_fields_by_permission CASCADE;

CREATE TABLE core_users (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  username CHARACTER VARYING NOT NULL,
  first_name CHARACTER VARYING NOT NULL,
  last_name CHARACTER VARYING NOT NULL,
  email CHARACTER VARYING NOT NULL,
  receive_emails CHARACTER VARYING NOT NULL,
  password CHARACTER VARYING NOT NULL,
  language_code CHARACTER VARYING NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(username)
);

CREATE TABLE core_usr_notifications (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  user_id CHARACTER VARYING NOT NULL,
  structure_id CHARACTER VARYING NOT NULL,
  structure_type CHARACTER VARYING NOT NULL,
  scope CHARACTER VARYING NOT NULL,
  message_action CHARACTER VARYING NOT NULL,
  link CHARACTER VARYING NOT NULL,
  sender CHARACTER VARYING NOT NULL,
  message_text CHARACTER VARYING NOT NULL,
  acknowledged BOOLEAN DEFAULT FALSE,
  email_sent BOOLEAN DEFAULT FALSE,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE core_trees (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_tre_levels (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  tree_id CHARACTER VARYING NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_tre_units (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  tree_id CHARACTER VARYING NOT NULL,
  parent_id CHARACTER VARYING,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(tree_id, code)
);

CREATE TABLE core_currencies (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_cry_rates (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  from_currency_id CHARACTER VARYING NOT NULL,
  to_currency_id CHARACTER VARYING NOT NULL,
  from_currency_code CHARACTER VARYING NOT NULL,
  to_currency_code CHARACTER VARYING NOT NULL,
  value integer NOT NULL,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ, 
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE core_config_languages (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_groups (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_grp_permissions (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  group_id CHARACTER VARYING NOT NULL,
  structure_type CHARACTER VARYING NOT NULL,
  structure_id CHARACTER VARYING NOT NULL,
  permission_type integer NOT NULL,
  condition_query CHARACTER VARYING,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE core_groups_users (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  user_id CHARACTER VARYING NOT NULL,
  group_id CHARACTER VARYING NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(user_id, group_id)
);

CREATE TABLE core_schemas (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  job_id CHARACTER VARYING,
  code CHARACTER VARYING NOT NULL,
  module BOOLEAN DEFAULT FALSE NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  status CHARACTER VARYING DEFAULT 'processing' NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_sch_followers (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,	
  schema_id CHARACTER VARYING NOT NULL,
  schema_instance_id CHARACTER VARYING NOT NULL,
  user_id CHARACTER VARYING NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(schema_id, schema_instance_id, user_id)
);

CREATE TABLE core_schemas_modules (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  schema_id CHARACTER VARYING NOT NULL,
  module_id CHARACTER VARYING NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(schema_id, module_id)
);

CREATE TABLE core_lookups (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  type CHARACTER VARYING NOT NULL,
  query CHARACTER VARYING,
  value CHARACTER VARYING NOT NULL,
  label CHARACTER VARYING NOT NULL,
  autocomplete CHARACTER VARYING,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_lkp_options (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  lookup_id CHARACTER VARYING NOT NULL,
  value CHARACTER VARYING NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(lookup_id, code)
);

CREATE TABLE core_sch_fields (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  schema_id CHARACTER VARYING NOT NULL,
  field_type CHARACTER VARYING NOT NULL,
  multivalue BOOLEAN,
  lookup_id CHARACTER VARYING,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(schema_id, code)
);

CREATE TABLE core_sch_fld_validations (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  schema_id CHARACTER VARYING NOT NULL,
  field_id CHARACTER VARYING NOT NULL,
  validation CHARACTER VARYING NOT NULL,
  valid_when CHARACTER VARYING,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE core_widgets (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  query CHARACTER VARYING NOT NULL,
  widget_type CHARACTER VARYING NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_sch_pages (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  schema_id CHARACTER VARYING NOT NULL,
  page_type CHARACTER VARYING NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(schema_id, code)
);

CREATE TABLE core_sch_views (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  schema_id CHARACTER VARYING NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(schema_id, code)
);

CREATE TABLE core_views_pages (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  view_id CHARACTER VARYING NOT NULL,
  page_id CHARACTER VARYING NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(view_id, page_id)
);

CREATE TABLE core_sch_pag_sections (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  schema_id CHARACTER VARYING NOT NULL,
  page_id CHARACTER VARYING NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(schema_id, page_id, code)
);

CREATE TABLE core_sch_pag_sec_tabs (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  schema_id CHARACTER VARYING NOT NULL,
  page_id CHARACTER VARYING NOT NULL,
  section_id CHARACTER VARYING NOT NULL,
  tab_order integer NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(schema_id, page_id, section_id, code)
);

CREATE TABLE core_sch_pag_cnt_structures ( -- core_sch_pag_containers_structures
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  schema_id CHARACTER VARYING NOT NULL,
  page_id CHARACTER VARYING NOT NULL,
  container_id CHARACTER VARYING NOT NULL,
  container_type CHARACTER VARYING NOT NULL,
  structure_id CHARACTER VARYING NOT NULL,
  structure_type CHARACTER VARYING NOT NULL,
  position_row integer NOT NULL,
  position_column integer NOT NULL,
  width integer NOT NULL,
  height integer NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(schema_id, page_id, container_id, container_type, structure_id, structure_type)
);

CREATE TABLE core_translations (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  structure_type CHARACTER VARYING NOT NULL,
  structure_id CHARACTER VARYING NOT NULL,
  structure_field CHARACTER VARYING NOT NULL,
  value CHARACTER VARYING NOT NULL,
  language_code CHARACTER VARYING NOT NULL,
  replicated BOOLEAN DEFAULT FALSE NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(structure_type, structure_id, structure_field, language_code)
);

CREATE TABLE core_jobs (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING,
  job_type CHARACTER VARYING NOT NULL, --system, user
  parameters JSONB,
  exec_timeout INTEGER NOT NULL DEFAULT 60,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_jobs_followers (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,	
  job_id CHARACTER VARYING NOT NULL,
  follower_id CHARACTER VARYING NOT NULL,
  follower_type CHARACTER VARYING NOT NULL, --group, user
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(job_id, follower_id, follower_type)
);

CREATE TABLE core_job_tasks (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING,
  job_id CHARACTER VARYING NOT NULL,
  task_sequence INTEGER NOT NULL DEFAULT 0,  
  exec_timeout INTEGER NOT NULL DEFAULT 60,
  parent_id CHARACTER VARYING NOT NULL,
  parameters JSONB,
  exec_action CHARACTER VARYING NOT NULL, --exec_query, api_post, api_get, api_delete, api_patch
  exec_address CHARACTER VARYING NOT NULL, --/api/v1/schema/{parent_id}/page
  exec_payload CHARACTER VARYING,
  action_on_fail CHARACTER VARYING NOT NULL, --continue, retry_and_continue, cancel, retry_and_cancel, rollback, retry_and_rollback
  max_retry_attempts INTEGER DEFAULT 2,
  rollback_action CHARACTER VARYING, --drop table, api_delete
  rollback_address CHARACTER VARYING, --/api/v1/schema/{parent_id}/fields/{field_id}
  rollback_payload CHARACTER VARYING,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(job_id, code)
);

CREATE TABLE core_job_instances (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  job_id CHARACTER VARYING NOT NULL,
  service_id CHARACTER VARYING,
  exec_timeout INTEGER NOT NULL DEFAULT 60,
  parameters JSONB,
  status CHARACTER VARYING NOT NULL,
  start_at TIMESTAMPTZ,
  finish_at TIMESTAMPTZ,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE core_job_task_instances (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  job_instance_id CHARACTER VARYING NOT NULL,
  task_id CHARACTER VARYING NOT NULL,
  code CHARACTER VARYING NOT NULL,
  status CHARACTER VARYING NOT NULL, -- created, processing, concluded, warning, fail
  start_at TIMESTAMPTZ,
  finish_at TIMESTAMPTZ,
  task_sequence INTEGER NOT NULL DEFAULT 0,
  exec_timeout INTEGER NOT NULL DEFAULT 60,
  parent_id CHARACTER VARYING NOT NULL,
  parameters JSONB,
  exec_action CHARACTER VARYING NOT NULL, --exec_query, api_post, api_get, api_delete, api_patch
  exec_address CHARACTER VARYING NOT NULL, --/api/v1/schema/{parent_id}/page
  exec_payload CHARACTER VARYING NOT NULL,
  exec_response CHARACTER VARYING,
  action_on_fail CHARACTER VARYING NOT NULL, --continue, retry_and_continue, cancel, retry_and_cancel, rollback, retry_and_rollback
  max_retry_attempts INTEGER DEFAULT 2,
  rollback_action CHARACTER VARYING, --drop table, api_delete
  rollback_address CHARACTER VARYING, --/api/v1/schema/{parent_id}/fields/{field_id}
  rollback_payload CHARACTER VARYING,
  rollback_response CHARACTER VARYING,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(job_instance_id, task_id)
);

CREATE TABLE core_services (
	id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
	code CHARACTER VARYING NOT NULL,
	service_type CHARACTER VARYING NOT NULL, -- module, aux, external
	heartbeat_at TIMESTAMPTZ NOT NULL,
	registered_at TIMESTAMPTZ NOT NULL,
	active BOOLEAN,
	PRIMARY KEY(id),
	UNIQUE(code)
);

CREATE TABLE core_system_params (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  param_key CHARACTER VARYING NOT NULL,
  param_value CHARACTER VARYING NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(param_key)
);

CREATE VIEW core_v_user_groups AS
  SELECT
    core_groups.id AS id,
    core_groups_users.user_id AS user_id,
    core_groups.code AS code,
    core_translations_name.value AS name,
    core_translations_description.value AS description,
    core_translations_name.language_code AS language_code,
    core_groups.active AS active,
    core_groups.created_by AS created_by,
    core_groups.created_at AS created_at,
    core_groups.updated_by AS updated_by,
    core_groups.updated_at AS updated_at
  FROM core_groups
  JOIN core_groups_users
  ON core_groups_users.group_id = core_groups.id
  JOIN core_translations core_translations_name
  ON core_translations_name.structure_id = core_groups.id
  AND core_translations_name.structure_field = 'name'
  JOIN core_translations core_translations_description
  ON core_translations_description.structure_id = core_groups.id
  AND core_translations_description.structure_field = 'description'
  WHERE core_translations_name.language_code = core_translations_description.language_code;

CREATE VIEW core_v_group_users AS
  SELECT
    core_users.id AS id,
    core_groups_users.group_id AS group_id,
    core_users.username AS username,
    core_users.first_name AS first_name,
    core_users.last_name AS last_name,
    core_users.email AS email,
    core_users.password AS password,
    core_users.language_code AS language_code,
    core_users.active AS active,
    core_users.created_by AS created_by,
    core_users.created_at AS created_at,
    core_users.updated_by AS updated_by,
    core_users.updated_at AS updated_at
  FROM core_users
  JOIN core_groups_users
  ON core_groups_users.user_id = core_users.id;

CREATE VIEW core_v_users_and_groups AS 
  SELECT * FROM (
    SELECT
      core_users.id AS id,
      core_users.first_name || ' ' || core_users.last_name AS name,
      NULL AS language_code,
      'user' AS ug_type,
      core_users.active AS active,
      core_users.created_by AS created_by,
      core_users.created_at AS created_at,
      core_users.updated_by AS updated_by,
      core_users.updated_at AS updated_at  
    FROM core_users
  ) AS users
  UNION ALL
  SELECT * FROM (
    SELECT
      core_groups.id AS id,
      core_translations_name.value AS name,
      core_translations_name.language_code AS language_code,
      'group' AS ug_type,
      core_groups.active AS active,
      core_groups.created_by AS created_by,
      core_groups.created_at AS created_at,
      core_groups.updated_by AS updated_by,
      core_groups.updated_at AS updated_at
    FROM core_groups
    JOIN core_translations core_translations_name
    ON core_translations_name.structure_id = core_groups.id
    AND core_translations_name.structure_field = 'name'
  ) AS groups;

CREATE VIEW core_v_sch_modules AS
  SELECT
    core_schemas.id AS id,
    core_schemas_modules.schema_id AS schema_id,
    core_schemas.code AS code,
    core_translations_name.value AS name,
    core_translations_description.value AS description,
    core_translations_name.language_code AS language_code,
    core_schemas.module AS module,
    core_schemas.active AS active,
    core_schemas.created_by AS created_by,
    core_schemas.created_at AS created_at,
    core_schemas.updated_by AS updated_by,
    core_schemas.updated_at AS updated_at
  FROM core_schemas
  JOIN core_translations AS core_translations_name
  ON core_translations_name.structure_id = core_schemas.id
  and core_translations_name.structure_field = 'name'
  JOIN core_translations AS core_translations_description
  ON core_translations_description.structure_id = core_schemas.id
  and core_translations_description.structure_field = 'description'
  JOIN core_schemas_modules ON core_schemas_modules.module_id = core_schemas.id
  WHERE core_translations_name.language_code =  core_translations_description.language_code;

CREATE VIEW core_v_job_followers AS 
  SELECT
    ug.id AS id,
    followers.job_id AS job_id,
    ug.name AS name,
    ug.language_code AS language_code,
    ug.ug_type AS follower_type,
    ug.active AS active,
    followers.created_by AS created_by,
    followers.created_at AS created_at,
    followers.updated_by AS updated_by,
    followers.updated_at AS updated_at
  FROM core_jobs_followers AS followers
  JOIN core_v_users_and_groups AS ug
  ON ug.id = followers.follower_id
  AND ug.ug_type = followers.follower_type;

CREATE VIEW core_v_job_instance AS
  SELECT
    core_job_instances.id AS id,
    core_jobs.id AS job_id,
    core_job_instances.code AS code,
    core_translations_name.value AS name,
    core_translations_description.value AS description,
    core_translations_name.language_code AS language_code,
    core_jobs.job_type AS job_type,
    core_job_instances.exec_timeout AS exec_timeout,
    core_job_instances.parameters AS parameters,
    core_job_instances.status AS status,
    core_job_instances.start_at AS start_at,
    core_job_instances.finish_at AS finish_at,
    core_job_instances.created_by AS created_by,
    core_job_instances.created_at AS created_at,
    core_job_instances.updated_by AS updated_by,
    core_job_instances.updated_at AS updated_at
  FROM core_jobs
  JOIN core_job_instances
  ON core_job_instances.job_id = core_jobs.id
  JOIN core_translations core_translations_name
  ON core_translations_name.structure_id = core_jobs.id
  AND core_translations_name.structure_field = 'name'
  JOIN core_translations core_translations_description
  ON core_translations_description.structure_id = core_jobs.id
  AND core_translations_description.structure_field = 'description'
  WHERE core_translations_name.language_code = core_translations_description.language_code;

CREATE VIEW core_v_job_task_instance AS
  SELECT
    core_job_task_instances.id AS id,
    core_job_tasks.id AS task_id,
    core_job_tasks.job_id AS job_id,
    core_job_task_instances.job_instance_id AS job_instance_id,
    core_job_task_instances.code AS code,
    core_translations_name.value AS name,
    core_translations_description.value AS description,
    core_translations_name.language_code AS language_code,
    core_job_task_instances.status AS status,
    core_job_task_instances.start_at AS start_at,
    core_job_task_instances.finish_at AS finish_at,
    core_job_task_instances.task_sequence AS task_sequence,
    core_job_task_instances.exec_timeout AS exec_timeout,
    core_job_task_instances.parameters AS parameters,
    core_job_task_instances.parent_id AS parent_id,
    core_job_task_instances.exec_action AS exec_action,
    core_job_task_instances.exec_address AS exec_address,
    core_job_task_instances.exec_payload AS exec_payload,
    core_job_task_instances.exec_response AS exec_response,
    core_job_task_instances.action_on_fail AS action_on_fail,
    core_job_task_instances.max_retry_attempts AS max_retry_attempts,
    core_job_task_instances.rollback_action AS rollback_action,
    core_job_task_instances.rollback_address AS rollback_address,
    core_job_task_instances.rollback_payload AS rollback_payload,
    core_job_task_instances.rollback_response AS rollback_response,
    core_job_task_instances.created_by AS created_by,
    core_job_task_instances.created_at AS created_at,
    core_job_task_instances.updated_by AS updated_by,
    core_job_task_instances.updated_at AS updated_at
  FROM core_job_tasks
  JOIN core_job_task_instances
  ON core_job_task_instances.task_id = core_job_tasks.id
  JOIN core_translations core_translations_name
  ON core_translations_name.structure_id = core_job_tasks.id
  AND core_translations_name.structure_field = 'name'
  JOIN core_translations core_translations_description
  ON core_translations_description.structure_id = core_job_tasks.id
  AND core_translations_description.structure_field = 'description'
  WHERE core_translations_name.language_code = core_translations_description.language_code;

CREATE VIEW core_v_fields_by_permission AS
  SELECT
    f.id AS id,
    f.schema_id AS schema_id,
    s.code AS schema_code,
    ug.user_id AS user_id,
    f.code AS code,
    translations_name.value AS name,
    translations_description.value AS description,
    f.field_type AS field_type,
    f.multivalue AS multivalue,
    f.lookup_id AS lookup_id,
    f.active AS active,
    translations_name.language_code AS language_code,
    max(gp.permission_type) permission
  FROM core_groups_users ug
  JOIN core_groups g
  ON g.id = ug.group_id
  JOIN core_grp_permissions gp
  ON gp.group_id = ug.group_id
  JOIN core_sch_fields f
  ON f.id = gp.structure_id
  AND gp.structure_type = 'field'
  JOIN core_schemas s
  ON s.id = f.schema_id
  JOIN core_translations translations_name
  ON translations_name.structure_id = f.id
  AND translations_name.structure_field = 'name'
  JOIN core_translations translations_description
  ON translations_description.structure_id = f.id
  AND translations_description.structure_field = 'description'
  WHERE f.active = true
  AND g.active = true
  AND translations_name.language_code = translations_description.language_code
  GROUP BY
    f.id,
    f.schema_id,
    s.code,
    ug.user_id,
    f.code,
    translations_name.value,
    translations_description.value,
    f.field_type,
    f.multivalue,
    f.lookup_id,
    f.active,
    translations_name.language_code;

INSERT INTO core_users(
  id,
  username,
  first_name,
  last_name,
  email,
  password,
  language_code,
  active,
  created_by,
  created_at,
  updated_by,
  updated_at
)
VALUES (
  '307e481c-69c5-11e9-96a0-06ea2c43bb20',
  'admin',
  'Administrator',
  'System',
  'admin@domain.com',
  '123456',
  'pt-br',
  true,
  '307e481c-69c5-11e9-96a0-06ea2c43bb20',
  '2019-04-23 15:30:36.480864',
  '307e481c-69c5-11e9-96a0-06ea2c43bb20',
  '2019-04-23 15:30:36.480864'
);

INSERT INTO core_config_languages(
  id,
  code,
  active,
  created_by,
  created_at,
  updated_by,
  updated_at
)
VALUES (
  '9b09866a-69c5-11e9-96a1-06ea2c43bb20',
  'pt-br',
  true,
  '307e481c-69c5-11e9-96a0-06ea2c43bb20',
  '2019-04-23 15:30:36.480864',
  '307e481c-69c5-11e9-96a0-06ea2c43bb20',
  '2019-04-23 15:30:36.480864'
);

INSERT INTO core_translations(
  id,
  structure_type,
  structure_id,
  structure_field,
  value,
  language_code
)
VALUES (
  'ff1d2822-69c6-11e9-92d9-06ea2c43bb20',
  'core_config_languages',
  '9b09866a-69c5-11e9-96a1-06ea2c43bb20',
  'name',
  'Português do Brasil',
  'pt-br'
);

CREATE OR REPLACE FUNCTION trg_func_replic_translations() RETURNS TRIGGER AS $$
  DECLARE
    from_lang TEXT := 'pt-br';
  BEGIN
    INSERT INTO core_translations (
      structure_type,
      structure_id,
      structure_field,
      value,
      language_code,
      replicated
    )
    SELECT
      structure_type,
      structure_id,
      structure_field,
      value,
      NEW.code AS language_code,
      true
    FROM core_translations
    WHERE
      language_code = from_lang;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_func_delete_translations() RETURNS TRIGGER AS $$
  BEGIN
    DELETE FROM core_translations WHERE language_code = NEW.code;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_replica_translations
  AFTER UPDATE ON core_config_languages
    FOR EACH ROW
      WHEN (NEW.active != OLD.active AND NEW.active = true)
        EXECUTE PROCEDURE trg_func_replic_translations();

CREATE TRIGGER trg_delete_translations
  AFTER UPDATE ON core_config_languages
    FOR EACH ROW
      WHEN (NEW.active != OLD.active AND NEW.active = false)
        EXECUTE PROCEDURE trg_func_delete_translations();

CREATE OR REPLACE FUNCTION trg_func_replic_new_translation() RETURNS TRIGGER AS $$
  BEGIN
    INSERT INTO core_translations (
      structure_type,
      structure_id,
      structure_field,
      value,
      language_code,
      replicated
    )
    SELECT
      NEW.structure_type AS structure_type,
      NEW.structure_id AS structure_id,
      NEW.structure_field AS structure_field,
      NEW.value AS value,
      code,
      true AS replicated
    FROM core_config_languages
    WHERE
      active = true
    AND
      code != NEW.language_code;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_replica_new_translations
  AFTER INSERT ON core_translations
    FOR EACH ROW
      WHEN (NEW.replicated = false)
        EXECUTE PROCEDURE trg_func_replic_new_translation();

CREATE OR REPLACE FUNCTION trg_func_set_end_currency_rate() RETURNS TRIGGER AS $$
  BEGIN
    UPDATE core_cry_rates
    SET
      end_at = NEW.start_at,
      updated_by = NEW.created_by,
      updated_at = NEW.created_at
    WHERE id = (
      SELECT
        id
      FROM core_cry_rates
      WHERE
        id != NEW.id
        AND from_currency_code = NEW.from_currency_code
        AND to_currency_code = NEW.to_currency_code
      ORDER BY
        id desc
      LIMIT 1
    );
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_end_currency_rate
  AFTER INSERT ON core_cry_rates
    FOR EACH ROW
      EXECUTE PROCEDURE trg_func_set_end_currency_rate();

CREATE OR REPLACE FUNCTION trg_func_replic_job_task_to_instances() RETURNS TRIGGER AS $$
  BEGIN
    INSERT INTO core_job_task_instances (
      task_id,
      code,
      job_instance_id,
      status,
      start_at,
      finish_at,
      task_sequence,
      exec_timeout,
      parent_id,
      parameters,
      exec_action,
      exec_address,
      exec_payload,
      exec_response,
      action_on_fail,
      max_retry_attempts,
      rollback_action,
      rollback_address,
      rollback_payload,
      rollback_response,
      created_by,
      updated_by,
      created_at,
      updated_at
    )
    SELECT
      id AS task_id,
      code AS code,
      NEW.id AS job_instance_id,
      'created' AS status,
      NULL AS start_at,
      NULL AS finish_at,
      task_sequence AS task_sequence,
      exec_timeout AS exec_timeout,
      parent_id AS parent_id,
      parameters AS parameters,
      exec_action AS exec_action,
      exec_address AS exec_address,
      exec_payload AS exec_payload,
      NULL AS exec_response,
      action_on_fail AS action_on_fail,
      max_retry_attempts AS max_retry_attempts,
      rollback_action AS rollback_action,
      rollback_address AS rollback_address,
      rollback_payload AS rollback_payload,
      NULL AS rollback_response,
      NEW.created_by AS created_by,
      NEW.updated_by AS updated_by,
      NEW.updated_at AS updated_at,
      NEW.created_at AS created_at
    FROM core_job_tasks
    WHERE
      job_id = NEW.job_id;

    UPDATE core_job_instances SET status = 'created', updated_at = NOW() WHERE id = NEW.id;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_replic_job_task_to_instances
  AFTER INSERT ON core_job_instances
    FOR EACH ROW
      EXECUTE PROCEDURE trg_func_replic_job_task_to_instances();

-- ALTER TABLE "core_trees" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_trees" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_tre_levels" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_tre_levels" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_tre_units" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_tre_units" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_tre_units" ADD FOREIGN KEY ("parent_id") REFERENCES "core_tre_units" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_currencies" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_currencies" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_cry_rates" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_cry_rates" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_cry_rates" ADD FOREIGN KEY ("currency_id") REFERENCES "core_currencies" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_config_languages" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_config_languages" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_users" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_users" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_groups" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_groups" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_grp_permissions" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_grp_permissions" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_grp_permissions" ADD FOREIGN KEY ("group_id") REFERENCES "core_groups" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_groups_users" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_groups_users" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_groups_users" ADD FOREIGN KEY ("user_id") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_groups_users" ADD FOREIGN KEY ("group_id") REFERENCES "core_groups" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_schemas" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_schemas" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_schemas_modules" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_schemas_modules" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_schemas_modules" ADD FOREIGN KEY ("schema_id") REFERENCES "core_schemas" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_schemas_modules" ADD FOREIGN KEY ("module_id") REFERENCES "core_schemas" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_lookups" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_lookups" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_lkp_options" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_lkp_options" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_lkp_options" ADD FOREIGN KEY ("lookup_id") REFERENCES "core_lookups" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_fields" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_fields" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_fields" ADD FOREIGN KEY ("schema_id") REFERENCES "core_schemas" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_fields" ADD FOREIGN KEY ("lookup_id") REFERENCES "core_lookups" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_fld_validations" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_fld_validations" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_fld_validations" ADD FOREIGN KEY ("schema_id") REFERENCES "core_schemas" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_fld_validations" ADD FOREIGN KEY ("field_id") REFERENCES "core_sch_fields" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_widgets" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_widgets" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pages" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pages" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pages" ADD FOREIGN KEY ("schema_id") REFERENCES "core_schemas" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_views" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_views" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_views" ADD FOREIGN KEY ("schema_id") REFERENCES "core_schemas" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_views_pages" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_views_pages" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_views_pages" ADD FOREIGN KEY ("view_id") REFERENCES "core_sch_views" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_views_pages" ADD FOREIGN KEY ("page_id") REFERENCES "core_sch_pages" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_sections" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_sections" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_sections" ADD FOREIGN KEY ("schema_id") REFERENCES "core_schemas" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_sections" ADD FOREIGN KEY ("page_id") REFERENCES "core_sch_pages" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_sec_tabs" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_sec_tabs" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_sec_tabs" ADD FOREIGN KEY ("schema_id") REFERENCES "core_schemas" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_sec_tabs" ADD FOREIGN KEY ("page_id") REFERENCES "core_sch_pages" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_sec_tabs" ADD FOREIGN KEY ("section_id") REFERENCES "core_sch_pag_sections" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_cnt_structures" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_cnt_structures" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_cnt_structures" ADD FOREIGN KEY ("schema_id") REFERENCES "core_schemas" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_sch_pag_cnt_structures" ADD FOREIGN KEY ("page_id") REFERENCES "core_sch_pages" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_translations" ADD FOREIGN KEY ("created_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;
-- ALTER TABLE "core_translations" ADD FOREIGN KEY ("updated_by") REFERENCES "core_users" ("id") ON DELETE CASCADE;