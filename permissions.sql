-- Retorna permissões de estrutura de um usuário por unidade de árvore
SELECT DISTINCT
  res.user_id AS user_id,
  -- res.field AS field,
  -- res.tree AS tree,
  -- res.tree_unit AS tree_unit,
  -- unit.path AS path,
  sch.code AS schema_code,
  jsonb_array_elements(unit_path.permissions)->>'structure_type' AS structure_type,
  jsonb_array_elements(unit_path.permissions)->>'structure_id' AS structure_id,
  jsonb_array_elements(unit_path.permissions)->>'permission_type' AS permission_type
FROM
(
  SELECT
    res.parent_id AS user_id,
    -- jsonb_array_elements(res.data->'trees')->>'field' AS field,
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
JOIN core_sch_fields fld
ON unit_path.permissions @> ('[{"structure_id":"' || fld.id || '", "structure_type": "field"}]')::JSONB
JOIN core_schemas sch
ON sch.id = fld.schema_id
WHERE
(
  (
    unit_path.path = unit.path
    AND unit_path.permission_scope = 'unit_only'
  )
  OR
  (
    unit.path <@ unit_path.path
    AND unit_path.permission_scope = 'unit_and_descendent'
  )
)

-- Retorna permissões de estrutura de um usuário por grupo padrão
SELECT DISTINCT
  res.parent_id AS user_id,
  sch.code AS schema_code,
  jsonb_array_elements(grp.permissions)->>'structure_type' AS structure_type,
  jsonb_array_elements(grp.permissions)->>'structure_id' AS structure_id,
  jsonb_array_elements(grp.permissions)->>'permission_type' AS permission_type
FROM cst_resources AS res
JOIN core_groups grp
ON grp.users @> ('[{"id":"' || res.parent_id || '"}]')::JSONB
JOIN core_sch_fields fld
ON grp.permissions @> ('[{"structure_id":"' || fld.id || '", "structure_type": "field"}]')::JSONB
JOIN core_schemas sch
ON sch.id = fld.schema_id
WHERE grp.tree_unit_id IS NULL

-- Retorna permissões de estrutura de um usuário por instâncias
SELECT 
  inst.user_id AS user_id,
  fld.instance_type AS schema_code,
  jsonb_array_elements(inst.permissions)->>'structure_type' AS structure_type,
  jsonb_array_elements(inst.permissions)->>'structure_id' AS structure_id,
  jsonb_array_elements(inst.permissions)->>'permission_type' AS permission_type
FROM core_instance_premissions inst

