package builder

// Join add the relationship to another table
func join(table, on string) Builder {
	return PrepareFunc(func(q Query) error {
		q.WriteString(" JOIN ")
		q.WriteString(table)
		q.WriteString(" ON ")
		q.WriteString(on)
		return nil
	})
}

// Join add foreng table with inner join
func (s *Statement) Join(table, on string) *Statement {
	s.JoinTable = append(s.JoinTable, join(table, on))
	return s
}

// leftJoin add the relationship to another table
func leftJoin(table, on string) Builder {
	return PrepareFunc(func(q Query) error {
		q.WriteString(" LEFT JOIN ")
		q.WriteString(table)
		q.WriteString(" ON ")
		q.WriteString(on)
		return nil
	})
}

// LeftJoin add foreng table with left join
func (s *Statement) LeftJoin(table, on string) *Statement {
	s.JoinTable = append(s.JoinTable, leftJoin(table, on))
	return s
}
