package socket

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"time"

	"github.com/agile-work/srv-shared/constants"
	"github.com/agile-work/srv-shared/token"
	"github.com/gorilla/websocket"
)

var ws *WebSocketConnection

// WebSocketConnection represents a web socket connection
type WebSocketConnection struct {
	code        string
	serviceType string
	host        string
	port        int
	token       string
	available   bool
	shutdown    bool
	dialer      *websocket.Dialer
	conn        *websocket.Conn
	messages    chan *Message
}

func (ws *WebSocketConnection) connect() {
	url := fmt.Sprintf("wss://%s:%d/realtime/ws", ws.host, ws.port)
	conn, _, err := ws.dialer.Dial(url, http.Header{"Authorization": []string{ws.token}})
	if err != nil {
		ws.available = false
		return
	}

	ws.conn = conn
	ws.available = true

	go ws.readPump()
}

func (ws *WebSocketConnection) readPump() {
	defer func() {
		ws.conn.Close()
		ws.available = false
	}()

	ws.conn.SetReadLimit(maxMessageSize)
	ws.conn.SetReadDeadline(time.Now().Add(pongWait))
	ws.conn.SetPongHandler(func(string) error { ws.conn.SetReadDeadline(time.Now().Add(pongWait)); return nil })

	for {
		if !ws.available {
			break
		}

		_, message, err := ws.conn.ReadMessage()
		if err != nil {
			ws.available = false
			break
		}

		msg := Message{}
		err = json.Unmarshal(message, &msg)
		if err != nil {
			fmt.Println("[socket]readPump: error unmarshaling message")
			continue
		}

		select {
		case ws.messages <- &msg:
		default:
			fmt.Println("[socket]readPump: message channel full. discarding message")
		}

	}
}

// Init initialize web socket connection
func Init(code, serviceType, host string, port int) error {
	if ws != nil && ws.dialer != nil {
		return fmt.Errorf("socket already initilized")
	}

	payload := make(map[string]interface{})
	payload["code"] = code
	payload["scope"] = "service"
	payload["service_type"] = serviceType

	tokenString, err := token.New(payload, constants.Year)
	if err != nil {
		return err
	}

	ws = &WebSocketConnection{
		code:        code,
		serviceType: serviceType,
		host:        host,
		port:        port,
		token:       tokenString,
		messages:    make(chan *Message, 100),
		shutdown:    false,
	}

	ws.dialer = &websocket.Dialer{
		TLSClientConfig: &tls.Config{
			InsecureSkipVerify: true,
		},
	}

	ws.connect()
	return nil
}

// HandleReconnection deal with all actions to keep connection up
func HandleReconnection(interval int) {
	if ws.available {
		fmt.Println("Realtime connected")
	}

	attempts := 1
	for {
		if !ws.available && !ws.shutdown {
			if r := math.Mod(float64(attempts), 10); r == 0 {
				interval += 10
			}
			duration := time.Duration(interval) * time.Second
			time.Sleep(duration)
			fmt.Printf("Realtime trying to connect (attempt: %d | interval: %s)\n", attempts, duration)
			ws.connect()
			if ws.available {
				fmt.Printf("Realtime connected after %d attemps\n", attempts)
				attempts = 1
				continue
			}
			attempts++
		}
	}
}

// Emit emit to the web socket server a message
func Emit(message Message) error {
	if !ws.available {
		return fmt.Errorf("no available connections")
	}

	jsonByte, err := json.Marshal(message)
	if err != nil {
		return err
	}

	err = ws.conn.WriteMessage(websocket.TextMessage, jsonByte)
	if err != nil {
		ws.available = false
	}

	return err
}

// MessagesChannel returns a channel with the message to this connection
func MessagesChannel() <-chan *Message {
	return ws.messages
}

// Available returns if redis client is available
func Available() bool {
	return ws.available
}

// Close web socket connection
func Close() {
	ws.shutdown = true
	if ws.conn != nil {
		ws.conn.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
		ws.conn.Close()
	}
	close(ws.messages)
	ws.available = false
}
