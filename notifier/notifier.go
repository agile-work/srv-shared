package notifier

import (
	"encoding/json"
	"time"
)

type notification struct {
}

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

// Receiver represents
type Receiver struct {
	Users     []string `json:"users"`
	Groups    []string `json:"groups"`
	Followers bool     `json:"followers"`
	allUsers  []user
}

type user struct {
	UserName     string
	Email        bool
	Notification bool
	Realtime     bool
}

// LoadUsers get usernames from groups and followers
func (r *Receiver) LoadUsers() {
	// TODO: Get receivers usernames from groups and followers table
	// TODO: Remove duplicated usernames
	// TODO: Pupulate arrays: allUsers
}

// Validate get usernames from groups and followers
func (r *Receiver) Validate() {
	// TODO: Validate if users already have an equal notification
	// TODO: Validate if user has email enabled and notification already sent email
	// TODO: REmove users from notifyUsers and emailUsers
}

// New creates a new notification on the system
func New(message Message, receiver Receiver, passthrough, forceEmail bool) {
	message.Ack = false
	message.CreatedAt = time.Now()
	receiver.LoadUsers()
	if !passthrough {
		receiver.Validate()
	}

	for _, usr := range receiver.allUsers {
		if usr.Notification {
			// TODO: Insert one row for each user in the DB with the message
		}
		if usr.Email {
			// TODO: Send email
		}
		if usr.Realtime {
			// TODO: Emit to websocket
		}
	}
}
