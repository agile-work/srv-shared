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
	client            *redis.Client
	addr              string
	pass              string
	store             map[string]interface{}
	connection        chan bool
	reconnectInterval int
	reconnectAttempts int
}

// ConnectionRefused check if the error is because connection was refused
func (r *RedisClient) connectionRefused(err error) {
	if err == nil {
		return
	}
	if ok := strings.Contains(err.Error(), "connect: connection refused"); ok {
		r.connection <- false
	}
}

//Connect creates a new redis client connection
func (r *RedisClient) connect() {
	r.client = redis.NewClient(&redis.Options{
		Addr:     r.addr,
		Password: r.pass,
		DB:       0, // use default DB
	})

	if r.reconnectAttempts == 0 {
		fmt.Println("Redis connecting...")
		r.reconnectAttempts++
	}

	if err := r.client.Ping().Err(); err != nil {
		duration := time.Duration(r.reconnectInterval) * time.Second
		time.Sleep(duration)
		fmt.Printf("Redis trying to connect (attempt: %d | interval: %s)\n", r.reconnectAttempts, duration)
		r.reconnectAttempts++
		if res := math.Mod(float64(r.reconnectAttempts), 10); res == 0 {
			r.reconnectInterval += 10
		}
		r.connection <- false
		return
	}

	if r.reconnectAttempts == 1 {
		fmt.Println("Redis connected")
	} else {
		fmt.Printf("Redis connected after %d attemps\n", r.reconnectAttempts-1)
	}

	r.reconnectAttempts = 1
}

// Init initialize redis client parameters and connect
func Init(host string, port int, pass string) {
	rdb = &RedisClient{
		addr:              fmt.Sprintf("%s:%d", host, port),
		pass:              pass,
		connection:        make(chan bool, 1),
		reconnectInterval: 5,
		reconnectAttempts: 0,
	}

	go handleConnection(rdb.connection)
	rdb.connection <- false
}

func handleConnection(conn <-chan bool) {
	for status := range conn {
		if !status {
			rdb.connect()
		}
	}
}

// Available returns if redis client is available
func Available() bool {
	if rdb == nil || rdb.client == nil {
		return false
	}
	return rdb.client.Ping().Val() == "PONG"
}

// Close redis client
func Close() {
	rdb.client.Close()
}
