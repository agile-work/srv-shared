package notifier

import (
	"encoding/json"
	"fmt"
	"strings"

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
	UserID           string `json:"id" sql:"id"`
	ReceiveEmails    string `json:"user_receive_emails" sql:"user_receive_emails"`
	UserEmail        string `json:"user_email" sql:"user_email"`
	UserLanguageCode string `json:"user_language_code" sql:"user_language_code"`
	SendEmail        bool   `json:"send_email" sql:"send_email"`
	Notify           bool   `json:"notify" sql:"notify"`
	EmitRealtime     bool   `json:"emit_realtime" sql:"emit_realtime"`
}

// UsersToJSON return allUsers in byte array
func (r *Receiver) UsersToJSON() ([]byte, error) {
	jsonUsers, err := json.Marshal(r.allUsers)
	if err != nil {
		return nil, err
	}
	return jsonUsers, nil
}

// LoadUsers get usernames from groups and followers
func (r *Receiver) LoadUsers(message Message) error {
	sql := `
		SELECT
			usr.id AS id,
			usr.receive_emails AS user_receive_emails,
			usr.email AS user_email,
			usr.language_code AS user_language_code,
			true AS send_email,
			true AS notify,
			true AS emit_realtime
		FROM core_users usr
	`
	userList := []string{}
	if !r.Broadcast {
		userList = r.Users
		sql += " WHERE usr.id IN ('%s')"
		if len(r.Groups) > 0 {
			err := r.loadUsersByGroup(&userList)
			if err != nil {
				return err
			}
		}
		if r.Followers {
			err := r.loadUsersByFollowers(&userList, message)
			if err != nil {
				return err
			}
		}
		sql = fmt.Sprintf(sql, strings.Join(userList, `', '`))
	}

	statement := builder.Raw(sql)
	rows, err := db.Query(statement)
	if err != nil {
		return err
	}
	db.StructScan(rows, &r.allUsers)
	return nil
}

func (r *Receiver) loadUsersByGroup(users *[]string) error {
	sql := `
		SELECT DISTINCT
			gu.user_id AS id
		FROM core_groups_users gu
		WHERE gu.group_id IN ('%s')
	`
	err := loadUsersBySQL(users, sql, r.Groups)
	if err != nil {
		return err
	}

	return nil
}

func (r *Receiver) loadUsersByFollowers(users *[]string, message Message) error {
	sql := `
		SELECT DISTINCT
			sfl.user_id AS id
		FROM core_sch_followers sfl
		WHERE sfl.schema_instance_id IN ('%s')
	`

	if message.StructureType == "job" {
		sql = `
			SELECT DISTINCT
				COALESCE(gu.user_id, sfl.follower_id) AS id
			FROM core_jobs_followers sfl
			LEFT JOIN core_groups_users AS gu
			ON gu.group_id = sfl.follower_id
			AND sfl.follower_type = 'group'
			WHERE sfl.job_id IN ('%s')
		`
	}
	err := loadUsersBySQL(users, sql, []string{message.StructureID})
	if err != nil {
		return err
	}

	return nil
}

// Validate get usernames from groups and followers
func (r *Receiver) Validate(message Message) error {
	// TODO: Validate if users already have an equal notification
	// TODO: Validate if user has email enabled and notification already sent email
	allUsersJSON, err := r.UsersToJSON()
	if err != nil {
		return err
	}
	sql := `
		SELECT
			usrs.id AS id,
			usrs.user_receive_emails AS user_receive_emails,
			usrs.user_language_code AS user_language_code,
			usrs.user_email AS user_email,
			CASE
				WHEN usrs.user_receive_emails != 'email_never'
				AND (
					ntf.user_id IS NULL
					OR ntf.email_sent = false
				)
				THEN true
				ELSE false
			END AS send_email,
			CASE
				WHEN ntf.user_id IS NULL
				THEN true
				ELSE false
			END AS notify,
			true AS emit_realtime
		FROM (
			SELECT *
			FROM jsonb_to_recordset(
				'%s'::jsonb
			) AS x(
				id character varying,
				user_receive_emails character varying,
				user_email character varying,
				user_language_code character varying
			)
		) AS usrs
		LEFT JOIN (
			SELECT
				ntf.user_id AS user_id,
				max(ntf.email_sent::int)::boolean AS email_sent
			FROM core_usr_notifications ntf
			WHERE ntf.user_id IN (
				SELECT *
				FROM jsonb_to_recordset(
					'%s'::jsonb
				) AS x(
					id character varying
				)
			)
			AND ntf.acknowledged = false
			AND ntf.structure_id = '%s'
			AND ntf.structure_type = '%s'
			AND ntf.scope = '%s'
			AND ntf.message_action = '%s'
			AND ntf.link = '%s'
			AND ntf.message_text = '%s'
			GROUP BY
				ntf.user_id
		) AS ntf
		ON ntf.user_id = usrs.id
	`
	sql = fmt.Sprintf(
		sql,
		string(allUsersJSON),
		string(allUsersJSON),
		message.StructureID,
		message.StructureType,
		message.Scope,
		message.Action,
		message.Link,
		message.String(),
	)
	statement := builder.Raw(sql)
	rows, err := db.Query(statement)
	if err != nil {
		return err
	}
	err = db.StructScan(rows, &r.allUsers)
	if err != nil {
		return err
	}

	return nil
}

func loadUsersBySQL(result *[]string, sql string, filter []string) error {
	if filter != nil {
		sql = fmt.Sprintf(sql, strings.Join(filter, `', '`))
	}
	statement := builder.Raw(sql)
	rows, err := db.Query(statement)
	if err != nil {
		return err
	}
	userList := []user{}
	err = db.StructScan(rows, &userList)
	if err != nil {
		return err
	}
	for _, user := range userList {
		*result = append(*result, user.UserID)
	}

	return nil
}
