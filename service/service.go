package service

import (
	"crypto/tls"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"net/http"
	"net/url"

	"github.com/agile-work/srv-shared/constants"
	"github.com/agile-work/srv-shared/socket"
	"github.com/agile-work/srv-shared/token"

	"github.com/gorilla/websocket"
)

// Service represents a service in the system
type Service struct {
	id          string
	code        string
	serviceType string
	conn        *websocket.Conn
}

// Down set service down in the realtime web socket
func (s *Service) Down() error {
	err := s.conn.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
	s.conn.Close()
	return err
}

// Emit emits a new message to the realtime web socket
func (s *Service) Emit(message *socket.Message) error {
	jsonByte, err := json.Marshal(message)
	if err != nil {
		return err
	}
	return s.conn.WriteMessage(websocket.TextMessage, jsonByte)
}

var realTimeAddr = flag.String("addr", "localhost:8010", "Realtime address and port")

// Register register the service in the realtime web socket
func Register(code, serviceType string) (*Service, error) {
	u := url.URL{Scheme: "wss", Host: *realTimeAddr, Path: "/realtime/ws"}

	payload := make(map[string]interface{})
	payload["code"] = code
	payload["scope"] = "service"
	payload["service_type"] = serviceType

	tokenString, err := token.New(payload, constants.Year)

	// TODO: remove the InsecureSkipVerify when deploy in production
	dialer := websocket.Dialer{
		TLSClientConfig: &tls.Config{
			InsecureSkipVerify: true,
		},
	}
	conn, resp, err := dialer.Dial(u.String(), http.Header{"Authorization": []string{tokenString}})
	if err != nil {
		if err == websocket.ErrBadHandshake {
			msg := fmt.Sprintf("handshake failed with status %d", resp.StatusCode)
			return nil, errors.New(msg)
		}
		return nil, err
	}

	service := Service{
		code:        code,
		serviceType: serviceType,
		conn:        conn,
	}

	fmt.Printf("Connected to realtime web socket %s", u.String())

	return &service, nil
}
