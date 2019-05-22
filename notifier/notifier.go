package notifier

import (
	"fmt"
	"log"
	"time"

	shared "github.com/agile-work/srv-shared"
	"github.com/agile-work/srv-shared/sql-builder/builder"
	"github.com/agile-work/srv-shared/sql-builder/db"
)

// New creates a new notification on the system
func New(message Message, receiver Receiver, passthrough, forceEmail bool) {
	message.Ack = false
	message.CreatedAt = time.Now() // TODO: ver se é necessário
	err := receiver.LoadUsers(message)
	if err != nil {
		// TODO: log this erro to file
		log.Println(err.Error())
	}
	if !passthrough {
		err := receiver.Validate(message)
		if err != nil {
			// TODO: log this erro to file
			log.Println(err.Error())
		}
	}

	// TODO: Emit to websocket

	now := time.Now()
	for _, user := range receiver.allUsers {
		sendEmail := (user.SendEmail && user.ReceiveEmails == "email_yes") || (forceEmail && user.ReceiveEmails == "email_only_required")
		if user.Notify {
			statemant := builder.Insert(
				shared.TableCoreUsrNotifications,
				"user_id",
				"structure_id",
				"structure_type",
				"scope",
				"message_action",
				"link",
				"sender",
				"message_text",
				"acknowledged",
				"email_sent",
				"created_by",
				"created_at",
				"updated_by",
				"updated_at",
			).Values(
				user.UserID,
				message.StructureID,
				message.StructureType,
				message.Scope,
				message.Action,
				message.Link,
				message.Sender,
				message.String(),
				message.Ack,
				sendEmail,
				"307e481c-69c5-11e9-96a0-06ea2c43bb20",
				now,
				"307e481c-69c5-11e9-96a0-06ea2c43bb20",
				now,
			)

			err := db.Exec(statemant)
			if err != nil {
				// TODO: log this erro to file
				log.Println(err.Error())
			}
		}
		if sendEmail {
			// TODO: Send email
			fmt.Println("email sent")
		}
	}
}
