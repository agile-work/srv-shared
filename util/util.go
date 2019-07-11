package util

import (
	"database/sql"
	"encoding/json"
	"strings"

	"github.com/agile-work/srv-shared/constants"
	"github.com/agile-work/srv-shared/sql-builder/builder"
	"github.com/agile-work/srv-shared/sql-builder/db"
)

// Remove an item from a slice
func Remove(slice []string, match string) []string {
	for i, v := range slice {
		if v == match {
			return append(slice[:i], slice[i+1:]...)
		}
	}
	return slice
}

// Contains check if slice contains string
func Contains(slice []string, match ...string) bool {
	if slice == nil || len(match) == 0 {
		return false
	}
	result := false
	for _, m := range match {
		found := false
		for _, s := range slice {
			if strings.ToLower(s) == strings.ToLower(m) {
				found = true
				break
			}
		}
		result = found
	}
	return result
}

// GetSystemParams return system parameters
func GetSystemParams() (map[string]string, error) {
	statemant := builder.Select(
		"param_key",
		"param_value",
	).From(constants.TableCoreSystemParams)
	rows, err := db.Query(statemant)
	if err != nil {
		return nil, err
	}

	params := map[string]string{}

	for rows.Next() {
		var key, value string
		if err := rows.Scan(&key, &value); err != nil {
			return nil, err
		}
		params[key] = value
	}

	return params, nil
}

// RowToMap transform a db row to map
func RowToMap(row *sql.Rows) (map[string]interface{}, error) {
	cols, err := row.Columns()
	if err != nil {
		return nil, err
	}

	columns := make([]interface{}, len(cols))
	columnPointers := make([]interface{}, len(cols))
	for i := range columns {
		columnPointers[i] = &columns[i]
	}

	if err := row.Scan(columnPointers...); err != nil {
		return nil, err
	}

	rowMap := make(map[string]interface{})
	for i, column := range cols {
		val := columnPointers[i].(*interface{})
		if source, ok := columns[i].([]byte); ok {
			var raw json.RawMessage
			if err := json.Unmarshal(source, &raw); err != nil {
				return nil, err
			}
			rowMap[column] = raw
		} else {
			rowMap[column] = *val
		}
	}

	return rowMap, nil
}
