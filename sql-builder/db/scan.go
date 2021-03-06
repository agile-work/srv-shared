package db

import (
	"database/sql"
	"encoding/json"
	"reflect"
	"sort"
	"strings"
)

// MapScan scan rows to a map
func MapScan(rows *sql.Rows) ([]map[string]interface{}, error) {
	cols, _ := rows.Columns()

	results := []map[string]interface{}{}

	for rows.Next() {
		columns := make([]interface{}, len(cols))
		columnPointers := make([]interface{}, len(cols))
		for i := range columns {
			columnPointers[i] = &columns[i]
		}

		if err := rows.Scan(columnPointers...); err != nil {
			return nil, err
		}

		mapJSON := make(map[string]interface{})
		for i, colName := range cols {
			val := columnPointers[i].(*interface{})
			source, ok := columns[i].([]byte)
			if ok {
				var raw json.RawMessage
				_ = json.Unmarshal(source, &raw)
				mapJSON[colName] = raw
			} else {
				mapJSON[colName] = *val
			}
		}
		results = append(results, mapJSON)
	}
	rows.Close()

	if len(results) == 0 {
		return nil, nil
	}

	results = processEmbeddedStructs(results)

	return results, nil
}

// StructScan write rows data to struct array or struct
func StructScan(rows *sql.Rows, obj interface{}) error {

	results, err := MapScan(rows)
	if err != nil {
		return err
	}

	if len(results) == 0 {
		return nil
	}

	var jsonMap []byte
	if reflect.TypeOf(obj).Elem().Kind() == reflect.Struct {
		jsonMap, _ = json.Marshal(results[0])
	} else {
		jsonMap, _ = json.Marshal(results)
	}

	return json.Unmarshal(jsonMap, obj)
}

func processEmbeddedStructs(results []map[string]interface{}) []map[string]interface{} {
	for i, row := range results {
		embeddedColumnName := ""
		embeddedMap := map[string]interface{}{}

		sortedKeys := make([]string, 0, len(row))
		for k := range row {
			sortedKeys = append(sortedKeys, k)
		}
		sort.Strings(sortedKeys)

		for _, col := range sortedKeys {
			index := strings.Index(col, "__")
			if index >= 0 {
				if embeddedColumnName == "" {
					embeddedColumnName = col[0:index]
					embeddedMap = make(map[string]interface{})
					embeddedMap[col[index+2:]] = row[col]
				} else if embeddedColumnName != col[0:index] {
					results[i][embeddedColumnName] = embeddedMap
					embeddedColumnName = col[0:index]
					embeddedMap = make(map[string]interface{})
					embeddedMap[col[index+2:]] = row[col]
				} else {
					embeddedMap[col[index+2:]] = row[col]
				}
			}
		}
		if embeddedColumnName != "" {
			results[i][embeddedColumnName] = embeddedMap
		}
	}
	return results
}
