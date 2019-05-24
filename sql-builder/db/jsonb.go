package db

import (
	"encoding/json"
	"fmt"

	"github.com/agile-work/srv-shared/sql-builder/builder"
)

// InsertStructToJSON insert a new instance in the json column
func InsertStructToJSON(column, table string, object interface{}, conditions builder.Builder) error {
	jsonBytes, err := json.Marshal(object)
	if err != nil {
		return err
	}

	statement := builder.InsertJSON(table, column, string(jsonBytes))

	if conditions != nil {
		statement.Where(conditions)
	}

	query := builder.NewQuery()
	statement.Prepare(query)

	_, err = db.Exec(query.String(), query.Value()...)
	return err
}

// UpdateStructToJSON update an existing object in the json column
func UpdateStructToJSON(jsonObjectID, instanceID, column, table string, object interface{}) error {
	jsonBytes, err := json.Marshal(object)
	if err != nil {
		return err
	}

	sql := fmt.Sprintf(`WITH data_object as ( select index-1 as obj_index from %s ,jsonb_array_elements(%s) with ordinality arr(obj, index)
			where ((obj->>'id') = '%s') and (id = '%s')
		)
		update %s set %s = jsonb_set(
		%s,
		('{'||data_object.obj_index||'}') ::text[],
		%s::jsonb#>('{'||data_object.obj_index||'}')::text[] || '%s',
		true
		) from data_object
		where (id = '%s')`, table, column, jsonObjectID, instanceID, table, column, column, column, string(jsonBytes), instanceID)

	statement := builder.Raw(sql)
	query := builder.NewQuery()
	statement.Prepare(query)

	_, err = db.Exec(query.String(), query.Value()...)
	return err
}

// DeleteStructFromJSON delete an object in the json column
func DeleteStructFromJSON(jsonObjectID, instanceID, column, table string) error {
	sql := fmt.Sprintf(`WITH data_object as (
		select index-1 as obj_index from %s ,jsonb_array_elements(%s) with ordinality arr(obj, index)
		where ((obj->>'id') = '%s') and (id = '%s')
	)
	UPDATE %s
	SET %s = %s #- ('{'||data_object.obj_index||'}') ::text[]
	from data_object
	where (id = '%s')`, table, column, jsonObjectID, instanceID, table, column, column, instanceID)

	statement := builder.Raw(sql)
	query := builder.NewQuery()
	statement.Prepare(query)

	_, err := db.Exec(query.String(), query.Value()...)
	return err
}
