package shared

import (
	"strings"
)

// Contains check if slice contains string
func Contains(slice []string, match ...string) bool {
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
