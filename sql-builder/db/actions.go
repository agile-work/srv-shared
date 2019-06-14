package db

import (
	"database/sql"
	"fmt"
	"reflect"
	"strings"

	"github.com/agile-work/srv-shared/sql-builder/builder"
)

// QueryStruct prepare and execute the statement and then populates the model
// model must be a pointer to a struct or an array.
func QueryStruct(statement builder.Builder, model interface{}) error {
	query := builder.NewQuery()
	statement.Prepare(query)
	rows, err := db.Query(query.String(), query.Value()...)
	printQueryIfError(err, query.String(), query.Value())
	if err != nil {
		return err
	}

	return StructScan(rows, model)
}

// SelectStruct select struct values from the database table.
// model must be a pointer to a struct or an array.
func SelectStruct(table string, model interface{}, conditions builder.Builder) error {
	query, values, err := StructSelectQuery(table, model, conditions)
	if err != nil {
		return err
	}
	rows, err := db.Query(query, values...)
	printQueryIfError(err, query, values)
	if err != nil {
		return err
	}

	return StructScan(rows, model)
}

// SelectStructTx select struct values from the database table.
// model must be a pointer to a struct or an array.
func SelectStructTx(tx *sql.Tx, table string, model interface{}, conditions builder.Builder) error {
	query, values, err := StructSelectQuery(table, model, conditions)
	if err != nil {
		return err
	}
	rows, err := tx.Query(query, values...)
	printQueryIfError(err, query, values)
	if err != nil {
		return err
	}

	return StructScan(rows, model)
}

// InsertStruct insert struct values in the database table
func InsertStruct(table string, model interface{}, fields ...string) (string, error) {
	var err error
	id := ""
	query := ""
	values := []interface{}{}
	if reflect.TypeOf(model).Kind() == reflect.Slice {
		query, values = StructMultipleInsertQuery(table, model, strings.Join(fields, ","))
		_, err = db.Exec(query, values...)
	} else {
		query, values = StructInsertQuery(table, model, strings.Join(fields, ","), false).Query()
		err = db.QueryRow(query, values...).Scan(&id)
	}
	printQueryIfError(err, query, values)

	return id, err
}

// InsertStructTx insert struct values in the database table
func InsertStructTx(tx *sql.Tx, table string, model interface{}, fields ...string) (string, error) {
	var err error
	id := ""
	query := ""
	values := []interface{}{}
	if reflect.TypeOf(model).Kind() == reflect.Slice {
		query, values = StructMultipleInsertQuery(table, model, strings.Join(fields, ","))
		_, err = tx.Exec(query, values...)
	} else {
		query, values = StructInsertQuery(table, model, strings.Join(fields, ","), false).Query()
		err = tx.QueryRow(query, values...).Scan(&id)
	}
	printQueryIfError(err, query, values)

	return id, err
}

// UpdateStruct update struct values in the database table
func UpdateStruct(table string, model interface{}, conditions builder.Builder, fields ...string) error {
	query, values, err := StructUpdateQuery(table, model, strings.Join(fields, ","), conditions)
	if err != nil {
		return err
	}
	_, err = db.Exec(query, values...)
	printQueryIfError(err, query, values)
	return err
}

// UpdateStructTx update struct values in the database table
func UpdateStructTx(tx *sql.Tx, table string, model interface{}, conditions builder.Builder, fields ...string) error {
	query, values, err := StructUpdateQuery(table, model, strings.Join(fields, ","), conditions)
	if err != nil {
		return err
	}
	_, err = tx.Exec(query, values...)
	printQueryIfError(err, query, values)
	return err
}

// DeleteStruct delete struct instance in the database table
func DeleteStruct(table string, conditions builder.Builder) error {
	query, values, err := StructDeleteQuery(table, conditions)
	if err != nil {
		return err
	}
	_, err = db.Exec(query, values...)
	printQueryIfError(err, query, values)
	return err
}

// DeleteStructTx delete struct instance in the database table
func DeleteStructTx(tx *sql.Tx, table string, conditions builder.Builder) error {
	query, values, err := StructDeleteQuery(table, conditions)
	if err != nil {
		return err
	}
	_, err = tx.Exec(query, values...)
	printQueryIfError(err, query, values)
	return err
}

// Exec prepare the statement and insert into the database
func Exec(statement builder.Builder) error {
	query := builder.NewQuery()
	statement.Prepare(query)
	_, err := db.Exec(query.String(), query.Value()...)
	printQueryIfError(err, query.String(), query.Value())
	return err
}

// Query prepare the statement, executes and returns the Rows
func Query(statement builder.Builder) (*sql.Rows, error) {
	query := builder.NewQuery()
	statement.Prepare(query)
	rows, err := db.Query(query.String(), query.Value()...)
	printQueryIfError(err, query.String(), query.Value())
	return rows, err
}

// Count prepare the statement, executes and return the total of lines
func Count(field, table string, conditions builder.Builder) (int, error) {
	countColumn := fmt.Sprintf("count(%s.%s) as total", table, field)
	statement := builder.Select(countColumn).From(table).Where(conditions)
	query, values := statement.Query()
	total := 0
	err := db.QueryRow(query, values...).Scan(&total)
	if err != nil && err != sql.ErrNoRows {
		return -1, err
	}
	return total, nil
}

// printQueryIfError show information about query execution if has error
func printQueryIfError(err error, query string, values []interface{}) {
	if err != nil {
		fmt.Print("\033[1;31m\nError on execution query:\n\033[0m")
		fmt.Print(err)
		fmt.Print("\033[1;33m\n\nQuery:\n\033[0m")
		fmt.Print(query)
		if values != nil {
			fmt.Print("\033[1;33m\n\nParameters:\n\033[0m")
			fmt.Printf("%s\n\n", values)
		}
	}
}
