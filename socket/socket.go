package socket

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"time"

	"github.com/agile-work/srv-shared/constants"
	"github.com/agile-work/srv-shared/service"
	"github.com/agile-work/srv-shared/token"
	"github.com/gorilla/websocket"
)

var ws *WebSocketConnection

// WebSocketConnection represents a realtime connection
type WebSocketConnection struct {
	code              string
	serviceType       string
	host              string
	port              int
	token             string
	reconnectInterval int
	reconnectAttempts int
	dialer            *websocket.Dialer
	conn              *websocket.Conn
	messages          chan *Message
	connection        chan bool
	service           *service.Service
}

func (ws *WebSocketConnection) connect() {
	url := fmt.Sprintf("wss://%s:%d/realtime/ws", ws.host, ws.port)
	conn, _, err := ws.dialer.Dial(url, http.Header{"Authorization": []string{ws.token}})
	if ws.reconnectAttempts == 0 {
		fmt.Println("Realtime connecting...")
		ws.reconnectAttempts++
	}
	if err != nil {
		fmt.Println(err)
		duration := time.Duration(ws.reconnectInterval) * time.Second
		time.Sleep(duration)
		fmt.Printf("Realtime trying to connect (attempt: %d | interval: %s)\n", ws.reconnectAttempts, duration)
		ws.reconnectAttempts++
		if r := math.Mod(float64(ws.reconnectAttempts), 10); r == 0 {
			ws.reconnectInterval += 10
		}
		ws.connection <- false
		return
	}

	if ws.reconnectAttempts == 1 {
		fmt.Println("Realtime connected")
	} else {
		fmt.Printf("Realtime connected after %d attemps\n", ws.reconnectAttempts-1)
	}

	ws.reconnectAttempts = 1
	ws.conn = conn
	go ws.readPump()
}

func (ws *WebSocketConnection) readPump() {
	for {
		if ws.conn == nil {
			break
		}

		_, message, err := ws.conn.ReadMessage()
		if err != nil {
			ws.connection <- false
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

// Init initialize realtime connection
func Init(service *service.Service, host string, port int) error {
	if ws != nil && ws.dialer != nil {
		return fmt.Errorf("realtime already initilized")
	}

	payload := make(map[string]interface{})
	payload["service"] = service
	payload["scope"] = "service"
	payload["code"] = service.InstanceCode

	tokenString, err := token.New(payload, constants.Year)
	if err != nil {
		return err
	}

	ws = &WebSocketConnection{
		code:              service.InstanceCode,
		serviceType:       service.Category,
		host:              host,
		port:              port,
		token:             tokenString,
		messages:          make(chan *Message, 100),
		connection:        make(chan bool, 1),
		reconnectInterval: 5,
		reconnectAttempts: 0,
	}

	ws.dialer = &websocket.Dialer{
		TLSClientConfig: &tls.Config{
			InsecureSkipVerify: true,
		},
	}
	go handleConnection(ws.connection)
	ws.connection <- false
	return nil
}

// handleConnection deal with all actions to keep connection up
func handleConnection(conn <-chan bool) {
	for status := range conn {
		if !status {
			ws.connect()
		}
	}
}

// Emit send to the realtime server a message
func Emit(message Message) error {
	if ws.conn != nil {
		return fmt.Errorf("no available connections")
	}

	jsonByte, err := json.Marshal(message)
	if err != nil {
		return err
	}

	err = ws.conn.WriteMessage(websocket.TextMessage, jsonByte)
	if err != nil {
		ws.connection <- false
	}

	return err
}

// MessagesChannel returns a channel with the message to this connection
func MessagesChannel() <-chan *Message {
	return ws.messages
}

// Available returns if realtime connection is available
func Available() bool {
	return ws.conn != nil
}

// Close realtime connection
func Close() {
	if ws.conn != nil {
		ws.conn.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
		ws.conn.Close()
	}
	close(ws.messages)
	close(ws.connection)
}
