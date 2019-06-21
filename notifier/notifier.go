package notifier

import (
	"fmt"
	"log"
	"time"

	"github.com/agile-work/srv-shared/constants"
	"github.com/agile-work/srv-shared/sql-builder/db"
)

// Emit creates a new realtime notification on the system
func Emit(message Message, receiver Receiver) {
	// TODO: Iimplementar as funcionalidades p emissão de notificações realtime
}

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

	Emit(message, receiver)

	for _, user := range receiver.allUsers {
		if user.Notify {
			message.UserID = user.UserID
			_, err := db.InsertStruct(constants.TableCoreUserNotifications, &message)
			if err != nil {
				// TODO: log this erro to file
				log.Println(err.Error())
			}
		}
		if (user.SendEmail && user.ReceiveEmails == constants.NotificationsEmailAlways) || (forceEmail && user.ReceiveEmails == constants.NotificationsEmailRequired) {
			_, err := db.InsertStruct(
				constants.TableCoreUserNotificationEmails,
				&message,
				"user_id",
				"structure_id",
				"structure_type",
				"message_action",
				"link",
				"sender_id",
				"body",
				"created_at",
			)
			if err != nil {
				// TODO: log this erro to file
				log.Println(err.Error())
			}
			// TODO: Send email
			fmt.Println("email sent")
		}
	}
}
