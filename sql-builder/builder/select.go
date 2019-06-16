package builder

// Select returns a statement with columns
func Select(columns ...string) *Statement {
	return &Statement{
		Type:        "select",
		Columns:     columns,
		JSONColumns: make(map[string][]string),
	}
}

// JSON defines statement columns from a json column with defined fields
func (s *Statement) JSON(column string, fields ...string) *Statement {
	if len(fields) > 0 {
		s.JSONColumns[column] = append(s.JSONColumns[column], fields...)
	}
	return s
}

// From defines statement from table
func (s *Statement) From(table string) *Statement {
	s.Table = table
	return s
}

// Limit defines statement limit select
func (s *Statement) Limit(value int) *Statement {
	s.LimitOpt = value
	return s
}

// Offset defines statement offset select
func (s *Statement) Offset(value int) *Statement {
	s.OffsetOpt = value
	return s
}
