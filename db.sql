DROP TABLE IF EXISTS core_users CASCADE;
DROP TABLE IF EXISTS core_config_languages CASCADE;
DROP TABLE IF EXISTS core_trees CASCADE;
DROP TABLE IF EXISTS core_tree_levels CASCADE;
DROP TABLE IF EXISTS core_tree_units CASCADE;
DROP TABLE IF EXISTS core_currencies CASCADE;
DROP TABLE IF EXISTS core_groups CASCADE;
DROP TABLE IF EXISTS core_datasets CASCADE;
DROP TABLE IF EXISTS core_schemas CASCADE;
DROP TABLE IF EXISTS core_schema_fields CASCADE;
DROP TABLE IF EXISTS core_jobs CASCADE;
DROP TABLE IF EXISTS core_job_tasks CASCADE;
DROP TABLE IF EXISTS core_job_instances CASCADE;
DROP TABLE IF EXISTS core_job_task_instances CASCADE;
DROP TABLE IF EXISTS core_system_params CASCADE;
DROP TABLE IF EXISTS core_user_notifications CASCADE;
DROP TABLE IF EXISTS core_user_notification_emails CASCADE;

DROP VIEW IF EXISTS core_v_group_users CASCADE;

CREATE TABLE core_users (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  username CHARACTER VARYING NOT NULL,
  first_name CHARACTER VARYING NOT NULL,
  last_name CHARACTER VARYING NOT NULL,
  email CHARACTER VARYING NOT NULL,
  receive_emails CHARACTER VARYING NOT NULL, -- always, never, required
  password CHARACTER VARYING NOT NULL,
  language_code CHARACTER VARYING NOT NULL,
  security JSONB DEFAULT '{}'::JSONB,
  security_instances JSONB DEFAULT '{}'::JSONB,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(username)
);

INSERT INTO core_users (
  id,
  username,
  first_name,
  last_name,
  email,
  receive_emails,
  password,
  language_code,
  security,
  security_instances,
  active,
  created_by,
  created_at,
  updated_by,
  updated_at
)
VALUES (
  'admin',
  'admin',
  'Administrator',
  'System',
  'admin@domain.com',
  'always',
  '123456',
  'pt-br',
  '{}',
  '{}',
  true,
  'admin',
  '2019-04-23 15:30:36.480864+00',
  'admin',
  '2019-04-23 15:30:36.480864+00'
);

