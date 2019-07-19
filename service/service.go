package service

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/agile-work/srv-shared/constants"
	"github.com/agile-work/srv-shared/sql-builder/builder"
	"github.com/agile-work/srv-shared/sql-builder/db"
)

// Service represents a service in the system
type Service struct {
	InstanceCode string    `json:"instance_code"`
	Name         string    `json:"name"`
	Category     string    `json:"category"`
	Mode         string    `json:"mode,omitempty"`
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

// RemoveModuleRegister deletes this instance from the database modules table if temporary
func (s *Service) RemoveModuleRegister() {
	if s.Mode == constants.ModuleInstanceModePersistent || s.Category != constants.ServiceTypeModule {
		return
	}

	query := fmt.Sprintf(`WITH data_object as (
		select index-1 as obj_index from %s ,jsonb_array_elements(definitions->'instances') with ordinality arr(obj, index)
		where ((obj->>'id') = '%s') and (code = '%s')
	)
	UPDATE %s
	SET definitions = definitions #- ('{instances, '||data_object.obj_index||'}') ::text[]
	from data_object
	where (code = '%s')`, constants.TableCoreModules, s.InstanceCode, s.Name, constants.TableCoreModules, s.Name)
	err := db.Exec(builder.Raw(query))
	if err != nil {
		fmt.Println(err.Error())
	}
}

// LoadModule load from database the module configuration
func LoadModule(code, host string, port, pid int, store bool) (*Service, error) {
	s := &Service{
		Category:    constants.ServiceTypeModule,
		PID:         pid,
		ConnectedAt: time.Now(),
	}

	query := fmt.Sprintf(`select 
		mdl.code as name, 
		instances.id as instance_code,
		instances.host,
		instances.port,
		instances.mode
	from 
		%s mdl 
		left join (
			select mdl.code, ist.id, ist.host, ist.port, ist.mode from %s mdl, lateral jsonb_to_recordset(mdl.definitions->'instances') as ist(id text, host text, mode text, port int)
		) instances on instances.code = mdl.code and instances.host = ? and instances.port = ?
	where mdl.code = ? and mdl.status = 'ready'`, constants.TableCoreModules, constants.TableCoreModules)
	rows, err := db.Query(builder.Raw(query, host, port, code))

	if err != nil {
		return nil, err
	}

	if err := db.StructScan(rows, s); err != nil {
		return nil, err
	}

	if s.Name == "" {
		return nil, fmt.Errorf("module %s not installed", code)
	}

	if s.InstanceCode != "" {
		return s, nil
	}

	s.InstanceCode = db.UUID()
	s.Name = code
	s.Host = host
	s.Port = port
	s.Mode = constants.ModuleInstanceModeTemporary
	if store {
		s.Mode = constants.ModuleInstanceModePersistent
	}

	i := &instance{
		ID:        s.InstanceCode,
		Host:      s.Host,
		Port:      s.Port,
		Mode:      s.Mode,
		CreatedAt: time.Now(),
		CreatedBy: "admin",
		UpdatedAt: time.Now(),
		UpdatedBy: "admin",
	}

	instanceBytes, err := json.Marshal(i)
	if err != nil {
		return nil, err
	}

	query = fmt.Sprintf(`update %s set definitions = jsonb_set(
		definitions,
		'{instances}'::text[],
		definitions->'instances' || '[%s]'::jsonb,
		true
	)	
	where code = '%s'`, constants.TableCoreModules, string(instanceBytes), code)
	err = db.Exec(builder.Raw(query))
	if err != nil {
		return nil, err
	}

	return s, nil
}

// New returns a new service entity
func New(code, category, host string, port, pid int) *Service {
	return &Service{
		InstanceCode: db.UUID(),
		Name:         code,
		Category:     category,
		Host:         host,
		Port:         port,
		PID:          pid,
		ConnectedAt:  time.Now(),
	}
}

type instance struct {
	ID        string    `json:"id"`
	Host      string    `json:"host"`
	Port      int       `json:"port"`
	Mode      string    `json:"mode"`
	CreatedBy string    `json:"created_by" sql:"created_by"`
	CreatedAt time.Time `json:"created_at" sql:"created_at"`
	UpdatedBy string    `json:"updated_by" sql:"updated_by"`
	UpdatedAt time.Time `json:"updated_at" sql:"updated_at"`
}
