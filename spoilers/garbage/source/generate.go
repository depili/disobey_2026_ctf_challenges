package main

import (
	"crypto/sha256"
	"fmt"
)

var prevChar rune = 'A'

func main() {
	pw := "this is the hard way, btw..."

	hash := sha256.Sum256([]byte(pw))
	fmt.Printf("Hash: \"%x\"}, ", hash)
}
