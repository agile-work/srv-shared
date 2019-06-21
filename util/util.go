package util

import (
	"strings"

	"github.com/agile-work/srv-shared/constants"
	"github.com/agile-work/srv-shared/sql-builder/builder"
	"github.com/agile-work/srv-shared/sql-builder/db"
)

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
