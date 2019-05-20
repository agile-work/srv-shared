package notifier

import (
	"time"
)

// New creates a new notification on the system
func New(message Message, receiver Receiver, passthrough, forceEmail bool) {
	message.Ack = false
	message.CreatedAt = time.Now()
	receiver.LoadUsers()
	if !passthrough {
		receiver.Validate()
	}

	// TODO: Emit to websocket

	for _, usr := range receiver.allUsers {
		if usr.Notify {
			// TODO: Insert one row for each user in the DB with the message
		}
		if usr.SendEmail {
			// TODO: Send email
		}
	}
}
