package token

import (
	"errors"
	"fmt"
	"time"

	"github.com/dgrijalva/jwt-go"
)

// New return a string with the token including payload and the expiration in years, months or days
func New(payload map[string]interface{}, exp int64) (string, error) {
	claims := jwt.MapClaims{}
	claims["exp"] = time.Now().Add(time.Second * time.Duration(exp)).Unix()
	for k, v := range payload {
		claims[k] = v
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	cryoSigningKey := []byte("AllYourBase")
	return token.SignedString(cryoSigningKey)

}

// Validate return the token payload and error
func Validate(tokenString string) (map[string]interface{}, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte("AllYourBase"), nil
	})

	if token == nil {
		return nil, fmt.Errorf("token is invalid")
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims, nil
	} else if ve, ok := err.(*jwt.ValidationError); ok {
		if ve.Errors&jwt.ValidationErrorMalformed != 0 {
			return nil, errors.New("that is not even a token")
		} else if ve.Errors&(jwt.ValidationErrorExpired|jwt.ValidationErrorNotValidYet) != 0 {
			return nil, errors.New("token is either expired or not active yet")
		} else {
			return nil, err
		}
	} else {
		return nil, err
	}
}
