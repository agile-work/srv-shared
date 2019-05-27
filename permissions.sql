CREATE VIEW core_v_structure_permissions AS
  SELECT
    tab.user_id,
    tab.schema_code,
    tab.id,
    tab.structure_code,
    tab.structure_type,
    tab.structure_class,
    max(tab.permission) AS permission
  FROM
  (
    -- Retorna permissões de estrutura de um usuário por unidade de árvore
    SELECT DISTINCT
      res.user_id AS user_id,
      sch.code AS schema_code,
      jsonb_array_elements(unit_path.permissions)->>'structure_id' AS id,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.code
        ELSE wdg.code
      END AS structure_code,
      jsonb_array_elements(unit_path.permissions)->>'structure_type' AS structure_type,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.field_type
        ELSE wdg.widget_type
      END AS structure_class,
      (jsonb_array_elements(unit_path.permissions)->>'permission_type')::int AS permission,
      'unit' AS scope
    FROM
    (
      SELECT
        res.parent_id AS user_id,
        jsonb_array_elements(res.data->'trees')->>'tree' AS tree,
        jsonb_array_elements(res.data->'trees')->>'tree_unit' AS tree_unit
      FROM cst_resources AS res
    ) AS res
    JOIN core_trees tree
    ON tree.code = res.tree
    JOIN core_tree_units unit
    ON unit.tree_code = tree.code
    AND unit.code = res.tree_unit
    JOIN core_tree_units unit_path
    ON unit_path.tree_code = unit.tree_code
    LEFT JOIN core_sch_fields fld
    ON unit_path.permissions @> ('[{"structure_id":"' || fld.id || '", "structure_type": "field"}]')::JSONB
    LEFT JOIN core_schemas sch
    ON sch.id = fld.schema_id
    LEFT JOIN core_widgets wdg
    ON unit_path.permissions @> ('[{"structure_id":"' || wdg.id || '", "structure_type": "widget"}]')::JSONB
    WHERE
    (
      (
        unit_path.path = unit.path
        AND unit_path.permission_scope != NULL
      )
      OR
      (
        unit.path <@ unit_path.path
        AND unit_path.permission_scope = 'unit_and_descendent'
      )
    )

    UNION ALL
    -- Retorna permissões de estrutura de um usuário por grupo
    SELECT DISTINCT
      res.parent_id AS user_id,
      sch.code AS schema_code,
      jsonb_array_elements(grp.permissions)->>'structure_id' AS id,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.code
        ELSE wdg.code
      END AS structure_code,
      jsonb_array_elements(grp.permissions)->>'structure_type' AS structure_type,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.field_type
        ELSE wdg.widget_type
      END AS structure_class,
      (jsonb_array_elements(grp.permissions)->>'permission_type')::int AS permission,
      CASE
        WHEN grp.tree_unit_id IS NULL
        THEN 'group'
        ELSE 'unit_group'
      END AS scope
    FROM cst_resources AS res
    JOIN core_groups grp
    ON grp.users @> ('[{"id":"' || res.parent_id || '"}]')::JSONB
    LEFT JOIN core_sch_fields fld
    ON grp.permissions @> ('[{"structure_id":"' || fld.id || '", "structure_type": "field"}]')::JSONB
    LEFT JOIN core_schemas sch
    ON sch.id = fld.schema_id
    LEFT JOIN core_widgets wdg
    ON grp.permissions @> ('[{"structure_id":"' || wdg.id || '", "structure_type": "widget"}]')::JSONB

    UNION ALL
    -- Retorna permissões de estrutura de um usuário por instâncias
    SELECT
      inst.user_id AS user_id,
      inst.instance_type AS schema_code,
      jsonb_array_elements(inst.permissions)->>'structure_id' AS id,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.code
        ELSE wdg.code
      END AS structure_code,
      jsonb_array_elements(inst.permissions)->>'structure_type' AS structure_type,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.field_type
        ELSE wdg.widget_type
      END AS structure_class,
      (jsonb_array_elements(inst.permissions)->>'permission_type')::int AS permission,
      'instance_' || inst.source_type AS scope
    FROM core_instance_premissions inst
    LEFT JOIN core_sch_fields fld
    ON inst.permissions @> ('[{"structure_id":"' || fld.id || '", "structure_type": "field"}]')::JSONB
    LEFT JOIN core_widgets wdg
    ON inst.permissions @> ('[{"structure_id":"' || wdg.id || '", "structure_type": "widget"}]')::JSONB
  ) AS tab
  GROUP BY
    tab.user_id,
    tab.schema_code,
    tab.id,
    tab.structure_code,
    tab.structure_type,
    tab.structure_class