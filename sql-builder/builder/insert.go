package builder

// Insert returns a statement
func Insert(table string, columns ...string) *Statement {
	return &Statement{
		Type:        "insert",
		Table:       table,
		Columns:     columns,
		JSONColumns: make(map[string][]string),
	}
}

// Return include in insert statement the return columns
func (s *Statement) Return(columns ...string) *Statement {
	s.ReturnColumns = append(s.ReturnColumns, columns...)
	return s
}

// InsertJSON returns a statement
func InsertJSON(table, column, json string) *Statement {
	s := &Statement{
		Type:       "insert_json",
		Table:      table,
		JSONObject: json,
	}
	s.Columns = append(s.Columns, column)
	return s
}
