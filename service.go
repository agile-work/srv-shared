package shared

import (
	"time"

	"github.com/agile-work/srv-shared/sql-builder/builder"
	"github.com/agile-work/srv-shared/sql-builder/db"
)

const (
	//ServiceTypeExternal defines an external service
	ServiceTypeExternal string = "external"
	//ServiceTypeModule defines an module service
	ServiceTypeModule string = "module"
	//ServiceTypeAuxiliary defines an auxiliary service
	ServiceTypeAuxiliary string = "auxiliary"
)

//Service represents a service in the system
type Service struct {
	ID           string    `json:"id" sql:"id" pk:"true"`
	Code         string    `json:"code" sql:"code"`
	Type         string    `json:"service_type" sql:"service_type"`
	HeartbeatAt  time.Time `json:"heartbeat_at" sql:"heartbeat_at"`
	RegisteredAt time.Time `json:"registered_at" sql:"registered_at"`
	Active       bool      `json:"active" sql:"active"`
}

//Heartbeat update service in the database
func (s *Service) Heartbeat(t time.Time) error {
	s.Active = true
	s.HeartbeatAt = t
	return db.UpdateStruct(TableCoreServices, s, builder.Equal("id", s.ID), "heartbeat_at", "active")
}

//Down set service down in the database
func (s *Service) Down() error {
	s.Active = false
	return db.UpdateStruct(TableCoreServices, s, builder.Equal("id", s.ID), "active")
}

//RegisterService register the service in the database
func RegisterService(code, serviceType string) (*Service, error) {
	service := Service{
		Code:         code,
		Type:         serviceType,
		HeartbeatAt:  time.Now(),
		RegisteredAt: time.Now(),
		Active:       true,
	}
	id, err := db.InsertStruct(TableCoreServices, &service)
	if err != nil {
		return nil, err
	}
	service.ID = id
	return &service, nil
}
