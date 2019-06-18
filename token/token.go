package token

import (
	"errors"

	"github.com/dgrijalva/jwt-go"
)

// New return a string with the token including payload
func New(payload map[string]interface{}) (string, error) {
	claims := jwt.MapClaims{}
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
