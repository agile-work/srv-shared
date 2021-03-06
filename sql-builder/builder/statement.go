package builder

import (
	"fmt"
	"strconv"
	"strings"
)

// Statement represents a sql query
type Statement struct {
	Type          string
	Table         string
	Columns       []string
	WhereCond     Builder
	JoinTable     []Builder
	Data          []interface{}
	ReturnColumns []string
	JSONColumns   map[string][]string
	JSONHandler   []Builder
	JSONObject    string
	JSONWhereCond Builder
	RawQuery      string
	LimitOpt      int
	OffsetOpt     int
	OrderByOpt    Builder
}

// Query returns query as a string with an array with values
func (s *Statement) Query() (string, []interface{}) {
	query := NewQuery()
	s.Prepare(query)
	return query.String(), query.Value()
}

// Values defines the input data to insert and update
func (s *Statement) Values(values ...interface{}) *Statement {
	s.Data = append(s.Data, values...)
	return s
}

// Prepare build the query that will be executed
func (s *Statement) Prepare(q Query) error {
	var err error
	switch s.Type {
	case "raw":
		err = prepareRaw(s, q)
	case "select":
		err = prepareSelect(s, q)
	case "insert":
		err = prepareInsert(s, q)
	case "insert_json":
		err = prepareJSONInsert(s, q)
	case "update":
		err = prepareUpdate(s, q)
	case "delete":
		err = prepareDelete(s, q)
	}

	queryPlaceHolder := q.String()
	total := strings.Count(queryPlaceHolder, "?")
	for i := 0; i < total; i++ {
		placeholder := "$" + strconv.Itoa(i+1)
		queryPlaceHolder = strings.Replace(queryPlaceHolder, "?", placeholder, 1)
	}
	q.Reset()
	q.WriteString(queryPlaceHolder)

	return err
}

func prepareRaw(s *Statement, q Query) error {
	q.WriteString(s.RawQuery)

	if s.WhereCond != nil {
		err := s.WhereCond.Prepare(q)
		if err != nil {
			return err
		}
	}

	q.WriteValue(s.Data...)
	return nil
}

func prepareJSONInsert(s *Statement, q Query) error {
	q.WriteString("UPDATE ")
	q.WriteString(s.Table)
	q.WriteString(" SET ")

	jsonColumn := ""
	if len(s.Columns) > 0 {
		jsonColumn = s.Columns[0]
	}
	q.WriteString(jsonColumn)
	q.WriteString(" = ")
	q.WriteString(jsonColumn)
	q.WriteString(" || '")
	q.WriteString(s.JSONObject)
	q.WriteString("' ")

	if s.WhereCond != nil {
		err := s.WhereCond.Prepare(q)
		if err != nil {
			return err
		}
	}

	return nil
}

func prepareSelect(s *Statement, q Query) error {

	q.WriteString("SELECT ")
	q.WriteString(strings.Join(s.Columns, ", "))

	if len(s.JSONColumns) > 0 {
		if len(s.Columns) > 0 {
			q.WriteString(", ")
		}
		for column, fields := range s.JSONColumns {
			for i, f := range fields {
				if i > 0 {
					q.WriteString(", ")
				}
				jsonCol := fmt.Sprintf("%s->>'%s' AS %s", column, f, f)
				q.WriteString(jsonCol)
			}
		}
	}

	q.WriteString(" FROM ")
	q.WriteString(s.Table)

	//joins
	if len(s.JoinTable) > 0 {
		for _, join := range s.JoinTable {
			err := join.Prepare(q)
			if err != nil {
				return err
			}
		}
	}

	if s.WhereCond != nil {
		err := s.WhereCond.Prepare(q)
		if err != nil {
			return err
		}
	}

	if s.OrderByOpt != nil {
		err := s.OrderByOpt.Prepare(q)
		if err != nil {
			return err
		}
	}

	if s.LimitOpt > 0 {
		q.WriteString(" LIMIT ")
		q.WriteString(strconv.Itoa(s.LimitOpt))
	}

	if s.OffsetOpt > 0 {
		q.WriteString(" OFFSET ")
		q.WriteString(strconv.Itoa(s.OffsetOpt))
	}

	return nil
}

func prepareInsert(s *Statement, q Query) error {
	q.WriteString("INSERT INTO ")
	q.WriteString(s.Table)
	q.WriteString(" (")
	q.WriteString(strings.Join(s.Columns, ", "))
	q.WriteString(") ")

	q.WriteString("VALUES ")
	records := len(s.Data) / len(s.Columns)
	for i := 0; i < records; i++ {
		if i > 0 {
			q.WriteString(", ")
		}
		q.WriteString("(")
		for i := 0; i < len(s.Columns); i++ {
			if i > 0 {
				q.WriteString(", ")
			}
			q.WriteString("?")
		}
		q.WriteString(")")
	}

	if len(s.ReturnColumns) > 0 {
		q.WriteString(" RETURNING ")
		for i, col := range s.ReturnColumns {
			if i > 0 {
				q.WriteString(", ")
			}
			q.WriteString(col)
		}
	}

	q.WriteValue(s.Data...)

	return nil
}

func prepareUpdate(s *Statement, q Query) error {
	q.WriteString("UPDATE ")
	q.WriteString(s.Table)
	q.WriteString(" SET ")

	for i, col := range s.Columns {
		if i > 0 {
			q.WriteString(", ")
		}
		q.WriteString(col)
		q.WriteString(" = ?")
	}

	if len(s.JSONColumns) > 0 {
		if len(s.Columns) > 0 {
			q.WriteString(", ")
		}
		i := 0
		for column, fields := range s.JSONColumns {
			if i > 0 {
				q.WriteString(", ")
			}
			jsonCol := fmt.Sprintf("%s = jsonb_set(%s::jsonb,'{%s}'::text[],(?)::jsonb, true)", column, column, fields[0])
			q.WriteString(jsonCol)
			i++
		}
	}

	if len(s.JSONHandler) > 0 {
		if len(s.Columns) > 0 {
			q.WriteString(", ")
		}
		for i, jsonHandler := range s.JSONHandler {
			if i > 0 {
				q.WriteString(", ")
			}
			jsonHandler.Prepare(q)
		}
	}

	q.WriteValue(s.Data...)

	err := s.WhereCond.Prepare(q)
	if err != nil {
		return err
	}

	return nil
}

func prepareDelete(s *Statement, q Query) error {
	q.WriteString("DELETE FROM ")
	q.WriteString(s.Table)

	err := s.WhereCond.Prepare(q)
	if err != nil {
		return err
	}

	return nil
}
