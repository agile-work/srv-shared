package rdb

import (
	"fmt"
	"math"
	"strings"
	"time"

	"github.com/go-redis/redis"
)

var rdb *RedisClient

// RedisClient represents a connection to the redis db
type RedisClient struct {
	available bool
	client    *redis.Client
	addr      string
	pass      string
	store     map[string]interface{}
}

// ConnectionRefused check if the error is because connection was refused
func (r *RedisClient) connectionRefused(err error) {
	if err == nil {
		return
	}
	if ok := strings.Contains(err.Error(), "connect: connection refused"); ok {
		r.available = false
	}
}

//Connect creates a new redis client connection
func (r *RedisClient) connect() {
	r.client = redis.NewClient(&redis.Options{
		Addr:     r.addr,
		Password: r.pass,
		DB:       0, // use default DB
	})

	r.available = true
	if err := r.client.Ping().Err(); err != nil {
		r.available = false
	}
}

// Init initialize redis client parameters and connect
func Init(host string, port int, pass string) {
	rdb = &RedisClient{
		addr: fmt.Sprintf("%s:%d", host, port),
		pass: pass,
	}

	rdb.connect()
}

// HandleReconnection function to be started as a new thread to handle redis reconnection
// interval defines the time between the attempts to reconnect
func HandleReconnection(interval int) {
	if rdb.available {
		fmt.Println("Redis connected")
	}
	attempts := 1
	for {
		if !rdb.available {
			if r := math.Mod(float64(attempts), 10); r == 0 {
				interval += 10
			}
			duration := time.Duration(interval) * time.Second
			fmt.Printf("Redis trying to connect (attempt: %d | interval: %s)\n", attempts, duration)
			rdb.connect()
			if rdb.available {
				fmt.Printf("Redis connected after %d attemps\n", attempts)
				attempts = 1
				continue
			}
			time.Sleep(duration)
			attempts++
		}
	}
}

// Available returns if redis client is available
func Available() bool {
	return rdb.available
}

// Close redis client
func Close() {
	rdb.client.Close()
}
