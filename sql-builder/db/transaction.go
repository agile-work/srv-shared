package db

import (
	"database/sql"

	"github.com/agile-work/srv-shared/sql-builder/builder"
)

// Transaction is an database transaction.
type Transaction struct {
	tx         *sql.Tx
	statements []builder.Statement
}

// Add new statement to be executed
func (t *Transaction) Add(statement builder.Statement) {
	t.statements = append(t.statements, statement)
}

// Exec executes a query that doesn't return rows. For example: an INSERT and UPDATE.
func (t *Transaction) Exec() error {
	for _, s := range t.statements {
		str, vals := s.Query()
		_, err := t.tx.Exec(str, vals...)
		if err != nil {
			t.tx.Rollback()
			return err
		}
	}
	t.tx.Commit()
	return nil
}

// NewTransaction returns a new transaction
func NewTransaction() (*Transaction, error) {
	tx, err := db.Begin()
	if err != nil {
		return nil, err
	}
	return &Transaction{
		tx: tx,
	}, nil
}