CREATE TABLE core_config_languages (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  name JSONB DEFAULT '{}'::JSONB NOT NULL,
  description JSONB DEFAULT '{}'::JSONB NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

INSERT INTO core_config_languages (
  id,
  code,
  name,
  description,
  active,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  '9b09866a-69c5-11e9-96a1-06ea2c43bb20',
  'pt-br',
  '{"pt-br": "Português do Brasil"}',
  '{"pt-br": "Idioma disponível no sistema"}',
  true,
  'admin',
  '2019-04-23 15:30:36.480864+00',
  'admin',
  '2019-04-23 15:30:36.480864+00'
);

INSERT INTO core_config_languages (
  id,
  code,
  name,
  description,
  active,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  '1a09866a-69c5-11e9-96a1-06ea2c43bb21',
  'en-us',
  '{"pt-br": "Inglês dos Estados Unidos"}',
  '{"pt-br": "Idioma disponível no sistema"}',
  true,
  'admin',
  '2019-04-23 15:30:36.480864+00',
  'admin',
  '2019-04-23 15:30:36.480864+00'
);

CREATE TABLE core_trees (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  name JSONB DEFAULT '{}'::JSONB NOT NULL,
  description JSONB DEFAULT '{}'::JSONB NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_tree_levels (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  name JSONB DEFAULT '{}'::JSONB NOT NULL,
  description JSONB DEFAULT '{}'::JSONB NOT NULL,
  tree_code CHARACTER VARYING NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_tree_units (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  name JSONB DEFAULT '{}'::JSONB NOT NULL,
  description JSONB DEFAULT '{}'::JSONB NOT NULL,
  tree_code CHARACTER VARYING NOT NULL,
  path LTREE NOT NULL,
  permission_scope CHARACTER VARYING,
  permissions JSONB DEFAULT '[]'::JSONB NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(tree_code, code)
);

CREATE TABLE core_currencies (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  name JSONB DEFAULT '{}'::JSONB NOT NULL,
  description JSONB DEFAULT '{}'::JSONB NOT NULL,
  rates JSONB DEFAULT '{}'::JSONB NOT NULL,
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
  name JSONB DEFAULT '{}'::JSONB NOT NULL,
  description JSONB DEFAULT '{}'::JSONB NOT NULL,
  tree_unit_id CHARACTER VARYING,
  tree_unit_permission_scope CHARACTER VARYING,
  users JSONB DEFAULT '[]'::JSONB NOT NULL,
  permissions JSONB DEFAULT '[]'::JSONB NOT NULL,
  wildcards JSONB DEFAULT '[]'::JSONB NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_datasets (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  type CHARACTER VARYING NOT NULL,
  name JSONB DEFAULT '{}'::JSONB NOT NULL,
  description JSONB DEFAULT '{}'::JSONB NOT NULL,
  definitions JSONB DEFAULT '{}'::JSONB,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

INSERT INTO core_datasets (
  id,
  code,
  type,
  name,
  description,
  definitions,
  active,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  '4b34b08e-9e99-11e9-81c6-06ea2c43bb20',
  'ds_currencies',
  'dynamic',
  '{"pt-br": "Lista de moedas ativas"}',
  '{"pt-br": "Lista de moedas ativas"}',
  '{"query": "select code, value as name from core_currencies, lateral jsonb_each_text(name) where active = true and key = {{param:user:language}}", "fields": [{"code": "code", "label": "code", "security": {"field_code": "", "schema_code": ""}, "data_type": "text", "field_type": "field"}, {"code": "name", "label": "name", "security": {"field_code": "", "schema_code": ""}, "data_type": "text", "field_type": "field"}], "created_at": "2019-07-04T17:21:22.838384568-03:00", "created_by": "admin", "updated_at": "2019-07-04T20:04:10.455163656-03:00", "updated_by": "admin"}',
  true,
  'admin',
  '2019-07-04 20:21:22.838385+00',
  'admin',
  '2019-07-04 23:04:10.455164+00'
);

CREATE TABLE core_schemas (
  id CHARACTER VARYING NOT NULL DEFAULT uuid_generate_v1(),
  code CHARACTER VARYING NOT NULL,
  name JSONB DEFAULT '{}'::JSONB NOT NULL,
  description JSONB DEFAULT '{}'::JSONB NOT NULL,
  module BOOLEAN NOT NULL DEFAULT false,
  prefixo CHARACTER VARYING,
  is_extension BOOLEAN,
  active BOOLEAN NOT NULL DEFAULT false,
  status CHARACTER VARYING NOT NULL DEFAULT 'processing',
  followers JSONB DEFAULT '[]'::JSONB,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  parent_id CHARACTER VARYING,
  PRIMARY KEY(id),
  UNIQUE(code)
);

CREATE TABLE core_schema_fields (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  code CHARACTER VARYING NOT NULL,
  schema_code CHARACTER VARYING NOT NULL,
  field_type CHARACTER VARYING NOT NULL,
  name JSONB DEFAULT '{}'::JSONB NOT NULL,
  description JSONB DEFAULT '{}'::JSONB NOT NULL,
  default_value JSONB DEFAULT '{}'::JSONB NOT NULL,
  definitions JSONB DEFAULT '{}'::JSONB NOT NULL,
  validations JSONB DEFAULT '[]'::JSONB NOT NULL,
  active BOOLEAN DEFAULT FALSE NOT NULL,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(schema_code, code)
);

CREATE TABLE core_jobs (
  id CHARACTER VARYING NOT NULL DEFAULT uuid_generate_v4(),
  code CHARACTER VARYING NOT NULL,
  name JSONB DEFAULT '{}'::JSONB NOT NULL,
  description JSONB DEFAULT '{}'::JSONB NOT NULL,
  job_type CHARACTER VARYING NOT NULL, --system, user
  parameters JSONB DEFAULT '[]'::JSONB,
  followers JSONB DEFAULT '[]'::JSONB,
  exec_timeout INTEGER NOT NULL DEFAULT 60,
  active BOOLEAN NOT NULL DEFAULT false,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(code)
);

INSERT INTO core_jobs (
  id,
  code,
  name,
  description,
  job_type,
  parameters,
  followers,
  exec_timeout,
  active,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  '97273448-0600-4987-96e9-796ae54c3409',
  'job_system_create_schema',
  '{"pt-br": "Criar Schema"}',
  '{"pt-br": "Job para criação de todas as tarefas de schema"}',
  'system',
  '[{"key": "schema_code"}]',
  '[]',
  60,
  true,
  'admin',
  '2019-05-14 16:23:55.546555+00',
  'admin',
  '2019-05-14 19:12:21.364253+00'
);

INSERT INTO core_jobs (
  id,
  code,
  name,
  description,
  job_type,
  parameters,
  followers,
  exec_timeout,
  active,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  '1dc914d8-dbdf-4b21-8755-4034bf01feac',
  'job_system_delete_schema',
  '{"pt-br": "Delete Schema"}',
  '{"pt-br": "Job execução das tarefas necessárias após a exclusão de um schema"}',
  'system',
  '[{"key": "schema_code"}]',
  '[]',
  60,
  true,
  'admin',
  '2019-05-14 16:23:55.546555+00',
  'admin',
  '2019-05-14 19:12:21.364253+00'
);

CREATE TABLE core_job_tasks (
  id CHARACTER VARYING NOT NULL DEFAULT uuid_generate_v4(),
  code CHARACTER VARYING,
  name JSONB DEFAULT '{}'::JSONB NOT NULL,
  description JSONB DEFAULT '{}'::JSONB NOT NULL,
  job_code CHARACTER VARYING NOT NULL,
  task_sequence INTEGER NOT NULL DEFAULT 0,
  exec_timeout INTEGER NOT NULL DEFAULT 60,
  parent_code CHARACTER VARYING,
  parameters JSONB DEFAULT '[]'::JSONB,
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
  UNIQUE(job_code, code)
);

INSERT INTO core_job_tasks (
  id,
  code,
  name,
  description,
  job_code,
  task_sequence,
  exec_timeout,
  parent_code,
  parameters,
  exec_action,
  exec_address,
  exec_payload,
  action_on_fail,
  max_retry_attempts,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  '6647f5e9-f1b7-4e41-8cea-c38a744a3678',
  'create_table',
  '{"pt-br": "Criar tabela de dados"}',
  '{"pt-br": "Criação de tabela"}',
  'job_system_create_schema',
  0,
  60,
  null,
  '[]',
  'exec_query',
  'local',
  $$CREATE TABLE cst_{job.schema_code} (
    id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
    data JSONB DEFAULT '[]'::JSONB NOT NULL,
    created_by CHARACTER VARYING NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_by CHARACTER VARYING NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY(id)
  );$$,
  'retry_and_cancel',
  2,
  'admin',
  '2019-05-14 16:27:14.492063+00',
  'admin',
  '2019-05-14 16:27:14.492063+00'
);

INSERT INTO core_job_tasks (
  id,
  code,
  name,
  description,
  job_code,
  task_sequence,
  exec_timeout,
  parent_code,
  parameters,
  exec_action,
  exec_address,
  exec_payload,
  action_on_fail,
  max_retry_attempts,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  'c26fdc64-7726-4d6b-aea6-20bb8f9f5a51',
  'create_field01',
  '{"pt-br": "Criação de campo Nome"}',
  '{"pt-br": "Criação de campo Nome"}',
  'job_system_create_schema',
  1,
  60,
  null,
  '[]',
  'api_post',
  '{system.api_host}/api/v1/core/admin/schemas/{job.schema_code}/fields',
  '{"code": "name","schema_code": "{job.schema_code}","field_type": "text","name": {"pt-br": "Nome"},"description": {"pt-br": "Descrição do campo nome"},"active": true,"definitions": {"display": "single_line"}}',
  'retry_and_cancel',
  2,
  'admin',
  '2019-05-14 16:27:14.492063+00',
  'admin',
  '2019-05-14 16:27:14.492063+00'
);

INSERT INTO core_job_tasks (
  id,
  code,
  name,
  description,
  job_code,
  task_sequence,
  exec_timeout,
  parent_code,
  parameters,
  exec_action,
  exec_address,
  exec_payload,
  action_on_fail,
  max_retry_attempts,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  '5a774097-ca92-4244-9467-b53d66d9c1ec',
  'create_field02',
  '{"pt-br": "Criação de campo Descrição"}',
  '{"pt-br": "Criação de campo Descrição"}',
  'job_system_create_schema',
  1,
  60,
  null,
  '[]',
  'api_post',
  '{system.api_host}/api/v1/core/admin/schemas/{job.schema_code}/fields',
  '{"code": "description","schema_code": "{job.schema_code}","field_type": "text","name": {"pt-br": "Descrição"},"description": {"pt-br": "Descrição do campo descrição"},"active": true,"definitions": {"display": "multi_line"}}',
  'retry_and_cancel',
  2,
  'admin',
  '2019-05-14 16:27:14.492063+00',
  'admin',
  '2019-05-14 16:27:14.492063+00'
);

INSERT INTO core_job_tasks (
  id,
  code,
  name,
  description,
  job_code,
  task_sequence,
  exec_timeout,
  parent_code,
  parameters,
  exec_action,
  exec_address,
  exec_payload,
  action_on_fail,
  max_retry_attempts,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  '4a774097-ca92-4244-9467-b53d66d9c1ec',
  'create_dataset01',
  '{"pt-br": "Criação de Dataset padrão"}',
  '{"pt-br": "Criação de Dataset padrão"}',
  'job_system_create_schema',
  2,
  60,
  null,
  '[]',
  'api_post',
  '{system.api_host}/api/v1/core/admin/datasets',
  '{"code": "{job.schema_code}","name": "Dataset de {job.schema_code}","description": "Dataset padrão de {job.schema_code}","type": "schema","active": true}',
  'retry_and_cancel',
  2,
  'admin',
  '2019-05-14 16:27:14.492063+00',
  'admin',
  '2019-05-14 16:27:14.492063+00'
);

INSERT INTO core_job_tasks (
  id,
  code,
  name,
  description,
  job_code,
  task_sequence,
  exec_timeout,
  parent_code,
  parameters,
  exec_action,
  exec_address,
  exec_payload,
  action_on_fail,
  max_retry_attempts,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  '3b25010f-4e50-4b91-84d4-6b0d19f1c3ae',
  'update_schema',
  '{"pt-br": "Passa status do Schema para completado"}',
  '{"pt-br": "Passa status do schema para completado. Finalizando o processo de criação do mesmo."}',
  'job_system_create_schema',
  3,
  60,
  null,
  '[]',
  'api_patch',
  '{system.api_host}/api/v1/core/admin/schemas/{job.schema_code}',
  '{"status": "completed"}',
  'retry_and_cancel',
  2,
  'admin',
  '2019-05-14 16:27:14.492063+00',
  'admin',
  '2019-05-14 16:27:14.492063+00'
);

CREATE TABLE core_job_instances (
  id CHARACTER VARYING NOT NULL DEFAULT uuid_generate_v1(),
  job_code CHARACTER VARYING NOT NULL,
  service_id CHARACTER VARYING,
  exec_timeout INTEGER NOT NULL DEFAULT 60,
  parameters JSONB DEFAULT '[]'::JSONB,
  status CHARACTER VARYING NOT NULL,
  start_at TIMESTAMPTZ,
  finish_at TIMESTAMPTZ,
  created_by CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_by CHARACTER VARYING NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  queue_at TIMESTAMPTZ,
  PRIMARY KEY(id)
);

CREATE TABLE core_job_task_instances (
  id CHARACTER VARYING NOT NULL DEFAULT uuid_generate_v1(),
  job_instance_id CHARACTER VARYING NOT NULL,
  task_code CHARACTER VARYING NOT NULL,
  status CHARACTER VARYING NOT NULL, -- created, processing, concluded, warning, fail
  start_at TIMESTAMPTZ,
  finish_at TIMESTAMPTZ,
  task_sequence INTEGER NOT NULL DEFAULT 0,
  exec_timeout INTEGER NOT NULL DEFAULT 60,
  parent_code CHARACTER VARYING,
  parameters JSONB DEFAULT '[]'::JSONB,
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
  UNIQUE(job_instance_id, task_code)
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

INSERT INTO core_system_params (
  id,
  param_key,
  param_value,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  'b555496e-78f2-11e9-8f86-06ea2c43bb20',
  'api_host',
  'https://localhost:8080',
  'admin',
  '2019-05-17 21:26:51.191108+00',
  'admin',
  '2019-05-17 21:26:51.191108+00'
);

INSERT INTO core_system_params (
  id,
  param_key,
  param_value,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  'd004a2ca-7981-11e9-a8f0-06ea2c43bb20',
  'api_login_email',
  'admin@domain.com',
  'admin',
  '2019-05-17 21:26:51.191108+00',
  'admin',
  '2019-05-17 21:26:51.191108+00'
);

INSERT INTO core_system_params (
  id,
  param_key,
  param_value,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  'd03101d0-7981-11e9-a8f1-06ea2c43bb20',
  'api_login_password',
  '123456',
  'admin',
  '2019-05-17 21:26:51.191108+00',
  'admin',
  '2019-05-17 21:26:51.191108+00'
);

INSERT INTO core_system_params (
  id,
  param_key,
  param_value,
  created_by,
  created_at,
  updated_by,
  updated_at
) VALUES (
  'cb2b2330-78f2-11e9-8f87-06ea2c43bb20',
  'api_login_url',
  '/api/v1/core/admin/login',
  'admin',
  '2019-05-17 21:26:51.191108+00',
  'admin',
  '2019-05-17 21:26:51.191108+00'
);

CREATE TABLE core_user_notifications (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  username CHARACTER VARYING NOT NULL,
  structure_id CHARACTER VARYING NOT NULL,
  structure_type CHARACTER VARYING NOT NULL,
  message_action CHARACTER VARYING NOT NULL,
  link CHARACTER VARYING NOT NULL,
  sender_id CHARACTER VARYING NOT NULL,
  body CHARACTER VARYING NOT NULL,
  acknowledged BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE core_user_notification_emails (
  id CHARACTER VARYING DEFAULT uuid_generate_v1() NOT NULL,
  username CHARACTER VARYING NOT NULL,
  structure_id CHARACTER VARYING NOT NULL,
  structure_type CHARACTER VARYING NOT NULL,
  message_action CHARACTER VARYING NOT NULL,
  link CHARACTER VARYING NOT NULL,
  sender_id CHARACTER VARYING NOT NULL,
  body CHARACTER VARYING NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY(id)
);

CREATE VIEW core_v_group_users AS
  SELECT
    core_users.id AS id,
    core_groups.id AS group_id,
    core_users.username AS username,
    core_users.first_name AS first_name,
    core_users.last_name AS last_name,
    core_users.email AS email,
    core_users.password AS password,
    core_users.receive_emails AS receive_emails,
    core_users.language_code AS language_code,
    core_users.active AS active,
    core_users.created_by AS created_by,
    core_users.created_at AS created_at,
    core_users.updated_by AS updated_by,
    core_users.updated_at AS updated_at
  FROM core_users
  JOIN core_groups
  ON core_groups.users @> ('[{"username":"' || core_users.username || '"}]')::JSONB;

CREATE OR REPLACE FUNCTION trg_func_replic_job_task_to_instances() RETURNS TRIGGER AS $$
  BEGIN
    INSERT INTO core_job_task_instances (
      task_code,
      job_instance_id,
      status,
      start_at,
      finish_at,
      task_sequence,
      exec_timeout,
      parent_code,
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
      code AS task_code,
      NEW.id AS job_instance_id,
      'created' AS status,
      NULL AS start_at,
      NULL AS finish_at,
      task_sequence AS task_sequence,
      exec_timeout AS exec_timeout,
      parent_code AS parent_code,
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
      job_code = NEW.job_code;

    UPDATE core_job_instances SET status = 'created', updated_at = NOW() WHERE id = NEW.id;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_replic_job_task_to_instances
  AFTER INSERT ON core_job_instances
    FOR EACH ROW
      EXECUTE PROCEDURE trg_func_replic_job_task_to_instances();