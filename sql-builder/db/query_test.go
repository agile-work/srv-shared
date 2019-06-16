package db

import (
	"fmt"
	"testing"

	"github.com/agile-work/srv-shared/sql-builder/builder"
	"github.com/stretchr/testify/assert"
)

type user struct {
}

func TestStructSelectQuery(t *testing.T) {
	user := user{}

	query, values, err := StructSelectQuery("core_users", &user, Options{Conditions: builder.Equal("core_users.id", "57a97aaf-16da-44ef-a8be-b1caf52becd6")})
	assert.NoError(t, err, "invalid interface")
	fmt.Println(values)
	assert.Equal(t, "query", query)
}
