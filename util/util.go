package util

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"net/http"
	"net/url"
	"reflect"
	"strconv"
	"strings"
	"time"

	"github.com/agile-work/srv-mdl-shared/models"
	"github.com/agile-work/srv-shared/constants"
	"github.com/agile-work/srv-shared/sql-builder/builder"
	"github.com/agile-work/srv-shared/sql-builder/db"
)

// Contains check if slice contains string
func Contains(slice []string, match ...string) bool {
	if slice == nil || len(match) == 0 {
		return false
	}
	result := false
	for _, m := range match {
		found := false
		for _, s := range slice {
			if strings.ToLower(s) == strings.ToLower(m) {
				found = true
				break
			}
		}
		result = found
	}
	return result
}

// GetSystemParams return system parameters
func GetSystemParams() (map[string]string, error) {
	statemant := builder.Select(
		"param_key",
		"param_value",
	).From(constants.TableCoreSystemParams)
	rows, err := db.Query(statemant)
	if err != nil {
		return nil, err
	}

	params := map[string]string{}

	for rows.Next() {
		var key, value string
		if err := rows.Scan(&key, &value); err != nil {
			return nil, err
		}
		params[key] = value
	}

	return params, nil
}

// LoadSQLOptionsFromURLQuery load sql options from url query
func LoadSQLOptionsFromURLQuery(query url.Values, opt *db.Options) {
	opt.Limit, _ = strconv.Atoi(query.Get("limit"))
	opt.Offset, _ = strconv.Atoi(query.Get("offset"))
}

// GetColumnsFromBody get a body and return an string array with columns from the body
func GetColumnsFromBody(body []byte, object interface{}) ([]string, map[string]string, error) {
	jsonMap := make(map[string]interface{})
	if err := json.Unmarshal(body, &jsonMap); err != nil {
		return nil, nil, err
	}
	objectTranslationColumns := []string{}
	if models.TranslationFieldsRequestLanguageCode != "all" {
		objectTranslationColumns = getObjectTranslationColumns(object)
	}
	columns := []string{}
	translations := make(map[string]string)
	for k, v := range jsonMap {
		if k != "created_by" && k != "created_at" && k != "updated_by" && k != "updated_at" && !Contains(objectTranslationColumns, k) {
			columns = append(columns, k)
		} else if Contains(objectTranslationColumns, k) {
			translations[k] = v.(string)
		}
	}
	return columns, translations, nil
}

// GetBody get request body while maintaining the value in the request
func GetBody(r *http.Request) ([]byte, error) {
	var bodyBytes []byte
	var err error
	if r.Body != nil {
		bodyBytes, err = ioutil.ReadAll(r.Body)
		if err != nil {
			return nil, err
		}
	}
	r.Body = ioutil.NopCloser(bytes.NewBuffer(bodyBytes))
	return bodyBytes, nil
}

// getObjectTranslationColumns return an array with all translation columns from an object
func getObjectTranslationColumns(object interface{}) []string {
	translationColumns := []string{}
	elementType := reflect.TypeOf(object).Elem()
	for i := 0; i < elementType.NumField(); i++ {
		if elementType.Field(i).Type == reflect.TypeOf(models.Translation{}) {
			translationColumns = append(translationColumns, elementType.Field(i).Tag.Get("sql"))
		}
	}
	return translationColumns
}

// GetBodyColumns return all columns from body
func GetBodyColumns(body []byte) ([]string, error) {
	jsonMap := make(map[string]interface{})
	if err := json.Unmarshal(body, &jsonMap); err != nil {
		return nil, err
	}
	columns := []string{}
	for k := range jsonMap {
		columns = append(columns, k)
	}
	return columns, nil
}

// SetSchemaAudit load user and time to audit fields
func SetSchemaAudit(r *http.Request, object interface{}) {
	userID := r.Header.Get("userID")
	now := time.Now()
	elementValue := reflect.ValueOf(object).Elem()

	if r.Method == http.MethodPost {
		elementCreatedBy := elementValue.FieldByName("CreatedBy")
		elementCreatedAt := elementValue.FieldByName("CreatedAt")
		if elementCreatedBy.IsValid() {
			elementCreatedBy.SetString(userID)
		}
		if elementCreatedAt.IsValid() {
			elementCreatedAt.Set(reflect.ValueOf(now))
		}
	}

	elementUpdatedBy := elementValue.FieldByName("UpdatedBy")
	elementUpdatedAt := elementValue.FieldByName("UpdatedAt")
	if elementUpdatedBy.IsValid() {
		elementUpdatedBy.SetString(userID)
	}
	if elementUpdatedAt.IsValid() {
		elementUpdatedAt.Set(reflect.ValueOf(now))
	}
}

// LoadBodyToStruct load the request body to an object
func LoadBodyToStruct(r *http.Request, object interface{}) error {
	body, _ := GetBody(r)

	err := json.Unmarshal(body, &object)
	if err != nil {
		return err
	}
	return nil
}
