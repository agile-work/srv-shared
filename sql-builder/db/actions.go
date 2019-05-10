package db

import (
	"database/sql"
	"fmt"
	"reflect"
	"strings"

	"github.com/agile-work/srv-shared/sql-builder/builder"
)

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

// LoadStruct select struct values from the database table.
// model must be a pointer to a struct or an array.
func LoadStruct(table string, model interface{}, conditions builder.Builder) error {
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

// InsertStruct insert struct values in the database table
func InsertStruct(table string, model interface{}) (string, error) {
	var err error
	id := ""
	query := ""
	values := []interface{}{}
	if reflect.TypeOf(model).Kind() == reflect.Slice {
		query, values = StructMultipleInsertQuery(table, model)
		_, err = db.Exec(query, values...)
	} else {
		query, values = StructInsertQuery(table, model)
		err = db.QueryRow(query, values...).Scan(&id)
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
	return db.Query(query.String(), query.Value()...)
}
