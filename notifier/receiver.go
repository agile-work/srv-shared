package notifier

import (
	"github.com/agile-work/srv-shared/sql-builder/builder"

	"github.com/agile-work/srv-shared/sql-builder/db"
)

// Receiver represents
type Receiver struct {
	Users     []string `json:"users"`
	Groups    []string `json:"groups"`
	Followers bool     `json:"followers"`
	Broadcast bool     `json:"broadcast"`
	allUsers  []user
}

type user struct {
	UserID       string `json:"id" sql:"id"`
	UserEmail    string `json:"user_email" sql:"user_email"`
	SendEmail    bool   `json:"send_email" sql:"send_email"`
	Notify       bool   `json:"notify" sql:"notify"`
	EmitRealtime bool   `json:"emit_realtime" sql:"emit_realtime"`
}

// LoadUsers get usernames from groups and followers
func (r *Receiver) LoadUsers() {
	statement := builder.Raw(`
		select distinct
			usr.id AS id,
			usr.email AS user_email,
			true AS send_email,
			true AS notify,
			true AS emit_realtime,
		from core_users usr
	`)
	// if !r.Broadcast {
	// 	statement
	// }
	rows, err := db.Query(statement)
	if err != nil {
		// TODO: log this erro to file
	}
	db.StructScan(rows, &r.allUsers)
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
