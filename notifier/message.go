package notifier

import (
	"encoding/json"
	"time"
)

// Message represents a notification
type Message struct {
	StructureID   string    `json:"structure_id"`
	StructureType string    `json:"structure_type"`
	Scope         string    `json:"scope"`
	Action        string    `json:"action"`
	Link          string    `json:"link"`
	Sender        string    `json:"sender"`
	Body          []byte    `json:"body"`
	CreatedAt     time.Time `json:"created_at"`
	Ack           bool      `json:"acknowledged"`
	EmailSent     bool      `json:"email_sent"`
	UserID        string    `json:"user_id"`
}

// String returns message body as a string
func (m *Message) String() string {
	return string(m.Body)
}

// StringToBody sets the body byte array
func (m *Message) StringToBody(value string) {
	m.Body = []byte(value)
}

// StructToBody sets the body byte array
func (m *Message) StructToBody(value interface{}) {
	jsonBody, err := json.Marshal(value)
	if err != nil {
		// TODO: log this erro to file
		m.Body = nil
		return
	}
	m.Body = jsonBody
}

// BodyToStruct loads an struct from the body byte array to an object pointer
func (m *Message) BodyToStruct(object interface{}) {
	err := json.Unmarshal(m.Body, object)
	if err != nil {
		// TODO: log this erro to file
	}
}
