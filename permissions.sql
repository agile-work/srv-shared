CREATE VIEW core_v_user_structure_permissions AS
  SELECT
    tab.user_id AS user_id,
    tab.schema_code AS schema_code,
    tab.id AS id,
    tab.structure_code AS structure_code,
    tab.structure_type AS structure_type,
    tab.structure_class AS structure_class,
    tab.structure_definitions AS structure_definitions,
    max(tab.permission) AS permission
  FROM (
    -- Retorna permissões de estrutura de um usuário por unidade de árvore
    SELECT
      res.user_id AS user_id,
      sch.code AS schema_code,
      unit_path.structure_id AS id,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.code
        ELSE wdg.code
      END AS structure_code,
      unit_path.structure_type AS structure_type,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.field_type
        ELSE wdg.widget_type
      END AS structure_class,
      unit_path.permission AS permission,
      'unit' AS scope,
      fld.definitions AS structure_definitions
    FROM (
      SELECT
        res.parent_id AS user_id,
        trees->>'tree' AS tree,
        trees->>'tree_unit' AS tree_unit
      FROM
        cst_resources AS res,
        jsonb_array_elements(res.data->'trees') trees
    ) AS res
    JOIN
      core_trees tree
    ON
      tree.code = res.tree
    JOIN
      core_tree_units unit
    ON
      unit.tree_id = tree.id
      AND unit.code = res.tree_unit
    JOIN (
      SELECT 
        unit_path.tree_id AS tree_id,
        unit_path.permission_scope AS permission_scope,
        unit_path.path AS path,
        perm->>'structure_id' AS structure_id,
        perm->>'structure_type' AS structure_type,
        (perm->>'permission_type')::INT AS permission
      FROM 
        core_tree_units unit_path,
        jsonb_array_elements(unit_path.permissions) perm
      WHERE
        perm->>'structure_type' != 'schema'
    ) AS unit_path
    ON
      unit_path.tree_id = unit.tree_id
    LEFT JOIN
      core_sch_fields fld
    ON
      unit_path.structure_id = fld.id
    LEFT JOIN
      core_schemas sch
    ON
      sch.id = fld.schema_id
    LEFT JOIN
      core_widgets wdg
    ON
      unit_path.structure_id = wdg.id
    WHERE (
      (
        unit_path.path = unit.path
        AND unit_path.permission_scope IS NOT NULL
      )
      OR
      (
        unit.path <@ unit_path.path
        AND unit_path.permission_scope = 'unit_and_descendent'
      )
    )

    UNION ALL
    -- Retorna permissões de estrutura de um usuário por grupo
    SELECT
      res.parent_id AS user_id,
      sch.code AS schema_code,
      grp.structure_id AS id,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.code
        ELSE wdg.code
      END AS structure_code,
      grp.structure_type,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.field_type
        ELSE wdg.widget_type
      END AS structure_class,
      grp.permission,
      CASE
        WHEN grp.tree_unit_id IS NULL
        THEN 'group'
        ELSE 'unit_group'
      END AS scope,
      fld.definitions AS structure_definitions
    FROM cst_resources AS res
    JOIN (
      SELECT 
        grp.id AS id,
        grp.tree_unit_id AS tree_unit_id,
        grp.users AS users,
        perm->>'structure_id' AS structure_id,
        perm->>'structure_type' AS structure_type,
        (perm->>'permission_type')::INT AS permission
      FROM 
        core_groups grp,
        jsonb_array_elements(grp.permissions) perm
      WHERE
        perm->>'structure_type' != 'schema'
    ) AS grp
    ON
      grp.users @> ('[{"id":"' || res.parent_id || '"}]')::JSONB
    LEFT JOIN
      core_sch_fields fld
    ON
      grp.structure_id = fld.id
    LEFT JOIN
      core_schemas sch
    ON
      sch.id = fld.schema_id
    LEFT JOIN
      core_widgets wdg
    ON
      grp.structure_id = wdg.id

    UNION ALL
    -- Retorna permissões de estrutura de um usuário por instâncias
    SELECT
      inst.user_id AS user_id,
      inst.instance_type AS schema_code,
      inst.structure_id AS id,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.code
        ELSE wdg.code
      END AS structure_code,
      inst.structure_type AS structure_type,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.field_type
        ELSE wdg.widget_type
      END AS structure_class,
      inst.permission AS permission,
      'instance_' || inst.source_type AS scope,
      fld.definitions AS structure_definitions
    FROM (
      SELECT 
        inst.user_id AS user_id,
        inst.instance_type AS instance_type,
        inst.source_type AS source_type,
        perm->>'structure_id' AS structure_id,
        perm->>'structure_type' AS structure_type,
        (perm->>'permission_type')::INT AS permission
      FROM 
        core_instance_premissions inst,
        jsonb_array_elements(inst.permissions) perm
      WHERE
        perm->>'structure_type' != 'schema'
    ) AS inst    
    LEFT JOIN
      core_sch_fields fld
    ON
      inst.structure_id = fld.id
    LEFT JOIN
      core_widgets wdg
    ON
      inst.structure_id = wdg.id
  ) AS tab
  GROUP BY
    tab.user_id,
    tab.schema_code,
    tab.id,
    tab.structure_code,
    tab.structure_type,
    tab.structure_class,
    tab.structure_definitions;

