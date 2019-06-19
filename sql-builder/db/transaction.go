package db

import (
	"database/sql"

	"github.com/agile-work/srv-shared/sql-builder/builder"
)

// Transaction is an database transaction.
type Transaction struct {
	Tx         *sql.Tx
	statements []*builder.Statement
}

// Add new statement to be executed
func (t *Transaction) Add(statement *builder.Statement) {
	t.statements = append(t.statements, statement)
}

// Exec executes a query that doesn't return rows. For example: an INSERT and UPDATE.
func (t *Transaction) Exec() error {
	for _, s := range t.statements {
		str, vals := s.Query()
		_, err := t.Tx.Exec(str, vals...)
		if err != nil {
			t.Tx.Rollback()
			printQueryIfError(err, str, vals)
			return err
		}
	}
	t.Tx.Commit()
	return nil
}

// Query executes a query returning rows when this method is called.
func (t *Transaction) Query(statement *builder.Statement) (*sql.Rows, error) {
	str, vals := statement.Query()
	rows, err := t.Tx.Query(str, vals...)
	if err != nil {
		printQueryIfError(err, str, vals)
		return nil, err
	}
	return rows, nil
}

// Commit executes the commit action
func (t *Transaction) Commit() {
	t.Tx.Commit()
}

// Rollback executes the rollback action
func (t *Transaction) Rollback() {
	t.Tx.Rollback()
}

// NewTransaction returns a new transaction
func NewTransaction() (*Transaction, error) {
	tx, err := db.Begin()
	if err != nil {
		return nil, err
	}
	return &Transaction{
		Tx: tx,
	}, nil
}
