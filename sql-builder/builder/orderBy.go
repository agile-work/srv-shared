package builder

// OrderBy defines statement order by select
func (s *Statement) OrderBy(columns ...Builder) *Statement {
	s.OrderByOpt = orderBy(columns...)
	return s
}

func orderBy(columns ...Builder) Builder {
	return PrepareFunc(func(q Query) error {
		q.WriteString(" ORDER BY ")
		for i, column := range columns {
			err := column.Prepare(q)
			if err != nil {
				return err
			}
			if i+1 != len(columns) {
				q.WriteString(", ")
			}
		}
		return nil
	})
}

// OrderBy defines an array builder to use in a statement
func OrderBy(columns ...Builder) []Builder {
	return columns
}

// Asc creates an ascending sort column
func Asc(column string) Builder {
	return PrepareFunc(func(q Query) error {
		q.WriteString(column)
		q.WriteString(" ASC")
		return nil
	})
}

// Desc creates an descending sort column
func Desc(column string) Builder {
	return PrepareFunc(func(q Query) error {
		q.WriteString(column)
		q.WriteString(" DESC")
		return nil
	})
}
