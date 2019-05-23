package notifier

import (
	"time"
)

// Message represents a notification
type Message struct {
	ID            string      `json:"id" sql:"id"`
	StructureID   string      `json:"structure_id" sql:"structure_id"`
	StructureType string      `json:"structure_type" sql:"structure_type"`
	Action        string      `json:"action" sql:"action"`
	Link          string      `json:"link" sql:"link"`
	Sender        string      `json:"sender_id" sql:"sender_id"`
	Payload       interface{} `json:"payload" sql:"payload" field:"jsonb"`
	Body          string      `json:"body" sql:"body"`
	CreatedAt     time.Time   `json:"created_at" sql:"created_at"`
	UpdatedAt     time.Time   `json:"updated_at" sql:"updated_at"`
	Ack           bool        `json:"acknowledged" sql:"acknowledged"`
	UserID        string      `json:"user_id" sql:"user_id"`
}

// // String returns message body as a string
// func (m *Message) String() string {
// 	return string(m.Body)
// }

// // StringToBody sets the body byte array
// func (m *Message) StringToBody(value string) {
// 	m.Body = []byte(value)
// }

// // StructToBody sets the body byte array
// func (m *Message) StructToBody(value interface{}) {
// 	jsonBody, err := json.Marshal(value)
// 	if err != nil {
// 		// TODO: log this erro to file
// 		m.Body = nil
// 		return
// 	}
// 	m.Body = jsonBody
// }

// // BodyToStruct loads an struct from the body byte array to an object pointer
// func (m *Message) BodyToStruct(object interface{}) {
// 	err := json.Unmarshal(m.Body, object)
// 	if err != nil {
// 		// TODO: log this erro to file
// 	}
// }