CREATE VIEW core_v_user_all_permissions AS
  SELECT DISTINCT
    tab.user_id AS user_id,
    tab.schema_id AS schema_id,
    tab.schema_code AS schema_code,
    transl_schema.value AS schema_name,
    tab.structure_id AS structure_id,
    tab.structure_code AS structure_code,
    tab.structure_type AS structure_type,
    tab.structure_class AS structure_class,
    transl_struc.value AS structure_name,
    CASE
      WHEN transl_struc.language_code IS NULL
      THEN transl_schema.language_code
      ELSE transl_struc.language_code
    END language_code,
    tab.permission_type AS permission_type,
    tab.scope AS scope
  FROM
  (
    -- Retorna permissões de estrutura de um usuário por unidade de árvore
    SELECT
      res.user_id AS user_id,
      sch.code AS schema_code,
      sch.id AS schema_id,
      unit_path.structure_id AS structure_id,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.code
        ELSE wdg.code
      END AS structure_code,
      unit_path.structure_type AS structure_type,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.field_type
        ELSE wdg.widget_type
      END AS structure_class,
      unit_path.permission_type AS permission_type,
      'unit' AS scope
    FROM
    (
      SELECT
        res.parent_id AS user_id,
        trees->>'tree' AS tree,
        trees->>'tree_unit' AS tree_unit
      FROM
        cst_resources AS res,
        jsonb_array_elements(res.data->'trees') trees
    ) AS res
    JOIN core_trees tree
    ON tree.code = res.tree
    JOIN core_tree_units unit
    ON unit.tree_id = tree.id
    AND unit.code = res.tree_unit
    JOIN (
      SELECT 
        unit_path.tree_id AS tree_id,
        unit_path.permission_scope AS permission_scope,
        unit_path.path AS path,
        jsonb_array_elements(unit_path.permissions)->>'structure_id' AS structure_id,
        jsonb_array_elements(unit_path.permissions)->>'structure_type' AS structure_type,
        (jsonb_array_elements(unit_path.permissions)->>'permission_type')::INT AS permission_type
      FROM 
        core_tree_units unit_path
    ) AS unit_path
    ON unit_path.tree_id = unit.tree_id
    LEFT JOIN core_sch_fields fld
    ON unit_path.structure_id = fld.id
    LEFT JOIN core_schemas sch
    ON sch.id = fld.schema_id
    LEFT JOIN core_widgets wdg
    ON unit_path.structure_id = wdg.id
    WHERE
    (
      (
        unit_path.path = unit.path
        AND unit_path.permission_scope IS NOT NULL
      )
      OR
      (
        unit.path <@ unit_path.path
        AND unit_path.permission_scope = 'unit_and_descendent'
      )
    )

    UNION ALL
    -- Retorna permissões de estrutura de um usuário por grupo
    SELECT
      res.parent_id AS user_id,
      sch.code AS schema_code,
      sch.id AS schema_id,
      grp.structure_id AS structure_id,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.code
        ELSE wdg.code
      END AS structure_code,
      grp.structure_type,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.field_type
        ELSE wdg.widget_type
      END AS structure_class,
      grp.permission_type AS permission_type,
      CASE
        WHEN grp.tree_unit_id IS NULL
        THEN 'group'
        ELSE 'unit_group'
      END AS scope
    FROM cst_resources AS res
    JOIN (
      SELECT 
        grp.id AS id,
        grp.tree_unit_id AS tree_unit_id,
        grp.users AS users,
        jsonb_array_elements(grp.permissions)->>'structure_id' AS structure_id,
        jsonb_array_elements(grp.permissions)->>'structure_type' AS structure_type,
        (jsonb_array_elements(grp.permissions)->>'permission_type')::INT AS permission_type
      FROM 
        core_groups grp
    ) AS grp
    ON grp.users @> ('[{"id":"' || res.parent_id || '"}]')::JSONB
    LEFT JOIN core_sch_fields fld
    ON grp.structure_id = fld.id
    LEFT JOIN core_schemas sch
    ON sch.id = fld.schema_id
    LEFT JOIN core_widgets wdg
    ON grp.structure_id = wdg.id

    UNION ALL
    -- Retorna permissões de estrutura de um usuário por instâncias
    SELECT
      inst.user_id AS user_id,
      inst.instance_type AS schema_code,
      sch.id AS schema_id,
      inst.structure_id AS structure_id,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.code
        ELSE wdg.code
      END AS structure_code,
      inst.structure_type AS structure_type,
      CASE
        WHEN fld.id IS NOT NULL THEN fld.field_type
        ELSE wdg.widget_type
      END AS structure_class,
      inst.permission_type AS permission_type,
      'instance_' || inst.source_type AS scope
    FROM (
      SELECT 
        inst.user_id AS user_id,
        inst.instance_type AS instance_type,
        inst.source_type AS source_type,
        jsonb_array_elements(inst.permissions)->>'structure_id' AS structure_id,
        jsonb_array_elements(inst.permissions)->>'structure_type' AS structure_type,
        (jsonb_array_elements(inst.permissions)->>'permission_type')::INT AS permission_type
      FROM 
        core_instance_premissions inst
    ) AS inst    
    LEFT JOIN core_sch_fields fld
    ON inst.structure_id = fld.id
    LEFT JOIN core_schemas sch
    ON sch.id = fld.schema_id
    LEFT JOIN core_widgets wdg
    ON inst.structure_id = wdg.id
  ) AS tab
  LEFT JOIN core_translations transl_struc
  ON transl_struc.structure_id = tab.structure_id
  AND transl_struc.structure_field = 'name'
  LEFT JOIN core_translations transl_schema
  ON transl_schema.structure_id = tab.schema_id
  AND transl_schema.structure_field = 'name';

