package builder

// Raw allows a manually created query to be used when current SQL syntax is not supported
func Raw(query string, value ...interface{}) *Statement {
	return &Statement{
		Type:     "raw",
		RawQuery: query,
		Data:     value,
	}
}
