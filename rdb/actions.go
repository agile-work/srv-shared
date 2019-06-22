package rdb

import "time"

// BRPopLPush Atomically returns and removes the last element (tail) of the list stored at source,
// and pushes the element at the first element (head) of the list stored at destination
func BRPopLPush(source, destination string, timeout time.Duration) error {
	err := rdb.client.BRPopLPush(source, destination, timeout).Err()
	rdb.connectionRefused(err)
	return err
}

// LPush insert all the specified values at the head of the list stored at key
func LPush(key string, values ...interface{}) error {
	err := rdb.client.LPush(key, values).Err()
	rdb.connectionRefused(err)
	return err
}

// LPop removes and returns the first element of the list stored at key
func LPop(key string) (string, error) {
	res, err := rdb.client.LPop(key).Result()
	rdb.connectionRefused(err)
	return res, err
}

// LLen returns the length of the list stored at key.
// If key does not exist, it is interpreted as an empty list and 0 is returned.
func LLen(key string) (int64, error) {
	res, err := rdb.client.LLen(key).Result()
	rdb.connectionRefused(err)
	return res, err
}

// Set includes a new key value
func Set(key string, value interface{}, exp time.Duration) error {
	err := rdb.client.Set(key, value, exp).Err()
	rdb.connectionRefused(err)
	return err
}

// Get returns the key value
func Get(key string) (string, error) {
	res, err := rdb.client.Get(key).Result()
	rdb.connectionRefused(err)
	return res, err
}

// Delete key
func Delete(key string) error {
	err := rdb.client.Del(key).Err()
	rdb.connectionRefused(err)
	return err
}
