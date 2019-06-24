package service

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/agile-work/srv-shared/sql-builder/db"
)

// Service represents a service in the system
type Service struct {
	InstanceCode string    `json:"instance_code"`
	Name         string    `json:"name"`
	Category     string    `json:"category"`
	Host         string    `json:"host"`
	Port         int       `json:"port"`
	PID          int       `json:"pid"`
	ConnectedAt  time.Time `json:"connected_at"`
	Uptime       string    `json:"uptime"`
}

// JSON returns service as a json byte array
func (s *Service) JSON() []byte {
	jsonBytes, _ := json.Marshal(s)
	return jsonBytes
}

// URL returns host:port
func (s *Service) URL() string {
	return fmt.Sprintf("%s:%d", s.Host, s.Port)
}

// GetUptime calculates service uptime
func (s *Service) GetUptime() {
	s.Uptime = fmt.Sprint(time.Now().Sub(s.ConnectedAt))
}

// New returns a new service entity
func New(name, category, host string, port, pid int) *Service {
	return &Service{
		InstanceCode: db.UUID(),
		Name:         name,
		Category:     category,
		Host:         host,
		Port:         port,
		PID:          pid,
		ConnectedAt:  time.Now(),
	}
}
