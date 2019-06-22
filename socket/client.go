package socket

import (
	"fmt"
	"log"
	"net/http"

	"github.com/agile-work/srv-shared/token"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

// Client is a middleman between the websocket connection and the hub.
type Client struct {
	hub         *Hub
	id          string
	scope       string
	connections map[*Connection]bool
	register    chan *Connection
	unregister  chan *Connection
	inbox       chan *Message
	outbox      chan *Message
}

// GetID returns client id
func (c *Client) GetID() string {
	return c.id
}

// GetScope returns client scope
func (c *Client) GetScope() string {
	return c.scope
}

// GetTotalConnections returns client total available connections
func (c *Client) GetTotalConnections() int {
	return len(c.connections)
}

// Close all channels
func (c *Client) Close() {
	close(c.register)
	close(c.unregister)
	close(c.inbox)
	close(c.outbox)
}

// NewClient creates a new client
func NewClient(hub *Hub, id, scope string, conn *Connection) *Client {
	client := &Client{
		hub:         hub,
		id:          id,
		scope:       scope,
		connections: make(map[*Connection]bool),
		register:    make(chan *Connection),
		unregister:  make(chan *Connection),
		inbox:       make(chan *Message, 256),
		outbox:      make(chan *Message, 256),
	}

	client.connections[conn] = true

	return client
}

// Run start a new thread to process hub actions
func (c *Client) Run() {
	for {
		select {
		case conn := <-c.register:
			c.connections[conn] = true
			go conn.writePump()
			go conn.readPump()
		case conn := <-c.unregister:
			if _, ok := c.connections[conn]; ok {
				delete(c.connections, conn)
				close(conn.send)
				if len(c.connections) <= 0 {
					c.hub.unregister <- c.id
					return
				}
			}
		case incomingMessage := <-c.outbox:
			c.hub.messages <- incomingMessage
		case outcomingMessage := <-c.inbox:
			for conn := range c.connections {
				msgBytes, err := outcomingMessage.GetData()
				if err != nil {
					log.Println("invalid message data")
				} else {
					conn.send <- msgBytes
				}
			}

		}
	}
}

// ServeWs handles websocket requests from the peer.
func ServeWs(hub *Hub, w http.ResponseWriter, r *http.Request) {
	tokenString := r.URL.Query().Get("token")
	if tokenString == "" {
		tokenString = r.Header.Get("Authorization")
		if tokenString == "" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
	}

	payload, err := token.Validate(tokenString)
	if err != nil {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}

	connection := &Connection{
		conn: conn,
		send: make(chan []byte, 256),
	}

	id := payload["code"].(string)
	scope := payload["scope"].(string)
	if scope == "service" {
		id = fmt.Sprintf("%s.%s", payload["service_type"].(string), id)
	}

	client := hub.getClient(id)
	if client == nil {
		client = NewClient(hub, id, scope, connection)
		client.hub.register <- client
	}

	connection.client = client
	connection.client.register <- connection
}
