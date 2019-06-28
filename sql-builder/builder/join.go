package builder

// joins add the relationship to another table
func joins(joinType, table, on string) Builder {
	return PrepareFunc(func(q Query) error {
		q.WriteString(" ")
		q.WriteString(joinType)
		q.WriteString(" ")
		q.WriteString(table)
		q.WriteString(" ON ")
		q.WriteString(on)
		return nil
	})
}

// Join add foreng table with inner join
func (s *Statement) Join(table, on string) *Statement {
	s.JoinTable = append(s.JoinTable, joins("JOIN", table, on))
	return s
}

// LeftJoin add foreng table with left join
func (s *Statement) LeftJoin(table, on string) *Statement {
	s.JoinTable = append(s.JoinTable, joins("LEFT JOIN", table, on))
	return s
}

// joinsSubQuery add the relationship to another table
func joinsSubQuery(joinType, alias string, statement *Statement, on Builder) Builder {
	return PrepareFunc(func(q Query) error {
		q.WriteString(" ")
		q.WriteString(joinType)
		q.WriteString(" (")
		if err := statement.Prepare(q); err != nil {
			return err
		}
		q.WriteString(") ")
		q.WriteString(alias)
		q.WriteString(" ON ")
		if err := on.Prepare(q); err != nil {
			return err
		}
		return nil
	})
}

// JoinSubQuery add foreng subquery with inner join
func (s *Statement) JoinSubQuery(alias string, statement *Statement, on Builder) *Statement {
	s.JoinTable = append(s.JoinTable, joinsSubQuery("JOIN", alias, statement, on))
	return s
}

// LeftJoinSubQuery add foreng subquery with left join
func (s *Statement) LeftJoinSubQuery(alias string, statement *Statement, on Builder) *Statement {
	s.JoinTable = append(s.JoinTable, joinsSubQuery("LEFT JOIN", alias, statement, on))
	return s
}
