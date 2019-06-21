package socket

import (
	"github.com/agile-work/srv-shared/util"
)

// Hub maintains the set of active clients and broadcasts messages to the
// clients.
type Hub struct {
	// Registered clients.
	clients map[string]*Client

	// Register requests from the clients.
	register chan *Client

	// Unregister requests from clients.
	unregister chan string

	// Messages from the web socket
	messages chan *Message
}

var defaultHub Hub

// GetHub initialize hub
func GetHub() *Hub {
	defaultHub = Hub{
		register:   make(chan *Client),
		unregister: make(chan string),
		clients:    make(map[string]*Client),
		messages:   make(chan *Message, 256),
	}

	return &defaultHub
}

// Run start a new thread to process hub actions
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.clients[client.id] = client
			go client.Run()
		case clientID := <-h.unregister:
			if client, ok := h.clients[clientID]; ok {
				delete(h.clients, clientID)
				client.Close()
			}
		case message := <-h.messages:
			if len(message.Recipients) <= len(h.clients) {
				for _, id := range message.Recipients {
					if client, ok := h.clients[id]; ok {
						client.inbox <- message
					}
				}
			} else {
				for _, client := range h.clients {
					if util.Contains(message.Recipients, client.id) {
						client.inbox <- message
					}
				}
			}
		}
	}
}

// getClient returns a client based on the id
func (h *Hub) getClient(id string) *Client {
	if client, ok := h.clients[id]; ok {
		return client
	}
	return nil
}

// GetClients returns all registered clients
func (h *Hub) GetClients() map[string]*Client {
	return h.clients
}