CREATE VIEW core_v_structure_permissions AS
  SELECT
    perm.id AS id,
    perm.parent_id AS parent_id,
    perm.structure_id AS structure_id,
    perm.structure_type AS structure_type,
    transl.value AS structure_name,
    perm.permission_type AS permission_type,
    transl.language_code AS language_code,
    perm.created_by AS created_by,
    perm.created_at::TIMESTAMPTZ AS created_at
  FROM (
    SELECT 
      jsonb_array_elements(unit.permissions)->>'id' AS id,
      unit.id AS parent_id,
      jsonb_array_elements(unit.permissions)->>'structure_id' AS structure_id,
      jsonb_array_elements(unit.permissions)->>'structure_type' AS structure_type,
      (jsonb_array_elements(unit.permissions)->>'permission_type')::INT AS permission_type,
      jsonb_array_elements(unit.permissions)->>'created_by' AS created_by,
      jsonb_array_elements(unit.permissions)->>'created_at' AS created_at
    FROM 
      core_tree_units unit
    UNION ALL
    SELECT 
      jsonb_array_elements(grp.permissions)->>'id' AS id,
      grp.id AS parent_id,
      jsonb_array_elements(grp.permissions)->>'structure_id' AS structure_id,
      jsonb_array_elements(grp.permissions)->>'structure_type' AS structure_type,
      (jsonb_array_elements(grp.permissions)->>'permission_type')::INT AS permission_type,
      jsonb_array_elements(grp.permissions)->>'created_by' AS created_by,
      jsonb_array_elements(grp.permissions)->>'created_at' AS created_at
    FROM 
      core_groups grp
    UNION ALL
    SELECT
      jsonb_array_elements(fld.permissions)->>'id' AS id,
      fld.id AS parent_id,
      jsonb_array_elements(fld.permissions)->>'structure_id' AS structure_id,
      jsonb_array_elements(fld.permissions)->>'structure_type' AS structure_type,
      (jsonb_array_elements(fld.permissions)->>'permission_type')::INT AS permission_type,
      jsonb_array_elements(fld.permissions)->>'created_by' AS created_by,
      jsonb_array_elements(fld.permissions)->>'created_at' AS created_at
    FROM 
      core_sch_fields fld
  ) AS perm
  JOIN core_translations transl
  ON transl.structure_id = perm.structure_id
  AND transl.structure_field = 'name';


----------------------------------------------------------------------------------------------

