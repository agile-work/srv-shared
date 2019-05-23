package notifier

import (
	"testing"

	"github.com/agile-work/srv-shared/sql-builder/db"
	"github.com/stretchr/testify/suite"
)

type NotifierTestSuite struct {
	suite.Suite
}

func (suite *NotifierTestSuite) SetupTest() {
	db.Connect(
		"cryo.cdnm8viilrat.us-east-2.rds-preview.amazonaws.com",
		5432,
		"cryoadmin",
		"x3FhcrWDxnxCq9p",
		"cryo",
		false,
	)
}

func (suite *NotifierTestSuite) Test00001New() {
	// message := Message{
	// 	StructureID:   "f8962d76-7b57-11e9-8160-06ea2c43bb20",
	// 	StructureType: "intance",
	// }
	message := Message{
		StructureID:   "f8962d76-7b57-11e9-8160-06ea2c43bb20",
		StructureType: "instance",
		Action:        "update_contract",
		Link:          "http://localhost:8081/core/instances/f8962d76-7b57-11e9-8160-06ea2c43bb20",
		Sender:        "Contract, Manager",
		Body:          "O contrato CTR001 foi atualizado pelo usuário Contract, Manager",
		UserID:        "f03e9a26-7b4f-11e9-9a66-06ea2c43bb20",
	}

	receiver := Receiver{
		Users: []string{
			"307e481c-69c5-11e9-96a0-06ea2c43bb20",
			"e3f476f0-7b4f-11e9-ae2a-06ea2c43bb20",
		},
		Followers: false,
		Broadcast: false,
	}

	New(message, receiver, false, false)
}

// In order for 'go test' to run this suite, we need to create
// a normal test function and pass our suite to suite.Run
func TestNotifierSuite(t *testing.T) {
	suite.Run(t, new(NotifierTestSuite))
}
