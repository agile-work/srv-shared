package builder

import "fmt"

// handlerJSON add the relationship to another table
func handlerJSON(action, column, path, value string, opt bool) Builder {
	return PrepareFunc(func(q Query) error {
		q.WriteString(" ")
		q.WriteString(column)
		q.WriteString(" = ")
		q.WriteString(action)
		q.WriteString("(")
		q.WriteString(column)
		q.WriteString(",")
		q.WriteString(path)
		q.WriteString("::text[],")
		q.WriteString(value)
		q.WriteString(",")
		q.WriteString(fmt.Sprintf("%v", opt))
		q.WriteString(") ")
		return nil
	})
}

// InsertJSON defines statement columns from a json column with defined fields
func (s *Statement) InsertJSON(column, path, value string, insertAfter bool) *Statement {
	s.JSONHandler = append(s.JSONHandler, handlerJSON("jsonb_insert", column, path, value, insertAfter))
	return s
}

// UpdateJSON defines statement columns from a json column with defined fields
func (s *Statement) UpdateJSON(column, path, value string, createMissing bool) *Statement {
	s.JSONHandler = append(s.JSONHandler, handlerJSON("jsonb_set", column, path, value, createMissing))
	return s
}