CREATE VIEW core_v_user_instance_permissions AS
  SELECT
    'group' AS scope,
    res.parent_id AS user_id,
    sch.code AS schema_code,
    NULL AS tree_code,
    NULL AS tree_unit_code,
    NULL AS tree_unit_path,
    NULL AS tree_unit_permission_scope
  FROM
  (
    SELECT
      grp.id AS id,
      grp.tree_unit_id AS tree_unit_id,
      grp.users AS users,
      perm->>'structure_id' AS structure_id,
      perm->>'structure_type' AS structure_type,
      (perm->>'permission_type')::INT AS permission_type
    FROM
      core_groups AS grp,
      jsonb_array_elements(grp.permissions) AS perm
    WHERE
      (perm->>'permission_type')::INT = 100
      AND grp.tree_unit_id IS NULL
      AND grp.active = TRUE
  ) AS grp
  JOIN
    cst_resources AS res
  ON
    grp.users @> ('[{"id":"' || res.parent_id || '"}]')::JSONB
  JOIN
    core_schemas AS sch
  ON
    sch.id = grp.structure_id

  UNION ALL

  SELECT
    'group_unit' AS scope,
    res.user_id AS user_id,
    sch.code AS schema_code,
    res.tree_code AS tree_code,
    res.tree_unit_code AS tree_unit_code,
    unit_res.path AS tree_unit_path,
    min(grp.tree_unit_permission_scope) AS tree_unit_permission_scope
  FROM
  (
    SELECT
      grp.id AS id,
      grp.tree_unit_id AS tree_unit_id,
      grp.tree_unit_permission_scope AS tree_unit_permission_scope,
      grp.users AS users,
      perm->>'structure_id' AS structure_id,
      perm->>'structure_type' AS structure_type,
      (perm->>'permission_type')::INT AS permission_type
    FROM
      core_groups AS grp,
      jsonb_array_elements(grp.permissions) AS perm
    WHERE
      (perm->>'permission_type')::INT = 100
      AND grp.tree_unit_id IS NOT NULL
      AND grp.active = TRUE
  ) AS grp
  JOIN
    core_tree_units AS unit
  ON
    unit.id = grp.tree_unit_id
    AND unit.active = TRUE
  JOIN
    core_trees AS trees
  ON
    trees.id = unit.tree_id
  JOIN
    (
      SELECT
        res.parent_id AS user_id,
        trees->>'tree' AS tree_code,
        trees->>'tree_unit' AS tree_unit_code
      FROM
        cst_resources AS res,
        jsonb_array_elements(res.data->'trees') trees
    ) AS res
  ON
    grp.users @> ('[{"id":"' || res.user_id || '"}]')::JSONB
    AND res.tree_code = trees.code
  JOIN
    core_trees AS tree_res
  ON
    tree_res.code = res.tree_code
  JOIN
    core_tree_units AS unit_res
  ON
    unit_res.tree_id = tree_res.id
    AND unit_res.code = res.tree_unit_code
  JOIN
    core_schemas AS sch
  ON
    sch.id = grp.structure_id
  GROUP BY
    res.user_id,
    sch.code,
    res.tree_code,
    res.tree_unit_code,
    unit_res.path

  UNION ALL

  SELECT
    'unit' AS scope,
    res.user_id AS user_id,
    sch.code AS schema_code,
    res.tree_code AS tree_code,
    res.tree_unit_code AS tree_unit_code,
    unit.path AS tree_unit_path,
    min(unit_path.permission_scope) AS tree_unit_permission_scope
  FROM
    (
      SELECT
        res.parent_id AS user_id,
        trees->>'tree' AS tree_code,
        trees->>'tree_unit' AS tree_unit_code
      FROM
        cst_resources AS res,
        jsonb_array_elements(res.data->'trees') trees
    ) AS res
  JOIN
    core_trees AS tree
  ON
    tree.code = res.tree_code
  JOIN
    core_tree_units AS unit
  ON
    unit.tree_id = tree.id
    AND unit.code = res.tree_unit_code
  JOIN (
    SELECT
      unit_path.id AS unit_id,
      unit_path.tree_id AS tree_id,
      unit_path.permission_scope AS permission_scope,
      unit_path.path AS path,
      perm->>'structure_id' AS structure_id,
      perm->>'structure_type' AS structure_type,
      (perm->>'permission_type')::INT AS permission_type
    FROM 
      core_tree_units AS unit_path,
      jsonb_array_elements(unit_path.permissions) AS perm
    WHERE
      (perm->>'permission_type')::INT = 100
      AND unit_path.active = TRUE
  ) AS unit_path
  ON
    unit_path.tree_id = unit.tree_id
  JOIN
    core_schemas AS sch
  ON
    sch.id = unit_path.structure_id
  WHERE
    (
      unit_path.unit_id = unit.id
      AND unit_path.permission_scope IS NOT NULL
    )
    OR
    (
      unit.path <@ unit_path.path
      AND unit_path.permission_scope = 'unit_and_descendent'
    )
  GROUP BY
    res.user_id,
    sch.code,
    res.tree_code,
    res.tree_unit_code,
    unit.path;